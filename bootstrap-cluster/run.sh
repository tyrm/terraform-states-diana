#!/usr/bin/env bash

# add secrets
source ~/.config/terraform/secrets
envsubst < main.tf.template > main.tf
envsubst < consul-values.yaml.template > consul-values.yaml

# run terraform
terraform init
terraform apply -auto-approve
