from numpy.core.fromnumeric import sort
import configs
import numpy as np
from cal_stats import sim_route,weight_route

num_list=['0','1','2','3','4','5','6','7','8','9','.']

def isdig(a): #处理小数
    if a in num_list:
        return True
    return False

def fin(para_sym,line):
    flag=False
    para=0
    if para_sym in line:
        if para_sym == configs.seconds_sym:
            para+=float("".join(list(filter(isdig,line))))
        else:
            para+=float("".join(list(filter(str.isdigit,line))))
        flag=True
    return flag,para

def read_weight_file(weight_route=weight_route,sim_route=sim_route):
    f_w=open(weight_route)
    f_s=open(sim_route)
    weight=f_w.readlines()
    sim=f_s.readlines()
    length=len(weight)
    wei_sim=np.zeros((length,2))
    for i in range(length):
        temp=""
        for num in weight[i]:
            if isdig(num):
                temp+=num
                continue
            break
        wei_sim[i,0]=float(temp)
        temp=""
        for num in sim[i]:
            if isdig(num):
                temp+=num
                continue
            break
        wei_sim[i,1]=float(temp)
    sorted_wei_sim=sorted(wei_sim,key=lambda x:x[1])
    res=[]
    for item in sorted_wei_sim:
        res.append(item[0])
    return res

def num_sort(a):
    if str.isdigit(a[0]):
        return int(a)
    else:
        return a

if __name__=="__main__":
    print(read_weight_file())