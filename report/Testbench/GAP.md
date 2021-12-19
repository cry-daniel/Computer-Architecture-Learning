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