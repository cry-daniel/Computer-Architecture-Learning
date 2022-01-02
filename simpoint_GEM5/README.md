##  介绍
+   内容分为以下几个部分
    +   Simpoint，主要介绍如何在 GEM5 里面使用 Simpoint 生成 checkpoint
    +   Reload，在生成 checkpoint 下更换配置参数重载 checkpoint
    +   附录

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
    `configs/configs_example.sh` $\rightarrow$ `process_all_test.py` $\rightarrow$ `process_sim.sh` $\rightarrow$ `sim_init.sh` $\rightarrow$ `sim_generate_sim_weight.sh` $\rightarrow$ `sim_generate_checkpoint.sh` $\rightarrow$ `sim_O3.sh`

###  在生成 checkpoint 下更换配置参数重载 checkpoint (Reload)
+   使用时同样需要 ***先写好 configs_xxx.sh*** . 在测试的时候 ***改一下 process_all_test.py 中的 tests 参量*** ，将其改为（或添加） configs_xxx.sh 中的 xxx ，然后执行命令:
    ```python
    python3 process_all_test.py -r
    ```
+   程序将会执行以下功能：
    +   使用新的参数并行地重载所有的 checkpoint . (对于 configs_example.sh 所对应的参数，总时间约为 60s，相较于原来动辄数小时的仿真时间是极大优化)
+   如果要阅读或修改源码，推荐顺序：
    `configs/configs_example.sh` $\rightarrow$ `process_all_test.py` $\rightarrow$ `process_reload.sh` $\rightarrow$ `sim_reload.sh`
    
###  附录
+   FS 模式下不太好用 Simpoint ，就只写了 SE 模式的.