"""
Convert multiple fasta aligned to stockholm aligned file
"""

import sys
from Bio import AlignIO

__author__ = 'Chris Rands, Silas Kieser'

def main(FamilyIds,Alignment_files,out_stockholm_file):


    assert len(FamilyIds) == len(Alignment_files), 'Need for each FamilyID a mas file'
    assert len(set(FamilyIds)) == len(FamilyIds), "Familiy Ids ned to be unique!"

    def unique_id(i,j):
        return f"{FamilyIds[i]}/{j}"


    with open(out_stockholm_file,'w') as fout:
        for i in range(len(FamilyIds)) :
            fout.write("# STOCKHOLM 1.0\n")
            fout.write(f'#=GF AC {FamilyIds[i]}\n')
            # write metadata
            for j,record in enumerate(AlignIO.read(Alignment_files[i],'fasta')):
                fout.write(f"#=GS {unique_id(i,j)} ID {record.id}\n")
                if not record.id==record.description:
                    fout.write(f"#=GS {unique_id(i,j)} DE {record.description}\n")

            #write sequences
            for j,record in enumerate(AlignIO.read(Alignment_files[i],'fasta')):
                fout.write(f"{unique_id(i,j)} {record.seq}\n")

            fout.write('//\n')


if __name__ == "__main__":
    if snakemake is not None:
        main(snakemake.params.family_ids,
             snakemake.input.alignment_files,
             snakemake.output.stockholm_file
             )
    else:

        import argparse

        p = argparse.ArgumentParser()
        p.add_argument("--family-ids",nargs='+',des='FamilyIds')
        p.add_argument("--alignment-files",nargs='+',des='Alignment_files')
        p.add_argument("--stockholm-file",dest='out_stockholm_file')
        args = vars(p.parse_args())
        get_fasta_of_bins(**args)
