# Gem5 使用 Simpoint 运行 SPEC17 实验记录
---
参考了 http://www.m5sim.org/SPEC_CPU2006_benchmarks 以及 https://cluelessram.blogspot.com/2017/10/using-simpoint-in-gem5-to-speed-up_11.html

*Copy right by ChenRuiyang*

---

## 前言
+   SPEC06 对 ARM 的支持不好，出了一些 bug ，就换成 SPEC17 了.
+   如果只关注 Simpoint 可以跳过 `SPEC17 准备工作`这一部分.
+   说到在 Gem5 中使用 Simpoint 的原因，就不得不提到 Gem5 的仿真速度，常规来讲 Gem5 中运行的程序会比程序正常运行的速度慢10000倍，例如一个1s的程序，Gem5可能就要10000s=2.78h，尤其是 SPEC17 这种大规模的测试程序，运行时间可能要以天计. 为此，我们会有一个很自然的想法，能否只运行一个程序的典型部分来加快程序的运行速度？
+   Simpoint 可以做到这一点，它对源代码进行抽样聚类，以加速后续执行。这里有个问题， Simpoint 是在运行完整个程序后得到聚类还是以一定策略跳跃选取 interval ，我在网上查看了一些资料，但没发现有说明这个的，暂时存疑.

## SPEC17准备工作
+   准备好 SPEC17 的iso文件，因为版权问题网上下载不了，但在 stu1 服务器上 /home/data/ChenRuiyang/SPEC_ISO 目录里有 cpu2017-1.0.2.iso ，用那个即可，详细安装过程参考 CSDN 这篇博文，在此不多赘述：
    https://blog.csdn.net/weixin_30648963/article/details/102273129 .
    ```bash
    sudo mount -t iso9660 -o ro,exec cpu2006.iso /mnt
    # 注：挂载用这个
    ```
+   SPEC06 编译时需要改配置文件，这里直接在 Example 上小改：
    ```bash
    cd speccpu2006/config
    scp Example-linux64-amd64-gcc41.cfg gcc41.cfg
    ```
    因为 Gem5 要求静态链接，并且我们是在 arm 下测试程序，所以要改一下 gcc41.cfg，把参数改成下面的即可：
    ```
    ...
    CC                 = aarch64-linux-gnu-gcc
    CXX                = aarch64-linux-gnu-g++
    sw_compiler        = aarch64-linux-gnu-gcc, aarch64-linux-gnu-g++,  & gfortran 4.1.2
    ...
    default=base=default=default:
    COPTIMIZE   = -O2 -static
    CXXOPTIMIZE = -O2 -static
    FOPTIMIZE   = -O2 -static
    ...
    ```
+   在 config 目录下运行下命令：
    `runspec --config=gcc41.cfg --action=build --tune=base --size=test bzip2`
    此处 `--size=test` 意味着采用最小测试集，bzip2为我们举例的测试集，可选取的测试集详见 `speccpu2006/benchspec/CPU2006` .
    注意：若此时出现 runspec 未定义的警告，需要运行下列命令
    ```bash
    cd speccpu2006
    source shrc
    ```
+   build 完成之后在`speccpu2006/benchspec/CPU2006/401.bzip2`下会出现 data 以及 exe 文件夹，代表成功.
    但是不是所有的测试程序都能用 runspec build 成功，部分程序可能因为与 arm-linux-gnu- 不兼容而失败.
+   对所有程序进行编译：
    `runspec --config=gcc41.cfg --action=build --tune=base all`
    all代表所有测试程序.
+   直接运行SPEC06：
    ```bash
    cd ../gem5 #此处改为GEM5的地址
    ./build/ARM/gem5.opt --outdir=m5out/spec06 \
    configs/example/se.py \
    -c ~/ChenRuiyang/spec06/benchspec/CPU2006/401.bzip2/exe/bzip2_base.armv7-gcc \
    -o ~/ChenRuiyang/spec06/benchspec/CPU2006/401.bzip2/data/ref/input/control
    ```
+   存在问题：
    +   benchmark运行时间太慢，时间远远超过在 gem5 给出的 spec06 每个样例程序的时间.
        可能原因：CPU不是Xeon.
+   需要做的事情：
    +   整理出gem5下simpoint的运行命令
    +   在服务器上用使用gem5直接跑测试集
    +   在服务器上用simpoint采点跑测试集
    +   比较两者的区别

## 安装Simpoint.3.2
+   第一步是下载Simpoint的源码，链接为：
    `https://cseweb.ucsd.edu/~calder/simpoint/releases/SimPoint.3.2.tar.gz`
    下载完成后解压缩
+   打开解压好的文件夹，这里要改部分文件
    `/config`文件夹中需要更改的内容如下,前面为需要更改的文件，后面为文件需要添加的内容：
    ```cpp
    cmdlineparser.cpp #include <cstring>
    utilities.h #include <climits> #include <cstdlib>
    datapoint.h #include <iostream>
    FVParser.cpp #include <cstring>
    ```
