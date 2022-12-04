import os
import numpy as np
import argparse
import tools.configs
import tools.utils

# simpoint 文件对应的前缀，如不是使用 simpoint_GEM5 生成的则需要更改后面的 weight_route 与 sim_route
sim_name='graph500_s_14_e_14'

# 测试用的 CPU 是 2.5GHz 的，这个会被用来算 IPC. stats.txt 里的数据有问题，要自己手动设置
freq=2.5e9

normal_name='normal'
checkpoint_name='test'

route=f"./data/stats/{checkpoint_name}"
route_normal=f"./data/stats/{normal_name}"
weight_route=f"./data/simpoint/{sim_name}/{sim_name}_weight_file"
sim_route=f"./data/simpoint/{sim_name}/{sim_name}_simpoint_file"

IPC_nomral=IPC_sim=0
Dcache_miss_normal=Dcache_miss_sim=0
Pred_incorrect_normal=Pred_incorrect_sim=0
ROB_stall_normal=ROB_stall_sim=0

def cal_sim():
    dir=[]
    res=[]
    # stats_name = 'stats.txt'
    stats_name=tools.configs.stats_name
    # start_sym = '---------- Begin Simulation Statistics ----------'
    start_sym=tools.configs.start_sym
    # paras_sym 感兴趣的数据对应的关键词集合
    paras_sym=tools.configs.paras_sym
    # 用来记录那些数据的数组，大小为 len(paras_sym)
    paras=tools.configs.paras
    weight=tools.utils.read_weight_file(weight_route,sim_route)
    
    #   在并行执行reload时生成的文件夹可能不是顺序的，这个时候 os.walk 遍历就会出问题，解决方法是用 dir 记录每次访问的文件夹序号.
    for root,subdir,file in os.walk(route):
        if root == route:
            for i in subdir:
                dir.append(i)
        for subfile in file:
            #print(subfile)
            if subfile == stats_name:
                #print('yes')
                #print(root+'/'+subfile)
                fp=open(root+'/'+subfile)
                res.append(fp.readlines())
    
    num=0

    for stats in res:
        tot=-1
        for line in stats:
            if start_sym in line:
                tot+=1
            # 第一遍预热的数据不需要，所以等到tot==1(即第二遍访问到begin simulation的时候)才开始统计
            if tot == 1:
                for i in range(len(paras_sym)):
                    flag,para=tools.utils.fin(paras_sym[i],line)
                    if flag == True:
                        # i == 0 对应 freq ，这个是不变的
                        if i == 0:
                            paras[i]=para
                        else:
                            #   下面更改使得可以适应不同的顺序
                            paras[i]+=para*weight[int(dir[num])-1]
        num+=1

    # for i in range(len(paras_sym)):
    #     print(paras_sym[i],paras[i])
    
    # 2.5GHz 的 IPC ， GEM5 里统计的 freq 有问题
    IPC_sim=paras[1]/(freq*paras[2])
    Dcache_miss_sim=paras[4]/(paras[3]+paras[4])
    Pred_incorrect_sim=paras[6]/paras[5]
    ROB_stall_sim=paras[7]/paras[8]
    print()
    print("Simpoint results are:")
    print("IPC =",IPC_sim)
    print("Dcache miss rate =",Dcache_miss_sim)
    print("Predict incorrect rate =",Pred_incorrect_sim)
    #print("ROB stall rate =",ROB_stall_sim)
    
    return IPC_sim,Dcache_miss_sim,Pred_incorrect_sim,ROB_stall_sim
    
def cal_normal():
    dir=[]
    res=[]
    stats_name=tools.configs.stats_name
    paras_sym=tools.configs.paras_sym_nor
    paras=tools.configs.paras_nor
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
                flag,para=tools.utils.fin(paras_sym[i],line)
                if flag == True:
                    paras[i]=para

    #for i in range(len(paras_sym)):
        #print(paras_sym[i],paras[i])
    
    IPC_nomral=paras[1]/(freq*paras[2])
    Dcache_miss_normal=paras[4]/(paras[3]+paras[4])
    Pred_incorrect_normal=paras[6]/paras[5]
    ROB_stall_normal=paras[7]/paras[8]
    print()
    print("Normal results are:")
    print("IPC =",IPC_nomral)
    print("Dcache miss rate =",Dcache_miss_normal)
    print("Predict incorrect rate =",Pred_incorrect_normal)
    #print("ROB stall rate =",ROB_stall_normal)
    
    return IPC_nomral,Dcache_miss_normal,Pred_incorrect_normal,ROB_stall_normal  

def disp_error():
    def cal_error(a,b):
        return abs(a-b)/b
    
    print()
    print("Errors are:")
    print("IPC :",cal_error(IPC_sim,IPC_nomral)*100,'%')
    print("Dcache miss :",cal_error(Dcache_miss_sim,Dcache_miss_normal)*100,'%')
    print("Predict incorrect :",cal_error(Pred_incorrect_sim,Pred_incorrect_normal)*100,'%')
    #print("ROB stall:",cal_error(ROB_stall_sim,ROB_stall_normal)*100,'%')

parser=argparse.ArgumentParser(description="A tool for calculate stats for GEM5")
parser.add_argument("-c","--compare",help="use compare method to calculate error rate",
                    action="store_true")
parser.add_argument("-r","--reload",help="calculate reload stats",
                    action="store_true")
parser.add_argument("-n","--normal",help="calculate normal stats",
                    action="store_true")
args=parser.parse_args()

if __name__=="__main__":
    if args.compare:
        IPC_sim,Dcache_miss_sim,Pred_incorrect_sim,ROB_stall_sim=cal_sim()
        IPC_nomral,Dcache_miss_normal,Pred_incorrect_normal,ROB_stall_normal=cal_normal()
        disp_error()
    elif args.reload:
        cal_sim()
    elif args.normal:
        cal_normal()
    else:
        print("Please use -h to get help.")
