#Gem5 采用 SE 验证 FS 下程序运行时间的正确性

---

参考了 gem5.org ,
https://www.gem5.org/documentation/general_docs/m5ops/
以及 MB2020-HiPEAC_20201-gem5-sve-hands-on.pdf

*Copy right by ChenRuiyang*

---

##前言
+   在 gem5_FS_arm_linux.md 中做过一个程序的测试，当时是用C++的ctime在程序内进行计时，该程序的运行结果如下所示：
    ```bash
    root@aarch64-gem5:/mountfile# ./test2_static 
    10000
    0
    5000
    1000
    6000
    2000
    7000
    3000
    8000
    4000
    9000
    Total time:0.000836
    Total time:0.836ms
    ```
+   现在遇到了这样的一个问题，如何验证上面程序时间是真实的时间？验证时间的一个策略是在不同的环境下运行同一个可执行程序，但是限于处理器架构不同（本机是X86，而FS下的linux是arm），就需要一个新的方法.
+   一个很合理的想法是借助gem5的SE模式进行验证，SE模式下可以选择build/ARM/gem5.opt，这样运行的结果就是arm架构下的结果，此外，也可以选择和FS相同的CPU进行验证，保证结果的可靠性.

##SE模式下进行模拟
+   首先需要编写一个测试程序，在这里需要注意，SE模式下不支持 ctime 以及 openmp ，所以无法在程序内部调用计时函数以及采用并行编程.不过gem5会将程序运行的结果存在~/gem5/m5out文件夹中，可以通过查看stats.txt来得到程序运行的时间.
+   编写的测试程序如下所示：
    ```cpp
    test.cpp
    #include <iostream> 
    #include <cstdlib>

    using namespace std;

    long long N = 1e5;

    int main()
    {

        for (int i=0; i<N; i++) 
        {
            if(!(i%(N/10))) cout << i <<endl;
        }

        return 0;
    }
    ```
    该程序的目的是输入N，执行N次循环，每${\frac{N}{10}}$输出一次当前值.
+   我们为了得到自己希望得到的结果，例如在上面的程序中，希望得到执行循环部分所用时间，而忽视Input的时间，就要采用 m5ops 中的函数。对于C++而言，标准库肯定是不包含 m5ops.h 以及内部的函数实现，所以首先我们需要执行命令:
    ```bash
    cd ~/gem5/util/m5
    scons build/arm/out/m5
    ```
    在scons target done后，在 ~/gem5/util/m5/build/arm/out 文件夹内应该有 libm5.a 以及 m5 两个文件. 
    注：如果没有 libm5.a 尝试以下命令：
    ```bash
    cd ~/gem5/util/m5
    scons build/arm/out/libm5.a
    ```
+   完成库函数的配置之后，对之前的测试程序加以修改：
    ```cpp
    test.cpp
    #include <iostream> 
    #include <cstdlib>
    #include "gem5/m5ops.h" //add

    using namespace std;

    long long N = 1e5;

    int main()
    {

        m5_reset_stats(0,0); //add

        for (int i=0; i<N; i++) 
        {
            if(!(i%(N/10))) cout << i <<endl;
        }

        m5_dump_stats(0,0); //add

        return 0;
    }
    ```
    注意到在 #include 时增加了 "gem5/m5ops.h" ，而这个很明显是本来不在 include path 的路径上的，所以在编译时，需要添加 "-I ～gem5/include"  以及 "-L ~gem5/util/m5/build/aarch64/out -lm5" ，最终的编译命令如下所示：
    ```bash
    cd ~/gem5/mountfile
    arm-linux-gnueabi-g++ test.cpp -o test -I ~/gem5/include/  -L ~/gem5/util/m5/build/arm/out -lm5 -static
    ```
    注：test.cpp是位于~/gem5/mountfile下的.
    在SE模式下进行模拟：
    ```bash
    build/ARM/gem5.opt \
    configs/example/se.py \
    --cpu-type AtomicSimpleCPU \
    --cmd mountfile/test
    ```
