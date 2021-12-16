#Gem5 测试 Checkpoints 对指定区域进行debug打印

---

参考了 gem5.org

*Copy right by ChenRuiyang*

---

##前言
+   上一篇实验报告（gem5_checkpoint）简单介绍了gem5中checkpoint的使用，但并没有对其获取的信息进行检验，这篇报告将继续上一篇的工作，测试checkpoint从指定区域或取debug信息的准确性.
    注：debug信息包括CPU信息，MEM信息，程序运行时间等.
+   这篇实验报告除了测试正确性之外，也提供了采用checkpoint进行debug的多种策略，可以根据不同的环境灵活调整.
+   这篇报告将讨论以下几种类型的debug打印：
    1.  运行一个程序中的某个代码段，例如一个for循环，或者从语句A到语句B.
    2.  运行一个完整程序的debug打印.
    3.  运行多个完整程序的debug打印.

##前期准备
+   在进行测试之前，需要先将测试程序进行在SE模式下运行，以获得参考的debug数据.
+   测试的程序有3个，分别为test、test2和test3.其中：
    +   test程序首先执行2e4次循环，随后执行1e4次循环，最后执行3e4次循环，每个循环内每执行十分之一会输出一次当前值.
    +   test2程序首先执行1e4次循环，随后执行2e4次循环，最后执行3e4次循环，每个循环内每执行十分之一会输出一次当前值.
    +   test3程序首先执行2e4次循环，随后执行1e4次循环，最后执行3e4次循环，每个循环内每执行十分之一会输出一次当前值，但第一个循环的输出值初始值为1. 且test3是在程序内采用checkpoint. 
+   测试采用的CPU均为AtomicSimpleCPU,MEM类型为SimpleMemory；程序源代码详见附录.
+   测试命令如下（以test2为例，test3只需要改名字）：
    ```bash
    build/ARM/gem5.opt \
    configs/example/se.py \
    --cpu-type AtomicSimpleCPU \
    --mem-type SimpleMemory \
    --cmd mountfile/test2
    ```
+   test2测试结果如下（stats.txt in m5out）：
    ```bash
    ---------- Begin Simulation Statistics ----------
    simSeconds                                   0.003251                       # Number of seconds simulated (Second)
    simTicks                                   3251081000                       # Number of ticks simulated (Tick)
    finalTick                                  4824353000                       # Number of ticks from beginning of simulation (restored from checkpoints and never reset) (Tick)
    simFreq                                  1000000000000                       # The number of ticks per simulated second ((Tick/Second))
    hostSeconds                                      3.05                       # Real time elapsed on the host (Second)
    hostTickRate                               1066989119                       # The number of ticks simulated per host second (ticks/s) ((Tick/Second))
    hostMemory                                     280844                       # Number of bytes of host memory used (Byte)
    simInsts                                      8590739                       # Number of instructions simulated (Count)
    ……
    system.clk_domain.clock                          1000                       # Clock period in ticks (Tick)
    system.cpu.numCycles                          6502162                       # Number of cpu cycles simulated (Cycle)
    system.cpu.numWorkItemsStarted                      0                       # Number of work items this cpu started (Count)
    system.cpu.numWorkItemsCompleted                    0                       # Number of work items this cpu completed (Count)
    system.cpu.exec_context.thread_0.numInsts      5797784                       # Number of instructions committed (Count)
    ……
    system.mem_ctrls.bytesRead::cpu.inst         23191216                       # Number of bytes read from this memory (Byte)
    system.mem_ctrls.bytesRead::cpu.data          2824909                       # Number of bytes read from this memory (Byte)
    system.mem_ctrls.bytesRead::total            26016125                       # Number of bytes read from this memory (Byte)
    system.mem_ctrls.bytesInstRead::cpu.inst     23191216                       # Number of instructions bytes read from this memory (Byte)
    ……
    system.membus.snoop_filter.totSnoops                0                       # Total number of snoops made to the snoop filter. (Count)
    system.membus.snoop_filter.hitSingleSnoops            0                       # Number of snoops hitting in the snoop filter with a single holder of the requested data. (Count)
    system.membus.snoop_filter.hitMultiSnoops            0                       # Number of snoops hitting in the snoop filter with multiple (>1) holders of the requested data. (Count)
    system.voltage_domain.voltage                       1                       # Voltage in Volts (Volt)
    system.workload.inst.arm                            0                       # number of arm instructions executed (Count)
    system.workload.inst.quiesce                        0                       # number of quiesce instructions executed (Count)

    ---------- End Simulation Statistics   ----------

    ---------- Begin Simulation Statistics ----------
    ……
    ---------- End Simulation Statistics   ----------

    ---------- Begin Simulation Statistics ----------
    ……
    ---------- End Simulation Statistics   ----------
    ```
    在stats.txt中有多个Begin Simultaion与End Simulation，这是因为 "m5_dump_stats(0,0);" 会对stats.txt进行写入，每个写入会增加一组Begin - End，除了 "m5_dump_stats(0,0);" 会写入之外，程序运行完成（即 return 0; ）之后会自动再写入一组Begin - End.
    与此同时，stats.txt中还有程序运行数据（时间，tick等）、CPU的各项数据以及MEM的各项数据.
