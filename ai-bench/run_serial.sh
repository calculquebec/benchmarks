#!/bin/bash
source ai-bench-venv/bin/activate

BASE_DIR=$PWD

export HF_HOME=$BASE_DIR/hf_cache
export HF_DATASETS_CACHE=$BASE_DIR/hf_cache
export TRANSFORMERS_CACHE=$BASE_DIR/hf_cache

export HF_DATASETS_OFFLINE=1
export TRANSFORMERS_OFFLINE=1

export CUBLAS_WORKSPACE_CONFIG=:4096:8

read -p "How many GPUs will be used to run this benchmark?" n_proc;

export BENCH_PARALLELISM="DISABLED"

run_bench(){
   
   cd $BASE_DIR/benchmarks/$1
   echo "Running $1 benchmark in serial mode with $n_proc device(s)..."

      
   accelerate launch --mixed_precision=fp16 --num_machines=1 --num_processes=$n_proc  main.py --max_epochs=10
 
}


echo "Starting benchmark suite..."

BENCHMARKS=`ls $BASE_DIR/benchmarks`

for bench in $BENCHMARKS
do

   run_bench $bench

done

cd $BASE_DIR

echo "Collecting results and generating final performance report..."

python $BASE_DIR/reporting/make_final_report.py --n_gpus=1 | tee result_serial.txt

# Output the result
RESULT=$(awk '/Final score/ {a=$3} END {print a}' result_serial.txt)

echo Test,Hostname,Timestamp,Score
echo AI-SERIAL,$(hostname),$(date '+%F %T'),$RESULT