+   在模拟结束之后，打开~/gem5/m5out中的 stats.txt ，结果如下：
    ```
    ---------- Begin Simulation Statistics ----------
    simSeconds                                   0.016021                       # Number of seconds simulated (Second)
    simTicks                                  16021070000                       # Number of ticks simulated (Tick)
    finalTick                                 16055963500                       # Number of ticks from beginning of simulation (restored from checkpoints and never reset) (Tick)
    simFreq                                  1000000000000                       # The number of ticks per simulated second ((Tick/Second))
    hostSeconds                                     15.08                       # Real time elapsed on the host (Second)
    hostTickRate                               1062142656                       # The number of ticks simulated per host second (ticks/s) ((Tick/Second))
    ……
    ```
    在这里对几个重要的变量进行解释：
    1.  "simSeconds"的含义是从"m5_reset_stats(0,0);" 到 "m5_dump_stats(0,0);" 之间程序所执行的时间（单位 s），注意，这里的时间是模拟上述程序在arm架构下运行完的时间，而不是真实世界里我们等待SE里结束的时间.
    2.  "simTicks"与"finalTick"的区别在于simTicks是从"m5_reset_stats(0,0);" 到 "m5_dump_stats(0,0);" 之间经历的Tick；而finalTick则是程序从头至尾运行经历的总Tick.
    3.  "hostSeconds"是我们在SE模式下等待程序运行完成的时间，是真实世界流逝的时间。例如上个程序可能一般情况下 0.16021s 就运行完成了，但是SE模式下程序运行的速度很慢（因为要模拟数量较多的硬件），我们要等 15.08s 程序才能跑完， 0.16021s 是 "simSeconds" ， 15.08s 则是 "hostSeconds" .

##验证FS的结果
+   验证程序如下所示：
    ```cpp
    test_FS.cpp
    #include <iostream> 
    #include <cstdlib>
    #include <ctime>

    using namespace std;

    long long N = 1e5;

    clock_t start,End;

    int main()
    {
        start = clock();

        for (int i=0; i<N; i++) 
        {
            if(!(i%(N/10))) cout << i <<endl;
        }
        
        End = clock();

        double endtime=(double)(End-start)/CLOCKS_PER_SEC;
        cout<<"Total time:"<<endtime<<endl;		//s为单位
        cout<<"Total time:"<<endtime*1000<<"ms"<<endl;

        return 0;
    }
    ```
+   在FS下执行下列命令：
    ```bash
    build/ARM/gem5.opt configs/example/fs.py --kernel vmlinux.arm64 --disk-image ubuntu-18.04-arm64-docker.img --bootloader ~/gem5/system/arm/bootloader/arm64/boot.arm64 --param "system.highest_el_is_64 = True" --cpu-type AtomicSimpleCPU
    ```
    运行结果如下：
    ```bash
    root@aarch64-gem5:/mountfile# time ./test_FS
    0
    10000
    20000
    30000
    40000
    50000
    60000
    70000
    80000
    90000
    Total time:0.016094
    Total time:16.094ms

    real	0m0.017s
    user	0m0.017s
    sys	0m0.000s
    ```
+   上面的运行结果分两部分，一部分是采用程序内部ctime计时，结果为 0.016094s ; 一部分是采用 time 命令直接在系统层面计时，结果为 0m0.017s （注：这个时间是user的时间，也就是程序从头到尾执行完毕的时间）.
+   因为time计时包括的除了我们期望的循环部分，还有变量预处理以及return 0等过程，故时间应该大于ctime得到的时间.
+   将在SE模式下得到的时间 0.016021s 与FS模式下程序内部计时的时间 0.016094s 进行比较，误差为 0.4% ，考虑到一次运行结果具有偶然性，后又多次运行进行比较，误差均小于 1% ，故验证了FS模式下程序内部计时所得时间的合理性.

##小结
+   这份报告记录了通过SE模式下的 m5ops 验证FS模式下 ctime 计时的过程，并通过多次实验以及结果的误差分析最终得到了FS模式下程序内部计时所得时间的合理性.
+   这次实验最大的收获在于学会了使用 m5ops 中的函数，并初步了解了checkpoint的机制（在下篇报告会提到使用checkpoint获取我们期望得到的信息），此外，对m5out中统计数据的认识使得以后的学习研究更加便捷.
+   这篇报告没有讨论多线程编成的情况，是因为SE模式下不支持openmp，查阅相关资料后发现，SE模式下要想做到多线程一个方法是用"m5threads"，另一个方法是在执行时加上后缀 --param "system.cpu[:].isa[:].sve_vl_se = ${sve_vl}" ，但考虑到并不清楚他们的执行机理，若采用他们进行多线程的验证，就不符合控制变量的思想，遂未验证多线程情况下FS内运行时间的准确性. gem5_FS_arm_linux.md 曾讨论过多线程时间的问题，如果单线程（上文所做的实验都是单线程的）的时间是合理的，那么我们有理由相信多线程的时间也具有合理性.