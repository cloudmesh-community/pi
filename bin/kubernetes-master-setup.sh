#!/usr/bin/env bash
# Install requirements for the master Kubernetes node on Raspberry Pi
# usage:
# sudo kubernetes-master-setup.sh
# Examples:
#   sudo kubernetes-setup.sh

# Pre-pull the images to make the init command go faster
kubeadm config images pull

# Fix a warning message in kubeadm init
sudo modprobe ip_vs && \
  sudo modprobe ip_vs_sh && \
  sudo modprobe ip_vs_vs && \
  sudo modprobe ip_vs_rr && \
  sudo modprobe ip_vs_wrr && \
  sudo modprobe nf_conntrack_ipv4

kubeadm init --token-ttl=0  --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=<internal master ip>

# kubeadm join --token <token> --discovery-token-ca-cert-hash <ca hash>

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config


kubectl apply -f \
   "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
