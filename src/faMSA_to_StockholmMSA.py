"""
Convert fasta aligned to stockholm aligned file
"""

import sys
from Bio import AlignIO

def yield_altered(alignments, append_int_to_headers):
    """Yield altetered alignment records"""
    i = 0
    for alignment in alignments:
        for r in alignment:
            i += 1
            if append_int_to_headers:
                r.description += '_SeqNUM:{}'.format(i)
                r.id = r.description.split()[0]
        stockholm_al = alignment.format('stockholm')
        num_ids = stockholm_al.count('\n#=GF AC')
        if num_ids == 1:
            yield stockholm_al
        if num_ids > 1:
            raise SystemExit('Error: Two "GF" header lines, format not as expected')
        else:  # 0
            print('Adding "#=GF AC" header line to output...')
            lst, flag = [], False
            for line in stockholm_al.split('\n'):
                if flag:
                    lst.append('#=GF AC {}'.format(line.split()[0]))
                    flag = False
                elif line.startswith('#=GF'):
                    flag = True
                lst.append(line)
            yield '\n'.join(lst)

def main(in_file, append_int_to_headers, out_file):
    """Main work"""
    with open(in_file) as in_f:
        alignments = AlignIO.parse(in_f, "fasta")
        alignments = yield_altered(alignments, append_int_to_headers)
        with open(out_file, 'w') as out_f:
            for al in alignments:
                out_f.write(al)

if __name__ == '__main__':
    bool_ = sys.argv[2]
    if bool_ not in {'True', 'False'}:
        raise ValueError('2nd arg must be "True" or "False"')
    bool_ = eval(bool_)
    if bool_:
        print("Adding seq number counts to headers...")
    main(sys.argv[1], bool_, sys.argv[3])
