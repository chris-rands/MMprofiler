
from common import faMSA_stats

## Alignment rules

if config.get('aligner','clustalo') == 'clustalo':

    rule align:
        input:
            os.path.join(INPUT_DIR, '{input_targets}.%s' % (INPUT_SUFFIX))
        output:
            'msa/{input_targets}.al.fa'
        conda: "../envs/alignment.yaml"
        shell:
            'clustalo --in {input} --out {output} --auto --threads {threads}'

if config.get('aligner','clustalo') == 'mafft':

    rule align:
        input:
            os.path.join(INPUT_DIR, '{input_targets}.%s' % (INPUT_SUFFIX))
        output:
            'msa/{input_targets}.al.fa'
        conda: "../envs/alignment.yaml"
        shell:
            "mafft --thread {threads} --auto {input} > {output}"


rule trim:
    input:
        rules.align.output
    output:
        'msa/{input_targets}.trim.al.fa'
    conda: "../envs/alignment.yaml"
    params: # this should ho in the config or so
        params= [f'-{key} {value}' for key,value in config['trimal'].items()]
    shell:
        'trimal -in {input} -out {output}'
        ' {params.params} '



rule align_stats:
    input:
        expand(rules.trim.output, input_targets=INPUT_TARGETS)
    output:
        'msa_trim_alignment_stats.txt'
    run:
        faMSA_stats.collate_stats([os.path.dirname(input[0])], output[0])
