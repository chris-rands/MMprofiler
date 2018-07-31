snakemake -s ../Snakefile -d workingdir -j 1 --configfile ../config.yaml -p --use-conda  --conda-prefix ../conda_envs $@
