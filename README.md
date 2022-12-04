## 介绍
+   这个仓库存的是在学习计算机体系结构时的学习资料以及写的代码，目录结构如下：

```
├─cal_GEM5_stats
│  ├─data
│  └─tools
├─docs
│  ├─makefile
│  └─python
├─paper
│  ├─GEM5_tutorial
│  └─misc
├─report
│  ├─gem5
│  ├─Simpoint
│  └─Testbench
└─simpoint_GEM5
    ├─configs
    ├─process
    └─sim
```

### cal_GEM5_stats
+   从 GEM5 的统计文件中自动读取并计算 IPC 等信息的自动化脚本.

### docs
+   写代码时的技巧，让代码更加优雅.

### paper
+   存有论文以及论文阅读笔记.

### report:
+   做实验时留下的记录，方便未来复现.

### simpoint_GEM5
+   便于在 GEM5 内使用 simpoint 的自动化脚本.
+   可以加速 GEM5 的模拟，在测试中可以将十数小时的程序在 60s 左右完成.