#!/usr/bin/env bash
# Install requirements for Kubernetes on Raspberry Pi
# usage:
# kubernetes-setup.sh
# Examples:
#   sudo kubernetes-setup.sh

# Install Docker
curl -sSL get.docker.com \
  | sh \
  && usermod pi -aG docker

# Disable Swap
dphys-swapfile swapoff \
  && dphys-swapfile uninstall -qy \
  && update-rc.d dphys-swapfile -qy remove
echo Adding " cgroup_enable=cpuset cgroup_enable=1 cgroup_enable=memory" to /boot/cmdline.txt
cp /boot/cmdline.txt /boot/cmdline_backup.txt

orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo "$orig" | tee /boot/cmdline.txt

# Add repo list and install kubeadm
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
  apt-get update -q && \
  apt-get install -qy kubeadm

echo "You must now reboot. This can be done with the command:"
echo "sudo reboot"
