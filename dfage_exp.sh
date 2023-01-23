# echo ${PWD}
# export GPUNFA_ROOT=${PWD}
cd ${GPUNFA_ROOT}
cd results

# if [ ! -d "exp_dfage" ]; then
#     mkdir exp_dfage && cd exp_dfage
# else
#     cd exp_dfage
# fi

n=0
while ! mkdir exp_dfage_$n
do
    n=$((n+1))
done

cd exp_dfage_$n

cp ${GPUNFA_ROOT}/gpunfa_code/scripts/configs/* .

echo "Running Experiments... This will take several hours. "
python ${GPUNFA_ROOT}/gpunfa_code/scripts/launch_exps.py -b app_spec_d -f exec_config_table_d -e --clean

echo "Experiments finished. "


if [ $? -eq 0 ]; then
    echo "Collecting experiment raw data."
    python ${GPUNFA_ROOT}/gpunfa_code/scripts/collect_results.py -b app_spec_d -f exec_config_table_d


    echo "Generate the Table 3 from the raw data."
    python ${GPUNFA_ROOT}/gpunfa_code/scripts/ploting/abs_throughput_table_d.py 
    python ${GPUNFA_ROOT}/gpunfa_code/scripts/ploting/plot_norm_throughput_d.py 

    echo "You may find a csv file in the folder, which shows comparison for infant2 speedup to infant. "
else
    echo "Experiments terminate abnormally."
    exit 1
fi

cd ${GPUNFA_ROOT}