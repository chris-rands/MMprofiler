"""
Score other seqs (these are sequenenes that were NOT used to build each HMM)
by scaning them against the profile HMMs.
"""

import sys
import os

HMMER3_PATH = '/home/cegg/rands/scripts/hmmer3/hmmer-3.1b2-linux-intel-x86_64/binaries/'

def main(ogs_dir, in_file, out_file, evalue, input_suffix, hmmer_path):
    true_positive_f_name = os.path.join(ogs_dir,
                           '{}.{}'.format(os.path.basename(in_file).split('.hmm')[0],
                           input_suffix.lstrip('.')))
    
    other_f_names = [os.path.join(ogs_dir, item) for item in
                     os.listdir(ogs_dir) if item.endswith(input_suffix)]
    other_f_names.remove(true_positive_f_name)
    cmd = 'cat {} | {}/hmmsearch -E {} --cpu 1 --tblout {} {} -'.format(' '.join(other_f_names), HMMER3_PATH, evalue, out_file, in_file)
    os.system(cmd)

if __name__ == '__main__':
    main(*sys.argv[1:])
