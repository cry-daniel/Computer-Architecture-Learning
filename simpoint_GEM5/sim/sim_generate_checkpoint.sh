#!/bin/bash

. ../configs/configs_$1.sh

cd ${GEM5_PATH}

if [ ${SE_OR_FS} == SE ];then

build/${ARCH}/gem5.${METHOD} --outdir=${SE_OUT_DIR_CHECKPOINT} \
configs/example/se.py \
--take-simpoint-checkpoint=\
${SE_simpoint_file_path},${SE_weight_file_path},\
${interval_length},${warmup_length} \
--cpu-type=AtomicSimpleCPU \
${CACHE_PRAM} \
${MEM_PRAM} \
-c ${SE_ELF_ROUTE} \
-o "${SE_INPUT_ROUTE}${OPTIONS}"


else
echo SE_OR_FS should be SE 
fi

