from __future__ import division

"""
Calculate pairwise percent sequence identity (pid) for 
a FASTA multiple sequence alignment file following the 
BLAST definition of pid, see
http://lh3.github.io/2018/11/25/on-the-definition-of-sequence-identity
"""

import sys
from itertools import combinations
from Bio import AlignIO


def get_pid(in_file):
    """Get pid for file"""
    with open(in_file) as f:
        alignment = AlignIO.read(f, 'fasta')
        seqs = (record.seq for record in alignment)
    total = matches = 0
    for pair in combinations(seqs, 2):
        for n1, n2 in zip(*pair):
            if n1 == '-' and n2 == '-':  # Ignoring double gapped columns
                continue
            total += 1
            if n1.lower() == n2.lower():
                matches += 1
    return in_file, matches / total * 100


def main(in_file):
    """Main work, print results"""
    print('Percent sequence identity for file- {}: {}%'.format(*get_pid(in_file)))

if __name__ == '__main__':
    main(sys.argv[1])
