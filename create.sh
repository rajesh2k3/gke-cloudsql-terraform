#!/bin/bash

###############################################################################
#
# Creates all resources with Terraform.
#
###############################################################################

# Bash safeties: exit on error, no unset variables, pipelines can't hide errors
set -o errexit
set -o nounset
set -o pipefail

# Initialize and run Terraform
echo 'Creating GCP resources'
(cd "terraform"; terraform init -input=false)
(cd "terraform"; terraform apply -input=false -auto-approve)

# Get cluster credentials
echo 'Updating kube-config'
GET_CREDS="$(terraform output --state=terraform/terraform.tfstate --raw get_credentials)"
${GET_CREDS}