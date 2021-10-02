#Python Tricks
---

*Copy right by ChenRuiyang*

---

##一些优雅的写法
+   添加 utils.py, config.py，其中 utils.py 写一些功能性的函数，configs.py 写一些常用参数. 需要里面的函数就 import utils,config. 如果引用 utils.py 或者 config.py 的 python 文件和他们在同一文件夹下，就不需要任何操作，否则需要加如下语句：
    ```python
    import sys
    sys.path.append('path_to_utils_or_config')
    ```
    举个例子，如果他们在上一级文件夹中，则可以这么写
    ```python
    import sys
    sys.path.append('..')
    ```
+   `if __name__ == "__main__":` 
    上面的语句可以做到只有在运行自己时才执行if语句，如果是被其他 python 文件调用，则 if 语句将被忽略.
    这是因为__name__是文件的一个属性，如果是被其他 python 文件调用，__name__将会变成其他，可以 print 一下看看是什么.
+   ```python
    from tqdm import tqdm
    for i in tqdm(range(1,10005))
    ```
    tqdm 可以给循环加进度条，很好用.
+   ```python
    dataPath=config.dataPath
    for root, dirs, files in os.walk(dataPath):
        for file in tqdm(files):
            filePath=os.path.join(root, file)
    ```
    遍历文件的写法，注意第二个 for 循环的 root 并不是第一个 for 循环的 root，而是对应 file in files 中每一个 file 的 root.
+   numpy保存读取的格式，举几个例子
    ```python
    import numpy as np
    np.savetxt(r'../data/x1.txt',x[1],fmt='%s',newline='\n')
    np.save(r'../data/x1.npy',x[1])
    x1=np.load('../data/x1.npy')
    x2=np.load('../data/x1.txt')
    ```
+   对矩阵的行列哪个在前哪个在后傻傻分不清，对np.size不会用，看看下面的输出结果就懂了：
    ```python
    test=[[1,3,4,2],
    [2,1,4,3],
    [3,2,4,4],
    [4,1,1,2]]

    print(test[0][2])
    print(np.size(test),np.size(test,1),np.size(test,0))
    ```