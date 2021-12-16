#!/bin/bash

. ./configs/configs_$1.sh

cd /home/data/ChenRuiyang/SimPoint.3.2/bin

if [ ${SE_OR_FS} == SE ];then
./simpoint -loadFVFile /home/data/ChenRuiyang/gem5/${SE_OUT_DIR_INIT}/simpoint.bb.gz \
-maxK 30 -saveSimpoints ${SE_simpoint_file_path} \
-saveSimpointWeights ${SE_weight_file_path} \
-inputVectorsGzipped
elif [ ${SE_OR_FS} == FS ];then
./simpoint -loadFVFile /home/data/ChenRuiyang/gem5/${FS_OUT_DIR_INIT}/simpoint.bb.gz \
-maxK 30 -saveSimpoints ${FS_simpoint_file_path} \
-saveSimpointWeights ${FS_weight_file_path} \
-inputVectorsGzipped
else
echo SE_OR_FS should be SE or FS 
fi

