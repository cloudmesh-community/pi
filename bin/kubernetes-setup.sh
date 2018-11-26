#!/usr/bin/env bash
# Install requirements for Kubernetes on Raspberry Pi
# usage:
# kubernetes-setup.sh
# Examples:
#   sudo kubernetes-setup.sh

# Check for root user
if [[ $EUID -ne 0 ]]; then
  echo "You must be root to run this script. Run with:" 1>&2
  printf >&2 "sudo %s\\n" "$(realpath --relative-to="$(pwd)" "$0")"
  exit 1
fi

# Install Docker
# This is currently installing a version of docker 18.09 that is not verified by
# kubernetes on the Pi
curl -sSL get.docker.com \
  | sh \
  && usermod pi -aG docker

# NEXT DOWNGRADE to the latest supported docker version 18.06.1
# first, stop the docker service that is running
systemctl stop docker.service
# then downgrade the package
apt-get install -qy --allow-downgrades docker-ce=18.06.1~ce~3-0~raspbian
# and restart the docker service (this is probability not necessary)
systemctl start docker.service

# Add kubernetes repository and update caches
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update -q

# Install kubernetes kubeadm
apt-get install -qy kubeadm

# Make the system changes necessary for Kubernetes

# Disable Swap
dphys-swapfile swapoff && \
  dphys-swapfile uninstall -qy && \
  update-rc.d dphys-swapfile remove

echo Adding " cgroup_enable=cpuset cgroup_enable=1 cgroup_enable=memory" to /boot/cmdline.txt
cp /boot/cmdline.txt /boot/cmdline.bak.txt

new_options="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo "$new_options" | tee /boot/cmdline.txt

# Enable the following modules to avoid warnings
cat << EOF >> /etc/modules
ip_vs
ip_vs_sh
ip_vs_rr
ip_vs_wrr
nf_conntrack_ipv4
EOF

echo "You must now reboot. This can be done with the command:"
echo "$ sudo reboot"
