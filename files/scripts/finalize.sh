#!/bin/sh

sleep 15

KUBECONFIG=output/kubeconfig

if [ ! -f $KUBECONFIG ]; then
    echo "Kubeconfig file not found"
    exit 1
fi

# check if kubectl is installed
if ! [ -x "$(command -v kubectl)" ]; then
    echo "kubectl is not installed"
    exit 1
fi

kubectl apply -k infrastructure/flux 
kubectl apply -k infrastructure/cloud-controller-manager 
kubectl apply -k infrastructure/cinder-csi
kubectl apply -k infrastructure/cert-manager

# Install Emmissary
kubectl create namespace emissary || true
kubectl apply -f https://app.getambassador.io/yaml/emissary/3.9.1/emissary-crds.yaml

kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system

kubectl apply -f https://app.getambassador.io/yaml/emissary/3.9.1/emissary-emissaryns.yaml
kubectl -n emissary wait --for condition=available --timeout=90s deploy -lproduct=aes  || true

kubectl label --overwrite --all nodes topology.cinder.csi.openstack.org/zone=nova
