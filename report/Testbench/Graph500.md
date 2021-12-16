# Graph 500

## 简介
+   数据密集型超级计算机应用程序是越来越重要的工作负载，但不适合为 3D 物理模拟设计的平台。没有有意义的基准测试就无法提高应用程序性能。图是大多数分析工作负载的核心部分。在由来自学术界、工业界和国家实验室的 30 多位国际 HPC 专家组成的指导委员会的支持下，该规范为这些应用建立了大规模基准。它将为社区提供一个论坛，并为数据密集型超级计算问题提供一个集结点。
+   基准测试问题（“搜索”和“最短路径”）的目的是开发一个紧凑的应用程序，该应用程序具有多种分析技术（多个内核），可以访问表示加权无向图的单个数据结构。除了从输入元组列表构建图的内核之外，还有两个额外的计算内核可以对图进行操作。
+   该基准测试包括一个可扩展的数据生成器，它生成包含每个边的起始顶点和结束顶点的边元组。第一个内核以所有后续内核都可用的格式构造一个无向图。不允许进行后续修改以使特定内核受益。第二个内核对图执行广度优先搜索。第三个内核在图上执行多个单源最短路径计算。所有三个内核都是定时的(包含在性能里)。

## 步骤
1.  Generate the edge list.
2.  Construct a graph from the edge list (timed, kernel 1).
3.  Randomly sample 64 unique search keys with degree at least one, not counting self-loops.
4.  For each search key:
    1.  Compute the parent array (timed, kernel 2).
    2.  Validate that the parent array is a correct BFS search tree for the given search tree.
5.  For each search key:
    1.  Compute the parent array and the distance array (timed, kernel 3).
    2.  Validate that the parent array/distance vector is a correct SSSP search tree with shortest paths for the given search tree.
6.  Compute and output performance information.

## Generate the edge list (还没到 kernel)
+   可扩展数据生成器将构造一个包含顶点标识符的边元组列表。每条边都是无向的，其端点在元组中指定为 StartVertex、EndVertex 和 Weight。如果边元组仅用于运行内核 2，则允许不生成边权重。这允许 BFS 运行不受存储边缘权重导致的不必要内存使用的影响。
+   下面第一个内核的目的是将没有局部性的列表转换为更优化的形式。生成的输入元组列表不得表现出任何可被计算内核利用的局部性。因此，顶点编号必须随机化，并且元组的随机排序必须呈现给内核 1。数据生成器可以并行化，但顶点名称必须全局一致，并且必须注意尽量减少处理器中数据局部性的影响等级。

### 参数
+   scale: 规模参数，总顶点数为 $2^{scale}$
+   edgefactor: 图的边数与其顶点数的比率(即图中顶点平均度数的一半)
+   由此推出总边数为: $N=edgefactor*2^{scale}$
+   采用了 Kronecker generator 的算法，算法有四个参数:a,b,c,d，它们对应邻接矩阵的四个大小相等的分区，含义为邻接矩阵添加边时选择该分区的概率.

## Kernel 1 : Constrct a graph
+   第一个内核可以将边列表转换为用于其余内核的任何数据结构（保存在内部或外部存储器中）。例如，内核 1 可以从元组列表构造一个（稀疏）图；每个元组包含一条边的端点标识符，以及一个表示分配给边的数据的权重。
+   该图可以以任何方式表示，但不能被后续内核修改或在后续内核之间进行修改。可以在数据结构中保留空间用于标记或锁定。一次只能运行一个内核副本；该内核对任何此类标记或锁定空间具有独占访问权，并且被允许（仅）修改该空间。
+   稀疏图有多种内部存储器表示，包括（但不限于）稀疏矩阵和（多级）链表。出于本应用的目的，内核仅提供边列表和边列表的大小。必须在此内核中计算更多信息，例如顶点数。
+   ```
    function G = kernel_1 (ij)
    %% Compute a sparse adjacency matrix representation
    %% of the graph with edges from ij.

        %% Remove self-edges.
        ij(:, ij(1,:) == ij(2,:)) = [];
        %% Adjust away from zero labels.
        ij = ij + 1;
        %% Find the maximum label for sizing.
        N = max (max (ij));
        %% Create the matrix, ensuring it is square.
        G = sparse (ij(1,:), ij(2,:), ones (1, size (ij, 2)), N, N);
        %% Symmetrize to model an undirected graph.
        G = spones (G + G.');
    ```

