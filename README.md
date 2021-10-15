## gem5/apl_source_file
+   gem5/armpl_sour_file/ 文件夹内的是从arm performance library中选取的测试文件，编译命令为：
+    `make`
    注意：编译前需要更改Makefile中ARMPL_DIR的路径，编译环境为arm架构的QEMU虚拟机.

## gem5/sh_command
+   从每个文件名字可以大致了解用途，这里主要用的是XXX_init.sh与XXX_init.sh，init用于初始化，用到了init.sh脚本，XXX_run.sh则用于运行，具体详见：
    `https://www.gem5.org/documentation/general_docs/checkpoints/`
+   fullsystem_normal.sh用于正常启用gem5 fs，注意开启term监听，例：
    ```bash
    sh fullsystem_normal.sh
    sh m5term.sh
    ```

## gem5/spmv_test
+   spmv稀疏矩阵运算优化的测试程序，主要是根据样例写的，加入了读如文件以及m5ops.
+   对于新的XXX.mtx文件，只需放入/matrices文件夹中，再运行generate_mtx.py，即可将其转化为CSR格式.