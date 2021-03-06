#!/usr/bin/env bash
# Install requirements for the master Kubernetes node on Raspberry Pi
# usage:
# sudo kubernetes-master-setup.sh
# Examples:
#   sudo kubernetes-setup.sh

if [[ $EUID -ne 0 ]]; then
  echo "You must be root to run this script. Run with:" 1>&2
  printf >&2 "sudo %s\\n" "$(realpath --relative-to="$(pwd)" "$0")"
  exit 1
fi

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

if [ -z "$APISERVER_IP" ]; then
  WLAN0_IP=$(ifconfig wlan0 | grep '\binet\b' | awk '{print $2}')
  ETH0_IP=$(ifconfig eth0 | grep '\binet\b' | awk '{print $2}')

  if [ ! -z "$WLAN0_IP" ]; then
    APISERVER_IP=$WLAN0_IP
    echo "Setting --apiserver-advertise-address to wlan0 IP $APISERVER_IP"
  else
    if [ ! -z "$ETH0_IP" ]; then
      APISERVER_IP=$ETH0_IP
      echo "Setting --apiserver-advertise-address to eth0 IP $APISERVER_IP"
    fi
  fi
fi

if [ -z "$APISERVER_IP" ]; then
  echo No valid IP found. Please run again with -a option to set --apiserver-advertise-address
  exit 1
fi

# Pre-pull the images to make the init command go faster
echo "Pulling config images. This may take a while..."
kubeadm config images pull

init_output_file=$(mktemp /tmp/kubernetes-master-setup.XXXXX)

kubeadm init --token-ttl=0 --pod-network-cidr="$POD_CIDR" --apiserver-advertise-address="$APISERVER_IP" 2>&1 | tee "$init_output_file"
KUBEADM_RETVAL=$?
if [ $KUBEADM_RETVAL -ne 0 ]; then
  echo "kubeadm init failed. Aborting."
  exit $KUBEADM_RETVAL
fi

# Get the cluster join command
# `  kubeadm join 10.0.0.101:6443 --token h913u2.uh9ocdeqpz6zr9r6 --discovery-token-ca-cert-hash sha256:017b24e2b70873c5a993dda7e03cfee60761d4038d87232a8791c4a426587e75`
JOIN_CMD=$(tail -n 20 "$init_output_file" | awk '/kubeadm join/')
# Trim whitespace
JOIN_CMD=$(echo $JOIN_CMD)
JOIN_PARTS=($JOIN_CMD)
JOIN_IP=${JOIN_PARTS[2]}
JOIN_TOKEN=${JOIN_PARTS[4]}
JOIN_CA_HASH=${JOIN_PARTS[6]}

# Save these settings to a yaml file
cat << EOF > kubeadm-settings.yml
---
kubeadm:
  join-cmd: "$JOIN_CMD"
  ip: $JOIN_IP
  token: $JOIN_TOKEN
  ca-hash: $JOIN_CA_HASH
EOF

rm "$init_output_file"

mkdir -p "$HOME/.kube"
cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
chown "$(id -u)":"$(id -g)" "$HOME/.kube/config"


kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# kubectl get pods --namespace=kube-system
