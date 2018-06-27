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



__author__ = 'Chris Rands'

# Inputs
INPUT_DIR = config['in_dir']
INPUT_SUFFIX = config['suffix'].lstrip('.')
SCRIPTS_DIR =  os.path.join(os.path.dirname(os.path.abspath(workflow.snakefile)), "scripts")
sys.path.append(SCRIPTS_DIR)
# TODO: one could also use the scripts directive, wich automaticaly ajusts the path from the Snakefile.

# Build wildcard(s)
INPUT_TARGETS = ['.'.join(os.path.basename(item).split('.')[:-1])
                 for item in glob.glob('{}/*.{}'.format(INPUT_DIR, INPUT_SUFFIX))]

print(f"Input targets: {INPUT_TARGETS}")

if len(INPUT_TARGETS)==0:
    raise Exception("No input targes specified. Change 'in_dir' and 'suffix' in the config file.")


rule all:
    input:
        "mmSeqs2.done",
        "hmmer.done"

# Rules
rule mmseqs:
    input:
        # MMSeqs2 Profiles
        expand('msa_trim_stockholm/{input_targets}.trim.al.sth', input_targets=INPUT_TARGETS),
        expand('msa_trim_mmseqs_db/{input_targets}.trim.al.db', input_targets=INPUT_TARGETS),
        expand('msa_trim_mmseqs_profile/{input_targets}.profile', input_targets=INPUT_TARGETS),
        expand('msa_trim_mmseqs_pssm/{input_targets}.pssm', input_targets=INPUT_TARGETS),
        expand('msa_trim_mmseqs_profile/{input_targets}.profile.sk5', input_targets=INPUT_TARGETS),
        expand('msa_trim_mmseqs_input_indexes/{input_targets}.db', input_targets=INPUT_TARGETS),
        expand('scores_mmseqs_positivies/{input_targets}.scores', input_targets=INPUT_TARGETS)
    output:
        touch("mmSeqs2.done")
include: "rules/alignment.smk"
include: "rules/mmseqs.smk"


rule hmmer:
    input:
        # HMMER3 HMMs
        expand('hmms/{input_targets}.hmm', input_targets=INPUT_TARGETS),
        expand('scores_truePositives/{input_targets}.scores', input_targets=INPUT_TARGETS),
        expand('scores_otherSeqs/{input_targets}.scores', input_targets=INPUT_TARGETS),
        expand('hmms_with_GA_thresholds/{input_targets}.hmm', input_targets=INPUT_TARGETS),
        expand('msa_trim_alignment_stats.txt')
    output:
        touch("hmmer.done")

include: "rules/hmmer.smk"

# this files are intermediate files, do we request them?

rule all_align:
    input:
        # Alignments
        expand('msa/{input_targets}.al.fa', input_targets=INPUT_TARGETS),
        expand('msa_trim/{input_targets}.trim.al.fa', input_targets=INPUT_TARGETS)
