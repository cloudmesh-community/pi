#!/usr/bin/env bash
# Install requirements for the master Kubernetes node on Raspberry Pi
# usage:
# sudo kubernetes-master-setup.sh
# Examples:
#   sudo kubernetes-setup.sh

POD_CIDR="10.244.0.0/16"

usage() { echo "Usage: $0 [-c <pod-cidr>] [-a <apiserver ip address>]" 1>&2; exit 1; }

while getopts ":c:a:" o; do
    case "${o}" in
        c)
            POD_CIDR=${OPTARG}
            ;;
        a)
            APISERVER_IP=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z $APISERVER_IP ]; then
  WLAN0_IP=$(ifconfig wlan0 | grep '\binet\b' | awk '{print $2}')
  ETH0_IP=$(ifconfig eth0 | grep '\binet\b' | awk '{print $2}')

  if [ ! -z $WLAN_IP ]; then
    APISERVER_IP=$WLAN0_IP
    echo "Setting --apiserver-advertise-address to wlan0 IP $APISERVER_IP"
  else
    if [ ! -z $ETH0_IP ]; then
      APISERVER_IP=$ETH0_IP
      echo "Setting --apiserver-advertise-address to eth0 IP $APISERVER_IP"
    fi
  fi
fi

if [ -z $APISERVER_IP ]; then
  echo No valid IP found. Please run again with -a option to set --apiserver-advertise-address
  exit 1
fi

# Pre-pull the images to make the init command go faster
kubeadm config images pull

# Fix a warning message in kubeadm init
modprobe ip_vs
modprobe ip_vs_sh
modprobe ip_vs_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe nf_conntrack_ipv4

kubeadm init --token-ttl=0 "--pod-network-cidr=$POD_CIDR" "--apiserver-advertise-address=$APISERVER_IP"

# kubeadm join --token <token> --discovery-token-ca-cert-hash <ca hash>

mkdir -p "$HOME/.kube"
cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
chown "$(id -u)":"$(id -g)" "$HOME/.kube/config"


kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
