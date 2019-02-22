# MMprofiler wrapper for mmseqs profile search.

[![Snakemake](https://img.shields.io/badge/snakemake-≥5.0.0-brightgreen.svg)](https://snakemake.bitbucket.io)
[![Build Status](https://travis-ci.org/snakemake-workflows/pfpf.svg?branch=master)](https://travis-ci.org/snakemake-workflows/pfpf)

A command line wrapper for:

1. aligning unaligned protein families
2. building mmseqs2 profiles
3. searching using profiles



## Install

### Conda
[![Bioconda](https://img.shields.io/conda/dn/bioconda/mmprofiler.svg?label=Bioconda )](https://anaconda.org/bioconda/mmprofiler)

  ```
  conda install mmprofiler
  ```

### Install development version

Requires:
  - mafft=7.313
  - clustalo
  - trimal=1.4.1
  - mmseqs2
  - snakemake
  - Python>=3.6 with numpy, Biopython, matplotlib, scipy

clone git repository.

```
pip install --editable .

```

## Usage

See also test.sh and the example data in .test/data

```
cd .test

# align
mmprofiler align data --faa-extension .fa --stockholm aligned.stk $@

#build
mmprofiler build aligned.stk mmprofile $@

# search
mmprofiler search -o mapresults mmprofile queries/*.fa data/*.fa $@


```
## Output
