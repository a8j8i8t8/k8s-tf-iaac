#!/usr/bin/env bash
set -e -o pipefail

TF_OUTPUT=$(cd ./main && terraform output -json)
CLUSTER_NAME="$(echo ${TF_OUTPUT} | jq -r .k8s_cluster_name.value)"
STATE="s3://$(echo ${TF_OUTPUT} | jq -r .kops_state_store.value)"

kops delete cluster --state ${STATE} --name ${CLUSTER_NAME} --yes

cd ./main
terraform destroy -auto-approve