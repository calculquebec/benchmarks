import sys
sys.path.append("../../reporting/") # Will make the whole bench into a package eventually, but for now...
from reporting_utils import init_report, save_report
import os

import transformers

from transformers import AutoTokenizer, AutoModelForSequenceClassification, Trainer
from transformers.training_args import ParallelMode
from accelerate import Accelerator
from datasets import load_dataset

import argparse

accelerator = None

report = init_report()

proc_id = os.environ['LOCAL_RANK']

if os.environ['BENCH_PARALLELISM'] == "ENABLED":

   accelerator = Accelerator()
   report["num_gpus"] = accelerator.num_processes

else:
   report["num_gpus"] = 1
   os.environ['CUDA_VISIBLE_DEVICES'] = os.environ['LOCAL_RANK']
   os.environ['MASTER_PORT'] = str(int(os.environ['LOCAL_RANK']) + 3456)
   os.environ['WORLD_SIZE'] = "1"
   os.environ.pop('RANK')
   os.environ.pop('LOCAL_RANK')


def main():

   import torch

   torch.backends.cudnn.benchmark = False
   torch.use_deterministic_algorithms(True)
   torch.manual_seed(42)

   if os.environ['BENCH_PARALLELISM'] == "DISABLED":

      torch.cuda.set_device(0)

   dataset = load_dataset("glue", "cola")["train"]

   tokenizer = AutoTokenizer.from_pretrained("google-bert/bert-base-cased")
   model = AutoModelForSequenceClassification.from_pretrained("google-bert/bert-base-cased")

   def tokenize_func(examples):
       return tokenizer(examples["sentence"], padding=True, truncation=True)

   training_set = dataset.map(tokenize_func, batched=True)

   training_args = {'output_dir': "./",
        'per_device_train_batch_size': 512,
        'num_train_epochs': 10,
        'learning_rate': 2.5e-5, # Want a small lr for finetuning
        'optim': "adamw_torch",
        'logging_dir': "./logs",
        #"fp16": fp16,
        "log_level": 'debug'}

   trainer = Trainer(
     model=model,
     train_dataset=training_set,
     tokenizer=tokenizer,
     args=transformers.TrainingArguments(
        **training_args
     ),
   )

   trainer.train()
    
   accelerator = Accelerator()

   accelerator.wait_for_everyone()

   training_history = trainer.state.log_history[-1]

   if accelerator.is_main_process:

       report["train_run_time"] = training_history["train_runtime"] 
       report["train_samples_per_second"] = training_history["train_samples_per_second"]
       report["train_steps_per_second"] = training_history["train_steps_per_second"]
       report["avg_flops"] = training_history["total_flos"] / (512/training_history["train_samples_per_second"])
       report["train_loss"] = training_history["train_loss"]
       report["status"] = "PASS"

       print(report)
   return report

if __name__=='__main__':

   try:
      report  = main()

   except:
      if accelerator:
         if accelerator.is_main_process:
            print("Benchmark FAILED. Skipping...")
      else:
         if proc_id == "0":
             print("Benchmark FAILED. Skipping...")
      
      report["status"]="FAIL"

   if accelerator:
      if accelerator.is_main_process:
         save_report(report)
   else:
       if proc_id == "0":
         save_report(report)
