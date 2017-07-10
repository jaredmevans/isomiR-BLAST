# isomiR-BLAST
BLAST isomiR sequences to a canonical miRNA database

## INSTALLATION
This script uses a local copy of ncbi blast+ which can be downoaded here:
ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+

A canonical mature miRNA database must also be created. Here is an example of how to create a blast database from miRBase sequences:
```
ncbi-blast-2.2.30+/bin/makeblastdb -in /data5/bsi/refdata/mirbase/v19/mature.hsa.dna.fa -dbtype 'nucl' -out mirbase_db/mirbase19.hsa.mature -title mirbase19.hsa.mature
```

## USAGE
```
./isomiR-BLAST.sh -s sequences_to_blast.txt -o output_directory/ -d blast_database_directory/ -n mirbase19.hsa.mature -r hg19.fa -b ncbi-blast-2.2.30+/bin/blastn
```

## OPTIONS
```
-s    Text file containing the miRNA sequences to BLAST. Should contain 2 tab-seperated columns with a header row.
      The first column is the sequence count and the second column is the sequence.
-o    Path to the output directory. 
-d    Path to the directory containing the canonical miRNA BLAST database
-n    Name of the canonical miRNA BLAST database
-r    Path to reference genome FASTA file.
-b    Path to blastn binary.
```
