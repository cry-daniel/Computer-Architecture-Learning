#   ssh连接的地址，本机跑 Simpoint 则忽略
SSH_ROUTE=stu1@10.184.17.65:

#   存放 Simpoint 结果的地址，改成自己的
SIM_ROUTE=/home/data/ChenRuiyang/SimPoint.3.2/output/gem5

#   存放 Reload 结果的地址，改成自己的
RELOAD_ROUTE=/home/data/ChenRuiyang/gem5/m5out/RELOAD

scp -r ${SSH_ROUTE}${SIM_ROUTE}/* ./simpoint
scp -r ${SSH_ROUTE}${RELOAD_ROUTE}/* ./stats