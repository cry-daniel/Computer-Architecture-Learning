#!/bin/bash

. ./configs/configs_$1.sh $2

cd ${GEM5_PATH}

if [ ${SE_OR_FS} == SE ];then
rm -r ${SE_OUT_DIR_CHECKPOINT};
build/${ARCH}/gem5.${METHOD} --outdir=${SE_OUT_DIR_CHECKPOINT} \
configs/example/se.py \
--cpu-clock 2.5GHz \
--num-cpu 1 \
--caches --l2cache --l1i_size 64kB --l1d_size 32kB --l2_size 1MB \
--l1i_assoc 8 --l1d_assoc 8 --l2_assoc 16 --cacheline_size 128 \
--mem-type DDR3_2133_8x8 --mem-size 16GB \
--take-simpoint-checkpoint=${SE_simpoint_file_path},${SE_weight_file_path},${interval_length},${warmup_length} \
--cpu-type=AtomicSimpleCPU \
-c ${SE_ELF_ROUTE} \
-o "${SE_INPUT_ROUTE}${OPTIONS}" \
--l2-hwp-type \
StridePrefetcher
elif [ ${SE_OR_FS} == FS ];then
rm -r ${FS_OUT_DIR_CHECKPOINT} 
build/${ARCH}/gem5.${METHOD} --outdir=${FS_OUT_DIR_CHECKPOINT} \
configs/example/fs.py \
--kernel /home/data/ChenRuiyang/gem5/full_system_images/binaries/vmlinux.arm64 \
--disk-image /home/data/ChenRuiyang/gem5/full_system_images/disks/ubuntu-18.04-arm64-docker.img \
--bootloader /home/data/ChenRuiyang/gem5/full_system_images/binaries/boot.arm64 \
--param "system.highest_el_is_64 = True" \
--checkpoint-dir ${FS_OUT_DIR_INIT} -r 1 \
--take-simpoint-checkpoint=${FS_simpoint_file_path},${FS_weight_file_path},${interval_length},${warmup_length} \
--cpu-type=AtomicSimpleCPU \
--mem-type DDR3_2133_8x8 --mem-size 16GB \
--cpu-clock=2.5GHz --num-cpu 1 --caches --l2cache \
--l1i_size 64kB --l1d_size 32kB --l2_size 1MB --l1i_assoc 8 \
--l1d_assoc 8 --l2_assoc 16 --cacheline_size 128 \
--l2-hwp-type \
StridePrefetcher --script ${FS_COMMAND};
else
echo SE_OR_FS should be SE or FS 
fi

