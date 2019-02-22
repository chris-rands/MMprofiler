import os
#

if config.get('tmpdir') is None:
    config['tmpdir'] = '/tmp'
PROFILE= config['profile']

OUTPUT_FOLDER= config['output_folder']
INPUTDB_FOLDER= f'{OUTPUT_FOLDER}/inputdb'


Querries={}
for file in config['queries']:
    name,extension= os.path.splitext(os.path.split(file)[-1])

#    if extension not in ['.faa','.fa','.fasta']:
#        raise IOError(f'Extension is not a fasta (aa) extension, {file}')

    Querries[name]=file


rule all_search:
    input:
        expand('{OUTPUT_FOLDER}/{query}.tsv',OUTPUT_FOLDER=OUTPUT_FOLDER,query=Querries.keys())
    shell:
        "rm -rf {INPUTDB_FOLDER}"

rule make_db:
    input:
        lambda wc: Querries[wc.query]
    output:
        temp(expand('{folder}/{{query}}.{extension}',
               folder=INPUTDB_FOLDER,
               extension=['db','db.index','db.dbtype','db_h','db_h.index','db.lookup']))
    conda:
        "../envs/mmseqs.yaml"
    threads: 1
    shell:
        'mmseqs createdb {input} {output[0]}'


# Search using querries

rule search_mmseqs:
    input:
        profile = PROFILE,
        inputdb = rules.make_db.output
    output:
        db = temp(f'{OUTPUT_FOLDER}/{{query}}.db'),
        index = temp(f'{OUTPUT_FOLDER}/{{query}}.db.index'),
        tsv = f'{OUTPUT_FOLDER}/{{query}}.tsv',
    params:
        extra=config.get("mmseqs_search_commands","")
    threads: config['threads']
    conda:
        "../envs/mmseqs.yaml"
    shell:
        """
            mmseqs search {params.extra} --threads {threads} {input.inputdb[0]} {input.profile}/profile {output.db} {config[tmpdir]}

            mmseqs convertalis --threads {threads} {input.inputdb[0]} {input.profile}/profile {output.db} {output.tsv}
        """





# ## Evaluation
#
#
# rule get_train_seq:
#     input:
#         fasta = os.path.join(INPUT_DIR, '{input_targets}.'+INPUT_SUFFIX)
#     output:
#         temp('evaluation_seq/train/{input_targets}.fasta')
#     shell:
#         "cp {input} {output}" # TODO: make symlink
#
# ## this rule works also for hmmer
# def get_all_targets_but(INPUT_TARGETS,remove_this):
#
#     return [ x for x in INPUT_TARGETS if not x==remove_this ]
#
# from Bio import SeqIO
# import numpy as np
#
# def subsample_fasta(input_fasta, N, output_fasta= None):
#     """
#         Subsample sequences in file. If N > than n seqs in file all sequences are retreved.
#         If outputfile is not specified, a list of BioPython Seqs are given.
#     """
#     seqs = list(SeqIO.parse(input_fasta,'fasta'))
#
#     if N >= len(seqs):
#         outseqs = seqs
#     else:
#         # subsample
#         outseqs= [seqs[j] for j in np.random.randint(0,len(seqs), N)]
#
#     if output_fasta is None:
#         return outseqs
#     else:
#         SeqIO.write(outseqs,output_fasta,'fasta')
#
#
#
# rule get_negative_evaluation_fasta:
#     input:
#         fasta = lambda wc: expand("{in_dir}/{targets}.{suffix}",
#                           targets = get_all_targets_but(INPUT_TARGETS, wc.input_targets),
#                           in_dir=config['in_dir'],suffix=INPUT_SUFFIX)
#     output:
#         fasta= 'evaluation_seq/negative/{input_targets}.fasta',
#     params:
#         n_negatives = 2000
#     run:
#
#
#         if len(input.fasta) < 10:
#             shell("cat {input.fasta} > {output.fasta}")
#         else:
#             #subsample
#
#             # random int +- 1
#             n_samples_per_file = lambda : int(np.random.randn(1) + params.n_negatives / len(input.fasta) )
#
#             selected_sequences =[]
#
#             i=0
#             while len(selected_sequences) <= params.n_negatives:
#
#             # this acctually may subsample several times the same sequence
#
#                 # cycle trough input files
#                 seq_file = input.fasta[i % len(input.fasta) ]
#
#                 i+=1
#                 n_select= min([n_samples_per_file(), params.n_negatives-len(selected_sequences) ])
#
#                 selected_sequences += subsample_fasta(seq_file, n_select)
#
#             assert len(selected_sequences) == params.n_negatives
#
#             SeqIO.write(selected_sequences,output.fasta,'fasta')
#
#
# rule score_mmseqs:
#     input:
#         profile = rules.MSAdb_to_profile.output,
#         fasta = 'evaluation_seq/{classify_group}/{input_targets}.db'
#     output:
#         db = temp('mmseqs/scores/{classify_group}/{input_targets}.scores'),
#         index = temp('mmseqs/scores/{classify_group}/{input_targets}.scores.index'),
#         tsv = 'mmseqs/scores/{classify_group}/{input_targets}.m8',
#     conda: "../envs/mmseqs.yaml"
#     shell:
#         """
#
#         mmseqs search -e 10  {input.fasta} {input.profile} {output.db} {config[tmpdir]}
#         mmseqs convertalis {input.fasta} {input.profile} {output.db} {output.tsv}
#
#         """
