#!/bin/bash

. ../configs/configs_$1.sh

cd /home/data/ChenRuiyang/SimPoint.3.2/bin

if [ ${SE_OR_FS} == SE ];then

rm -r /home/data/ChenRuiyang/SimPoint.3.2/output/gem5/${SE_NAME}
mkdir /home/data/ChenRuiyang/SimPoint.3.2/output/gem5/${SE_NAME}

./simpoint -loadFVFile /home/data/ChenRuiyang/gem5/${SE_OUT_DIR_INIT}/simpoint.bb.gz \
-maxK 30 -saveSimpoints ${SE_simpoint_file_path} \
-saveSimpointWeights ${SE_weight_file_path} \
-inputVectorsGzipped

else
echo SE_OR_FS should be SE 
fi

