"""
Calculate summary statistics for many multiple sequence alignment files
"""

from __future__ import division
import os
import sys
import time
from numpy import mean, median
from itertools import combinations
from Bio import AlignIO

__author__ = 'Chris Rands'

def get_alignment_stats(in_file):
    """Get alignment stats for file"""
    seqs = []
    with open(in_file) as f:
        alignment = AlignIO.read(f, 'fasta')
        for record in alignment:
            seqs.append(record.seq)
    indels = matches = mismatches = gapped_cols = total = 0
    for pair in combinations(seqs, 2):
        in_gap1 = in_gap2 = False
        for idx, nuc1 in enumerate(pair[0]):  # Note nuc1 and nuc2 may be aa1 and aa2 (aa = amino acid)
            nuc2 = pair[1][idx]
            if nuc1 == '-' and nuc2 == '-':  # Ignoring double gapped columns
                continue
            total += 1
            if nuc1 == '-':
                in_gap2 = False
                gapped_cols += 1
                if not in_gap1:
                    indels += 1
                    in_gap1 = True
            elif nuc2 == '-':
                in_gap1 = False
                gapped_cols += 1
                if not in_gap2:
                    indels += 1
                    in_gap2 = True
            else:
                in_gap1 = in_gap2 = False
                #if not all(n.isalpha() for n in (nuc1, nuc2)):
                #    raise ValueError('Nuc/AA1: {} or Nuc/AA2: {} is invalid'.format(nuc1, nuc2))
                if nuc1.lower() == nuc2.lower():
                    matches += 1
                else:
                    mismatches += 1
    return (in_file, indels / float(total) * 100,
            matches / float(matches + mismatches) * 100,
            gapped_cols / float(total) * 100, len(seqs))

def get_dir_stats(in_dir):
    """Yield alignment stats for directoy"""
    for each_file in os.listdir(in_dir):
        yield get_alignment_stats('{}/{}'.format(in_dir, each_file))


def mean_median(lst):
    """Calculate mean and median values of a list"""
    return round(mean(lst), 5), round(median(lst), 5)

def collate_stats(in_dirs, out_file):
    """Colate stats and write out file"""
    with open(out_file, 'w') as out_f:
        for each_dir in in_dirs:
            indels_perc, matches_perc, gapped_col_perc, num_seqs = [], [], [], []
            for row in get_dir_stats(each_dir):
                indels_perc.append(row[1])
                matches_perc.append(row[2])
                gapped_col_perc.append(row[3])
                num_seqs.append(row[4])
            out_f.write('Dir: {}\n'.format(each_dir))
            out_f.write('Mean (median) % pairwise seq id: {} ({})\n'.format(*mean_median(matches_perc)))
            out_f.write('Mean (median) % pairwise indels: {} ({})\n'.format(*mean_median(indels_perc)))
            out_f.write('Mean (median) % gapped collumns: {} ({})\n'.format(*mean_median(gapped_col_perc)))
            out_f.write('Mean (median) nucs cluster size: {} ({})\n###\n'.format(*mean_median(num_seqs)))


if __name__ == '__main__':
    start_time = time.time()
    collate_stats(['msa_trim'], 'MSA_TRIM_STATS.txt')
    print('Time {} s'.format(round(time.time() - start_time, 2)))
