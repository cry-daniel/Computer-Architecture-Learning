import os
import numpy as np
import sys
sys.path.append('.')
import configs
import utils

route='graph_500_s_13_e_12_O3' # sim & weight 记得改 configs.py 里的 route
route_normal='graph_500_s_13_e_12_normal'


def cal_sim():
    dir=[]
    res=[]
    stats_name=configs.stats_name
    start_sym=configs.start_sym
    paras_sym=configs.paras_sym
    paras=configs.paras
    weight=utils.read_weight_file()
    for root,subdir,file in os.walk(route):
        #print(root,subdir,file)
        if root == route:
            for i in subdir:
                dir.append(i)
        for subfile in file:
            #print(subfile)
            if subfile == stats_name:
                #print('yes')
                fp=open(root+'/'+subfile)
                res.append(fp.readlines())

    num=0

    for stats in res:
        tot=-1
        for line in stats:
            if start_sym in line:
                tot+=1
            if tot == 1:
                for i in range(len(paras_sym)):
                    flag,para=utils.fin(paras_sym[i],line)
                    if flag == True:
                        #print(res[num])
                        if i == 0:
                            paras[i]=para
                        else:
                            paras[i]+=para*weight[num]
        num+=1

    for i in range(len(paras_sym)):
        print(paras_sym[i],paras[i])
    print()
    print("Simpoint results are:")
    print("IPC =",paras[1]/(2.5e9*paras[2]))
    print("Dcache miss rate =",paras[4]/(paras[3]+paras[4]))
    print("Predict incorrect rate =",paras[6]/paras[5])
    print("ROB stall rate =",paras[7]/paras[8])
    
def cal_normal():
    dir=[]
    res=[]
    stats_name=configs.stats_name
    start_sym=configs.start_sym
    paras_sym=configs.paras_sym_nor
    paras=configs.paras_nor
    for root,subdir,file in os.walk(route_normal):
        #print(root,subdir,file)
        if root == route:
            for i in subdir:
                dir.append(i)
        for subfile in file:
            #print(subfile)
            if subfile == stats_name:
                #print('yes')
                fp=open(root+'/'+subfile)
                res.append(fp.readlines())
                
    for stats in res:
        for line in stats:
            for i in range(len(paras_sym)):
                flag,para=utils.fin(paras_sym[i],line)
                if flag == True:
                    paras[i]=para

    #for i in range(len(paras_sym)):
        #print(paras_sym[i],paras[i])
    print()
    print("Normal results are:")
    print("IPC =",paras[1]/(2.5e9*paras[2]))
    print("Dcache miss rate =",paras[4]/(paras[3]+paras[4]))
    print("Predict incorrect rate =",paras[6]/paras[5])
    print("ROB stall rate =",paras[7]/paras[8])
    
if __name__ == "__main__":
    cal_sim()
    cal_normal()
    