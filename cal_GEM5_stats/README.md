##  测试配置
+   Python 3.8.10

### 使用说明
+   核心程序为 `cal_stats.py` ，该程序使用说明如下：
    ```
    usage: cal_stats.py [-h] [-c] [-r] [-n]

    A tool for calculate stats for GEM5

    optional arguments:
    -h, --help     show this help message and exit
    -c, --compare  use compare method to calculate error rate
    -r, --reload   calculate reload stats
    -n, --normal   calculate normal stats
    ```
+   normal 模式为抽取并计算正常情况(即无 checkpoint 的情况)下 GEM5 的部分参数信息.
+   reload 模式为抽取并计算采用 Simpoint 重载后 GEM5 的部分参数信息，建议配合 simpoint_GEM5 一起使用.
+   compare 模式为比较 normal 和 reload 的误差. 

### 示例步骤
1.  更改 get_stats.sh 中的路径，将数据读入文件夹中，运行命令：
    ```bash
    bash get_stats.sh
    ```
    注：这里的 get_stats.sh 是配套 simpoint_GEM5 里结果使用的，对于其他结果需要自己根据需求调整.
2.  修改 cal_stats.py 中的 sim_name，运行命令：
    ```bash
    python cal_stats.py -c
    ```
    此命令是进行比较，不更新数据采用默认数据输出结果如下：
    ```
    Simpoint results are:
    IPC = 1.6477541695712086
    Dcache miss rate = 0.07962523778881567
    Predict incorrect rate = 0.016028486480200825

    Normal results are:
    IPC = 1.617784874066762
    Dcache miss rate = 0.07957689978578111
    Predict incorrect rate = 0.015927835343287462

    Errors are:
    IPC : 1.852489535837374 %
    Dcache miss : 0.06074376252992806 %
    Predict incorrect : 0.6319197476873759 %
    ```
    发现使用 Simpoint 的结果(即文件夹中的样例)非常准确.

### 拓展
+   程序可拓展性非常强，更改或增加 configs.py 以及 cal_stats.py 中的变量即可算出对应的不同参数.