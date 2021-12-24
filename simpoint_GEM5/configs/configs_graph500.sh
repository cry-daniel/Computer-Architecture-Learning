#!/bin/bash

#   这两个是给 process_sim.sh 写的，第一个对应写的脚本文件夹
#   的地址,第二个对应记录程序运行结果的地址，改成自己的地址即可
SH_ROUTE=/home/data/ChenRuiyang/sh_command/simpoint_GEM5
REC_ROUTE=/home/data/ChenRuiyang/time_rec

# 一般都是用 SE 做的， FS 对 Simpoint 的支持不太好
SE_OR_FS=SE 

# 下面是 GEM5 的一些基本参数
GEM5_PATH=/home/data/ChenRuiyang/gem5
ARCH=ARM
METHOD=fast

# CPU 的模型以及 CPU 的部分参数
CPU_PARM=\
"--cpu-type O3_ARM_v7a_3 \
--cpu-clock 2.5GHz \
--num-cpu 1"

# Cache 的参数
CACHE_PRAM=\
"--caches --l2cache --l1i_size 64kB \
--l1d_size 32kB --l2_size 1MB \
--l1i_assoc 8 --l1d_assoc 8 \
--l2_assoc 16 --cacheline_size 128"

# Memory 的参数
MEM_PRAM=\
"--mem-type DDR3_2133_8x8 --mem-size 16GB \
--l2-hwp-type StridePrefetcher"

# 下面的几个是每个新的 config 需要改的内容

# 这个对应的是后面输入与输出文件夹的名称前缀，每个新的 config 需要改一下
SE_NAME=graph500_s_13_e_12 

# 这个对应的是 Benchmark 的地址，每个新的 config 需要改一下
TEST_ROUTE=/home/data/ChenRuiyang/graph500-graph500-2.1.4/seq-csr

# 这个对应的是测试 ELF 的地址，每个新的 config 一般要改
SE_ELF_ROUTE=${TEST_ROUTE}/seq-csr

# 这个对应的是给 ELF 的输入文件的地址，Graph500 中还没用到输入文件，就先为空
# 这个是一般要改的
SE_INPUT_ROUTE= 

# 这个是传递给 ELF 的参数，等价与在 GEM5 外，命令行中 ELF 后的那些参数
# 在这个例子中就等价于 "{TEST_ROUTE}/seq-csr -s 13 -e 12"
# 这个是一般要改的
OPTIONS=' -s 13 -e 12' 

# Simpoint 的两个参数，这个一般不用改
interval_length=10000000
warmup_length=1000000

# 后面都是基本上不用改的

SE_OUT_DIR_NORMAL=m5out/${SE_NAME}_normal

SE_OUT_DIR_INIT=m5out/${SE_NAME}/${SE_NAME}_init

SE_OUT_DIR_CHECKPOINT=m5out/${SE_NAME}/${SE_NAME}_checkpoint

SE_OUT_DIR_O3=m5out/${SE_NAME}/${SE_NAME}_O3

SE_simpoint_file_path=/home/data/ChenRuiyang/SimPoint.3.2/output/gem5/${SE_NAME}/${SE_NAME}_simpoint_file
SE_weight_file_path=/home/data/ChenRuiyang/SimPoint.3.2/output/gem5/${SE_NAME}/${SE_NAME}_weight_file