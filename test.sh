#!/usr/bin/env bash

set -e


cd .test

# align
mmprofiler align data --faa-extension .fa --stockholm aligned.stk $@

#build
mmprofiler build aligned.stk mmprofile $@

# search
mmprofiler search -o mapresults mmprofile queries/*.fa data/*.fa $@
