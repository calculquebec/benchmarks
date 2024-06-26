#!/bin/bash
source ai-bench-venv/bin/activate

BASE_DIR=$PWD

export HF_HOME=$BASE_DIR/hf_cache
export HF_DATASETS_CACHE=$BASE_DIR/hf_cache
export TRANSFORMERS_CACHE=$BASE_DIR/hf_cache

export HF_DATASETS_OFFLINE=1
export TRANSFORMERS_OFFLINE=1

export CUBLAS_WORKSPACE_CONFIG=:4096:8

MAIN_NODE=$1
MAIN_PORT=$2
N_NODES=$3
N_GPUS=$4
MACHINE_RANK=$OMPI_COMM_WORLD_RANK

export BENCH_PARALLELISM="ENABLED"

N_PROCS=$((${N_NODES} * ${N_GPUS}))

run_bench_parallel(){

   cd $BASE_DIR/benchmarks/$1
   echo "Running $1 benchmark with ${N_NODES} nodes and ${N_GPUS} device(s) per node..."

   if [ "$1" == "large_language_model" ]; then

       accelerate launch  --mixed_precision=fp16 --num_machines=${N_NODES} --num_processes=${N_PROCS} --main_process_ip=${MAIN_NODE} --main_process_port=${MAIN_PORT} --machine_rank=${MACHINE_RANK} --config_file="${BASE_DIR}/configs/fsdp_llama.yaml"  main.py

   else

       accelerate launch --multi_gpu --mixed_precision=fp16 --num_machines=${N_NODES} --num_processes=${N_PROCS} --main_process_ip=${MAIN_NODE} --main_process_port=${MAIN_PORT} --machine_rank=${MACHINE_RANK} main.py

   fi

}


echo "Starting benchmark suite..."

#BENCHMARKS="large_language_model" #`ls $BASE_DIR/benchmarks`
BENCHMARKS=`ls $BASE_DIR/benchmarks`

for bench in $BENCHMARKS
do

   run_bench_parallel $bench

done

cd $BASE_DIR

echo "Collecting results and generating final performance report..."

python $BASE_DIR/reporting/make_final_report.py --n_gpus=$N_PROCS | tee result_parallel.txt

# Output the result
RESULT=$(awk '/Final score/ {a=$3} END {print a}' result_parallel.txt)

echo Test,Hostname,Timestamp,NbNodes,NbGPUPerNode,Score
echo AI-PARALLEL,$(hostname),$(date '+%F %T'),$N_NODES,$N_GPUS,$RESULT
