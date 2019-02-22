# MMprofiler wrapper for mmseqs profile search.

[![Snakemake](https://img.shields.io/badge/snakemake-≥5.0.0-brightgreen.svg)](https://snakemake.bitbucket.io)
[![CircleCI](https://circleci.com/gh/chris-rands/profiles_from_protein_families/tree/master.svg?style=svg)](https://circleci.com/gh/chris-rands/profiles_from_protein_families/tree/master)

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
  - Biopython
  - numpy
  - Python>=3.6

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

protein14 | family1 | 0.86 | 391 | 54 | 0 | 3 | 393 | 1 | 387 | 4.43E-230 | 698
-- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | --
protein33 | family1 | 0.79 | 387 | 80 | 0 | 1 | 387 | 1 | 384 | 1.22E-205 | 627
protein52 | family1 | 0.865 | 389 | 52 | 0 | 3 | 391 | 1 | 385 | 8.57E-231 | 700
protein30 | family1 | 0.765 | 395 | 91 | 0 | 1 | 395 | 1 | 387 | 1.19E-201 | 616
protein25 | family1 | 0.837 | 390 | 63 | 0 | 4 | 393 | 2 | 387 | 3.60E-222 | 675
protein16 | family1 | 0.798 | 389 | 78 | 0 | 2 | 390 | 2 | 386 | 4.20E-209 | 637
protein15 | family1 | 0.86 | 391 | 54 | 0 | 3 | 393 | 1 | 387 | 1.99E-230 | 699
protein5 | family1 | 0.79 | 387 | 80 | 0 | 1 | 387 | 1 | 384 | 1.17E-205 | 627


