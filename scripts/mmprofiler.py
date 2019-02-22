import click
import logging

import multiprocessing
import os
import sys
import subprocess
import click

__version__=0.1
__author__ = 'Silas Kieser,Chris Rands, Matthew Berkeley'

logging.basicConfig(
    level=logging.INFO,
    datefmt="%Y-%m-%d %H:%M",
    format="[%(asctime)s %(levelname)s] %(message)s",
)

def get_snakefile(file="Snakefile"):
    sf = os.path.join(os.path.dirname(os.path.abspath(__file__)),'..', file)
    if not os.path.exists(sf):
        sys.exit("Unable to locate the Snakemake workflow file; tried %s" % sf)
    return sf


@click.group(context_settings=dict(help_option_names=["-h", "--help"]))
@click.version_option(__version__)
@click.pass_context
def cli(obj):
    """
        MMprofiler wrapper for mmseqs profile search.

    """


@cli.command(
    "align",
    context_settings=dict(ignore_unknown_options=True),
    short_help="align multiple protein families into stockholm format "
)
@click.argument(
    "faa-folder",
    type=click.Path(dir_okay=True,file_okay=False,readable=True,resolve_path=True)
)
@click.option("-s",
    "--stockholm",
    type=click.Path(dir_okay=False,writable=True,resolve_path=True),
    help="Algned protein families in stockholm format",
    default="aligned.stk"
)
@click.option("-a",
    "--alignments",
    type=click.Path(dir_okay=False,writable=True,resolve_path=True),
    help="Algned protein families trimmed + untrimmed as tarbal of fasta format.",
)
@click.option("-t",
    "--threads",
    type=int,
    default=multiprocessing.cpu_count(),
    help="use at most this many jobs in parallel",
)
@click.option("-e",
    "--faa-extension",
    type=str,
    help="extension for faa files in folder",
    default='.faa'
)
@click.option("-c",
    "--config-file",
    type=click.Path(exists=True,resolve_path=True),
    help="config-file for alignment",
)
@click.argument("snakemake_args", nargs=-1, type=click.UNPROCESSED)
def align(faa_folder, stockholm,alignments,threads, faa_extension,config_file, snakemake_args):
    """
        Takes several protein families in fasta format and aligns them with mafft,
        optionally trimms thesm with trimal and puts out  the alignment in stockholm format,
        which then can be uses for building a profile.

    """

    if config_file is None:
        config_file = get_snakefile('config.yaml')

    if not os.path.exists(config_file):
        logging.critical(f"config-file not found: {config_file}")
        sys.exit(1)

    cmd =  (f"snakemake --snakefile {get_snakefile('rules/alignment.smk')} "
            f" --jobs {threads} --rerun-incomplete "
            f" --configfile '{config_file}' --nolock "
            f" {' '.join(snakemake_args)} "
            f" --config faa_folder={faa_folder} suffix={faa_extension} stockholm_file={stockholm}")

    logging.debug("Executing: %s" % cmd)
    try:
        subprocess.check_call(cmd, shell=True)
    except subprocess.CalledProcessError as e:
        # removes the traceback
        logging.critical(e)
        exit(1)


#  build


@cli.command(
    "build",
    context_settings=dict(ignore_unknown_options=True),
    short_help="build mmseq2 profile from alignment in stockholm file "
)
@click.argument(
    "stockholm_alignment",
    type=click.Path(dir_okay=False,writable=True,resolve_path=True),
#    help="Algned protein families in stockholm format",
)
@click.argument(
    "profile_folder",
    type=click.Path(dir_okay=True,file_okay=False,exists=False,resolve_path=True),
    default='mmprofile'
)
@click.argument("snakemake_args", nargs=-1, type=click.UNPROCESSED)
def build(stockholm_alignment,profile_folder, snakemake_args):
    """
        Takes aligned protein families in stockholm format and builds a mmseqs profile.
        The output is the FOLDER containing a 'profile' binary file and several indexes
    """


    cmd =  (f"snakemake --snakefile {get_snakefile('rules/build.smk')} "
            f" --jobs 1 --rerun-incomplete "
            f" --nolock "
            f" {' '.join(snakemake_args)} "
            f" --config stockholm_file={stockholm_alignment} profile={profile_folder}")

    logging.debug("Executing: %s" % cmd)
    try:
        subprocess.check_call(cmd, shell=True)
    except subprocess.CalledProcessError as e:
        # removes the traceback
        logging.critical(e)
        exit(1)


#  build


@cli.command(
    "search",
    context_settings=dict(ignore_unknown_options=True),
    short_help="search proteins against profile datbases "
)
@click.option("-t",
    "--threads",
    type=int,
    default=multiprocessing.cpu_count(),
    help="use at most this many jobs in parallel",
)
@click.option("-o",
    "--output-folder",
    type=click.Path(dir_okay=True,file_okay=False,resolve_path=True),
    default= 'mapresults',
    help="Output folder",
)
@click.argument(
    "profile_folder",nargs=1,
    type=click.Path(dir_okay=True,file_okay=False,exists=True,resolve_path=True),
)
@click.argument(
    "faa",nargs=-1,
    type=click.Path(dir_okay=False,file_okay=True,exists=True,resolve_path=True),
)
#@click.argument("snakemake_args", nargs=-1, type=click.UNPROCESSED)
def search(threads,output_folder,profile_folder, faa):
    """
        Searches a bunch of faa files against the a profile generated with 'mmprofiler build'.
    """


    cmd =  (f"snakemake --snakefile {get_snakefile('rules/mmseqs.smk')} "
            f" --jobs {threads} --rerun-incomplete "
            f" --nolock "
            f' --config profile={profile_folder} queries="{faa}" threads={threads} output_folder={output_folder}')

    logging.debug("Executing: %s" % cmd)
    try:
        subprocess.check_call(cmd, shell=True)
    except subprocess.CalledProcessError as e:
        # removes the traceback
        logging.critical(e)
        exit(1)



if __name__ == "__main__":
     cli()
