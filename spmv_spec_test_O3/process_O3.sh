#!/bin/bash

NAME=$1

. ../spmv_spec/configs/configs_graph500.sh

# $2 对应 spec17 输出的结果

if [ ${SE_OR_FS} == SE ];then
times=$(ls ${GEM5_PATH}/${SE_OUT_DIR_CHECKPOINT} | wc -l)
rm -r ${REC_ROUTE}/${SE_NAME}/${NAME}_O3
mkdir ${REC_ROUTE}/${SE_NAME}/${NAME}_O3
rm -r ${GEM5_PATH}/m5out/${NAME}_O3;
# -4 是因为有 config.ini,config.js,fs,stats.txt
for ((i=1;i<=times-4;i++))
do cd ${SH_ROUTE}/../spmv_spec_test_O3;nohup time bash sim_O3_${NAME}.sh $i ${NAME} > ${REC_ROUTE}/${SE_NAME}/${NAME}_O3/$i.txt
done
else
echo SE_OR_FS should be SE or FS 
fi
echo ${NAME} has been done! >> /home/data/ChenRuiyang/time_rec/done_tests.txt
