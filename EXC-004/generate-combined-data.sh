## make direction if not already existing 
if [ ! -d COMBINED-DATA ]; then
    mkdir COMBINED-DATA/
fi


## sample name with correct culture name 
for sample_dir in RAW-DATA/*/
do
    sample_name=$(basename "$sample_dir")
    culture_name=$(grep "$sample_name" RAW-DATA/sample-translation.txt | awk '{print $2}')

    bins_dir="${sample_dir}bins/"
    checkm_file="${sample_dir}checkm.txt"

    # Zähler für MAGs und BINs (für dieses Sample)
    mag_counter=1
    bin_counter=1

    ## rename checkm.txt files with correct culture name as prefix
    cp "${sample_dir}checkm.txt"  "COMBINED-DATA/${culture_name}-CHECKM.txt"

    ## rename gtdb.gtdbtk.tax files with correct culture name as prefix
    cp "${sample_dir}gtdb.gtdbtk.tax" "COMBINED-DATA/${culture_name}-GTDB-TAX.txt"

    # Liste alle FASTA-Dateien auf
    for fasta_file in ${bins_dir}*.fasta
    do
        filename=$(basename "$fasta_file")
    
    ## copy the unbinned files with into new direction with culture prefix
    if [[ "$filename" == "bin-unbinned.fasta" ]]; then

        awk '/^>/{printf(">%s_%s\n", culture, substr($0,2)); next} {print}' \
        culture="$culture_name" "$fasta_file" > "COMBINED-DATA/${culture_name}_UNBINNED.fa"

        else

            bin_name="${filename%.fasta}"
            completeness=$(grep "${bin_name}" "$checkm_file" | awk '{print $13}'  )
            contamination=$(grep "${bin_name}" "$checkm_file" | awk '{print $14}')

            ## remvove dezimal numbers
            comp_int=${completeness%.*}  
            cont_int=${contamination%.*}  
            
            ## loop to filter for MAGs and BINs and also incert unique deflines
            if [ "$comp_int" -ge 50 ] && [ "$cont_int" -le 5 ]; then

                output_name="${culture_name}_MAG_$(printf "%03d" $mag_counter).fa"
                awk '/^>/{printf(">%s_%s\n", culture, substr($0,2)); next} {print}' \
                culture="$culture_name" "$fasta_file" > "COMBINED-DATA/$output_name"
                ((mag_counter++))
            
            else 

                output_name="${culture_name}_BIN_$(printf "%03d" $bin_counter).fa"
                awk '/^>/{printf(">%s_%s\n", culture, substr($0,2)); next} {print}' \
                culture="$culture_name" "$fasta_file" > "COMBINED-DATA/$output_name"
                ((bin_counter++))

            fi  

        fi

    done

done

echo "
---------------------------------------------------------------------------------------------------------------------------------------------------
All the FASTA and text files have been successfully copied, renamed into the directory of COMBINED-DATA. The deflines are also unique! Have fun :)
---------------------------------------------------------------------------------------------------------------------------------------------------
"


