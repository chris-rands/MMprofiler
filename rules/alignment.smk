
from common import faMSA_stats

## Alignment rules

if config.get('aligner','clustalo') == 'clustalo':

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

elif config.get('aligner','clustalo') == 'mafft':

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


rule logo:
    input:
        rules.trim.output
    output:
        'msa/{input_targets}.logo.pdf'
    conda:
        '../envs/alignment.yaml'
    shell:
        'weblogo --format pdf --sequence-type protein < {input} > {output}'


rule align_stats:
    input:
        expand(rules.trim.output, input_targets=INPUT_TARGETS)
    output:
        'msa/trim_alignment_stats.txt'
    threads: 1
    run:
        faMSA_stats.collate_stats([os.path.dirname(input[0])], output[0])
