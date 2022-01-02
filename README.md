## 介绍
+   这个仓库存的是在学习计算机体系结构时的学习资料以及写的代码，具体内容如下：

### gem5: 保存了与 GEM5模拟器 有关的代码
+   armpl_source_file: ARM PERFORMANCE LIBRARY 中的样例代码以及 Makefile 文件，用的比较多的是 Spmv ，也就是稀疏矩阵乘法
+   cal_GEM5_stats: 从 GEM5 的统计文件中计算 IPC 等信息的代码，运行 cal_stats.py 即可，运行前记得改最前面的路径
+   sh_command_stu1: 在服务器上的脚本的备份
+   spmv_spec_copy: 对 benchmark 做 Simpoint 的备份，因为最开始的 benchmark 是 spmv 和 spec ，所以叫这个名字了，后面确定 benchmark 会改
+   spmv_test: 测试 spmv 性能
+   temp_files: 临时存一些文件的备份

### paper: 存的是一些论文
+   内容详见内部的 README.md

### report: 实验报告以及论文的阅读报告
+   内容详见内部的 README.md

### simpoint_GEM5
+   内有便于在 GEM5 内使用 simpoint 的脚本文件，详见内部的 README.md
+   可以加速 GEM5 的模拟，在测试中可以将数小时的程序在 60s 左右完成.

### docs
+   写代码时的技巧，让代码更加优雅