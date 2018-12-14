echo "Creating conda environment."
source /data/berkeley_overflow/anaconda3/etc/profile.d/conda.sh
conda env create -f og_classifier.yaml
conda activate og_classifier

echo "Creating FASTA files for each OG using training genomes."
mkdir data/OGs/
python scripts/map_genes_to_ogs.py

echo "Running Snakefile"
snakemake

conda deactivate
