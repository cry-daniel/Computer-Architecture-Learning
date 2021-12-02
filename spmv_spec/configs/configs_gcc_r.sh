#!/bin/bash

SH_ROUTE=/home/data/ChenRuiyang/sh_command/spmv_spec
REC_ROUTE=/home/data/ChenRuiyang/time_rec

GEM5_PATH=/home/data/ChenRuiyang/gem5
ARCH=ARM
METHOD=fast

SE_OR_FS=SE # FS/SE 改这个
FS_COMMAND=/home/data/ChenRuiyang/sh_command/spmv_spec/run.sh

SE_NAME=spec17_gcc #改这个
FS_NAME=spmv

SPEC_ROUTE=/home/data/ChenRuiyang/spec17/benchspec/CPU

SE_ELF_ROUTE=${SPEC_ROUTE}/502.gcc_r/exe/cpugcc_r_base.mytest-64 # 改这个
SE_INPUT_ROUTE=${SPEC_ROUTE}/502.gcc_r/data/test/input/t1.c # 改这个
OPTIONS=' -O3 -finline-limit=50000 -o '$1't1.opts-O3_-finline-limit_50000.s' # 改这个

interval_length=10000000
warmup_length=1000000

# 后面都是基本上不用改的

SE_OUT_DIR_NORMAL=m5out/${SE_NAME}_normal
FS_OUT_DIR_NORMAL=m5out/${FS_NAME}_normal

SE_OUT_DIR_INIT=m5out/${SE_NAME}_init
FS_OUT_DIR_INIT=m5out/${FS_NAME}_init

SE_OUT_GENE=${SE_NAME}_gene
FS_OUT_GENE=${FS_NAME}_gene

SE_OUT_DIR_CHECKPOINT=m5out/${SE_NAME}_checkpoint
FS_OUT_DIR_CHECKPOINT=m5out/${FS_NAME}_checkpoint

SE_OUT_DIR_O3=m5out/${SE_NAME}_O3
FS_OUT_DIR_O3=m5out/${FS_NAME}_O3

SE_simpoint_file_path=/home/data/ChenRuiyang/SimPoint.3.2/output/gem5/${SE_NAME}_simpoint_file
SE_weight_file_path=/home/data/ChenRuiyang/SimPoint.3.2/output/gem5/${SE_NAME}_weight_file

FS_simpoint_file_path=${GEM5_PATH}/m5out/${FS_OUT_GENE}/simpoint_file
FS_weight_file_path=${GEM5_PATH}/m5out/${FS_OUT_GENE}/weight_file