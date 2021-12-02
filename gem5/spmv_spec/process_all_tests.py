import os

tests=['bzip2','gcc']
#,'mcf','milc','namd','gobmk']

'''
'povray','hmmer','sjeng','libquantum','h264ref',\
'lbm','omnetpp','astar','sphinx3','xalancbmk','specrand'\
'specrand_2']
'''
for item in tests:
    os.system('nohup time bash process_sim.sh '+item+' > /home/data/ChenRuiyang/time_rec/'+item+'_process.txt &')
