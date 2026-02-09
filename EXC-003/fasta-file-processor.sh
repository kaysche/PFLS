##test for right order in file
if [ "$(head -c 1 $1)" == ">" ]; then 

## FASTA file all sequence in one line, new file created
awk '/>/ {if (seq) print seq; print; seq=""; next} {seq=seq $0} END {print seq}' $1 > genes-one-line.fna

## Number of sequences in file 
num_contigs=$( grep '>' genes-one-line.fna | wc -l | awk '{print $1}' )
total_length_sq=$(grep -v '>' genes-one-line.fna | tr -d '\n' | wc -c)

## Length of the longest sequence 
long=$(cat genes-one-line.fna | grep -v '>' "$one_line" |  awk '{print length}' | sort -n | tail -n 1) 

## length of shortest sequence 
short=$(cat genes-one-line.fna | grep -v '>' "$one_line" | awk '{print length}' | sort -n | head -n 1)

## average length of sequences
aveg=$(($total_length_sq/$num_contigs))

## GC Content (%)
GC_amount=$(cat genes-one-line.fna | grep -v '>' "$one_line"| awk '{gc_count += gsub(/[GgCc]/, "", $1)} END {print gc_count}')
GC=$(($GC_amount * 100/$total_length_sq))
GC_=$(echo "$GC" | bc)           ## extra step for xx.x percentage (my system does not have it installed)


#output
echo "FASTA File Statistics:"
echo "----------------------"
echo "Number of sequences: $num_contigs"
echo "Total length of sequences: $total_length_sq"
echo "Length of the longest sequence: $long"
echo "Length of the shortest sequence: $short"
echo "Average sequence length: $aveg"
echo "GC Content (%): $GC_"

# to remove unwanted file
rm genes-one-line.fna

else echo "file has not correct lines" 
fi


