
set -e

./pfpf -d test_results --config in_dir="../.test/data"  -j 1 $@

echo "Query \n"

./pfpf -d test_results --config in_dir="../.test/data" query_dir="../.test/queries" -j 1 $@
