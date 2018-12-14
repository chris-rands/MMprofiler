The test.sh file follows the following steps:

Step 1) Create and activate conda environment from og_classifier.yaml file.

Step 2) Sort all genomes into OGs

	Using OG file ("2335.og"), each of the genomes in data/genomes/ is sorted into orthologous groups.
	The results are printed to data/OGs/ where each file is names "og_{id}.fasta" and contains Biopython sequence records.

Step 3) Run snakemake file with the following steps: (This workflow can be visualized in the dag.svg file)

     3a) Run multi-sequence alignment using mafft on the OG files created in Step 2.
     3b) Trim the alignment files using trimAl
     3c) Combine all trimmed alignment files into a single file in Stockholm format.
     3d) Convert Stockholm file to MSA DB
     3e) Use the MSA DB to create OG profiles using mmseqs2.
     3f) Convert input query genome file in FASTA format to a mmseqs DB
     3g) Search profiles with query genome to classify genes to OGs.
