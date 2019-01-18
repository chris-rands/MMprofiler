import pandas as pd
import sys
import numpy as np
from faMSAPercID import get_pid
import re
import glob
import os
import json



def classifier(search_file):
    '''Convert mmseqs search output file to pandas dataframe'''
    classifier_df = pd.read_table(search_file, engine='python',
                                  names=["gene_id", "og_id", "seq_ident", "aln_length", "num_mismatch", "num_gaps",
                                         "q_start", "q_end", "t_start", "t_end", "e-value", "bitscore"])
    return classifier_df

def og(og_file):
    """Extract cluster ID and Sequence ID from file containing orthologous groups (og)"""
    og_df = pd.read_table(og_file, delim_whitespace=True, skiprows=1, skipfooter=0, engine='python', names=[
        "clid", "gene_id", "seq_type", "length", "start", "end", "rawscore", "normscore", "evalue"
        ])
    return og_df

def get_og_pid(aln_file):
    filename, pid, og_size = get_pid(aln_file)
    og_id = int(re.search(r'\d+', filename.split('/')[-1]).group(0))
    return og_id, pid, og_size

def og_quality(num_ogs=2328):
    og_ids = []
    og_pids = []
    og_sizes = []
    for i in range(num_ogs):
        og_aln_file = 'msa/og_{}.al.fa'.format(i)
        if os.path.isfile(og_aln_file):
            og_id, og_pid, og_size = get_og_pid(og_aln_file)
            og_ids.append(og_id)
            og_pids.append(og_pid)
            og_sizes.append(og_size)
    og_qual_df = pd.DataFrame({"clid": og_ids, "OG PID": og_pids, "OG Size": og_sizes})
    return og_qual_df

# Load OG dataframe
og_file = "561.og"
og_df = og(og_file)

# Load search output files into a dataframe.
gene_search_files = glob.glob('mmseqs/search/*.m8')
# print(gene_search_files)

classifier_df = None
for search_file in gene_search_files:
    if classifier_df is None:
        classifier_df = classifier(search_file)
    else:
        classifier_df = pd.concat([classifier_df, classifier(search_file)])
    print(len(classifier_df.index))


# Add column to classification DF to determine whether matches are correct or not
seq_clid = og_df[["clid", "gene_id"]]
# print('classifier df', classifier_df)
# print('seq clid', seq_clid)
merge_by_gene = pd.merge(classifier_df, seq_clid, how='left', on="gene_id")
correct = merge_by_gene.apply(lambda row: row["og_id"] == row["clid"], axis=1)
classifier_df["correct"] = correct
merge_by_gene["correct"] = correct
print(merge_by_gene)

# Find bitscore mean and std dev of each OG by selecting out True Positive hits for each group.
clid_grouped = merge_by_gene.sort_values('bitscore', ascending=False).groupby(['clid', 'gene_id'])

best_hits = clid_grouped.nth(0)
print(best_hits)

correct_hits = best_hits[best_hits.correct == True].sum()["correct"]
total = len(best_hits.index)
print('correct hits', correct_hits)
print('total', total)
print('Accuracy using only bitscore: {}%'.format(correct_hits*100/total))

names = []
means = []
stds = []
for name, group in clid_grouped:
    print(group)
    true_group = group[group['correct'] == True]
    #print(group.agg({'correct':'first'}))
    names.append(name)
    means.append(true_group['bitscore'].mean())
    stds.append(true_group['bitscore'].std())

# dist_df = pd.DataFrame({"clid":names, "Mean bitscore":means, "Std Dev":stds})
# print('dist_df', dist_df)

# og_qual_df = og_quality(num_ogs=6044)
# og_qual_df = pd.merge(og_qual_df, dist_df, how='left', on='clid')

# full_df = pd.merge(merge_by_gene, og_qual_df, how='left', on='clid')
# print('full_df\n', full_df)
# filtered_df = full_df[(full_df['Mean bitscore'] - 2.65*full_df['Std Dev'] < full_df['bitscore'])]

# print(filtered_df.sort_values('gene_id').reset_index())
# print(filtered_df.query("correct == True")['correct'].count())
# print(filtered_df.query("correct != True")['correct'].count())

# working_df = full_df[['gene_id', 'og_id', 'bitscore', 'clid', 'correct', 'OG PID', 'OG Size', 'Mean bitscore', 'Std Dev', 'Max', 'Min']].sort_values('correct', ascending=False)
# print(working_df.sort_values(['clid', 'bitscore'], ascending=[True, False]).dropna())

# full_df = pd.merge(merge_by_gene, og_qual_df, how='left', left_on='og_id', right_on='clid')
# working_df = full_df[['gene_id', 'og_id', 'bitscore', 'correct', 'OG PID', 'OG Size', 'Mean bitscore', 'Std Dev']].sort_values('correct', ascending=False)
# print(working_df.sort_values(['og_id', 'bitscore'], ascending=[True, False]).dropna())

# test_cond = working_df[(working_df['Mean bitscore'] - 2.65*working_df['Std Dev'] < working_df['bitscore']) == working_df['correct']]
# print(test_cond.dropna())
# print(test_cond['gene_id'].count())
# print(test_cond.query('correct == True')['correct'].count())
# print(test_cond.query('correct != True')['correct'].count())


# Filter OG hits per gene by bitscore > bitscore mean
# df_filter = classifier_df[classifier_df.bitscore > classifier_df.groupby('gene_id')['bitscore'].transform('mean')]
# print(df_filter)

# check = merge_by_gene.iloc[7430:7440]
# check = merge_by_gene.iloc[6345:6355]
# check = merge_by_gene.iloc[6307:6317]
# print(check)

# result_unq = merge_by_gene.drop_duplicates(subset="gene_id", keep="first", inplace=False).reset_index()

#problems = result_unq.query("correct != True and clid.notnull()")
#print(problems)

#print(result_unq)
#print(result_unq.dtypes)



#print(og_qual_df)
#print(og_qual_df.dtypes)
#add_qualfacts = pd.merge(result_unq, og_qual_df, how='left', on="clid")

#print(add_qualfacts)
#problems = add_qualfacts.query("correct != True and clid.notnull()")
#print(problems)

#000828655.1
#000832145.1