+   有了前面的铺垫，接下来就要讨论一下各种情况下的测试.

##得到一个程序中的某个代码段的debug数据
+   这个讨论需要分两种情况：
    1.  代码段不需要切换不同的CPU.
    2.  代码段需要切换不同的CPU.
+   不需要切换CPU的情况最为简单，**只需要在程序内部关注的代码段前后增加reset与dump指令即可，如果有多个代码段，就增加多组reset与dump**，其中reset是清空之前的数据，dump则是数据的写入. 
    +   下面举一个容易理解的例子：
        ```cpp
        m5_reset_stats(0,0);    //add

        for (int i=0; i<N; i++) 
        {
            if(!(i%(N/10))) cout << i <<endl;
        }

        m5_dump_stats(0,0);     //add
        ```
    +   在上面情况下，我们对执行for循环时的debug数据比较感兴趣，于是我们在前后分别加reset与dump命令，后面的两个参数第一个是delay（tick），第二个是period（tick），含义是延迟XXXtick进行reset与之后每XXXtick再次重复. 像m5_reset_stats(0,0)的意思就是在0个tick之后执行reset并每隔0个tick重复reset，即立即执行reset并在后续的tick不再重复.
    +   接下来在FS中运行test：
        ```bash
        cd /mountfile
        ./test
        ```
        当我们打开stats.txt时会很神奇的发现里面居然只有一组Begin - End，这便意味着写最后一组Begin - End的机制并不在程序一执行完就写入，而是在执行m5 exit退出时才写入（这个执行m5 exit就可以发现）.
    +   尝试运行test2:
        ```bash
        cd /mountfile
        ./test2
        ```
        打开stats.txt，完美出现2组Begin - End，并且每组里的数据都符合SE下的数据.
+   需要切换不同CPU，**只需要在程序内部关注的代码段前后增加checkpoint与dump指令即可，如果有多个代码段，就增加多组checkpoint与dump.**
    +   下面举一个容易理解的例子：
        ```cpp
        m5_checkpoint(0,0);    //add

        for (int i=0; i<N; i++) 
        {
            if(!(i%(N/10))) cout << i <<endl;
        }

        m5_dump_stats(0,0);     //add
        ```
        checkpoint后面的参数含义同dump.
    +   运行test3：
        ```bash
        cd /mountfile
        ./test3
        ```
        因为test3有两个m5_checkpoint，所以在m5out中会生成2个 opt.XXX ，我们可以从中选择其一切换CPU执行.
    +   切换CPU并获取数据：
        ```bash
        build/ARM/gem5.opt configs/example/fs.py --kernel vmlinux.arm64 --disk-image ubuntu-18.04-arm64-docker.img --bootloader ~/gem5/system/arm/bootloader/arm64/boot.arm64 --param "system.highest_el_is_64 = True" --dtb-filename ~/gem5/system/arm/dt/armv8_gem5_v1_2cpu.dtb --cpu-type TimingSimpleCPU -r 2
        ```
        查看stats.txt中的数据并与SE模式下进行验证，发现数据变为TimingSimpleCPU对应的数据.
        注：上面的变为与TimingSimpleCPU对应的数据的范围都是在checkpoint之后的，之前的没有影响.

##得到一个完整程序的debug数据
+   一种方法是使用如下命令：
    ```bash
    cd /mountfile
    m5 resetstats
    ./hello
    m5 dumpstats
    ```
    查看stats.txt即可获得对应信息.
