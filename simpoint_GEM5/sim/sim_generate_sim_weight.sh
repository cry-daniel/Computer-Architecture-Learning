#!/bin/bash

. ../configs/configs_$1.sh

cd ${SIMPOINT_PATH}/bin

if [ ${SE_OR_FS} == SE ];then

rm -r ${SIMPOINT_PATH}/output/gem5/${SE_NAME}
mkdir ${SIMPOINT_PATH}/output/gem5/${SE_NAME}

./simpoint -loadFVFile ${GEM5_PATH}/${SE_OUT_DIR_INIT}/simpoint.bb.gz \
-maxK 30 -saveSimpoints ${SE_simpoint_file_path} \
-saveSimpointWeights ${SE_weight_file_path} \
-inputVectorsGzipped

else
echo SE_OR_FS should be SE 
fi

