# GAP

## 简介
+   GAP 基准套件旨在通过标准化评估来帮助图形处理研究。图形处理评估之间的差异越小，就越容易比较不同的研究工作和量化改进。该基准测试不仅指定了图内核、输入图和评估方法，而且还提供了优化的基线实现（此 repo）。这些基线实现代表了最先进的性能，因此新的贡献应该优于它们以证明改进。

##  Kernels Included
+   Breadth-First Search (BFS) - direction optimizing
+   Single-Source Shortest Paths (SSSP) - delta stepping
+   PageRank (PR) - iterative method in pull direction
+   Connected Components (CC) - Afforest & Shiloach-Vishkin
    求一个图的联通分支
+   Betweenness Centrality (BC) - Brandes
    如果最短路中的很多条都经过某个节点，那么这个节点的 BC 就高，计算是用经过它的除以总的
+   Triangle Counting (TC) - Order invariant with possible relabelling
    找图里的三角形

## 参数
```
All of the binaries use the same command-line options for loading graphs:

-g 20 generates a Kronecker graph with 2^20 vertices (Graph500 specifications)
-u 20 generates a uniform random graph with 2^20 vertices (degree 16)
-f graph.el loads graph from file graph.el
-sf graph.el symmetrizes graph loaded from file graph.el

The graph loading infrastructure understands the following formats:

.el plain-text edge-list with an edge per line as node1 node2
.wel plain-text weighted edge-list with an edge per line as node1 node2 weight
.gr 9th DIMACS Implementation Challenge format
.graph Metis format (used in 10th DIMACS Implementation Challenge)
.mtx Matrix Market format
.sg serialized pre-built graph (use converter to make)
.wsg weighted serialized pre-built graph (use converter to make)
```

##  GAP 编译流程
+   正常情况：
    +   修改 gap/Makefile 中的 CXX ，在服务器上 CXX=g++ (X86) 或 CXX=aarch64-none-linux-gnu-g++ (ARM64)
    +   在 gap 路径下输入 `make` 即可编译.
+   加入 m5ops 的情况：
    +   首先修改 gap/src/benchmark.h ，在 kernel 的部分做如下修改：
        ```cpp
        #include "/home/data/ChenRuiyang/gem5/include/gem5/m5ops.h" //new add

        ...

        m5_checkpoint(0,0);     // new add
        m5_reset_stats(0,0);    // new add
        auto result = kernel(g);
        m5_exit(0);     // new add

        ...

        ```
        目的是为了能够使 gem5 只记录 kernel 核心部分运行的情况，统计信息不再包含数据的载入以及结果的输出.
    +   修改 Makefile 中的 CXX_FLAGS 以及编译命令，将其修改如下:
        ```makefile
        #  old CXX_FLAGS
        #  CXX_FLAGS += -std=c++11 -O3 -Wall -static

        #  new CXX_FLAGS
        CXX_FLAGS += -std=c++11 -O3 -I /home/data/ChenRuiyang/gem5/include/ \
        -L /home/data/ChenRuiyang/gem5/util/m5/build/aarch64/out -lm5 -static

        #   old command
        #   % : src/%.cc src/*.h
	    #       $(CXX) $(CXX_FLAGS) $< -o $@

        #   new command
        % : src/%.cc src/*.h 
	        $(CXX) $< -o $@ $(CXX_FLAGS)
        ```
    +   输入 `make` 即可编译.

##  GAP 运行流程
+   正常情况
    +   在 gap 路径下输入如下命令：
        ```bash
        #   example
        ./bc -g 10 -n 1
        ```
        `./bc` 是运行的测试程序的名称，`-g 10` 是生成大小为 $2^{10}$ 的 kronecker graph ， `-n 1` 是代表执行1遍 kernel ，如果 `-n 10` 将执行10遍 kernel ，每次执行都会采用不同的参数.
    +   如果需要指定输入文件，则需要在后面加上 `-f my_input_file` ，例如：
        ```bash
        #   example
        ./bc -f input/ks2010.mtx -n 1
        ```
        `input/ks2010.mtx` 是我们给定的输入矩阵，除了 `.mtx` 也支持其他常见矩阵格式的输入，例如以下的情形：
        ```  
        .el plain-text edge-list with an edge per line as node1 node2
        .wel plain-text weighted edge-list with an edge per line as node1 node2 weight
        .gr 9th DIMACS Implementation Challenge format
        .graph Metis format (used in 10th DIMACS Implementation Challenge)
        .mtx Matrix Market format
        .sg serialized pre-built graph (use converter to make)
        .wsg weighted serialized pre-built graph (use converter to make)
        ```
    +   常用的 kernel 有 6 个，分别是：
        +   Breadth-First Search (BFS) - direction optimizing
        +   Single-Source Shortest Paths (SSSP) - delta stepping
        +   PageRank (PR) - iterative method in pull direction
        +   Connected Components (CC) - Afforest & Shiloach-Vishkin
            求一个图的联通分支
        +   Betweenness Centrality (BC) - Brandes
            如果最短路中的很多条都经过某个节点，那么这个节点的 BC 就高，计算是用经过它的除以总的
        +   Triangle Counting (TC) - Order invariant with possible relabelling
            找图里的三角形
+   加入 m5ops 的情况：
    +    加入 m5ops 之后就无法正常在服务器上运行了(很奇特，X86 架构的服务器能运行 ARM 架构的程序，但是本机用 X86 的 CPU 就没法运行)，则需要在 gem5 里运行，命令行如下：
            ```bash
            #   以 ARM 为例，X86 类似
            build/ARM/gem5.fast --outdir=m5out/GAP_bc_m5ops_normal \
            configs/example/se.py --cpu-type O3_ARM_v7a_3 --cpu-clock 3.1GHz \
            --num-cpu 1 --caches --l2cache --l1i_size 64kB --l1d_size 64kB \
            --l2_size 1MB --l1i_assoc 4 --l1d_assoc 4 --l2_assoc 4 \
            --cacheline_size 128 --mem-type DDR3_2133_8x8 --mem-size 16GB \
            --l2-hwp-type StridePrefetcher \
            -c /home/data/ChenRuiyang/gap_GEM5_version/bc \
            -o ' -f /home/data/ChenRuiyang/gap_GEM5_version/input/ks2010.mtx'
            ```
            其中 `-c` 是 gem5 中需要被执行的程序，`-o` 是传给命令行的参数，等待执行完成之后读 `/m5out` 中的统计信息即可