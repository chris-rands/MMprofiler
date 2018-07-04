
## MMSeqs2 rules
rule MSAfasta_to_stockholm:
    input:
        rules.trim.output
    output:
        'mmseqs/input/{input_targets}.trimmed.sth'
    shell:
        'python3 %s/faMSA_to_StockholmMSA.py {input} False {output}' %(SCRIPTS_DIR)

rule stockholm_to_MSAdb:
    input:
        rules.MSAfasta_to_stockholm.output
    output:
        'mmseqs/input/{input_targets}.trimmed.db'
    conda: "../envs/mmseqs.yaml"
    shell:
        'mmseqs convertmsa {input} {output}'

rule MSAdb_to_profile:
    input:
        rules.stockholm_to_MSAdb.output
    output:
        'mmseqs/profile/{input_targets}.profile'
    conda: "../envs/mmseqs.yaml"
    shell:
        "mmseqs msa2profile {input} {output} "
        "--match-mode 1 --msa-type 2 --threads 1"

rule profile_to_pssm:
    input:
        rules.MSAdb_to_profile.output
    output:
        'mmseqs/pssm/{input_targets}.pssm'
    conda: "../envs/mmseqs.yaml"
    shell:
        'mmseqs  profile2pssm {input} {output} --threads {threads}'

rule profile_to_indexdb:
    input:
        rules.MSAdb_to_profile.output
    output:
        out1 = 'mmseqs/profile/{input_targets}.profile',
        tmp = temp('{input_targets}_tmp1/')
    conda: "../envs/mmseqs.yaml"
    shell:
        'mmseqs createindex {input} {output.tmp} -k 5 -s 7'

rule make_index:
    input:
        "{folder}/{file}.fasta"
    output:
        '{folder}/{file}.db'
    conda: "../envs/mmseqs.yaml"
    shell:
        'mmseqs createdb {input} {output}'

rule make_index_fa:
    input:
        "{folder}/{file}.fa"
    output:
        '{folder}/{file}.db'
    conda: "../envs/mmseqs.yaml"
    shell:
        'mmseqs createdb {input} {output}'


## Evaluation

ruleorder: score_mmseqs_train > score_mmseqs

rule score_mmseqs_train:
    input:
        profile = rules.MSAdb_to_profile.output,
        fasta = os.path.join(INPUT_DIR, '{input_targets}.db')
    output:
        out = 'mmseqs/scores/train/{input_targets}.scores',
        tmp = temp('{input_targets}_tmp2/')
    conda: "../envs/mmseqs.yaml"
    shell:
        'mmseqs search {input.fasta} {input.profile} {output.out} {output.tmp}'

## this rule works also for hmmer
def get_all_targets_but(INPUT_TARGETS,remove_this):

    return [ x for x in INPUT_TARGETS if not x==remove_this ]


rule get_negative_evaluation_fasta:
    input:
        fasta = lambda wc: expand("{in_dir}/{targets}.{suffix}",
                          targets = get_all_targets_but(INPUT_TARGETS, wc.input_targets),**config)
    output:
        fasta= 'mmseqs/evaluation_seq/{input_targets}.negative.fasta',
    params:
        n_negatives = 2000
    run:         # TODO: subsample
        import numpy as np
        from Bio import SeqIO

        # random int +- 1
        n_samples_per_file = lambda :  int(np.random.randn(1) + params.n_negatives / len(input.fasta) )

        selected_sequences =[]

        i=0
        while len(selected_sequences) < params.n_negatives:

            # cycle trough input files
            seq_file = input.fasta[i % len(input.fasta) ]

            i+=1

            seqs = list(SeqIO.parse(seq_file,'fasta'))

            n_select= min([n_samples_per_file(), len(seqs), params.n_negatives-len(selected_sequences) ])

            selected_sequences += [seqs[j] for j in np.random.randint(0,len(seqs), n_select)]

        assert len(selected_sequences) == params.n_negatives

        SeqIO.write(selected_sequences,output.fasta,'fasta')


rule score_mmseqs:
    input:
        profile = rules.MSAdb_to_profile.output,
        fasta = 'mmseqs/evaluation_seq/{input_targets}.{classify_group}.db'
    output:
        out = 'mmseqs/scores/{classify_group}/{input_targets}.scores',
        tmp = temp('{input_targets}_{classify_group}_tmp2/')
    conda: "../envs/mmseqs.yaml"
    shell:
        'mmseqs search -e 1e10  {input.fasta} {input.profile} {output.out} {output.tmp}'

rule merge_profiles:
    input:
