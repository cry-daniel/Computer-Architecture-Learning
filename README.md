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

### spmv_spec
+   对 Benchmark 进行模拟的代码，主要是使用 Simpoint 将一个长的程序切成很多小的 checkpoint ，更改参数模拟时可以减少很多时间. 没有 Simpoint 运行不了, Simpoint 有官网，下载安装就可以了. 后续还会优化，就先不写太多了

### spmv_spec_test_O3
+   里面的程序验证了 checkpoint 改参数是可行的，实验报告在 report/Simpoint

### tricks
+   写代码时的技巧，让代码更加优雅