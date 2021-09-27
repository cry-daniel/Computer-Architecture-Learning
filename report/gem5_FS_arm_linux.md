#Full system 模式运行 linux(arm) 实验记录
---
参考了 gem5.org 以及 doc_zhanglucheng_Full_System.md

*Copy right by ChenRuiyang*

---
##前期准备工作
  + 安装依赖(Ubuntu 20.XX)：
    ```
    sudo apt install build-essential git m4 scons zlib1g zlib1g-dev \
      libprotobuf-dev protobuf-compiler libprotoc-dev libgoogle-perftools-dev \
      python3-dev python3-six python-is-python3 libboost-all-dev pkg-config
    ```
  + 下载 gem5 源代码：
    推荐使用 gitee搜索gem5下载，官方的`git clone https://gem5.googlesource.com/public/gem5`命令需要科学上网（VPN）.
  + 解压缩文件至 ~/gem5.
    注：gitee下载压缩包需要解压，解压缩命令百度自查；直接clone的则跳过这一步.
  + 对arm架构使用scons命令进行build.
    ```bash
    cd ~/gem5
    scons build/ARM/gem5.opt -j9
    ```
    注：gem5里本来是没有build文件夹的，scons之后才有；-j9是为了加快编译速度，-j后的数字一般为你的CPU核心数+1，例如我的CPU是8核的，后面的数字就是8+1=9.
  + 上一步的编译时间一般较长，在等待时间可以提前下载arm_linux的kernel和image.
  `https://www.gem5.org/documentation/general_docs/fullsystem/guest_binaries`
  一般选择推荐的即可，下载完成后解压到 ~/gem5/full_system_images, 其中full_system_image是自己创建的存kernel和image的文件夹, XXX.img存在~/gem5/full_system_images/disk内.
  进入页面后可能出现点击链接无法下载的情况，复制链接新开一个页面粘贴链接即可下载，网速慢的话科学上网或者找找有没有国内的镜像.

##完善 Full System 依赖功能
  + 编译bootloader
    ```bash
    cd gem5
    make -C system/arm/bootloader/arm
    make -C system/arm/bootloader/arm64
    ```
    此时打开~/gem5/system/arm/bootloader/arm64会看到boot.arm64文件，后面我们会用它做bootloader.
  + 编译m5term
    ```bash
    cd ~/gem5/util/term
    make
    ```
    完成后会在对应文件夹内看到m5term. m5term将用来建立localhost与port间的联系，简单来说，就是建立full system模拟的linux与本机的联系.
  + 添加M5_PATH
    出于方便起见，避免每次使用都要export，将M5_PATH写到.bashrc里面.
    ```bash
    cd ~
    gedit .bashrc
    ```
    在.bashrc中添加
    ```bash
    export M5_PATH=$M5_PATH:~/gem5/full_system_images
    ```
    应用更改
    ```bash
    source .bashrc
    ```
    此时可以使用下述命令检查是否更改成功：
    ```bash
    echo $M5_PATH
    ```
    如若之前曾经设置过M5_PATH，即echo显示的M5_PATH有多个路径，采用下述命令即可：
    ```bash
    unset M5_PATH
    source .bashrc
    echo $M5_PATH
    ```
  + 更改 SysPaths.py 中的路径
    ```bash
    cd ~/configs/common
    gedit SysPaths.py
    ```
    将第51行(expect KeyError: 后的那条语句)改成：
    ```bash
    paths = [ '~/gem5/full_system_images', '/n/poolfs/z/dist/m5/system' ]
    ```
    主要改的是前面那个地址，目的是给FS做检索.
  + 试运行FS
    首先打开一个终端（叫它终端1）
    ```bash
    cd ~/gem5
    build/ARM/gem5.opt configs/example/fs.py --kernel vmlinux.arm64 --disk-image ubuntu-18.04-arm64-docker.img --bootloader ~/gem5/system/arm/bootloader/arm64/boot.arm64 --param "system.highest_el_is_64 = True" 
    ```
    另起一个终端（叫它终端2）
    ```bash
    cd ~/gem5/util/term
    sudo ./m5term localhost 3456
    ```
    等待几分钟后加载完成，即可在终端2运行FS模拟的linux，输入help即可查看可用命令.
    注：
    1. 'localhost'后的'3456'是第一个默认端口，若再起终端3则可用'3457'，详见终端1有关输出.
    2. 在终端2中执行'ls'命令可能会出现没有文件的情况，此时不要慌张，检查当前的目录是~还是/， 如果是~，执行 `cd / ` 切换到根目录再ls即可.

