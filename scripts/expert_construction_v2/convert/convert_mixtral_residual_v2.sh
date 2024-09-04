#!/usr/bin/bash

#SBATCH --job-name=convert-residual
#SBATCH --output=logs_split/%x-%j.log
#SBATCH --error=logs_split/%x-%j.log

#SBATCH --partition=MoE
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=0

#SBATCH --nodes=1
#SBATCH --gres=gpu:0
#SBATCH --quotatype=auto

# reserved spot auto

{
  model_path="/mnt/petrelfs/share_data/quxiaoye/models/Meta-Llama-3-8B-Instruct"

  num_experts=7
  num_residual=1
  top_k=1
  scale_factor=1.0
  moe_implementation_type="modulelist" #  modulelist megablocks scattermoe

  folder_name="${num_experts}experts-0.4jitter-l2"
  split_folder_name="split-gradient-max-ShareFalse-${num_residual}Residual-${num_experts}MoE"

  save_path="/mnt/petrelfs/share_data/quxiaoye/llama_moe_v2/converted_models/${split_folder_name}-Top${top_k}-Scale${scale_factor}"
  #  save_path="/mnt/petrelfs/share_data/quxiaoye/llama_moe_v2/v2_mixtral_gate/${folder_name}/models/${split_folder_name}-Top${top_k}-Scale${scale_factor}"
  neuron_indices_file="/mnt/petrelfs/share_data/quxiaoye/llama_moe_v2/v2_mixtral_gate/${folder_name}/results/${split_folder_name}/neuron_indices.pt"
  gate_weights_file="/mnt/petrelfs/share_data/quxiaoye/llama_moe_v2/v2_mixtral_gate/${folder_name}/results/gate_weights.pt"

  srun python smoe/entrypoint/expert_construction_v2/convert/convert_mixtral_residual_v2.py \
    --model_path ${model_path} \
    --save_path ${save_path} \
    --neuron_indices_file ${neuron_indices_file} \
    --gate_weights_file ${gate_weights_file} \
    --num_experts ${num_experts} \
    --top_k ${top_k} \
    --scale_factor ${scale_factor} \
    --moe_implementation_type ${moe_implementation_type}
}
