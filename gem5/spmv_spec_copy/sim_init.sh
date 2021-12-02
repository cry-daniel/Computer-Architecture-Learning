#!/bin/bash

. ./configs/configs_$1.sh

cd ${GEM5_PATH}

if [ ${SE_OR_FS} == SE ];then 
build/${ARCH}/gem5.${METHOD} --outdir=${SE_OUT_DIR_INIT} \
configs/example/se.py \
--simpoint-profile --simpoint-interval ${interval_length} \
--cpu-type=NonCachingSimpleCPU \
--cpu-clock 3.1GHz \
--num-cpu 1 \
--mem-type DDR4_2400_8x8 --mem-size 16GB \
-c ${SE_ELF_ROUTE} \
-o ${SE_INPUT_ROUTE} \
--param 'system.cpu[:].isa[:].sve_vl_se = 4'
elif [ ${SE_OR_FS} == FS ];then 
rm -r ${FS_OUT_DIR_INIT};
build/${ARCH}/gem5.${METHOD} --outdir=${FS_OUT_DIR_INIT} \
configs/example/fs.py \
--kernel ~/ChenRuiyang/gem5/full_system_images/binaries/vmlinux.arm64 \
--disk-image ~/ChenRuiyang/gem5/full_system_images/disks/ubuntu-18.04-arm64-docker.img \
--bootloader ~/ChenRuiyang/gem5/full_system_images/binaries/boot.arm64 \
--param "system.highest_el_is_64 = True" \
--cpu-type=NonCachingSimpleCPU \
--mem-type DDR4_2400_8x8 --mem-size 16GB \
--cpu-clock=3.1GHz --num-cpu 1 \
--param 'system.sve_vl = 4' --script ${FS_COMMAND};
build/${ARCH}/gem5.${METHOD} --outdir=${FS_OUT_DIR_INIT} \
configs/example/fs.py \
--kernel ~/ChenRuiyang/gem5/full_system_images/binaries/vmlinux.arm64 \
--disk-image ~/ChenRuiyang/gem5/full_system_images/disks/ubuntu-18.04-arm64-docker.img \
--bootloader ~/ChenRuiyang/gem5/full_system_images/binaries/boot.arm64 \
--param "system.highest_el_is_64 = True" \
--checkpoint-dir ${FS_OUT_DIR_INIT} -r 1 \
--simpoint-profile --simpoint-interval ${interval_length} \
--cpu-type=NonCachingSimpleCPU \
--mem-type DDR4_2400_8x8 --mem-size 16GB \
--cpu-clock=3.1GHz --num-cpu 1 \
--param 'system.sve_vl = 4';
else
echo SE_OR_FS should be SE or FS 
fi

