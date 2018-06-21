"""
Script for adding GA thresholds to hmm files based on the scan results
and plotting the bitscore distributions for the known true positive and
other (possibly false positive sequences)
"""

import sys
import os
import numpy as np
import scipy.stats
import time
import argparse
from collections import OrderedDict
from decimal import Decimal
import matplotlib
matplotlib.use('Agg')  # alterntaive to tunneling with ssh -X
import matplotlib.pyplot as plt
import matplotlib.backends.backend_pdf

def get_evalues_and_scores(in_dir):
    """Get evalues and scores from hmmer3 output file"""
    d = OrderedDict()
    for file_name in os.listdir(in_dir):
        with open('{}/{}'.format(in_dir, file_name)) as f:
            file_name = file_name.split('.scores')[0]
            evalues, scores = [], []
            for line in f:
                if not line.startswith('#'):
                    line = line.strip().split()
                    # evalues are so small I imagine floating point precision to be an issue
                    evalues.append(Decimal(line[4]))
                    scores.append(float(line[5]))
            d[file_name] = [evalues, scores]
    return d

def get_cutoffs(in_dir):
    """Get cutoffs, defined as the mean +- 2 standard deviations"""
    d = {}
    fname2score_d = get_evalues_and_scores(in_dir)
    for name, lst in fname2score_d.items():
        scores_array = np.array(lst[1])
        mean = np.mean(scores_array)
        sd = np.std(scores_array)
        cut_off = round(mean - 2 * sd, 2)
        d[name] = cut_off
    return d

def write_hmms_with_GA_thesh(scores_dir, hmms_in_dir, hmms_out_dir):
    """Write the new HMM files"""
    d = get_cutoffs(scores_dir)

    if not os.path.exists(hmms_out_dir):
        os.mkdir(hmms_out_dir)

    for file_name in sorted(os.listdir(hmms_in_dir)):
        name = file_name.split('.hmm')[0]
        try:
            ga = d[name]
        except KeyError: # do not know why there is a key error sometimes!
            print('Warning: key error with key {}, setting GA to 0'.format(name), file=sys.stderr)
            ga = 0
        if ga <= 0:
            print('Warning: GA is {} for {}'.format(ga, name), file=sys.stderr)
        with open(os.path.join(hmms_in_dir, file_name)) as in_f, open(os.path.join(hmms_out_dir, file_name), 'w') as out_f:
            for line in in_f:
                if line.startswith('CKSUM'):
                    out_f.write(line)
                    out_f.write('GA {} {}\n'.format(ga, ga))
                else:
                    out_f.write(line)

def plot_graphs(truePositive_scores_dir, otherSeq_scores_dir, graph_out_file):
    """Plot the graphs with matplotlib"""
    tp_d = get_evalues_and_scores(truePositive_scores_dir)
    cutOff_d = get_cutoffs(truePositive_scores_dir)
    fp_d = get_evalues_and_scores(otherSeq_scores_dir)

    pdf = matplotlib.backends.backend_pdf.PdfPages(graph_out_file + '.pdf')
    for name, lst in tp_d.items():
        fig = plt.figure()
        fig.suptitle(name)

        plt.xlabel('Bit score')
        plt.ylabel('Normalised frequency')
        true_scores = sorted(lst[1])
        true_weights = np.ones_like(true_scores) / len(true_scores)
        plt.hist(true_scores, color='r', weights=true_weights, label='Seqs used to build HMM')

        false_scores = sorted(fp_d[name][1])
        false_weights = np.ones_like(false_scores) / len(false_scores)
        plt.hist(false_scores, color='b', weights=false_weights, label='Other seqs')

        ga = cutOff_d[name]
        try:
            nearest_evalue = min((abs(ga - score), evalue) for score, evalue in zip(lst[1], lst[0]))[1]
        except ValueError:  # for Python3 could use default value
            nearest_evalue = 'NA'

        plt.axvline(x=ga, color='g', linestyle='dashed', linewidth=2, label='GA thresh {}; nearest evalue {}'.format(ga, nearest_evalue))

        plt.legend(loc='upper center')

        pdf.savefig(fig)
    pdf.close()

def main(truePositives_dir, otherSeqs_dir, hmms_in_dir, hmms_out_dir, plot_name):
    """The main work"""
    write_hmms_with_GA_thesh(truePositives_dir, hmms_in_dir, hmms_out_dir)
    plot_graphs(truePositives_dir, otherSeqs_dir, plot_name)


if __name__ == '__main__':
    # Options
    parser = argparse.ArgumentParser(description='Plot HMM bitscores for the actual the sequenecs of the actual HMMs and the other sequences')
    parser.add_argument('--truePositive_scores_dir', required=True, help='True positive scores directory')
    parser.add_argument('--otherSeq_scores_dir', required=True, help='Putative false positive scores directory')
    parser.add_argument('--in_hmms_dir', required=True, help='Input HMMs directory')
    parser.add_argument('--out_hmms_dir', required=True, help='Output HMMs directory')
    parser.add_argument('--plot_name', required=True, help='File name for plot (without suffix')

    args = parser.parse_args()

    # Execute main
    main(args.truePositive_scores_dir, args.otherSeq_scores_dir, args.in_hmms_dir, args.out_hmms_dir, args.plot_name)