## Kernel 2 : Breadth-First Search
+   图的广度优先搜索 (BFS) 从单个源顶点开始，然后分阶段查找并标记其邻居，然后是其邻居的邻居等。这是许多图算法所基于的基本方法. BFS 的正式描述可以在 Cormen、Leiserson 和 Rivest 中找到。下面，我们为 BFS 基准指定输入和输出，并对计算施加一些限制。但是，我们不限制 BFS 算法本身的选择，只要它产生正确的 BFS 树作为输出即可。
+   该基准测试的内存访问模式（内部或外部）依赖于数据，平均预取深度较小。就像在简单的并发链表遍历基准测试中一样，性能反映了架构在执行并发线程时的吞吐量，每个线程都具有低内存并发性和高内存引用密度。与此类基准测试不同的是，当许多内存引用指向同一位置时，该基准测试还测量了对热点的恢复能力；当每个线程的执行路径依赖于其他线程的异步副作用时的效率；以及动态负载平衡不可预测大小的工作单元的能力。测量同步性能不是这里的主要目标。
+   您不能同时从多个搜索键进行搜索。在此内核的不同调用之间不能传递任何信息。内核可能会返回一个用于验证的深度数组。
+   算法说明当 BFS 级别 k 的顶点发现级别 k+1 的顶点时，我们允许良性竞争条件。具体来说，我们不需要同步来确保第一个访问者必须成为父访问者，同时锁定后续访问者。只要最后发现的 BFS 树是正确的，就认为算法是正确的。
+   ```
    function parent = kernel_2 (G, root)
    %% Compute a sparse adjacency matrix representation
    %% of the graph with edges from ij.

    N = size (G, 1);
    %% Adjust from zero labels.
    root = root + 1;
    parent = zeros (N, 1);
    parent (root) = root;

    vlist = zeros (N, 1);
    vlist(1) = root;
    lastk = 1;
    for k = 1:N,
        v = vlist(k);
        if v == 0, break; end
        [I,J,V] = find (G(:, v));
        nxt = I(parent(I) == 0);
        parent(nxt) = v;
        vlist(lastk + (1:length (nxt))) = nxt;
        lastk = lastk + length (nxt);
    end

    %% Adjust to zero labels.
    parent = parent - 1;
    ```

## Kernel 3 : Single Source Shortest Paths
+   单源最短路径 (SSSP) 计算找到从给定起始顶点到图中每个其他顶点的最短距离。也可以在 Cormen、Leiserson 和 Rivest 中找到对非负权重图上 SSSP 的正式描述。我们为 SSSP 基准指定了输入和输出，并对计算施加了一些限制。但是，我们不限制 SSSP 算法本身的选择，只要实现产生正确的 SSSP 距离向量和父树作为输出即可。这是一个单独的内核，不能使用内核 2 (BFS)计算的数据。
+   该内核通过额外的测试和每个顶点的数据访问扩展了整体基准。许多但并非所有的 SSSP 算法都与 BFS 相似，并且存在类似的热点和重复内存引用问题。
+   您不能同时从多个初始顶点进行搜索。在此内核的不同调用之间不能传递任何信息。
+   算法说明我们也允许 SSSP 中的良性竞争条件。我们不要求第一个访问者必须阻止后续访问者占用父位置。只要最后SSSP距离和父树是正确的，算法就被认为是正确的。
+   ```
    function [parent, d] = kernel_3 (G, root)
    %% Compute the shortest path lengths and parent
    %% tree starting from vertex root on the graph
    %% represented by the sparse matrix G. Every
    %% vertex in G can be reached from root.

    N = size (G, 1);
    %% Adjust from zero labels.
    root = root + 1;
    d = inf * ones (N, 1);
    parent = zeros (N, 1);
    d (root) = 0;
    parent (root) = root;

    Q = 1:N;
    while length (Q) > 0
        [dist, idx] = min (d(Q));
        v = Q(idx);
        Q = setdiff (Q, v);
        [I, J, V] = find (G (:, v));
        for idx = 1:length(I),
        u = I(idx);
        dist_tmp = d(v) + V(idx);
        if dist_tmp < d(u),
            d(u) = dist_tmp;
            parent(u) = v;
        end
        end
    end

    %% Adjust back to zero labels.
    parent = parent - 1;
    ```