##向linux内部添加文件
  + 首先需要建立img与本机之间的关系，本文采用的是linux的mount命令.
    ```bash
    cd ~/gem5
    sudo util/gem5img.py mount full_system_images/disks/ubuntu-18.04-arm64-docker.img ~/mnt
    ```
    mount指令执行之后即建立了aarch64-ubuntu-trusty-headless.img和~/mnt之间的联系，对img的所有操作（例如删除或添加文件都可以cd到 ~/mnt进行）.
  + 添加文件
    ```bash
    cd ~/gem5
    sudo scp -r mountfile ~/mnt
    ```  
    scp是linux中的复制命令，-r代表将整个文件夹全部复制；mountflie是我存放已编译好的程序的文件夹，位置是~/gem5/mountfile，有关mountfile内的源文件以及编译后文件请见附录.
  + 在文件复制完成后img里实际就已经同步了我们所复制的文件，此时输入
    ```bash
    cd ~/gem5
    sudo util/gem5img.py umount ~/mnt
    ```
    img和我们~/mnt文件夹的联系到此就解除啦.
  + 在FS中尝试运行我们同步的文件
    首先启动系统
    ```bash
    cd ~/gem5
    build/ARM/gem5.opt configs/example/fs.py --kernel vmlinux.arm64 --disk-image ubuntu-18.04-arm64-docker.img --bootloader ~/gem5/system/arm/bootloader/arm64/boot.arm64 --param "system.highest_el_is_64 = True"
    ```
    ```bash
    cd ~/gem5/util/term
    sudo ./m5term localhost 3456
    ```
    等待系统加载完成后
    ```bash
    cd /mountfile
    ./hello_par_static
    ```
    系统输出
    ```bash
    root@aarch64-gem5:/mountfile# ./test_par_static 
    0123456789
    ```
    成功输出结果，但程序似乎是被串行执行的，因为按照附录hello_par.cpp的程序，多线程执行下输出应该是乱序的.在下面的拓展部分中，将会证明按照之前那么做程序只是单线程执行的，并给出了多线程执行的方法.

##拓展
  + 之前在FS下执行多线程程序最多只能有一个线程，采用测试程序输出如下所示：
    ```bash
    root@aarch64-gem5:/mountfile# ./hello_par_static 
    Hello World from thread = 0
    Number of threads = 1
    ```
  + 解决这个问题的方法是编译device tree文件，即给gem5指定硬件（例如即将用到的多核CPU）
    ```bash
    cd ~/gem5/system/arm
    make -C dt
    ```
    等待编译完成后，文件夹出现很多以.dtb为后缀的文件，其含义是device tree binaries，即device tree的二进制文件。此处注意，原来有的以.dts为后缀的文件是编译前的源文件，计算机没有办法直接读，要将其编译为.dtb的二进制文件后才能读取。
  + 有了device tree后原命令变成
    ```bash
    cd ~/gem5
    build/ARM/gem5.opt configs/example/fs.py --kernel vmlinux.arm64 --disk-image ubuntu-18.04-arm64-docker.img --bootloader ~/gem5/system/arm/bootloader/arm64/boot.arm64 --param "system.highest_el_is_64 = True" --dtb-filename ~/gem5/system/arm/dt/armv8_gem5_v1_2cpu.dtb --cpu-type AtomicSimpleCPU -n 2
    ```
    需要注意到这个命令与原命令不同的是加了两个后缀：
    ```bash
    --dtb-filename ~/gem5/system/arm/dt/armv8_gem5_v1_2cpu.dtb
    --cpu-type AtomicSimpleCPU -n 2
    ```
    dtb-filename顾名思义，就是制定了.dtb文件的路径；cpu-type是指定CPU类型，后面的-n 2 是CPU的核数（这里是2核）.
  + 采用更新后的指令启动FS下的linux
    ```bash
    cd ~/gem5
    build/ARM/gem5.opt configs/example/fs.py --kernel vmlinux.arm64 --disk-image ubuntu-18.04-arm64-docker.img --bootloader ~/gem5/system/arm/bootloader/arm64/boot.arm64 --param "system.highest_el_is_64 = True" --dtb-filename ~/gem5/system/arm/dt/armv8_gem5_v1_2cpu.dtb --cpu-type AtomicSimpleCPU -n 2
    ```
    ```bash
    cd ~/gem5/util/term
    sudo ./m5term localhost 3456
    ```
    启动后首先采用测试程序./hello_par_static测试是否是多线程
    ```bash
    root@aarch64-gem5:/mountfile# ./hello_par_static 
    Hello World from thread = 0
    Number of threads = 2
    Hello World from thread = 1
    ```
    显示为2个线程，与2核CPU相符.
    再运行之前顺序输出的./test_par_static
    ```bash
    root@aarch64-gem5:/mountfile# ./test_par_static 
    0125367489
    ```
    输出是乱序，符合预期.
    最后测试多线程是否带来了性能的提升，分别运行未进行openmp优化的./test2_un_static和./test2_static，观察执行时间的改变:
    ```bash
    root@aarch64-gem5:/mountfile# ./test2_un_static 
    10000
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
    Total time:0.001567
    Total time:1.567ms
    ```
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
    openmp优化后相较于优化前带来了执行速度接近一倍的提升，与多线程理论上带来的优化相符. 至此，FS运行linux(arm)的实验画上了完美的句号.

