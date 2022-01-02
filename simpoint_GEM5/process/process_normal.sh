#!/bin/bash

. ./configs/configs_$1.sh # 参数 $1 代表选用 XXX = $1 的 configs_XXX.sh

cd ${GEM5_PATH} # 移动当前目录到 Gem5 下，移动的话后面的一些参数就不用写绝对地址了

# 正常模拟(指不用Simpoint)，参数都来自 configs_XXX.sh

if [ ${SE_OR_FS} == SE ];then 

rm -r ${SE_OUT_DIR_NORMAL};

build/${ARCH}/gem5.${METHOD} --outdir=${SE_OUT_DIR_NORMAL} \
configs/example/se.py \
${CPU_PARM} \
${CACHE_PRAM} \
${MEM_PRAM} \
-c ${SE_ELF_ROUTE} \
-o "${SE_INPUT_ROUTE}${OPTIONS}"

else
echo SE_OR_FS should be SE 
fi