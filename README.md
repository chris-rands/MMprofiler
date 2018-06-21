# profiles_from_protein_families
Create profiles and profile HMMs from (unaligned) protein families/clusters, under development

Python snakemake pipeline that build profiles and profile HMMs from unaligned fasta protein familes.

input:
example/ >> directory of unaligned fasta sequences, 1 per group/family/cluster

outputs:
-alignment
msa/ >> aligned fasta files
msa_trim >> trimmed aligned fasta files
msa_trim_alignment_stats.txt >> alignment stats

-HMMER3 profile HMMs
hmms >> raw unscored hmms
hmms_logs >> logs of hmms
hmms_with_GA_thresholds >> final HMMER3 profile HMMs with custom thresholds
scores_otherSeqs >>> scoring of sequences not part of HMMs
scores_truePositives >>> scoring of sequences used to build HMMs
hmm_bitscore_plots.pdf >> bit score plots for HMMER3 profile HMMs
add_gathering_threshold_and_plot.err >> error log file

-mmseqs2 profiles
msa_trim_stockholm >> stocholm format msas
scores_mmseqs_positivies >> scores of original seqs vs clusters 
msa_trim_mmseqs_db >> mmsqes2 database
msa_trim_mmseqs_profile >> mmseqs2 profiles (binary)
msa_trim_mmseqs_pssm >> mmseqs2 human-readable pssm
msa_trim_mmseqs_input_indexes >> mmseqs2 input indexes

## Example run
### Print steps
snakemake -s src/build_hmms_from_ogs_MMSeqs_plus_HMMER3.snake --configfile example/config.json -pn

### Execute pipeline
snakemake -s src/build_hmms_from_ogs_MMSeqs_plus_HMMER3.snake --configfile example/config.json -p

### Delete outputs from example run (this does not remove any slurm logs)
rm -r add_gathering_threshold_and_plot.err hmm_bitscore_plots.pdf hmms hmms_logs hmms_with_GA_thresholds msa msa_trim msa_trim_alignment_stats.txt msa_trim_mmseqs_db msa_trim_mmseqs_input_indexes msa_trim_mmseqs_profile msa_trim_mmseqs_pssm msa_trim_stockholm scores_mmseqs_positivies scores_otherSeqs scores_truePositives .snakemake/

### For SLURM submission (on bee) add the cluster flag, like:
--cluster "sbatch -J profileP -o %j.slurm.out -e %j.slurm.err --constraint fast"
