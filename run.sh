




snakemake -s Snakefile -d workdir -j 3 --configfile config.yaml -p --use-conda  --conda-prefix ~/conda_envs $@
