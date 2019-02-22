import os

if config.get('tmpdir') is None:
    config['tmpdir'] = '/tmp'
PROFILE= config['profile']


rule all_build:
    input:
        PROFILE

rule stockholm_to_MSAdb:
    input:
        config['stockholm_file']
    output:
        temp(os.path.join(config['tmpdir'],'msa.db'))
    conda:
        '../envs/mmseqs.yaml'
    threads: 1
    shell:
        'mmseqs convertmsa {input} {output}'


rule MSAdb_to_profile:
    input:
        rules.stockholm_to_MSAdb.output
    output:
        directory(PROFILE)
    conda:
        '../envs/mmseqs.yaml'
    shell:
        'mkdir {output} ;'
        'mmseqs msa2profile {input} {output}/profile '
        '--match-mode 1 --msa-type 2 --threads {threads}'

# # ERROR: gives only first profile
# rule profile_to_pssm:
#     input:
#         rules.MSAdb_to_profile.output
#     output:
#         'mmseqs/pssm/profile.pssm'
#     conda: "../envs/mmseqs.yaml"
#     threads: config['threads']
#     shell:
#         'mmseqs  profile2pssm {input} {output} --threads {threads}'

# rule profile_to_indexdb:
#     input:
#         rules.MSAdb_to_profile.output
#     output:
#         out = 'mmseqs/profile/{input_targets}.profile.index',
#         tmp = temp('{input_targets}_tmp1/')
#     conda: "../envs/mmseqs.yaml"
#     shell:
#         'mmseqs createindex {input} {output.tmp} -k 5 -s 7'
