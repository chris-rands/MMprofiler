import click
import logging

import multiprocessing
import os
import sys
import subprocess
import click

__version__=0.1


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
    short_help="align "
)
@click.argument(
    "faa-folder",
    type=click.Path(dir_okay=True,readable=True,resolve_path=True)
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

    cmd =  (f"snakemake --snakefile {get_snakefile()} "
            f" --jobs {threads} --rerun-incomplete "
            f" --configfile '{config_file}' --nolock "
            f" all_align "
            f" {' '.join(snakemake_args)} "
            f" --config faa_folder={faa_folder} suffix={faa_extension} stockholm_file={stockholm}")

    logging.debug("Executing: %s" % cmd)
    try:
        subprocess.check_call(cmd, shell=True)
    except subprocess.CalledProcessError as e:
        # removes the traceback
        logging.critical(e)
        exit(1)


#
#
#
#
#
#


#
# from atlas import __version__
# from atlas.conf import make_config,prepare_sample_table,load_configfile
# from atlas.conf import validate_config,run_init
#
#
# logging.basicConfig(
#     level=logging.INFO,
#     datefmt="%Y-%m-%d %H:%M",
#     format="[%(asctime)s %(levelname)s] %(message)s",
# )
#
# def log_exception(msg):
#     logging.critical(msg)
#     logging.info("Documentation is available at: https://metagenome-atlas.readthedocs.io")
#     logging.info("Issues can be raised at: https://github.com/metagenome-atlas/atlas/issues")
#     sys.exit(1)
#

# cli.add_command(run_init)
#
#
#
#

#
#
#
#
#
#
# ## QC command
#
#
#
#
#
# # Download
# @cli.command(
#     "download",
#     context_settings=dict(ignore_unknown_options=True),
#     short_help="download reference files (need ~50GB)",
# )
# @click.option("-d",
#     "--db-dir",
#     help="location to store databases",
#     type=click.Path(dir_okay=True,writable=True,resolve_path=True),
#     required=True
# )
# @click.option(
#     "-j",
#     "--jobs",
#     default=1,
#     type=int,
#     show_default=True,
#     help="number of simultaneous downloads",
# )
# @click.argument("snakemake_args", nargs=-1, type=click.UNPROCESSED)
# def run_download(db_dir,jobs, snakemake_args):
#     """Executes a snakemake workflow to download reference database files and validate based on
#     their MD5 checksum.
#     """
#
#     cmd = (
#         "snakemake --snakefile {snakefile} "
#         "--printshellcmds --jobs {jobs} --rerun-incomplete "
#         "--nolock "
#         "--config database_dir='{db_dir}' {add_args} "
#         "{args}"
#     ).format(
#         snakefile=get_snakefile("rules/download.snakefile"),
#         jobs=jobs,
#         db_dir=db_dir,
#         add_args="" if snakemake_args and snakemake_args[0].startswith("-") else "--",
#         args=" ".join(snakemake_args),
#     )
#     logging.info("Executing: %s" % cmd)
#     try:
#         subprocess.check_call(cmd, shell=True)
#     except subprocess.CalledProcessError as e:
#         # removes the traceback
#         logging.critical(e)
#         exit(1)
#


# if __name__ == "__main__":
#     cli()
