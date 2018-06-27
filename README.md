# Snakemake workflow: Profiles from Protein Families

[![Snakemake](https://img.shields.io/badge/snakemake-≥5.0.0-brightgreen.svg)](https://snakemake.bitbucket.io)
[![Build Status](https://travis-ci.org/snakemake-workflows/pfpf.svg?branch=master)](https://travis-ci.org/snakemake-workflows/pfpf)

Create profiles and profile HMMs from (unaligned) protein families/clusters, under development

Python snakemake pipeline that build profiles and profile HMMs from unaligned fasta protein familes.



## Authors

* Christopher Rands (@chris-rands), Silas Kieser (@silask)


## Description
### input:
- `example/` >> directory of unaligned fasta sequences, 1 file per group specified in the `config.yaml` file or with the command argument `--config in_dir=<directory>`

### outputs:
- `msa/` >> aligned fasta files
- `msa_trim/` >> trimmed aligned fasta files
- `msa_trim_alignment_stats.txt` >> alignment statistics

#### Hmmer3 sub-workflow

- `hmms/` >> raw unscored profile HMMs
- `hmms_logs/` >> logs of profile HMMs
- `hmms_with_GA_thresholds/` >> final HMMER3 profile HMMs with custom thresholds
- `scores_otherSeqs/` >>> scoring of sequences not part of HMMs
- `scores_truePositives/` >>> scoring of sequences used to build HMMs
- `hmm_bitscore_plots.pdf` >> bit score plots for HMMER3 profile HMMs
- `add_gathering_threshold_and_plot.err` >> error log file for plots

#### mmseqs2 sub-workflow

- `msa_trim_stockholm/` >> stockholm format MSAs
- `scores_mmseqs_positivies/` >> scores of sequences used to build profiles vs profiles
- `msa_trim_mmseqs_db/` >> mmseqs2 MSA database
- `msa_trim_mmseqs_profile/` >> mmseqs2 profiles (binary)
- `msa_trim_mmseqs_pssm/` >> mmseqs2 human-readable pssm
- `msa_trim_mmseqs_input_indexes/` >> mmseqs2 input indexes

## Dependancies
- Miniconda

or

- Clustal Omega
- TrimAl
- HMMER3
- MMseqs2
- Python>=3.6 with snakemake, numpy, Biopython, matplotlib, scipy


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

Use conda to install dependecies automatically

    snakemake --use-conda  --conda-prefix <where you want to store your directories>

Execute the workflow locally via

    snakemake --cores $N

using `$N` cores or run it in a cluster environment via

    snakemake --cluster sbatch --jobs 100

or

    snakemake --drmaa --jobs 100

See the [Snakemake documentation](https://snakemake.readthedocs.io) for further details.


## Testing

Tests cases are in the subfolder `.test`. They should be executed via continuous integration with Travis CI.