##小结
  + 这次实验花费了将近一周的时间，可能看起来实验记录很顺利，但实际做起来各种各样的问题解决起来还是很费功夫的. 说到这里，我认为这次实验让我收获最大的是我为了解决程序运行中，而不得不深入了解gem5的代码结构，加深了对FS的理解，从而从只会按教程跑样例变成了可以根据实际需要进行调整.
  + FS下的ARM和X86对静态编译文件的支持度不同。在X86架构下，编译时静态链接的程序无法运行，显示错误为segfault，在google上也查询不到有关的解决方法，这就导致了FS的X86下很难跑openmp的程序。为什么说很难呢，因为FS下的linux实测编译速度巨慢，简单的hello world程序十分钟都没编译好（也不排除根本就不能编译），非静态链接的程序又会导致库以及glibc版本的不兼容，总之FS下的X86对openmp的支持不太好. 反观FS下的ARM，可以完美运行静态链接的程序（但不能运行非静态链接的程序，与X86恰好相反），进行模拟的结果也很符合理论，我认为是优秀的硬件仿真方式.
  + Openmp能带来很高的执行效率优化. 我一开始想FS下的能做到这么高程度的优化是因为CPU太理想化了，实际多核CPU还要考虑缓存一致性等因素优化达不到这么多，于是我又在本机的linux上运行了之前的测时程序，惊奇的发现几乎多线程并行的执行时间都能达到非多线程运行的${\frac{1}{n}}$. 不过后来又思考了一下，好像是因为我写的程序设置并行的代码段都是没有依赖关系的，也就不需要考虑data hazard；如果遇到依赖关系强的语句，就正常的顺序执行，等到遇到大规模的独立运算，再调用omp语句多线程执行.


##附录
  1. ~/gem5/mountfile中的文件及其编译指令
  + hello.cpp
    ```cpp
    #include <iostream>
    using namespace std;

    int main(){
        cout<<"Hello!"<<endl;
    }
    ```
    编译命令
    ```bash
    arm-linux-gnueabi-g++ hello.cpp -o hello_static -static
    ```
  + test_par.cpp
    ```cpp
  
    #include <iostream>

    using namespace std;
    int main()
    {
    #pragma omp parallel for
        for (int i=0; i<10; i++) 
        {
            cout << i;
        } 
    
        return 0;
    }
    ```
    编译命令
    ```bash
    arm-linux-gnueabi-g++ test_par.cpp -o test_par_static -static -fopenmp
    ```
  + hello_par.cpp
    ```cpp
    #include <omp.h>
    #include <stdio.h>
    #include <stdlib.h>

    int main()
    {
        int nthreads, tid;

        /* Fork a team of threads giving them their own copies of variables */
        #pragma omp parallel private(nthreads, tid)
        {

            /* Obtain thread number */
            tid = omp_get_thread_num();
            printf("Hello World from thread = %d\n", tid);

            /* Only master thread does this */
            if (tid == 0)
            {
                nthreads = omp_get_num_threads();
                printf("Number of threads = %d\n", nthreads);
            }

        }  /* All threads join master thread and disband */
        return 0;
    }
    ```
    编译命令
    ```bash
    arm-linux-gnueabi-g++ hello_par.cpp -o hello_par_static -static -fopenmp
    ```
  + test2.cpp
    ```bash
    #include <iostream> 
    #include <cstdlib>
    #include <ctime>

    using namespace std;

    long long N;

    clock_t start,End;

    int main()
    {
        cin >> N;
        start=clock();
        
        #pragma omp parallel for
        for (int i=0; i<N; i++) 
        {
            if(!(i%(N/10))) cout << i << endl;
        }
        End=clock();

        double endtime=(double)(End-start)/CLOCKS_PER_SEC;
        cout<<"Total time:"<<endtime<<endl;		//s为单位
        cout<<"Total time:"<<endtime*1000<<"ms"<<endl;

        return 0;
    }
    ```
    编译命令
    ```bash
    arm-linux-gnueabi-g++ test2.cpp -o test2_static -static -fopenmp
    ```
  + test2_un.cpp
    ```bash
    #include <iostream> 
    #include <cstdlib>
    #include <ctime>

    using namespace std;

    long long N;

    clock_t start,End;

    int main()
    {
        cin >> N;
        start=clock();
        
        //#pragma omp parallel for
        for (int i=0; i<N; i++) 
        {
            if(!(i%(N/10))) cout << i << endl;
        }
        
        End=clock();

        double endtime=(double)(End-start)/CLOCKS_PER_SEC;
        cout<<"Total time:"<<endtime<<endl;		//s为单位
        cout<<"Total time:"<<endtime*1000<<"ms"<<endl;

        return 0;
    }
    ```
    编译命令
    ```bash
    arm-linux-gnueabi-g++ test2_un.cpp -o test2_un_static -static -fopenmp
    ```

---
Up to 2021.07.25 02:26
这篇实验记录私以为是相当详细的，因为做的时候踩了太多的坑，不希望后面看这份记录的人也因为踩同样的坑浪费大量时间，这里要感谢张露承同学，帮我解决了好几个难题，不然此刻的我应该还在惨惨地踩坑. 代码都是自己跑过的，如果按照这份记录来做应该不会出现大的问题，不过有的代码可能会因为手误打错，注意更改即可.