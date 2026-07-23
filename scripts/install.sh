#!/bin/sh
set -eu

namespace="${1:-free5gc-zebra-test}"
deployment="${2:-free5gc-zebra-ueransim-ue}"
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
manifest_dir="${script_dir}/../kustomize"

sed "s/name: free5gc-zebra-ueransim-ue/name: ${deployment}/" \
    "${manifest_dir}/remove-existing-sidecars.yaml" |
    kubectl -n "${namespace}" patch deployment "${deployment}" \
        --type=strategic --patch-file=/dev/stdin

sed "s/name: free5gc-zebra-ueransim-ue/name: ${deployment}/" \
    "${manifest_dir}/ue-deployment-patch.yaml" |
    kubectl -n "${namespace}" patch deployment "${deployment}" \
        --type=strategic --patch-file=/dev/stdin

kubectl -n "${namespace}" apply -f "${manifest_dir}/service.yaml"
kubectl -n "${namespace}" rollout status "deployment/${deployment}" --timeout=300s
