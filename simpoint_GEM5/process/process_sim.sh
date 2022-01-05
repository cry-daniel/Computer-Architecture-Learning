#!/bin/bash

NAME=$1

#   注：这里是 ./configs 而不是 ../configs 是因为调用它的文件在上一级
. ./configs/configs_${NAME}.sh

if [ ${SE_OR_FS} == SE ];then
#   下面两行是清空记录的数据的文件夹
rm -r ${REC_ROUTE}/${SE_NAME};
mkdir ${REC_ROUTE}/${SE_NAME};
#   下面三行依次是初始化、使用simpoint计算切分点和权重、依据算出来的结果写checkpoint
cd ${SH_ROUTE};nohup time bash sim_init.sh ${NAME} > ${REC_ROUTE}/${SE_NAME}/${SE_NAME}_init.txt 
cd ${SH_ROUTE};nohup time bash sim_generate_sim_weight.sh ${NAME} > ${REC_ROUTE}/${SE_NAME}/${SE_NAME}_sim_weight.txt 
cd ${SH_ROUTE};nohup time bash sim_generate_checkpoint.sh ${NAME} > ${REC_ROUTE}/${SE_NAME}/${SE_NAME}_checkpoint.txt 
#   times 是读写了多少个 checkpoint
times=$(ls ${GEM5_PATH}/${SE_OUT_DIR_CHECKPOINT} | grep simpoint | wc -l)
mkdir ${REC_ROUTE}/${SE_NAME}/${SE_NAME}_O3
for ((i=1;i<=times;i++))
#   对每一个 checkpoint 做 O3 重载
do cd ${SH_ROUTE};nohup time bash sim_O3.sh $i ${NAME} > ${REC_ROUTE}/${SE_NAME}/${SE_NAME}_O3/$i.txt &
done

else
echo SE_OR_FS should be SE 
fi

#   将完成的结果写到文件里面
echo ${NAME} has been done! >> /home/data/ChenRuiyang/time_rec/done_tests.txt