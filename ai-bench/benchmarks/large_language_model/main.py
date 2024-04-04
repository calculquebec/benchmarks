import sys
sys.path.append("../../reporting/") # Will make the whole bench into a package eventually, but for now...
from reporting_utils import init_report, save_report

import json
import os
import argparse
import time

import transformers
from transformers import LlamaForCausalLM, LlamaTokenizerFast
from transformers.models.llama.configuration_llama import LlamaConfig
from transformers import TrainingArguments

from datasets import load_dataset
from datasets import DatasetDict

from accelerate import Accelerator

from trl import SFTTrainer

accelerator = None
proc_id = None

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


   with open("./llama_model.config", "r") as file:
      config = json.load(file)

   dataset = load_dataset("HuggingFaceH4/ultrachat_200k", split="train_gen")

   tokenizer = LlamaTokenizerFast.from_pretrained("hf-internal-testing/llama-tokenizer")

   tokenizer.pad_token = tokenizer.eos_token

   model = LlamaForCausalLM(LlamaConfig.from_dict(config))

   def preprocess(samples):
      batch = []
      for conversation in samples["messages"]:
         batch.append(tokenizer.apply_chat_template(conversation, tokenize=False))
      return {"content": batch}


   training_set=DatasetDict()

   training_set["train"] = dataset.map(preprocess,
            batched=True,
             remove_columns=dataset.column_names
            )

   trainer = SFTTrainer(
     model=model,
     train_dataset=training_set["train"],
     tokenizer=tokenizer,
     packing=True,
     dataset_text_field="content",
     max_seq_length=2048,
     args=transformers.TrainingArguments(
        output_dir="./",
        per_device_train_batch_size=8,
        gradient_accumulation_steps=1,
        gradient_checkpointing=True,
        max_steps=15,
        logging_steps=1,
        learning_rate=2.5e-5, # Want a small lr for finetuning
        optim="adamw_torch",
        logging_dir="./logs",        # Directory for storing logs
        remove_unused_columns=False,
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
       report["avg_flops"] = training_history["total_flos"] / (8/training_history["train_samples_per_second"])
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

