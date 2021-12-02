#!/bin/bash

. ./configs/configs_$1.sh

cd ${GEM5_PATH}

if [ ${SE_OR_FS} == SE ];then 
rm -r ${SE_OUT_DIR_INIT};
build/${ARCH}/gem5.${METHOD} --outdir=${SE_OUT_DIR_INIT} \
configs/example/se.py \
--simpoint-profile --simpoint-interval ${interval_length} \
--cpu-type=NonCachingSimpleCPU \
--cpu-clock 2.5GHz \
--num-cpu 1 \
--mem-type DDR3_2133_8x8 --mem-size 16GB \
-c ${SE_ELF_ROUTE} \
-o ${SE_INPUT_ROUTE} \
--l2-hwp-type \
StridePrefetcher
elif [ ${SE_OR_FS} == FS ];then 
rm -r ${FS_OUT_DIR_INIT};
build/${ARCH}/gem5.${METHOD} --outdir=${FS_OUT_DIR_INIT} \
configs/example/fs.py \
--kernel /home/data/ChenRuiyang/gem5/full_system_images/binaries/vmlinux.arm64 \
--disk-image /home/data/ChenRuiyang/gem5/full_system_images/disks/ubuntu-18.04-arm64-docker.img \
--bootloader /home/data/ChenRuiyang/gem5/full_system_images/binaries/boot.arm64 \
--param "system.highest_el_is_64 = True" \
--cpu-type=NonCachingSimpleCPU \
--mem-type DDR3_2133_8x8 --mem-size 16GB \
--cpu-clock=2.5GHz --num-cpu 1 \
--l2-hwp-type \
StridePrefetcher --script ${FS_COMMAND};
build/${ARCH}/gem5.${METHOD} --outdir=${FS_OUT_DIR_INIT} \
configs/example/fs.py \
--kernel /home/data/ChenRuiyang/gem5/full_system_images/binaries/vmlinux.arm64 \
--disk-image /home/data/ChenRuiyang/gem5/full_system_images/disks/ubuntu-18.04-arm64-docker.img \
--bootloader /home/data/ChenRuiyang/gem5/full_system_images/binaries/boot.arm64 \
--param "system.highest_el_is_64 = True" \
--checkpoint-dir ${FS_OUT_DIR_INIT} -r 1 \
--simpoint-profile --simpoint-interval ${interval_length} \
--cpu-type=NonCachingSimpleCPU \
--mem-type DDR3_2133_8x8 --mem-size 16GB \
--cpu-clock=2.5GHz --num-cpu 1 \
--l2-hwp-type \
StridePrefetcher;
else
echo SE_OR_FS should be SE or FS 
fi

