import os

tests=['gcc_r','gcc_r_long','mcf_r']

for item in tests:
    os.system('nohup time bash process_sim.sh '+item+' /home/data/ChenRuiyang/time_rec/sim_ > /home/data/ChenRuiyang/time_rec/'+item+'_process.txt &')
    os.system('nohup time bash process_normal.sh '+item+' /home/data/ChenRuiyang/time_rec/normal_ > /home/data/ChenRuiyang/time_rec/'+item+'_normal.txt &')    
