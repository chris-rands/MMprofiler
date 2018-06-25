# Snakemake workflow: Profiles from Protein Families

[![Snakemake](https://img.shields.io/badge/snakemake-≥5.0.0-brightgreen.svg)](https://snakemake.bitbucket.io)
[![Build Status](https://travis-ci.org/snakemake-workflows/pfpf.svg?branch=master)](https://travis-ci.org/snakemake-workflows/pfpf)

This is the template for a new Snakemake workflow. Replace this text with a comprehensive description covering the purpose and domain.
Insert your code into the respective folders, i.e. `scripts`, `rules`, and `envs`. Define the entry point of the workflow in the `Snakefile` and the main configuration in the `config.yaml` file.

## Authors

* Christopher Rands (@chris-rands), Silas Kieser (@silask)


## Description
Create profiles and profile HMMs from (unaligned) protein families/clusters, under development

Python snakemake pipeline that build profiles and profile HMMs from unaligned fasta protein familes.

input:
- `example/` >> directory of unaligned fasta sequences, 1 file per group and config.json file

outputs:
- `msa/` >> aligned fasta files
- `msa_trim/` >> trimmed aligned fasta files
- `msa_trim_alignment_stats.txt` >> alignment statistics

- `hmms/` >> raw unscored profile HMMs
- `hmms_logs/` >> logs of profile HMMs
- `hmms_with_GA_thresholds/` >> final HMMER3 profile HMMs with custom thresholds
- `scores_otherSeqs/` >>> scoring of sequences not part of HMMs
- `scores_truePositives/` >>> scoring of sequences used to build HMMs
- `hmm_bitscore_plots.pdf` >> bit score plots for HMMER3 profile HMMs
- `add_gathering_threshold_and_plot.err` >> error log file for plots

- `msa_trim_stockholm/` >> stockholm format MSAs
- `scores_mmseqs_positivies/` >> scores of sequences used to build profiles vs profiles
- `msa_trim_mmseqs_db/` >> mmseqs2 MSA database
- `msa_trim_mmseqs_profile/` >> mmseqs2 profiles (binary)
- `msa_trim_mmseqs_pssm/` >> mmseqs2 human-readable pssm
- `msa_trim_mmseqs_input_indexes/` >> mmseqs2 input indexes

## Dependancies
- Clustal Omega
- TrimAl
- HMMER3
- MMseqs2
- Python>=3.6 with snakemake, numpy, Biopython, matplotlib, scipy

## Example run
### Print steps
`snakemake -s src/build_hmms_from_ogs_MMSeqs_plus_HMMER3.snake --configfile example/config.json --jobs 2 -pn`

### Execute pipeline
`snakemake -s src/build_hmms_from_ogs_MMSeqs_plus_HMMER3.snake --configfile example/config.json --jobs 2 -p`

### Delete outputs from example run (this does not remove any SLURM logs)
`rm -r add_gathering_threshold_and_plot.err hmm_bitscore_plots.pdf hmms hmms_logs hmms_with_GA_thresholds msa msa_trim msa_trim_alignment_stats.txt msa_trim_mmseqs_db msa_trim_mmseqs_input_indexes msa_trim_mmseqs_profile msa_trim_mmseqs_pssm msa_trim_stockholm scores_mmseqs_positivies scores_otherSeqs scores_truePositives .snakemake/ src/__pycache__/`

### For SLURM submission (on bee) add the cluster flag, like:
`--cluster "sbatch -J profileP -o %j.slurm.out -e %j.slurm.err --constraint fast"`





## Usage

### Step 1: Install workflow

If you simply want to use this workflow, download and extract the [latest release](https://github.com/snakemake-workflows/pfpf/releases).
If you intend to modify and further develop this workflow, fork this repository. Please consider providing any generally applicable modifications via a pull request.

In any case, if you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this repository and, if available, its DOI (see above).

### Step 2: Configure workflow

Configure the workflow according to your needs via editing the file `config.yaml`.

### Step 3: Execute workflow

Test your configuration by performing a dry-run via

    snakemake -n

Execute the workflow locally via

    snakemake --cores $N

using `$N` cores or run it in a cluster environment via

    snakemake --cluster qsub --jobs 100

or

    snakemake --drmaa --jobs 100

See the [Snakemake documentation](https://snakemake.readthedocs.io) for further details.



## Testing

Tests cases are in the subfolder `.test`. They should be executed via continuous integration with Travis CI.
