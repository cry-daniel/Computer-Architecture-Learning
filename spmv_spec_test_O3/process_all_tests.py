import os

tests=['cpu_change','cache_change','mem_change']

for item in tests:
    os.system('nohup time bash process_O3.sh '+item+' /home/data/ChenRuiyang/time_rec/sim_ > /home/data/ChenRuiyang/time_rec/'+item+'_process.txt &')
    #os.system('nohup time bash process_normal.sh '+item+' /home/data/ChenRuiyang/time_rec/normal_ > /home/data/ChenRuiyang/time_rec/'+item+'_normal.txt &')    
