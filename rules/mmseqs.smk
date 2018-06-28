
## MMSeqs2 rules
rule MSAfasta_to_stockholm:
    input:
        rules.trim.output
    output:
        'msa_trim_stockholm/{input_targets}.trim.al.sth'
    shell:
        'python3 %s/faMSA_to_StockholmMSA.py {input} False {output}' %(SCRIPTS_DIR)


rule stockholm_to_MSAdb:
    input:
        rules.MSAfasta_to_stockholm.output
    output:
        'msa_trim_mmseqs_db/{input_targets}.trim.al.db'
    conda:
        '../envs/mmseqs.yaml'
    shell:
        'mmseqs convertmsa {input} {output}'


rule MSAdb_to_profile:
    input:
        rules.stockholm_to_MSAdb.output
    output:
        'msa_trim_mmseqs_profile/{input_targets}.profile'
    conda:
        '../envs/mmseqs.yaml'
    shell:
        'mmseqs msa2profile {input} {output} '
        '--match-mode 1 --msa-type 2 --threads 1'


rule profile_to_pssm:
    input:
        rules.MSAdb_to_profile.output
    output:
        'msa_trim_mmseqs_pssm/{input_targets}.pssm'
    conda:
        '../envs/mmseqs.yaml'
    shell:
        'mmseqs  profile2pssm {input} {output} --threads {threads}'


rule profile_to_indexdb:
    input:
        rules.MSAdb_to_profile.output
    output:
        out1 = 'msa_trim_mmseqs_profile/{input_targets}.profile.sk5',
        tmp = temp('{input_targets}_tmp1/')
    conda:
        '../envs/mmseqs.yaml'
    shell:
        'mmseqs createindex {input} {output.tmp} -k 5 -s 7'


rule input_seqs_to_indexes:
    input:
        os.path.join(INPUT_DIR, '{input_targets}.%s' % (INPUT_SUFFIX))
    output:
        'msa_trim_mmseqs_input_indexes/{input_targets}.db'
    conda:
        '../envs/mmseqs.yaml'
    shell:
        'mmseqs createdb {input} {output}'


rule score_mmseqs_positives:
    input:
        in1 = rules.MSAdb_to_profile.output,
        in2 = rules.input_seqs_to_indexes.output
    output:
        out1 = 'scores_mmseqs_positivies/{input_targets}.scores',
        tmp = temp('{input_targets}_tmp2/')
    conda:
        '../envs/mmseqs.yaml'
    shell:
        'mmseqs search {input.in2} {input.in1} {output.out1} {output.tmp}'
