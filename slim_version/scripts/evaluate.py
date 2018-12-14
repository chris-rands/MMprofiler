import pandas as pd
import sys
import numpy as np



def classifier(search_file):
    classifier_df = pd.read_table(search_file, engine='python',
                                  names=["gene_id", "og_id", "seq_ident", "aln_length", "num_mismatch", "num_gaps",
                                         "q_start", "q_end", "t_start", "t_end", "e-value", "bitscore"])
    return classifier_df

def og(og_file):
    """Extract cluster ID and Sequence ID from file containing orthologous groups (og)"""
    og_df = pd.read_table(og_file, skiprows=7, skipfooter=2, engine='python', names=[
        "clid", "gene_id", "seq_type", "length", "start", "end", "rawscore", "normscore", "evalue"
        ])
    return og_df

og_file = "data/2335.og"
search_file = sys.argv[1]

classifier_df = classifier(search_file)
og_df = og(og_file)


seq_clid = og_df[["clid", "gene_id"]]


merge_by_gene = pd.merge(classifier_df, seq_clid, how='left', on="gene_id")

# merge_by_gene["og_id"] = merge_by_gene["og_id"].astype(float)
# merge_by_gene["clid"] = merge_by_gene["clid"].astype(float)


correct = merge_by_gene.apply(lambda row: row["og_id"] == row["clid"], axis=1)
classifier_df["correct"] = correct
merge_by_gene["correct"] = correct

#check = merge_by_gene.iloc[3565:3575]
check = merge_by_gene.iloc[2560:2575]
print(check)
result_unq = merge_by_gene.drop_duplicates(subset="gene_id", keep="first", inplace=False).reset_index()

problems = result_unq.query("correct != True and clid.notnull()")
print(problems)
#print(np.where(result_unq["correct"] != True and result_unq["clid"].notnull()))

check = result_unq.iloc[500:510]
print(check)