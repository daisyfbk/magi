#!/bin/bash

VERSION="1.7.0"
TARGET=$1
SSH_OPTIONS="-i ~/.ssh/google_compute_engine"

if [[ -z $TARGET ]]; then
    echo "Need the target host name"
    exit
fi

wget https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.linux-amd64.tar.gz
tar xvfz node_exporter-$VERSION.linux-amd64.tar.gz

if [[ -n "$USE_GCLOUD" ]]; then
    gcloud compute scp --recurse --zone "$GCP_ZONE" node_exporter-$VERSION.linux-amd64 $TARGET:~/
else
    scp -r node_exporter-$VERSION.linux-amd64 $TARGET:
fi

# Run remotely in background
command="cd node_exporter-*.linux-amd64; nohup ./node_exporter > ~/node-exporter.log 2>&1 & echo \$! > ~/node-exporter.pid; disown" 
if [[ -n "$USE_GCLOUD" ]]; then
    gcloud compute ssh --zone "$GCP_ZONE" "$TARGET" -- "$command"
else
    ssh $SSH_OPTIONS "$TARGET" "$command"
fi
rm -rf node_exporter-$VERSION.linux-amd64 node_exporter-$VERSION.linux-amd64.tar.gz