#!/bin/bash

echo "DOCKER_OPTS='-H unix:///var/run/docker.sock --storage-driver aufs --label provider=scaleway --mtu=1500 --insecure-registry=10.0.0.0/8'" > /etc/default/docker
systemctl restart docker

curl -fsSL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

apt update -qq
apt install -y -q --no-install-recommends kubeadm kubelet kubectl

echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bashrc
