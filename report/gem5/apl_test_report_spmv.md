# Arm Performance Library Test Report
---
参考了 https://developer.arm.com/ 
*Copy right by ChenRuiyang*

---

## 测试参数：
+   架构：ARM指令集
+   处理器类型：DerivO3CPU
+   单核单线程
+   Cache：2级Cache
    +   L1_icache 64KB 4assoc
    +   L1_dcache 64KB 4assoc
    +   L2_cache 1MB 4assoc
    +   Cacheline_size 128
+   Mem：无指定mem（加入Mem参数后长时间无输出）
+   SVE：vector length = 4 （ * 128 ）

## 测试程序：
+   矩阵乘法运算:   dgemm
    $ C := \alpha * A * B + \beta * C$
    上式中 $\alpha , \beta $为双精度浮点数，$A,B,C$为矩阵，且满足矩阵乘法与加法的要求.
+   奇异值分解: dgesdd
    $A = U * \Sigma * V^T $
    上式中 $ A , U , \Sigma , V $均为矩阵.
+   LU分解: dgetrf
    $A = P * L * U$
    上式中 $A , P , L , U$均为矩阵.
+   稀疏矩阵线性运算:   spadd
    $ C := \alpha * A + \beta * B $
    上式中$ \alpha , \beta $为单精度浮点数， $A , B , C$为稀疏矩阵，且满足矩阵加法的要求.
+   稀疏矩阵乘法运算:   spmm
    $ C := \alpha * A * B + \beta * C$
    上式中 $\alpha , \beta $为单精度浮点数，$A,B,C$为稀疏矩阵，且满足矩阵乘法与加法的要求.
+   稀疏矩阵和向量的乘法运算:   spmv
    $ C := \alpha * A * x + \beta * y$
    上式中 $\alpha , \beta $为单精度浮点数，$A$为稀疏矩阵，$ x , y $为向量.

## 测试环境：
+   GEM5 + FS
    +   初始化脚本（GEM5 script）
        ```
        m5 checkpoint
        m5 resetstats
        m5 readfile > /tmp/gem5.sh && sh /tmp/gem5.sh
        m5 exit
        ```
    +   运行脚本（GEM5 script）
        ```
        ./filename
        m5 exit
        ```

## 测试结果：
| param | dgemm | dgesdd | dgetrf | spadd | spmm | smpv |
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
|Time /s |0.026537|0.011012|0.004807|0.004175|0.006348|0.005961|
|IPC|0.948067|1.322738|0.659510|0.554336|1.080294|1.283651|
|Dcache hit|26297684|14971421|3069195|2376856|8161132|7587199|
|Dcache miss|6613428|105773|100281|99434|101700|99455|
|Dcache miss rate|20.09%|7.02%|3.16%|4.02%|1.23%|1.29%|
|Branch prediction|4840430|5238655|1640061|1223354|3236808|3074956|
|Incorrect prediction|202956|204771|106523|100506|146004|102016|
|Branch mispredict rate|4.19%|3.91%|6.50%|8.22%|4.51%|3.22%|
|ROB stall|11286|14313|4048|3081|2183|2557|
|Renamed insts|9545255|10606040|9735275|9081936|25965997|9531122|
|Stall rate|0.0124%|0.0274%|0.0341%|0.0339%|0.0084%|0.0095%|

## 结果分析：
+   通过分析上表可以得出的最显然的结论是通过优化 cache miss , branch predict 以及 ROB stall 可以显著提高 IPC.
+   对于矩阵乘法运算来说， Cache miss 是限制 IPC 的瓶颈，通过优化Cache读取可以提升性能.
+   在LU分解以及稀疏矩阵加法中，瓶颈为分支预测的准确率以及ROB stall的概率.
+   得到的这些数据从某种意义上来说并不能直观的给出瓶颈所在，和预想的不同， cache miss 等参数在不同应用场景下并没有特别直观的差距，很难得到有说服力的结论. 