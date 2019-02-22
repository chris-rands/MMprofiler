#!/usr/bin/env bash

set -e

mkdir -p .test/results
cd .test/results

mmprofiler align "../data" --faa-extension .fa --stockholm aligned.stk $@

mmprofiler build aligned.stk mmprofile $@

mmprofiler search -o mapresults mmprofile ../queries/*.fa $@


# ./pfpf -d test_results --config in_dir="../.test/data" query_dir="../.test/data" -j 3 $@
#
# echo "Query"
#
# ./pfpf -d test_results --config in_dir="../.test/data" query_dir="../.test/queries" -j 3 $@
#
# #
#
# ./pfpf -d test_pfam --config stockholm_file="../.test/data/pfamA_slim.stk" query_dir="../.test/queries" -j 3 $@
