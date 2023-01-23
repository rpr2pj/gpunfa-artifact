# echo ${PWD}
# export GPUNFA_ROOT=${PWD}
cd ${GPUNFA_ROOT}
cd results

if [ ! -d "exp_infant2_infant" ]; then
    mkdir exp_infant2_infant && cd exp_infant2_infant
else
    cd exp_infant2_infant
fi

cp ${GPUNFA_ROOT}/gpunfa_code/scripts/configs/* .

echo "Running Experiments... This will take several hours. "
python ${GPUNFA_ROOT}/gpunfa_code/scripts/launch_exps.py -b app_spec -f exec_config_table -e --clean

echo "Experiments finished. "


if [ $? -eq 0 ]; then
    echo "Collecting experiment raw data."
    python ${GPUNFA_ROOT}/gpunfa_code/scripts/collect_results.py -b app_spec -f exec_config_table


    echo "Generate the Table 3 from the raw data."
    python ${GPUNFA_ROOT}/gpunfa_code/scripts/ploting/abs_throughput_table.py 
    python ${GPUNFA_ROOT}/gpunfa_code/scripts/ploting/plot_norm_throughput.py 

    echo "You may find a csv file in the folder, which shows comparison for infant2 speedup to infant. "
else
    echo "Experiments terminate abnormally."
    exit 1
fi

cd ${GPUNFA_ROOT}