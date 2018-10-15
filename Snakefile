'''
Python snakemake pipeline that build profiles and profile HMMs from unaligned fasta protein familes.

Example script execution from .test:
snakemake -s ../Snakefile -d workingdir -j 1 --configfile ../config.yaml -p --use-conda  --conda-prefix ../conda_envs $@

The main entry point of your workflow.
After configuring, running snakemake -n in a clone of this repository should successfully execute a dry-run of the workflow.

configfile: "config.yaml"

The first rule should define the default target files
Subsequent target rules can be specified below. They should start with all_*.
'''

# Imports
import os
import sys
import glob


__author__ = 'Chris Rands, Silas Kieser'


# Inputs
INPUT_DIR = config['in_dir']
INPUT_SUFFIX = config['suffix'].lstrip('.')
SCRIPTS_DIR =  os.path.join(os.path.dirname(os.path.abspath(workflow.snakefile)), "scripts")
sys.path.append(SCRIPTS_DIR)
# TODO: one could also use the scripts directive, wich automaticaly ajusts the path from the Snakefile.

#TODO: check if files exist

if config.get('target_names') is None:

    INPUT_TARGETS, = glob_wildcards('{}/{{targets}}.{}'.format(INPUT_DIR, INPUT_SUFFIX))
else:
    INPUT_TARGETS = config['target_names']

print(f'Input targets: {INPUT_TARGETS}')


if len(INPUT_TARGETS)==0:
    raise Exception("No input targes found in {in_dir}/*{suffix}. Change 'in_dir' and 'suffix' in the config file.".format(**config))
elif len(INPUT_TARGETS) > 500:
    raise Exception(" I don't now if I can handle {} files".format(len(INPUT_TARGETS)))

if config.get('query_dir') is not None:
    QUERY_DIR = config.get('query_dir')

    if config.get('query_names') is not None:
        INPUT_QUERRIES = config.get('query_names')
    else:
        INPUT_QUERRIES, = glob_wildcards('{}/{{querries}}.{}'.format(QUERY_DIR, INPUT_SUFFIX))

        print(f"Querries: {INPUT_QUERRIES} ")

else:
    QUERY_DIR = config['in_dir']
    INPUT_QUERRIES= None

if config.get('tmpdir') is None:
    config['tmpdir'] = 'tmp'

if not os.path.exists(config['tmpdir']): os.makedirs(config['tmpdir'])



# Rules


if INPUT_QUERRIES is not None:
    rule mmseqs:
        input:
            expand('search/{query}/{input_targets}.m8',query = INPUT_QUERRIES, input_targets= INPUT_TARGETS)

rule all:
    input:
        'mmSeqs2.done',
        # 'hmmer.done',
        #expand('msa_trim_logo/{input_targets}.logo.pdf', input_targets=INPUT_TARGETS)


rule mmseqs_evaluate:
    input:
        # MMSeqs2 Profiles
        expand('mmseqs/profile/{input_targets}.profile', input_targets=INPUT_TARGETS),
        expand('mmseqs/pssm/{input_targets}.pssm', input_targets=INPUT_TARGETS),
        expand('mmseqs/scores/{category}/{input_targets}.m8', category=['negative','train'] ,input_targets=INPUT_TARGETS)
    output:
        touch('mmSeqs2.done')

include: 'rules/alignment.smk'
include: 'rules/mmseqs.smk'


rule hmmer:
    input:
        # HMMER3 HMMs
        expand('hmms/{input_targets}.hmm', input_targets=INPUT_TARGETS),
        expand('scores_truePositives/{input_targets}.scores', input_targets=INPUT_TARGETS),
        expand('scores_otherSeqs/{input_targets}.scores', input_targets=INPUT_TARGETS),
        expand('hmms_with_GA_thresholds/{input_targets}.hmm', input_targets=INPUT_TARGETS),
        expand('msa_trim_alignment_stats.txt')
    output:
        touch('hmmer.done')

include: 'rules/hmmer.smk'

# this files are intermediate files, do we request them?

rule all_align:
    input:
        # Alignments
        expand('msa/{input_targets}.al.fa', input_targets=INPUT_TARGETS),
        expand('msa/{input_targets}.trim.al.fa', input_targets=INPUT_TARGETS),
        expand('msa/{input_targets}.logo.pdf', input_targets=INPUT_TARGETS)
