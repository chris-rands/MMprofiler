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
SCRIPTS_DIR =  os.path.join(os.path.dirname(os.path.abspath(workflow.snakefile)), "scripts")
sys.path.append(SCRIPTS_DIR)

INPUT_SUFFIX = config['suffix'].lstrip('.')
STOCKHOLMFILE= config['stockholm_file']


if 'faa_folder' in config:
    INPUT_DIR=config['faa_folder']
    INPUT_TARGETS = glob_wildcards('{}/{{targets}}.{}'.format(INPUT_DIR, INPUT_SUFFIX)).targets


    if len(INPUT_TARGETS)==0:
        raise Exception("No input targes found in {faa_folder}/*{suffix}. Change the comand line options.".format(**config))

else:

    INPUT_TARGETS=[]
    INPUT_DIR=""





if config.get('query_dir') is not None:
    QUERY_DIR = config.get('query_dir')

    if config.get('query_names') is not None:
        INPUT_QUERRIES = config.get('query_names')
    else:
        INPUT_QUERRIES, = glob_wildcards('{}/{{querries}}.{}'.format(QUERY_DIR, INPUT_SUFFIX))

        print(f"Querries: {INPUT_QUERRIES} ")

else:
    QUERY_DIR = "queries"
    INPUT_QUERRIES= None

if config.get('tmpdir') is None:
    config['tmpdir'] = '/tmp'


if not os.path.exists(config['tmpdir']): os.makedirs(config['tmpdir'])



if INPUT_QUERRIES is not None:
    rule mmseqs:
        input:
            expand('search/{query}.m8',query = INPUT_QUERRIES)



# rule mmseqs_evaluate:
#     input:
#         # MMSeqs2 Profiles
#         'mmseqs/profile/profile',
#         # 'mmseqs/pssm/profile.pssm' # works but may be ressource intensive
#         #expand('mmseqs/scores/{category}/{input_targets}.m8', category=['negative','train'] ,input_targets=INPUT_TARGETS)
#     output:
#         touch('mmSeqs2.done')

include: 'rules/alignment.smk'
include: 'rules/mmseqs.smk'

rule all:
    input:
        'mmSeqs2.done',
        # 'hmmer.done',
        #expand('msa_trim_logo/{input_targets}.logo.pdf', input_targets=INPUT_TARGETS)


rule all_align:
    input:
        STOCKHOLMFILE

        # Alignments
        #expand('msa/{input_targets}.al.fa', input_targets=INPUT_TARGETS),
        #expand('msa/{input_targets}.trim.al.fa', input_targets=INPUT_TARGETS),
        #expand('msa/{input_targets}.logo.pdf', input_targets=INPUT_TARGETS)
