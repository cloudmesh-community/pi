#!/usr/bin/env bash
# Install requirements for Kubernetes on Raspberry Pi
# usage:
# kubernetes-setup.sh
# Examples:
#   sudo kubernetes-setup.sh

# Check for root user
if [[ $EUID -ne 0 ]]; then
  echo "You must be root to run this script. Run with:" 1>&2
  printf >&2 "sudo %s %s %s\\n" "$(realpath --relative-to="$(pwd)" "$0")"
  exit 1
fi

# Install Docker
# This is currently installing a version of docker that is not supported by
# kubernetes on the Pi
curl -sSL get.docker.com \
  | sh \
  && usermod pi -aG docker

# Add docker repository
# add the repository to apt sources
# TEMP use original docker install
# echo "deb https://download.docker.com/linux/raspbian stretch stable" | tee /etc/apt/sources.list.d/docker.list
# add the gpg key
# curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

# Add kubernetes repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update -q


# Update apt caches
apt-get update

# Install docker and kubeadm
# apt-get install -qy docker-ce=18.06.1~ce~3-0~raspbian kubeadm

# TEMP use original docker install
# apt-get install -qy docker-ce=18.03.1~ce-0~raspbian 
apt-get install -qy kubeadm

# Disable Swap
dphys-swapfile swapoff && \
  dphys-swapfile uninstall -qy && \
  update-rc.d dphys-swapfile remove
echo Adding " cgroup_enable=cpuset cgroup_enable=1 cgroup_enable=memory" to /boot/cmdline.txt
cp /boot/cmdline.txt /boot/cmdline_backup.txt

orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo "$orig" | tee /boot/cmdline.txt

# Enable the following modules to avoid warnings
cat << EOF >> /etc/modules
ip_vs
ip_vs_sh
ip_vs_rr
ip_vs_wrr
nf_conntrack_ipv4
EOF

echo "You must now reboot. This can be done with the command:"
echo "sudo reboot"