+   执行命令：
    `make CXXFLAGS='-std=c++03 -O1'`
    注意此处要加后缀，因为Simpoint是06年的，部分标准和现在不同，不加会导致出现编译错误.
+   编译完成后应能看到./simpoint文件

## 使用 GEM5 中的 Simpoint 相关命令
+   首先生成 Simpoint，采取命令如下：（注：这一步还没用到 Simpoint.3.2）
    ```bash
    cd ../gem5  #此处改为GEM5的地址
    ./build/ARM/gem5.opt --outdir=m5out/spec06_sim \
    configs/example/se.py \
    -c ~/ChenRuiyang/spec06/benchspec/CPU2006/401.bzip2/exe/bzip2_base.armv7-gcc \
    -o ~/ChenRuiyang/spec06/benchspec/CPU2006/401.bzip2/data/ref/input/control \
    --simpoint-profile --simpoint-interval 10000000 \
    --cpu-type=NonCachingSimpleCPU
    ```
    生成完成后会在 `gem5/m5out/spec06_sim` 文件夹下生成 `simpoint.bb.gz`，注意此处的`--cpu-type=NoCachingSimpleCPU`代表着 SimpleCPU + Fastmem.
+   生成了 simpoint.bb.gz 后，使用Simpoint工具进行切分：
    ```bash
    cd ~/ChenRuiyang/SimPoint.3.2/bin
    ./simpoint -loadFVFile ~/ChenRuiyang/gem5/m5out/spec06_sim/simpoint.bb.gz \
    -maxK 30 -saveSimpoints ../output/gem5/simpoint_file \
    -saveSimpointWeights ../output/gem5/weight_file \
    -inputVectorsGzipped
    ```
    "-maxK 30" 参数代表最大的聚类个数为30；在`~/ChenRuiyang/SimPoint.3.2/output/gem5`中会出现`simpoint_file 以及 weight_file`，其中第一个代表 Simpoint 所属的 interval，第二个代表每个 interval 的权重文件.
+   使用 GEM5 的 `--take-simpoint-checkpoint` 功能进行切分，具体命令如下：
    ```bash
    cd ../gem5
    simpoint_file_path=~/ChenRuiyang/SimPoint.3.2/output/gem5/simpoint_file
    weight_file_path=~/ChenRuiyang/SimPoint.3.2/output/gem5/weight_file
    exe_path=~/ChenRuiyang/spec06/benchspec/CPU2006/401.bzip2/exe/bzip2_base.armv7-gcc
    input_path=~/ChenRuiyang/spec06/benchspec/CPU2006/401.bzip2/data/ref/input/control
    interval_length=10000000
    warmup_length=1000000
    build/ARM/gem5.opt --outdir=m5out/spec06_take_simpoint \
    configs/example/se.py \
    --take-simpoint-checkpoint=${simpoint_file_path},${weight_file_path},${interval_length},${warmup_length} \
    --cpu-type=AtomicSimpleCPU -c ${exe_path} \
    -o ${input_path}
    ```
    执行此命令后在 `m5out/spec06_take_simpoint` 文件夹下可见名为：
    `cpt.simpoint_00_inst_509000000_weight_0.030661_interval_10000000_warmup_1000000`
    的 checkpoint 文件，其含义为第 00 个checkpoint 位于 509000000 tick 处，权重为 0.030661 ， interval 大小为 10000000 , warmup 大小为 1000000.
+   运行完成后
    ```bash
    cd ../gem5
    ./build/ARM/gem5.opt --outdir=m5out/spec06_restore \
    configs/example/se.py \
    --cpu-clock 3.1GHz --num-cpu 1 --caches --l2cache \
    --l1i_size 64kB --l1d_size 64kB --l2_size 1MB \
    --l1i_assoc 4 --l1d_assoc 4 --l2_assoc 4 \
    --cacheline_size 128 --mem-type DDR4_2400_8x8 \
    -c /home/stu1/ChenRuiyang/spec06/benchspec/CPU2006/401.bzip2/exe/bzip2_base.armv7-gcc \
    -o /home/stu1/ChenRuiyang/spec06/benchspec/CPU2006/401.bzip2/data/ref/input/control \
    --restore-simpoint-checkpoint -r 1 --checkpoint-dir m5out/spec06_take_simpoint \
    -I 10000000 --cpu-type=AtomicSimpleCPU \
    --restore-with-cpu=O3_ARM_v7a_3
    ```
## 后记
+   上面写的都是当时在做做实验时的不成熟的记录，详细的运行命令参见 /home/data/ChenRuiyang/sh_command/spmv_spec 中的 sh 文件.
+   另外后面决定暂时先不做 SEPC 17 了，先做 Graph500 ， SPEC 06/17 的坑等以后遇到再填吧.