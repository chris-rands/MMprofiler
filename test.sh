
set -e

#./pfpf -d test_results --config in_dir="../.test/data"  -j 1 $@

echo "Query"

./pfpf -d test_results --config in_dir="../.test/data" query_dir="../.test/data" -j 1 $@
