#Gem5 利用 Checkpoints 进行FS中断与加载实验记录
---
参考了 gem5.org

*Copy right by ChenRuiyang*

---

##前言
+   在使用GEM5的FS进行仿真时，会发现程序执行的速度较我们在ubuntu下执行的速度要慢很多，如果我们要对一个很复杂的程序进行调试，例如在程序中间检查一个变量的值或者在某个语句后更换CPU模型进行模拟，我们不可能每次都要重新运行一遍程序，因为一次时间开销就很大，多次运行那时间的浪费太多了.所以，我们要希望有一个办法可以保存当前的状态，以等待下一次启动FS时可以继续执行.这时候我们就需要checkpoint的帮助了，checkpoint可以帮助我们在FS仿真时插入断点，其原理是会在m5out文件夹里生成一个名为 cpt.XXX 的文件，那个文件存储的是在第 XXX 个 tick ，FS对应的状态，在下次运行时我们只需要在命令行加上对应的命令即可从上一个checkpoint继续加载.
+   下文将讨论两种情况下的checkpoint及其恢复：第一种情况是程序与程序之间的，第二种情况是在一个程序内部的。第一种很好理解，比如现在有两个程序，我们对这两个程序要分别使用两种CPU模型进行测试，但是我们希望得到的数据是两者汇总的数据，这个时候我们就可以使用第一种CPU运行完第一个程序后并设置checkpoint，再切换另一个CPU运行第二个程序.第二种情况可以举一个这样的例子，有一个程序运行时间特别久，但我想在它执行到某一条语句后，查看FS在那个时间的各个硬件数据，并在下一次运行时可以继续执行那个程序的剩余部分.

##程序与程序之间的checkpoint
+   假设现在需要在两种CPU下运行同一个程序，其中第一个要在atomicCPU下运行，第二个要在TimingCPU下运行.
+   首先进入FS
    ```bash
    cd ~/gem5
    build/ARM/gem5.opt configs/example/fs.py --kernel vmlinux.arm64 --disk-image ubuntu-18.04-arm64-docker.img --bootloader ~/gem5/system/arm/bootloader/arm64/boot.arm64 --param "system.highest_el_is_64 = True" --dtb-filename ~/gem5/system/arm/dt/armv8_gem5_v1_2cpu.dtb --cpu-type AtomicSimpleCPU
    ```
    ```bash
    cd ~/gem5/util/term
    ./m5term 127.0.0.1 3456
    ```
    在FS下的linux输入如下命令：
    ```bash
    cd /mountfile
    ./test
    m5 checkpoint
    m5 exit
    ```
    此时第一个终端会出现以下输出：
    ```bash
    Writing checkpoint
    info: Entering event queue @ 20642618090000.  Starting simulation...
    ```
    而在~/gem5/m5out下出现了一个名为 cpt.20642618090000 的文件夹，这个文件夹内存放的就是我们恢复checkpoint所需要的数据.
    执行命令：
    ```bash
    build/ARM/gem5.opt configs/example/fs.py --kernel vmlinux.arm64 --disk-image ubuntu-18.04-arm64-docker.img --bootloader /home/daniel/gem5/system/arm/bootloader/arm64/boot.arm64 --param 'system.highest_el_is_64 = True' --dtb-filename /home/daniel/gem5/system/arm/dt/armv8_gem5_v1_2cpu.dtb --cpu-type TimingSimpleCPU -r 1
    ```
    注意恢复checkpoint我们需要在后缀加上 -r N，其含义为 --checkpoint-restore=N ，N是按照m5out文件夹里 cpt.XXX 中 XXX 的大小的顺序来定的，一般来说是从小往大的顺序. 例如现在有 cpt.1234 和 cpt.1111 ，我们要恢复 cpt.1234 ，那么后缀就应该是 -r 2 .
    执行完毕之后我们会非常快速的回到checkpoint断点的位置，即终端显示如下：
    ```bash
    daniel@daniel-ThinkPad-X1-Carbon-7th:~/gem5/util/term$ ./m5term localhost 3456
    ==== m5 terminal: Terminal 0 ====
    root@aarch64-gem5:/mountfile# 
    ```
    接下来尝试在TimingSimpleCPU下运行程序：
    ```bash
    root@aarch64-gem5:/mountfile# time ./test
    0
    1000
    2000
    3000
    4000
    5000
    6000
    7000
    8000
    9000

    real	0m0.267s
    user	0m0.178s
    sys	0m0.086s
    ```
    与AtomicSimpleCPU对比：
    ```bash
    root@aarch64-gem5:/mountfile# time ./test
    0
    1000
    2000
    3000
    4000
    5000
    6000
    7000
    8000
    9000

    real	0m0.002s
    user	0m0.002s
    sys	0m0.000s
    ```
    AtomicSimpleCPU的速度显然快得多.
    关于两者的其他数据详见m5out中的stats.txt，在此不多赘述.