## 其他
### 验证
+   因为采用了随机数(伪)，所以没有确定的结果可以比对，需要验证
+   具体验证方法没细看，但是验证的时间是不记在总时间里的.
+   ```
    function out = validate (parent, ijw, search_key, d, is_sssp)
    %% Validate the results of BFS or SSSP.

    %% Default: no error.
    out = 1;

    %% Adjust from zero labels.
    parent = parent + 1;
    search_key = search_key + 1;
    ijw = ijw + 1;

    %% Remove self-loops.
    ijw(:,(ijw(1, :) == ijw(2, :))') = [];
    
    %% root must be the parent of itself.
    if parent (search_key) != search_key,
        out = 0;
        return;
    end

    N = max (max (ijw(1:2,:)));
    slice = find (parent > 0);

    %% Compute levels and check for cycles.
    level = zeros (size (parent));
    level (slice) = 1;
    P = parent (slice);
    mask = P != search_key;
    k = 0;
    while any (mask),
        level(slice(mask)) = level(slice(mask)) + 1;
        P = parent (P);
        mask = P != search_key;
        k = k + 1;
        if k > N,
        %% There must be a cycle in the tree.
        out = -3;
        return;
        end
    end

    %% Check that there are no edges with only one end in the tree.
    %% This also checks the component condition.
    lij = level (ijw(1:2,:));
    neither_in = lij(1,:) == 0 & lij(2,:) == 0;
    both_in = lij(1,:) > 0 & lij(2,:) > 0;
    if any (not (neither_in | both_in)),
        out = -4;
        return
    end

    %% Validate the distances/levels.
    respects_tree_level = true(1,size(ijw, 2));
    if !is_sssp
        respects_tree_level = abs (lij(1,:) - lij(2,:)) <= 1;
    else
        respects_tree_level = abs (d(ijw(1,:)) - d(ijw(2,:)))' <= ijw(3,:);
    end
    if any (not (neither_in | respects_tree_level))
        out = -5;
        return
    end
    ```
### 输出结果
+   ```
    SCALE
    Graph generation parameter
    edgefactor
    Graph generation parameter
    NBFS
    Number of BFS searches run, 64 for non-trivial graphs
    construction_time
    The single kernel 1 time
    bfs_min_time, bfs_firstquartile_time, bfs_median_time, bfs_thirdquartile_time, bfs_max_time
    Quartiles for the kernel 2 times
    bfs_mean_time, bfs_stddev_time
    Mean and standard deviation of the kernel 2 times
    bfs_min_nedge, bfs_firstquartile_nedge, bfs_median_nedge, bfs_thirdquartile_nedge, bfs_max_nedge
    Quartiles for the number of input edges visited by kernel 2, see TEPS section above.
    bfs_mean_nedge, bfs_stddev_nedge
    Mean and standard deviation of the number of input edges visited by kernel 2, see TEPS section above.
    bfs_min_TEPS, bfs_firstquartile_TEPS, bfs_median_TEPS, bfs_thirdquartile_TEPS, bfs_max_TEPS
    Quartiles for the kernel 2 TEPS
    bfs_harmonic_mean_TEPS, bfs_harmonic_stddev_TEPS
    Mean and standard deviation of the kernel 2 TEPS.
    sssp_min_time, sssp_firstquartile_time, sssp_median_time, sssp_thirdquartile_time, sssp_max_time
    Quartiles for the kernel 3 times
    sssp_mean_time, sssp_stddev_time
    Mean and standard deviation of the kernel 3 times
    sssp_min_nedge, sssp_firstquartile_nedge, sssp_median_nedge, sssp_thirdquartile_nedge, sssp_max_nedge
    Quartiles for the number of input edges visited by kernel 3, see TEPS section above.
    sssp_mean_nedge, sssp_stddev_nedge
    Mean and standard deviation of the number of input edges visited by kernel 3, see TEPS section above.
    sssp_min_TEPS, sssp_firstquartile_TEPS, sssp_median_TEPS, sssp_thirdquartile_TEPS, sssp_max_TEPS
    Quartiles for the kernel 3 TEPS
    sssp_harmonic_mean_TEPS, sssp_harmonic_stddev_TEPS
    Mean and standard deviation of the kernel 3 TEPS.
    ```