+   不过极其极其不推荐这种方法，因为在m5 resetstats到m5 dumpstats之间的等待时间仍然会算在总时间里面. 这个与gem5的机制有关，gem5的时间单位是tick，在FS下就算你没有任何行动tick也是在增加的，就好比时间并不会因为你在睡觉而停止.
+   **一种可行的策略是写一个运行脚本:**
    ```
    configs/test.rcS:
    #!/bin/sh
    # Wait for system to calm down
    sleep 10
    # Take a checkpoint in 100000 ticks
    m5 checkpoint 100000
    # Reset the stats
    m5 resetstats
    # Run hello
    /mountfile/hello
    # Exit the simulation
    m5 exit
    ```
    在执行的时候加后缀--script=./configs/test.rcS
+   还有一种方法是**更改源文件**，用上文处理代码段的方法处理源文件，当然，这种方法更为简单，即：
    ```cpp
    ……
    #include <gem5/m5ops.h>

    int main(){
        m5_reset_stats(0,0);
        ……
        m5_dump_stats(0,0);
    }
    ```
    在编译时按gem5_checkpoint.md中的过程做即可.

##得到多个完整程序的debug数据
+   这个的方法只有写运行脚本了，举个例子：
    ```
    configs/test.rcS:
    #!/bin/sh
    # Wait for system to calm down
    sleep 10
    # Take a checkpoint in 100000 ticks
    m5 checkpoint 100000
    # Reset the stats
    m5 resetstats
    # Run hello
    /mountfile/hello
    /mountfile/hello2
    # Exit the simulation
    m5 exit
    ```
    在执行的时候加后缀--script=./configs/test.rcS
+   这个暂时没想到更好的办法，如果有好的想法欢迎讨论，不过一般来说需要测多个程序的情况不多，遇到要测多个的都是把单个的数据相加，似乎也可以，但是会麻烦很多.

##小结
+   这篇报告对讨论以下几种类型的debug打印进行了讨论：
    1.  运行一个程序中的某个代码段，例如一个for循环，或者从语句A到语句B.
    2.  运行一个完整程序的debug打印.
    3.  运行多个完整程序的debug打印.
+   其实如果只是单纯统计数据并不是很需要checkpoint，需要的是reset和dump，不过可能checkpoint是为了后续调试方便，所以在debug方式的讨论中我都加了checkpoint.
+   reset和dump并不是需要严格的一一对应，上文那么写是为了测试方便，实际情况下可以灵活调整的.
+   测试的结果是FS模式下通过上述方法得到的数据和SE模式下误差在5%以内，故认为是合理的.

---

##附录
+   test.cpp
    ```cpp
    #include <iostream> 
    #include <cstdlib>
    #include "gem5/m5ops.h"

    using namespace std;

    long long N = 1e4;

    int main()
    {
        
        for (int i=0; i<2*N; i++) 
        {
            if(!(i%(N/10))) cout << i <<endl;
        }

        m5_reset_stats(0,0);

        for (int i=0; i<N; i++) 
        {
            if(!(i%(N/10))) cout << i <<endl;
        }

        m5_dump_stats(0,0);

        for (int i=0; i<3*N; i++) 
        {
            if(!(i%(N/10))) cout << i <<endl;
        }

        return 0;
    }
    ```
+   test2.cpp
    ```cpp
    #include <iostream> 
    #include <cstdlib>
    #include "gem5/m5ops.h"

    using namespace std;

    long long N = 1e4;

    int main()
    {
        for (int i=0; i<N; i++) 
        {
            if(!(i%(N/10))) cout << i <<endl;
        }
        
        m5_reset_stats(0,0);

        for (int i=0; i<2*N; i++) 
        {
            if(!(i%(N/10))) cout << i <<endl;
        }

        m5_dump_stats(0,0);

        m5_reset_stats(0,0);

        for (int i=0; i<4*N; i++) 
        {
            if(!(i%(N/10))) cout << i <<endl;
        }

        m5_dump_stats(0,0);

        return 0;
    }
    ```
+   test3.cpp
    ```cpp
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

        m5_checkpoint(0,0);

        for (int i=0; i<4*N; i++) 
        {
            if(!(i%(N/10))) cout << i <<endl;
        }

        m5_dump_stats(0,0);

        return 0;
    }
    ```
+   编译命令（举个例子）：
    ```bash
    arm-linux-gnueabi-g++ test.cpp -o test -I ~/gem5/include/  -L ~/gem5/util/m5/build/arm/out -lm5 -static
    ```