#!/usr/bin/env python3
import glob
import os
import sys
import numpy as np
import scipy
import scipy.io
import scipy.sparse

DATA_PATH = './data'


def output(output_path, M):
  np.random.seed(1)
  x = np.random.normal(size=(M.shape[1],))  #正态分布的矩阵
  #print((M.shape[1],))
  #input()
  ans = M.dot(x) #输入矩阵和x做矩阵乘法
  x = list(x)
  ans = list(ans)

  data = list(M.data) #输入矩阵的数据
  colindx = list(M.indices)  #data中的数据在矩阵中其所在行的所在列数
  rowptr = list(M.indptr) #矩阵中每一行的数据在data中开始和结束的索引
  '''
  >>> indptr = np.array([0, 2, 3, 6])
  >>> indices = np.array([0, 2, 2, 0, 1, 2])
  >>> data = np.array([1, 2, 3, 4, 5, 6])
  >>> sparse.csc_matrix((data, indices, indptr), shape=(3, 3)).toarray()
  array([[1, 0, 4],
        [0, 0, 5],
        [2, 3, 6]])
  '''
  rowb = rowptr[:-1] #rowptr中除了最后一个
  rowe = rowptr[1:] #rowptr中除了第一个
  order = list(range(M.shape[0])) #行数 ？ 从0开始到M.shape[0]

  os.makedirs(output_path, exist_ok=True) #建文件夹

  with open(output_path + '/info.txt', 'w') as ff: #分别储存非零元个数，行数，列数
    ff.write(str(len(M.data)))
    ff.write('\n')
    ff.write(str(M.shape[0]))
    ff.write('\n')
    ff.write(str(M.shape[1]))
    ff.write('\n')
  with open(output_path + '/nnz.txt', 'w') as ff: #data -> nnz.txt
    for i in data:
      ff.write(str(i))
      ff.write(' ')
  with open(output_path + '/col.txt', 'w') as ff: #colindx -> col.txt
    for i in colindx:
      ff.write(str(i))
      ff.write(' ')
  with open(output_path + '/row.txt', 'w') as ff: #rowptr -> row.txt
    for i in rowptr:
      ff.write(str(i))
      ff.write(' ')
  with open(output_path + '/rowb.txt', 'w') as ff:
    for i in rowb:
      ff.write(str(i))
      ff.write(' ')
  with open(output_path + '/rowe.txt', 'w') as ff:
    for i in rowe:
      ff.write(str(i))
      ff.write(' ')
  with open(output_path + '/x.txt', 'w') as ff:
    for i in x:
      ff.write(str(i))
      ff.write(' ')
  with open(output_path + '/order.txt', 'w') as ff:
    for i in order:
      ff.write(str(i))
      ff.write(' ')
  with open(output_path + '/ans.txt', 'w') as ff:
    for i in ans:
      ff.write(str(i))
      ff.write(' ')


def main():
  matrices = []
  print('Loading matrices')
  for pathname in glob.glob('matrices/*.mtx'):  #读 matrices/ 文件夹下所有后缀为 .mtx 的文件
    name = os.path.splitext(os.path.basename(pathname))[0]
    print('Load %s' % name)
    matrix = scipy.io.mmread(pathname)  #读稀疏矩阵，自动过滤注释
    matrix = scipy.sparse.csr_matrix(matrix)  #将稀疏矩阵.mtx转化成array
    nonzeros = matrix.count_nonzero() #统计非零元个数
    matrices.append((nonzeros, name, matrix)) #将非零元、名称以及矩阵加入矩阵列表

  matrices.sort(key=lambda x: x[0]) #以非零元个数从小到大重排矩阵列表 ？

  #print(matrices[0])
  #input()

  print('Write list.txt')
  with open(DATA_PATH + '/list.txt', 'w') as f:   #统计矩阵信息，写进list.txt内
    for m in matrices:
      f.write(str(m[0]) + '\t' + m[1] + '\n')
      #print(m)
      #input()
  
  print('Write matrices')
  for m in matrices:
    print('Write %s' % m[1])
    output(DATA_PATH + '/' + m[1], m[2])
    #print(m[1],m[2])
    #input()

if __name__ == '__main__':
  main()