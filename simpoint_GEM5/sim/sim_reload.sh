#!/bin/bash

. ../configs/configs_$2.sh

cd ${GEM5_PATH}

if [ ${SE_OR_FS} == SE ];then 

build/${ARCH}/gem5.${METHOD} --outdir=${SE_OUT_DIR_RELOAD}/$1 \
configs/example/se.py \
${CPU_PARM} \
${CACHE_PRAM} \
${MEM_PRAM} \
-c ${SE_ELF_ROUTE} \
-o "${SE_INPUT_ROUTE}${OPTIONS}" \
--restore-simpoint-checkpoint -r $1 --checkpoint-dir ${SE_OUT_DIR_CHECKPOINT}

else
echo SE_OR_FS should be SE or FS 
fi

