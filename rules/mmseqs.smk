
## MMSeqs2 rules
localrules: MSAfasta_to_stockholm
rule MSAfasta_to_stockholm:
    input:
        alignment_files= expand(rules.trim.output,input_targets=INPUT_TARGETS)
    output:
        stockholm_file='mmseqs/input/msa_trimmed.sth'
    params:
        family_ids=INPUT_TARGETS
    threads:
        1
    script:
        "../scripts/faMSA_to_StockholmMSA.py"


rule stockholm_to_MSAdb:
    input:
        config.get('stockholm_file',rules.MSAfasta_to_stockholm.output)
    output:
        'mmseqs/input/msa_trimmed.db'
    conda:
        '../envs/mmseqs.yaml'
    threads: 1
    shell:
        'mmseqs convertmsa {input} {output}'


rule MSAdb_to_profile:
    input:
        rules.stockholm_to_MSAdb.output
    output:
        'mmseqs/profile/profile'
    conda:
        '../envs/mmseqs.yaml'
    shell:
        'mmseqs msa2profile {input} {output} '
        '--match-mode 1 --msa-type 2 --threads {threads}'

# ERROR: gives only first profile
rule profile_to_pssm:
    input:
        rules.MSAdb_to_profile.output
    output:
        'mmseqs/pssm/profile.pssm'
    conda: "../envs/mmseqs.yaml"
    threads: config['threads']
    shell:
        'mmseqs  profile2pssm {input} {output} --threads {threads}'

# rule profile_to_indexdb:
#     input:
#         rules.MSAdb_to_profile.output
#     output:
#         out = 'mmseqs/profile/{input_targets}.profile.index',
#         tmp = temp('{input_targets}_tmp1/')
#     conda: "../envs/mmseqs.yaml"
#     shell:
#         'mmseqs createindex {input} {output.tmp} -k 5 -s 7'

rule make_db:
    input:
        "{folder}/{file}.fasta"
    output:
        '{folder}/{file}.db'
    conda:
        "../envs/mmseqs.yaml"
    threads: config['threads']
    shell:
        'mmseqs createdb --threads {threads} {input} {output}'


rule make_db_fa:
    input:
        "{folder}/{file}.fa"
    output:
        '{folder}/{file}.db'
    conda: "../envs/mmseqs.yaml"
    threads: config['threads']
    shell:
        'mmseqs createdb --threads {threads} {input} {output}'


# Search using querries

rule search_mmseqs:
    input:
        profile = rules.MSAdb_to_profile.output,
        fasta = os.path.join(QUERY_DIR, '{query}.db')
    output:
        db = temp('search/{query}.db'),
        index = temp('search/{query}.db.index'),
        tsv = 'search/{query}.m8',
    threads: config['threads']
    conda:
        "../envs/mmseqs.yaml"
    shell:
        """
            mmseqs search --threads {threads} {input.fasta} {input.profile} {output.db} {config[tmpdir]}

            mmseqs convertalis --threads {threads} {input.fasta} {input.profile} {output.db} {output.tsv}
        """


# rule search_many_profiles:
#     input:
#         expand('search/{{query}}/{input_targets}.m8', input_targets= INPUT_TARGETS)
#     params:
#         names= INPUT_TARGETS
#     output:





## Evaluation


rule get_train_seq:
    input:
        fasta = os.path.join(INPUT_DIR, '{input_targets}.'+INPUT_SUFFIX)
    output:
        temp('evaluation_seq/train/{input_targets}.fasta')
    shell:
        "cp {input} {output}" # TODO: make symlink

## this rule works also for hmmer
def get_all_targets_but(INPUT_TARGETS,remove_this):

    return [ x for x in INPUT_TARGETS if not x==remove_this ]

from Bio import SeqIO
import numpy as np

def subsample_fasta(input_fasta, N, output_fasta= None):
    """
        Subsample sequences in file. If N > than n seqs in file all sequences are retreved.
        If outputfile is not specified, a list of BioPython Seqs are given.
    """
    seqs = list(SeqIO.parse(input_fasta,'fasta'))

    if N >= len(seqs):
        outseqs = seqs
    else:
        # subsample
        outseqs= [seqs[j] for j in np.random.randint(0,len(seqs), N)]

    if output_fasta is None:
        return outseqs
    else:
        SeqIO.write(outseqs,output_fasta,'fasta')



rule get_negative_evaluation_fasta:
    input:
        fasta = lambda wc: expand("{in_dir}/{targets}.{suffix}",
                          targets = get_all_targets_but(INPUT_TARGETS, wc.input_targets),
                          in_dir=config['in_dir'],suffix=INPUT_SUFFIX)
    output:
        fasta= 'evaluation_seq/negative/{input_targets}.fasta',
    params:
        n_negatives = 2000
    run:


        if len(input.fasta) < 10:
            shell("cat {input.fasta} > {output.fasta}")
        else:
            #subsample

            # random int +- 1
            n_samples_per_file = lambda : int(np.random.randn(1) + params.n_negatives / len(input.fasta) )

            selected_sequences =[]

            i=0
            while len(selected_sequences) <= params.n_negatives:

            # this acctually may subsample several times the same sequence

                # cycle trough input files
                seq_file = input.fasta[i % len(input.fasta) ]

                i+=1
                n_select= min([n_samples_per_file(), params.n_negatives-len(selected_sequences) ])

                selected_sequences += subsample_fasta(seq_file, n_select)

            assert len(selected_sequences) == params.n_negatives

            SeqIO.write(selected_sequences,output.fasta,'fasta')


rule score_mmseqs:
    input:
        profile = rules.MSAdb_to_profile.output,
        fasta = 'evaluation_seq/{classify_group}/{input_targets}.db'
    output:
        db = temp('mmseqs/scores/{classify_group}/{input_targets}.scores'),
        index = temp('mmseqs/scores/{classify_group}/{input_targets}.scores.index'),
        tsv = 'mmseqs/scores/{classify_group}/{input_targets}.m8',
    conda: "../envs/mmseqs.yaml"
    shell:
        """

        mmseqs search -e 1e10  {input.fasta} {input.profile} {output.db} {config[tmpdir]}
        mmseqs convertalis {input.fasta} {input.profile} {output.db} {output.tsv}

        """
