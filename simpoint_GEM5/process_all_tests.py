import os
import argparse

#   tests 里的是 configs_XXX.sh 后面的 XXX
#   例: configs_graph500.sh 中的 XXX 为 graph500
#   如果要同时做多组就写成 tests=['e1','e2','e3',...]
sim_tests=['graph500']
reload_tests=['graph500']

parser=argparse.ArgumentParser(description='A tool for simpoint , test and cal stats')
parser.add_argument("-s","--simpoint",help="use simpoint to generate checkpoint",
                    action="store_true")
parser.add_argument("-r","--reload",help="use new parms to reload checkpoint",
                    action="store_true")
args=parser.parse_args()

def simpoint(tests):
    for item in tests:
        #   第一个是进行 Simpoint 模拟的，第二个是正常跑的，是验证 Simpoint 结果准确性的，
        #   理论上生成 Simpoint 就可以了，第二行命令可以注释掉
        #   ">" 后面的是将运行的输出重定向的地址，改成自己的即可
        os.system('nohup time bash process/process_sim.sh '+item+' > \
                /home/data/ChenRuiyang/time_rec/'+item+'_process.txt &')
        #os.system('nohup time bash process_normal.sh '+item+' /home/data/ChenRuiyang/time_rec/normal_ > \
            # /home/data/ChenRuiyang/time_rec/'+item+'_normal.txt &')
            
def reload(tests):
    for item in tests:
        #   同上，只改了.sh文件的名字，执行重载操作
        os.system('nohup time bash process/process_reload.sh '+item+' > \
            /home/data/ChenRuiyang/time_rec/'+item+'_reload.txt &')

#   这里不能 simpoint 和 reload 同时做，
#   因为 reload 需要 simpoint 的结果
if args.simpoint:
    simpoint(sim_tests)
elif args.reload:
    reload(reload_tests)
else:
    print("    Please give input parms.")
    print("    e.g. -s or -r")