#!/usr/bin/env bash

# Author: Maxat Akbanov
# Description: Shell script to create base64 encoded Kubernetes secret
# Usage: ./create_kube_secret.sh

echo "Please specify your secret string: "
read SECRET
echo -n $SECRET | base64