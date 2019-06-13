#!/bin/bash

### will search peak file in peaks/*narrowPeak under $2
set -e

input_mtx_file=$1
ABS_PATH=`cd "$2"; pwd`

bc_stat_file=${ABS_PATH}/qc_result/${OUTPUT_PREFIX}.${MAPPING_METHOD}.qc_per_barcode.bed
mapping_qc_file=${ABS_PATH}/qc_result/${OUTPUT_PREFIX}.${MAPPING_METHOD}.summary
fragments_file=${ABS_PATH}/raw_matrix/fragments.bed
output_dir=${ABS_PATH}/filtered_matrix

curr_dir=`dirname $0`


echo "${CELL_CALLER} is usded for cell calling..."


if [ ${CELL_CALLER} = 'EmptyDrop' ];then
	output_dir1=${output_dir}/EmptyDrop
	mkdir -p $output_dir1
	${R_PATH}/R --vanilla --args $input_mtx_file $output_dir1 ${EmptyDrop_FDR} < ${curr_dir}/Utils/EmptyDrop.R
	
  

elif [ ${CELL_CALLER} = 'FILTER' ];then
	output_dir1=${output_dir}/FILTER
	mkdir -p $output_dir1
        ${R_PATH}/Rscript  ${curr_dir}/Utils/filter_barcodes.R  --bc_stat_file $bc_stat_file \
            --raw_mtx_file $input_mtx_file --output_prefix $output_dir1 $BC_FILTER_CUTOFF
        
    

else 
	## using cellranger
	## calculate peak coverage fraction
	gsize=$(awk '{sum+=$2}; END {print sum}' $CHROM_SIZE_FILE)

	## implement cellrange cell calling
	output_dir1=${output_dir}/cellranger
	mkdir -p output_dir1
	
    ${R_PATH}/R --vanilla --args $input_mtx_file $output_dir1 $gsize $bc_stat_file \
    < ${curr_dir}/Utils/cellranger_cell_caller.R

fi


