import pandas as pd
from Bio import SeqIO
from myutils.utils import print_progress
import os

def og(og_filename):
    '''Extract cluster ID and Sequence ID from file containing orthologous groups (og)'''
    df = pd.read_table(og_filename, delim_whitespace=True, skiprows=1, skipfooter=0, engine='python', names=[
        "clid", "seq_id", "seq_type", "length", "start", "end", "rawscore", "normscore", "evalue"
        ])
    return df

def find_all_seqs(og_filename, og_id):
    '''Returns all sequences that map to a specified orthologous group (og)'''
    df = og(og_filename)
    seqs = df.query('clid == {}'.format(og_id))['seq_id']
    return seqs

def load_data(filename):
    '''Extract Sequences and IDs from the input FASTA file'''
    gene_records = []
    for record in SeqIO.parse(filename, "fasta"):
        gene_records.append(record)
    return gene_records

def load_sequences(seq_id_list):
    '''
    Given a list of sequence ids of the form "{genome_id}:{gene_id}",
    the function opens the appropriate genome files and returns the gene sequences.
    :param seq_id_list: list of sequence ids of the form "{genome_id}:{gene_id}"
    :return: list of gene sequences
    '''
    sequences = []
    genome_id_list = [s.split(":")[0] for s in seq_id_list]
    genome_id_sorted = sorted(genome_id_list) # Lists are sorted for efficiency. Each file is only loaded once.
    seq_id_sorted = sorted(seq_id_list)
    openfile = None
    not_found = 0
    for i, id in enumerate(seq_id_sorted):
        genome_id = genome_id_sorted[i]
        filename = 'genomes/{}.fs'.format(genome_id)
        if not os.path.exists(filename):
            continue
        if filename != openfile:
            gene_records = load_data(filename)
            gene_ids = [g.id for g in gene_records]
            openfile = filename
        try:
            sequence = gene_records[gene_ids.index(id)]
            sequences.append(sequence)
        except ValueError:
            sequence = gene_records[gene_ids.index(id[:-3])] # this is to account for some records entries with IDs ending with _01 etc.
            sequences.append(sequence)
    return sequences

if __name__ == "__main__":
    og_filename = "561.og"
    df = og(og_filename)
    nunq = len(df.groupby('seq_id'))
    print('nunq', nunq)
    # num_ogs = 6044
    # if not os.path.isdir("OGs"):
    #     os.mkdir("OGs")
    # for i in range(num_ogs):
    #     print_progress(i+1,num_ogs)
    #     if os.path.isfile('OGs/og_{}.fasta'.format(i)):
    #         continue
    #     seq_ids = find_all_seqs(og_filename, i)
    #     seqs = load_sequences(seq_ids)
    #     if len(seqs) > 0:
    #         with open('OGs/og_{}.fasta'.format(i), 'w') as og_out:
    #             SeqIO.write(seqs, og_out, "fasta")
