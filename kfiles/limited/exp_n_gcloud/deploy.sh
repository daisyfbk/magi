#!/bin/bash

# First:  apache/spark:4.0.0-scala2.13-java17-python3-r-ubuntu
# Uncompressed size: 947 MB

images=(
    pytorch/pytorch:2.7.1-cuda11.8-cudnn9-runtime # Uncompressed size: 3106 MB
    jupyter/scipy-notebook:x86_64-python-3.11.6 # Uncompressed size: 1255 MB
    tensorflow/serving:latest-gpu # Uncompressed size: 3636 MB
    jupyter/tensorflow-notebook:x86_64-ubuntu-22.04 # Uncompressed size: 1780 MB
    ollama/ollama:rocm # Uncompressed size: 1320 MB
    google/cloud-sdk:529.0.0 # Uncompressed size: 1366 MB
    mathworks/matlab:r2025a # Uncompressed size: 2272 MB
    mathworks/matlab-deep-learning:r2024a # Uncompressed size: 6942 MB
    intel/deep-learning:pytorch-gpu-latest-py3.11 # Uncompressed size: 3830 MB
)

kubectl apply -n limited -f deployment.yaml 
sleep 10

for image in "${images[@]}"; do
    echo "Image: $image"
    # pod_name="test"
    # if [[ $i -eq 0 ]]; then
    #     kubectl deploy -n limited --image "$image"
    #         test-1 --replicas 1  

    #     kubectl run -n limited --image "$image" "$pod_name" \
    #         --overrides='{"spec":{"nodeSelector":{"magi-id":"1"}}}'
    # else
    #     kubectl 
    # sleep 5
    # kubectl delete pod -n limited "$pod_name" 
    kubectl patch deployment -n limited test-1 --type='json' -p="[{\"op\": \"replace\", \"path\": \"/spec/template/spec/containers/0/image\", \"value\": \"$image\"}]"
    sleep 10
    echo "Done with $image"
    echo "-----------------------------------"
done

# for image in "${images[@]}"; do
#     echo "Image: $image"
#     unc=$(docker manifest inspect "$image" | jq -c '.layers[].size' | paste -sd+ | bc)
#     echo "Uncompressed size: $((unc / 1024 / 1024)) MB"
# done

# Unused images:
# jupyter/scipy-notebook:x86_64-lab-4.0.7
# tensorflow/serving:2.18.0-gpu
# jupyter/tensorflow-notebook:tensorflow-2.14.0
# ollama/ollama:0.9.4-rc2-rocm
# apache/spark:3.5.6-scala2.12-java17-r-ubuntu