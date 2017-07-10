#! /usr/bin/env bash

usage()
{
cat << EOF
DESCRIPTION:
    Script to BLAST novel miRNA sequences to a canonical miRNA database in order to identify the potential isomiRs.

USAGE:
    ./isomiR-BLAST.sh -s sequences_to_blast.txt -o output_directory/ -d blast_database_directory/ -n mirbase19.hsa.mature -r hg19.fa -b ncbi-blast-2.2.30+/bin/blastn

OPTIONS:
    -s    Text file containing the miRNA sequences to BLAST. Should contain 2 tab-seperated columns with a header row.
          The first column is the sequence count and the second column is the sequence.
    -o    Path to the output directory. 
    -d    Path to the directory containing the canonical miRNA BLAST database
    -n    Name of the canonical miRNA BLAST database
    -r    Path to reference genome FASTA file.
    -b    Path to blastn binary.
EOF
}

while getopts "s:o:d:n:r:b:h" OPTION; do
	case $OPTION in
		s) seqs_to_blast=$OPTARG;;
		o) output_dir=$OPTARG;;
		d) blast_db_dir=$OPTARG;;
		n) blast_db=$OPTARG;;
		r) reference_seq=$OPTARG;;
		b) blastn=$OPTARG;;
		h) usage
		exit ;;
		\?) usage
		exit ;;
		:) usage
		exit ;;
	esac
done

#### start of the main wrapper
if [ ! -s "$seqs_to_blast" ]
then
	echo "Missing Required Paramters!" >&2
	usage
	exit 1;
fi

#set -x
echo `date`
export BLASTDB=$blast_db_dir


# make fasta file
cat $seqs_to_blast | sed 1d | awk '{print ">"$2"\n"$2}' >> $output_dir/tmp_query_seqs.fa
	
# run blast
$blastn -db $blast_db -query $output_dir/tmp_query_seqs.fa -out $output_dir/query.blast.out.txt -word_size 13 -gapopen 5 -gapextend 2 -num_threads 4 -outfmt '7 qseqid sseqid stitle pident length mismatch gapopen qstart qend sstart send evalue bitscore' -num_alignments 10 -evalue 100 -strand "plus"

# create final output
echo -e "blast.query_id\tblast.subject_id\tblast.subject.accession\tblast.subject.sequence\tblast.percent_identity\tblast.alignment_length\tblast.evalue\tblast.bit_score" | paste $seqs_to_blast - | head -1 > $output_dir/blast_results.xls
# parse blast output
for seq in $(cat $seqs_to_blast | sed 1d | cut -f2);
do
	grep -w $seq $seqs_to_blast | tr "\n" "\t" >> $output_dir/blast_results.xls
	if [ $(grep -v "^#" $output_dir/query.blast.out.txt | grep -cw "^$seq") -gt 0 ]
	then
		grep -v "^#" $output_dir/query.blast.out.txt | grep -w "^$seq" | head -1 | cut -f1,2,3,4,5,12,13 | awk -F"\t" '{if($3 == "."){acc=".";seq=".";}else{split($3,a," ");acc=a[2];seq=a[3];}print $1"\t"$2"\t"acc"\t"seq"\t"$4"\t"$5"\t"$6"\t"$7}' >> $output_dir/blast_results.xls
	else
		echo -e ".\t.\t.\t.\t.\t.\t.\t." >> $output_dir/blast_results.xls
	fi
done

# remove tmp files
rm $output_dir/tmp_query_seqs.fa $output_dir/query.blast.out.txt


echo `date`

