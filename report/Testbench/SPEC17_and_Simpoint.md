# SPEC17 & Simpoint 安装教程
---
参考了 `https://www.spec.org/cpu2017/`

*Copy right by ChenRuiyang*

---
## SPEC17准备工作
+   准备好 SPEC17 的iso文件，因为版权问题网上下载不了，但在 stu1 服务器上 /home/data/ChenRuiyang/SPEC_ISO 目录里有 cpu2017-1.0.2.iso ，用那个即可，详细安装过程参考 CSDN 这篇博文，在此不多赘述：
    `https://blog.csdn.net/weixin_30648963/article/details/102273129` .
    
    注：挂载参考下面的命令
    ```bash
    sudo mount -t iso9660 -o ro,exec cpu2006.iso /mnt
    ```
+   SPEC 编译时需要改配置文件，这里直接在 Example 上小改：
    ```bash
    cd spec17/config
    scp Example-gcc-linux64-aarch64.cfg ARM.cfg
    ```
    因为我们是在 arm 下测试程序，并且 Gem5 要求静态链接，所以要改一下 ARM.cfg，把参数改成下面的即可：
    ```
    ...
    CC                 = aarch64-linux-gnu-gcc -std=c99
    CXX                = aarch64-linux-gnu-g++
    ...
    default=base:         # flags for all base 
        OPTIMIZE         = -O2 -static
    ...
    ```
+   在 config 目录下运行下命令：
    `runspec --config=ARM.cfg --action=build --tune=base --size=test gcc_r`
    此处 `--size=test` 意味着采用最小测试集，bzip2为我们举例的测试集，可选取的测试集详见 `spec17/benchspec/CPU` .
    注意：若此时出现 runspec 未定义的警告，需要运行下列命令
    ```bash
    cd spec17
    source shrc
    ```
+   build 完成之后在`spec17/benchspec/CPU/502.gcc_r`下会出现 data 以及 exe 文件夹，代表成功.
    但是不是所有的测试程序都能用 runspec build 成功，部分程序可能因为与 aarch64-linux-gnu 不兼容而失败(或者因为 gFortran).
+   对所有程序进行编译：
    `runspec --config=ARM.cfg --action=build --tune=base all`
    all代表所有测试程序.


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