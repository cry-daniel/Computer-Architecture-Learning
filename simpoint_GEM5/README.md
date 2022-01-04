##  测试配置
+   SimPoint.3.2
+   GEM5 20.1.0.4
+   Python 3.9.7

##  简要介绍
+   核心程序为 **process_all_tests.py** , 该程序使用方法如下:
    ```
    usage: process_all_tests.py [-h] [-n NAME] [-s] [-r]

    A tool for simpoint and reload checkpoints

    optional arguments:
    -h, --help            show this help message and exit
    -n NAME, --name NAME  use new test to replace the original.
    -s, --simpoint        use simpoint to generate checkpoint
    -r, --reload          use new parms to reload checkpoint
    ```
+   在执行程序前 **要先写好 configs_xxx.sh** ,直接参考 configs/configs_example.sh 更改即可,写好后保存在 configs 目录下.
+   `-n NAME` 是为了在命令行中更快捷的指定对象,不必在原 python 文件中修改; `-s` 是指定执行 simpoint 操作, `-r` 是指定执行 reload 操作,因为转入了后台运行,所以在 simpoint 或 reload 时命令行只会显示 `nohup: redirecting stderr to stdout` ,程序的运行情况可以参考保存运行结果的文件夹(configs_xxx.sh 中设置)或者`htop`直接查看 CPU 运行情况.
+   simpoint 通常会需要数个小时,因为其包含了采用 Atomic 初始运行程序以及写 checkpoint ,但是在 simpoint 生成 checkpoint 后, reload 通常只需要一分钟就可以出结果.
+   例
    ```bash
    python3 process_all_tests.py -n example -s
    python3 process_all_tests.py -s
    python3 process_all_tests.py -n example -r
    python3 process_all_tests.py -r
    ```

##  详细介绍
###  如何在 GEM5 里面使用 Simpoint 生成 checkpoint (Simpoint)
+   使用时需要 ***先写好 configs_xxx.sh*** ，具体怎么写 configs_xxx.sh ，可以参考 `configs/configs_example.sh` ，里面有详细的注释关于什么地方要改什么地方不要改，把标注要改的地址改成自己的就可以了. 该配置文件包含了可执行文件的路径、参数等信息. 在测试的时候 ***改一下 process_all_test.py 中的 tests 参量*** ，将其改为（或添加） configs_xxx.sh 中的 xxx ，然后执行命令:
    ```python
    python3 process_all_test.py -s
    ```
    程序将会执行以下功能：
    +   采用 AtomicSimpleCPU 初始运行一遍程序，并生成 simpoint.bb.gz
    +   Simpoint 读取 simpoint.bb.gz，并生成划分结果以及权重文件
    +   按照 Simpoint 划分的结果写 checkpoint
    +   采用指定的 CPU 以及参数执行 checkpoint （注：这个功能只是为了验证，使用不同参数重跑详见 Reload ）
+   如果要阅读或修改源码，推荐顺序：
    `configs/configs_example.sh` $\rightarrow$ `process/process_all_test.py` $\rightarrow$ `process/process_sim.sh` $\rightarrow$ `sim/sim_init.sh` $\rightarrow$ `sim/sim_generate_sim_weight.sh` $\rightarrow$ `sim/sim_generate_checkpoint.sh` $\rightarrow$ `sim/sim_O3.sh`

###  在生成 checkpoint 下更换配置参数重载 checkpoint (Reload)
+   使用时同样需要 ***先写好 configs_xxx.sh*** . 在测试的时候 ***改一下 process_all_test.py 中的 tests 参量*** ，将其改为（或添加） configs_xxx.sh 中的 xxx ，然后执行命令:
    ```python
    python3 process_all_test.py -r
    ```
+   程序将会执行以下功能：
    +   使用新的参数并行地重载所有的 checkpoint . (对于 configs_example.sh 所对应的参数，总时间约为 60s，相较于原来动辄数小时的仿真时间是极大优化)
+   如果要阅读或修改源码，推荐顺序：
    `configs/configs_example.sh` $\rightarrow$ `process/process_all_test.py` $\rightarrow$ `process/process_reload.sh` $\rightarrow$ `sim/sim_reload.sh`
    
###  附录
+   FS 模式下不太好用 Simpoint ，就只写了 SE 模式的.
+   一般情况下都应先进行 simpoint 生成 checkpoint ,在有了 checkpoint 之后,就可以随意更改参数进行仿真(reload),不用再进行 simpoint 了.