import os

# tests 里的是 configs_XXX.sh 后面的 XXX
tests=['graph500']

for item in tests:
    # 第一个是进行 Simpoint 模拟的，第二个是正常跑的，理论上只用 Simpoint 就可以了，第二行命令可以注释掉
    # ">" 后面的是将运行的输出重定向的地址，改成自己的即可
    os.system('nohup time bash process_sim.sh '+item+' /home/data/ChenRuiyang/time_rec/sim_ > /home/data/ChenRuiyang/time_rec/'+item+'_process.txt &')
    #os.system('nohup time bash process_normal.sh '+item+' /home/data/ChenRuiyang/time_rec/normal_ > /home/data/ChenRuiyang/time_rec/'+item+'_normal.txt &')    
