#!/bin/bash

###############################################################################
#
# Connect pgadmin4 pod with postgres db hosted in Cloud SQL,
# and port-forward it to localhost.
#
###############################################################################

set -euo pipefail
set -o nounset

K8S_NAMESPACE="$(cd terraform && terraform output --raw kubernetes_namespace)"
POD_NAME=$(kubectl get pod -l app=pgadmin4 -o jsonpath="{.items[0].metadata.name}")
POSTGRES_USER="$(cd terraform && terraform output --raw postgres_user)"

# connect pgAdmin with database
kubectl -n="${K8S_NAMESPACE}" exec "${POD_NAME}" --stdin --tty --container pgadmin4 \
    -- /venv/bin/python setup.py \
    --load-servers server-config/psql-server.json \
    --user "${POSTGRES_USER}"

# port-forward pgAdmin service to http://localhost:8080
kubectl -n="${K8S_NAMESPACE}" port-forward service/pgadmin4 8080:80