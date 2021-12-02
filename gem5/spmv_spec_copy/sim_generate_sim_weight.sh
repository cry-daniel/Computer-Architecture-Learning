#!/bin/bash

. ./configs/configs_$1.sh

cd ~/ChenRuiyang/SimPoint.3.2/bin

if [ ${SE_OR_FS} == SE ];then
./simpoint -loadFVFile ~/ChenRuiyang/gem5/${SE_OUT_DIR_INIT}/simpoint.bb.gz \
-maxK 30 -saveSimpoints ~/ChenRuiyang/SimPoint.3.2/output/gem5/${SE_OUT_GENE}_simpoint_file \
-saveSimpointWeights ~/ChenRuiyang/SimPoint.3.2/output/gem5/${SE_OUT_GENE}_weight_file \
-inputVectorsGzipped
elif [ ${SE_OR_FS} == FS ];then
./simpoint -loadFVFile ~/ChenRuiyang/gem5/${FS_OUT_DIR_INIT}/simpoint.bb.gz \
-maxK 30 -saveSimpoints ~/ChenRuiyang/SimPoint.3.2/output/gem5/${FS_OUT_GENE}_simpoint_file \
-saveSimpointWeights ~/ChenRuiyang/SimPoint.3.2/output/gem5/${FS_OUT_GENE}_weight_file \
-inputVectorsGzipped
else
echo SE_OR_FS should be SE or FS 
fi

