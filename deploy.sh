#!/bin/bash

###############################################################################
#
# Apply the configmap, secret, and deployment manifests to the cluster.
#
###############################################################################

set -euo pipefail
set -o nounset

K8S_NAMESPACE="$(cd terraform && terraform output --raw kubernetes_namespace)"

# Create the secret that includes the user/pass of postgres instance
echo 'Creating the postgres db secret'
POSTGRES_USER="$(cd terraform && terraform output --raw postgres_user)"
POSTGRES_PASS="$(cd terraform && terraform output --raw postgres_pass)"
kubectl -n="${K8S_NAMESPACE}" create secret generic postgres-credentials \
  --from-literal=user="${POSTGRES_USER}" \
  --from-literal=password="${POSTGRES_PASS}" \
  --dry-run=client -o yaml | kubectl apply -f -

# Create the configmap that includes the connection string to the postgres instance.
echo 'Creating the postgresql connenction string Configmap'
POSTGRES_CONNECTION="$(cd terraform && terraform output --raw postgres_instance_connection_name)"
kubectl -n="${K8S_NAMESPACE}" create configmap connectionname \
  --from-literal=connectionname="${POSTGRES_CONNECTION}" \
  --dry-run=client -o yaml | kubectl apply -f -

# Create the configmap which is used to import the db connection in pgadmin.
echo 'Creating db connection Configmap for pgadmin import'
#echo '{"Servers":{"1":{"Name":"Dummy Database","Group":"deloitte-challenge-server-group","Port":5432,"Username":"'${POSTGRES_USER}'","Host":"localhost","SSLMode":"prefer","MaintenanceDB":"postgres"}}}' \
#> psql-server.json
echo '{"Servers":{"1":{"Name":"Dummy Database","Group":"db-ws9kiam-dev-server-group","Port":5432,"Username":"'${POSTGRES_USER}'","Host":"localhost","SSLMode":"prefer","MaintenanceDB":"postgres"}}}' \
> psql-server.json
kubectl -n="${K8S_NAMESPACE}" create configmap psql-server \
  --from-file=psql-server.json \
  --dry-run=client -o yaml | kubectl apply -f -

# Create the K8s Service Account (KSA)
echo 'Creating Kubernetes Service Account'
kubectl -n="${K8S_NAMESPACE}" create serviceaccount postgres-ksa -n default \
  --dry-run=client -o yaml | kubectl apply -f -

# Annotate the KSA
echo 'Annotating Kubernetes Service Account'
GCP_SA="$(cd terraform && terraform output --raw gcp_serviceaccount)"
kubectl -n="${K8S_NAMESPACE}" annotate serviceaccount -n default postgres-ksa --overwrite=true iam.gke.io/gcp-service-account="${GCP_SA}"

# Apply k8s manifests
echo 'Applying Kubernetes manifests'
find k8s -name "*.yml" | xargs -I{} kubectl apply -f {} \
--namespace "${K8S_NAMESPACE}"
