## 如何在 GEM5 里面使用 Simpoint 
+   FS 模式下不太好用 Simpoint ，就只写了 SE 模式的.
+   使用时先写好 configs_xxx.sh ，测的时候改一下 process_all_test.py 中的 tests 参量，然后`python3 process_all_test.py`就可以了.
+   怎么写 configs_xxx.sh 呢，可以参考 `configs/configs_example.sh` ，里面有详细的注释关于什么地方要改什么地方不要改.
+   如果要阅读或修改源码，推荐顺序：
    `configs/configs_example.sh` $\rightarrow$ `process_all_test.py` $\rightarrow$ `process_sim.sh` $\rightarrow$ `sim_init.sh` $\rightarrow$ `sim_generate_sim_weight.sh` $\rightarrow$ `sim_generate_checkpoint.sh` $\rightarrow$ `sim_O3.sh`