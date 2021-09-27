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
  x = np.random.normal(size=(M.shape[1],))
  ans = M.dot(x)
  x = list(x)
  ans = list(ans)

  data = list(M.data)
  colidx = list(M.indices)
  rowptr = list(M.indptr)
  rowb = rowptr[:-1]
  rowe = rowptr[1:]
  order = list(range(M.shape[0]))

  os.makedirs(output_path, exist_ok=True)

  with open(output_path + '/info.txt', 'w') as ff:
    ff.write(str(len(M.data)))
    ff.write('\n')
    ff.write(str(M.shape[0]))
    ff.write('\n')
    ff.write(str(M.shape[1]))
    ff.write('\n')
  with open(output_path + '/nnz.txt', 'w') as ff:
    for i in data:
      ff.write(str(i))
      ff.write(' ')
  with open(output_path + '/col.txt', 'w') as ff:
    for i in colidx:
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
  for pathname in glob.glob('matrices/*.mtx'):
    name = os.path.splitext(os.path.basename(pathname))[0]
    print('Load %s' % name)
    matrix = scipy.io.mmread(pathname)
    matrix = scipy.sparse.csr_matrix(matrix)
    nonzeros = matrix.count_nonzero()
    matrices.append((nonzeros, name, matrix))

  matrices.sort(key=lambda x: x[0])

  print('Write list.txt')
  with open(DATA_PATH + '/list.txt', 'w') as f:
    for m in matrices:
      f.write(str(m[0]) + '\t' + m[1] + '\n')
  
  print('Write matrices')
  for m in matrices:
    print('Write %s' % m[1])
    output(DATA_PATH + '/' + m[1], m[2])

if __name__ == '__main__':
  main()