# Full System实验记录



##  如何使用gem5 FS模式

0. Prerequisite

   ```bash
   sudo apt install build-essential git m4 scons zlib1g zlib1g-dev libprotobuf-dev \
   protobuf-compiler libprotoc-dev libgoogle-perftools-dev \
   python3-dev python3-six python-is-python3 libboost-all-dev \
   pkg-config
   
   # 需要注意不同Ubuntu版本下的aarch64-gcc版本
   sudo apt install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu binutils-aarch64-linux-gnu
   ```

1. build gem5

   ```bash
   git clone https://github.com/gem5/gem5.git
   cd gem5/
   scons build/ARM/gem5.opt -j9
   
   # make bootloader
   make -C system/arm/bootloader/arm
   make -C system/arm/bootloader/arm64
   # make device trees
   make -C system/arm/dt
   
   # build m5ops library
   cd util/m5
   scons build/aarch64/out/m5
   cd util/term; make
   ```

2. 下载pre-built ARM Linux kernel

   [Latest Linux Kernel Image / Bootloader](http://dist.gem5.org/dist/v21-0/arm/aarch-system-201901106.tar.bz2)（最新版不知为何服务器上跑不了，这里换成了201901106版）

   [Latest Linux Disk Images](http://dist.gem5.org/dist/current/arm/disks/ubuntu-18.04-arm64-docker.img.bz2)

3. 解压，**千万别用GUI解压工具**

   `bzip2 -d aarch-system-20210904.tar.bz2` `tar xvf aarch-system-20210904.tar`

   `bzip2 -d ubuntu-18.04-arm64-docker.img.bz2`

4. 设置环境变量M5_PATH为`aarch-system-20210904`解压路径

   `echo "export M5_PATH=\"~\\aarch-system-20210904\"" >> ~/.bashrc; source ~/.bashrc`

5. 扩容和添加内容（如Compiler, Library, Benchmark）到磁盘映像

   [arm-compiler-for-linux_21.0_Ubuntu-18.04_aarch64](https://developer.arm.com/-/media/Files/downloads/hpc/arm-allinea-studio/21-0/ACfL/arm-compiler-for-linux_21.0_Ubuntu-18.04_aarch64.tar?revision=31400f62-c9e6-4d20-a2b7-4ed597a53c5e)

   ```bash
   mkdir ~/mnt
   # 需要sudo，可以在自己虚拟机上整好再传到服务器上
   $GEM5_PATH/util/gem5img.py mount XXX.img ~/mnt
   cp XXX mnt/root/XXX
   $GEM5_PATH/util/gem5img.py umount mnt
   ```

   disk image 2G空间不够，用dd和gparted扩容

   ```bash
   # 扩容
   $ dd if=/dev/zero bs=1M count=10240 >> ./ubuntu-18.04-arm64-docker.img
   # 挂载
   $ sudo udisksctl loop-setup -f ./ubuntu-18.04-arm64-docker.img
   Mapped file linux-x86.img as /dev/loop0.
   
   # 用gparted把空闲空间加到image的sda1上
   $ sudo gparted /dev/loop0
   # 卸载
   $ sudo udisksctl loop-delete -b /dev/loop0
   ```
   
6. 启动

   ```bash
   $ ./build/ARM/gem5.opt ./configs/example/fs.py \
   >       --kernel $M5_PATH/binaries/vmlinux.arm64 \
   >       --disk-image $M5_PATH/disks/ubuntu-18.04-arm64-docker.img \
   >       --bootloader $M5_PATH/binaries/boot.arm64 \
   >       --param "system.highest_el_is_64 = True"
   ```

   或者

   ```bash
   ./build/ARM/gem5.opt ./configs/example/arm/starter_fs.py \
   	--kernel /home/zhanglucheng/aarch-system-201901106/binaries/vmlinux.arm64 \
   	--disk-image /home/zhanglucheng/ubuntu-18.04-arm64-docker.img
   ```

   从输出信息中看终端端口号

   ```bash
   system.terminal: Listening for connections on port 3456
   ```

   则使用m5term连接3456即可使用终端

   ```
   ./util/term/m5term 3456
   ```

   一般在gem5里启动aarch64 linux要5分钟左右

7. 虚拟机内安装arm-compiler-for-linux（内含performance library）

   ```bash
   cd <package_name>
   ./<package_name>.sh -a 
   # -a表示自动接受EULA协议，不然要在超高输入延迟下一行一行回车看完
   ```

   

## 试验

1. fs + 64 或 starter_fs + 32/64 都不行；

   用fs + 32位可跑，但最后会有kernel panic

   ```bash
   ./build/ARM/gem5.opt ./configs/example/fs.py \
   --kernel /home/zhanglucheng/aarch-system-20210904/binaries/vmlinux.arm \
   --disk-image /home/zhanglucheng/ubuntu-18.04-arm64-docker.img
   ```

   ```bash
   [    0.444805] Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance.
   [    0.444879] ---[ end Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance. ]---
   ```

2. *Mail Archive*类似状况解决办法：

   - 不能用GUI解压，要`bzip2 -d aarch-system-201901106.tar.bz2` `tar xvf aarch-system-201901106.tar`

   - `--root /dev/vda1` 加上似乎有别的问题

   - > Unrelated, could you use vmlinux.vexpress_gem5_v1_64 instead?

   - > there are some incompatibilities between the prebuilt kernel and 
     > your binutils

     换到自己的虚拟机ubuntu20.04 + gem5 21.0.1.0 也是

     ```bash
     warn: Kernel panic in simulated kernel
     ```

     ```bash
     [    0.444806] Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance.
     [    0.444880] ---[ end Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance. ]---
     ```

4. 尝试2019版另一个64位kernel，记得要修改M5_PATH

   ```bash
   ./build/ARM/gem5.opt ./configs/example/fs.py --kernel /home/zhanglucheng/aarch-system-201901106/binaries/vmlinux.arm64 --disk-image /home/zhanglucheng/ubuntu-18.04-arm64-docker.img --bootloader /home/zhanglucheng/aarch-system-201901106/binaries/boot.arm64 --param 'system.highest_el_is_64 = True'
   ```



## 总结

1. GUI解压工具Archive Manager就是辣鸡，应该用`bzip2 -d aarch-system-201901106.tar.bz2` `tar xvf aarch-system-201901106.tar`

   如果用Archive Manager解压，运行时会卡在最开始

2. 用不同版本的pre-built kernel 需要修改M5_PATH `export $M5_PATH=\path\to\aarch-system-XXXX`

3. fs.py 需要参数 `kernel` `disk-image` `bootloader` 以及设置最高exception level = 64。不加bootloader会导致上述kernel panic

   starter_fs.py 不用加`bootloader`和`param`，但需要提前make bootloader `make -C $GEM5_PATH/system/arm/bootloader/arm64`

   

