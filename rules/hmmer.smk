## HMMER3 HMM rules

PATH_HMMER3='.'
# TODO this needs to be set ore to be removed from the scripts
from common import hmms_add_GA_thresh_and_plot


# TODO: 'build' is not very specific
rule build:
    input:
        rules.trim.output
    output:
        'hmms/{input_targets}.hmm'
    log:
        'logs/hmms/{input_targets}.hmm_build.log'
    conda: "../envs/hmmer.yaml"
    shell:
        'hmmbuild -o {log} --cpu 1 --amino {output} {input}'

rule score_truePositives:
    input:
        in1 = rules.build.output,  # I think it's safe to assume that order of the in1 and in2 is the same
        # because the list comprhension that builds the input_targets retains the order
        in2 = os.path.join(INPUT_DIR, '{input_targets}.%s' % (INPUT_SUFFIX))
    output:
        'scores_truePositives/{input_targets}.scores'
    conda: "../envs/hmmer.yaml"
    params:
        eval= config['hmmsearch_evalue']  # recommend 10
    shell:
        'hmmsearch -E {params.eval} --cpu {threads} --tblout {output} {input.in1} {input.in2}'
# TODO: here params would also be more appropriate
rule score_otherSeqs:
    input:
        rules.build.output
    output:
        'scores_otherSeqs/{input_targets}.scores'
    conda: "../envs/hmmer.yaml"
    shell:
        'python3 %s %s {input} {output} %s %s %s' % (os.path.join(SCRIPTS_DIR, 'score_otherseqs_hmms.py'), INPUT_DIR, config['hmmsearch_evalue'], INPUT_SUFFIX, PATH_HMMER3)

rule add_gathering_thresholds:  # model-specific bitscore thresholds for hmms and pdf of plots
    input:
        in1 = rules.score_truePositives.output,
        in2 = rules.score_otherSeqs.output,
        in3 = rules.build.output
    output:
        'hmms_with_GA_thresholds/{input_targets}.hmm'
    run:
        with open('add_gathering_threshold_and_plot.err', 'w') as error_f:
            sys.stderr = error_f
            hmms_add_GA_thresh_and_plot.main(os.path.dirname(input.in1[0]),
                                             os.path.dirname(input.in2[0]),
                                             os.path.dirname(input.in3[0]),
                                             os.path.dirname(output[0]),
                                             'hmm_bitscore_plots')