##程序内部的checkpoint
+   这个假设不太合理，但我们为了清晰的阐述程序内checkpoint的机制还是用这个假设：现在有一个程序叫test3，我们需要在test3某条语句之后设置一个checkpoint，也就是下次可以从那条语句之后执行，之前的都不用执行了.
+   写出如下的test3:
    ```cpp
    test3
    #include <iostream> 
    #include <cstdlib>
    #include "gem5/m5ops.h"

    using namespace std;

    long long N = 1e4;

    int main()
    {
        
        for (int i=0; i<2*N; i++) 
        {
            if(!(i%(N/10))) cout << i+1 <<endl;
        }

        m5_checkpoint(0,0);

        for (int i=0; i<N; i++) 
        {
            if(!(i%(N/10))) cout << i <<endl;
        }

        m5_dump_stats(0,0);

        return 0;
    }
    ```
    test3首先是输出1~19001（步长为1000），随后有一条语句 m5_checkpoint(0,0) ，我们使用这条语句设置间断点，在间断点后我们一次输出0~9000（步长为1000）.
    输入命令
    ```bash
    build/ARM/gem5.opt configs/example/fs.py --kernel vmlinux.arm64 --disk-image ubuntu-18.04-arm64-docker.img --bootloader ~/gem5/system/arm/bootloader/arm64/boot.arm64 --param "system.highest_el_is_64 = True" --dtb-filename ~/gem5/system/arm/dt/armv8_gem5_v1_2cpu.dtb --cpu-type AtomicSimpleCPU
    ```
    在FS下的linux输入以下命令
    ```bash
    cd /mountfile
    ./test3
    ```
    输出以下结果
    ```bash
    root@aarch64-gem5:/mountfile# ./test3
    1
    1001
    2001
    3001
    4001
    5001
    6001
    7001
    8001
    9001
    10001
    11001
    12001
    13001
    14001
    15001
    16001
    17001
    18001
    19001
    0
    1000
    2000
    3000
    4000
    5000
    6000
    7000
    8000
    9000
    ```
    这里注意到，在程序运行时虽然在19001后并没有终止，但是在19001后第一个终端出现了如下输出：
    ```bash
    Writing checkpoint
    info: Entering event queue @ 21338047770000.  Starting simulation...
    ```
    这便意味着checkpoint的机制仅仅为将checkpoint这个时刻的数据备份，并不会真正中断模拟的进行.
    为了测试checkpoint的机制，再执行以下命令：
    ```bash
    build/ARM/gem5.opt configs/example/fs.py --kernel vmlinux.arm64 --disk-image ubuntu-18.04-arm64-docker.img --bootloader ~/gem5/system/arm/bootloader/arm64/boot.arm64 --param "system.highest_el_is_64 = True" --dtb-filename ~/gem5/system/arm/dt/armv8_gem5_v1_2cpu.dtb --cpu-type AtomicSimpleCPU -r 2
    ```
    注：这里需要像上面一样关注是-r 1还是-r 2,也就是 cpt.XXX 小的要在前面.
    执行结果如下：
    ```bash
    daniel@daniel-ThinkPad-X1-Carbon-7th:~/gem5/util/term$ ./m5term localhost 3456
    ==== m5 terminal: Terminal 0 ====
    0
    1000
    2000
    3000
    4000
    5000
    6000
    7000
    8000
    9000
    ```
    非常神奇的只执行了checkpoint之后的语句.

##小结
+   之前举的例子可能不太恰当，现在看来checkpoint机制的引入可能是为了更加快速的恢复checkpoint之前的工作状态，并且得到checkpoint之后的数据，因为在test3程序中一般执行checkpoint之后的指令时间为 0.001575s ，我们从checkpoint载入后stats.txt显示时间为 0.001569s ，数据在5%的置信区间内；而checkpoint之前执行的指令所需时间为上述时间的两倍，故不在统计的时间里面. 综上所述，checkpoint机制可以用于FS下获取指定程序（段）的信息.