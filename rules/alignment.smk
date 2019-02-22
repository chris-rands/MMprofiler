import os
import sys





INPUT_SUFFIX = config['suffix'].lstrip('.')
STOCKHOLMFILE= config['stockholm_file']

INPUT_DIR=config['faa_folder']
INPUT_TARGETS = glob_wildcards('{}/{{targets}}.{}'.format(INPUT_DIR, INPUT_SUFFIX)).targets


if len(INPUT_TARGETS)==0:
    raise Exception("No input targes found in {faa_folder}/*{suffix}. Change the comand line options.".format(**config))




rule all_align:
    input:
        STOCKHOLMFILE


## Alignment rules

if config.get('aligner','mafft') == 'clustalo':

    rule align:
        input:
            os.path.join(INPUT_DIR, '{input_targets}.%s' % (INPUT_SUFFIX))
        output:
            'msa/{input_targets}.al.fa'
        conda:
            '../envs/alignment.yaml'
        threads: config['threads']
        shell:
            'clustalo --in {input} --out {output} --auto --threads {threads}'

elif config.get('aligner','mafft') == 'mafft':

    rule align:
        input:
            os.path.join(INPUT_DIR, '{input_targets}.%s' % (INPUT_SUFFIX))
        output:
            'msa/{input_targets}.al.fa'
        conda:
            '../envs/alignment.yaml'
        threads: config['threads']
        shell:
            'mafft --thread {threads} --auto {input} > {output}'

else:
    raise ValueError('Aligner should be "clustalo" or "mafft", alter config file')

rule trim:
    input:
        rules.align.output
    output:
        'msa/{input_targets}.trim.al.fa'
    conda:
        '../envs/alignment.yaml'
    params: # this should ho in the config or so
        params= [f'-{key} {value}' for key,value in config['trimal'].items()]
    threads: 1
    shell:
        'trimal -in {input} -out {output}'
        ' {params.params} '

#
# rule logo:
#     input:
#         rules.trim.output
#     output:
#         'msa/{input_targets}.logo.pdf'
#     conda:
#         '../envs/alignment.yaml'
#     shell:
#         'weblogo --format pdf --sequence-type protein < {input} > {output}'



# SCRIPTS_DIR =  os.path.join(os.path.dirname(os.path.abspath(workflow.snakefile)), "scripts")
# sys.path.append(SCRIPTS_DIR)
# from common import faMSA_stats
# rule align_stats:
#     input:
#         expand(rules.trim.output, input_targets=INPUT_TARGETS)
#     output:
#         'msa/trim_alignment_stats.txt'
#     threads: 1
#     run:
#         faMSA_stats.collate_stats([os.path.dirname(input[0])], output[0])



localrules: MSAfasta_to_stockholm
rule MSAfasta_to_stockholm:
    input:
        alignment_files= expand(rules.trim.output,input_targets=INPUT_TARGETS)
    output:
        stockholm_file=STOCKHOLMFILE
    params:
        family_ids=INPUT_TARGETS
    threads:
        1
    script:
        "../scripts/faMSA_to_StockholmMSA.py"
