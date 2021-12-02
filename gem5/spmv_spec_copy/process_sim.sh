#!/bin/bash

NAME=$1

. ./configs/configs_${NAME}.sh

if [ ${SE_OR_FS} == SE ];then
cd ${SH_ROUTE};nohup time bash sim_init.sh ${NAME} > ${REC_ROUTE}/${SE_NAME}_init.txt 
cd ${SH_ROUTE};nohup time bash sim_generate_sim_weight.sh ${NAME} > ${REC_ROUTE}/${SE_NAME}_sim_weight.txt 
cd ${SH_ROUTE};nohup time bash sim_generate_checkpoint.sh ${NAME} > ${REC_ROUTE}/${SE_NAME}_checkpoint.txt 
times=$(ls ${GEM5_PATH}/${SE_OUT_DIR_CHECKPOINT} | wc -l)
mkdir ${REC_ROUTE}/${SE_NAME}_O3
for ((i=1;i<=times;i++))
do cd ${SH_ROUTE};nohup time bash sim_O3.sh $i ${NAME} > ${REC_ROUTE}/${SE_NAME}_O3/$i.txt
done
elif [ ${SE_OR_FS} == FS ];then
cd ${SH_ROUTE};nohup time bash sim_init.sh ${NAME} > ${REC_ROUTE}/${FS_NAME}_init.txt
cd ${SH_ROUTE};nohup time bash sim_generate_sim_weight.sh ${NAME} > ${REC_ROUTE}/${FS_NAME}_sim_weight.txt
cd ${SH_ROUTE};nohup time bash sim_generate_checkpoint.sh ${NAME} > ${REC_ROUTE}/${FS_NAME}_checkpoint.txt
times=$(ls $GEM5_PATH/${FS_OUT_DIR_CHECKPOINT} | wc -l)
mkdir ${REC_ROUTE}/${FS_NAME}_O3
for ((i=1;i<=times;i++))
do cd ${SH_ROUTE};nohup time bash sim_O3.sh $i ${NAME} > ${REC_ROUTE}/${FS_NAME}_O3/$i.txt
done
else
echo SE_OR_FS should be SE or FS 
fi
echo ${NAME} has been done! >> ~/ChenRuiyang/time_rec/done_tests.txt
