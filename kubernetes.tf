provider "scaleway" {
  organization = "${var.organization_key}"
  token        = "${var.secret_key}"
  region       = "${var.region}"
}

resource "scaleway_server" "k8s_master" {
  count = 1
  name  = "k8s-master"
  image = "${var.base_image_id}"
  type  = "${var.server_type}"
  public_ip = "${var.k8s_master_ip}"

  connection {
    user = "${var.ssh_user}"
    private_key = "${file(var.ssh_key_path)}"
  }

  provisioner "file" {
    source = "./install-k8s.sh"
    destination = "/tmp/install-k8s.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/install-k8s.sh",
      "kubeadm --token=${var.k8s_token} --service-dns-domain=$(scw-metadata --cached ID).pub.cloud.scaleway.com --pod-network-cidr=192.168.0.0/16 init",
      "export KUBECONFIG=/etc/kubernetes/admin.conf",
      "kubectl apply -f https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/hosted/etcd.yaml",
      "kubectl apply -f https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/hosted/calico.yaml",
      "kubectl taint nodes --all node-role.kubernetes.io/master-",
    ]
  }
}

resource "scaleway_server" "k8s_node" {
  count = "${var.k8s_node_count}"
  name  = "k8s-node-${count.index + 1}"
  image = "${var.base_image_id}"
  depends_on = ["scaleway_server.k8s_master"]
  dynamic_ip_required = "true"
  type  = "${var.server_type}"

  connection {
    user = "${var.ssh_user}"
    private_key = "${file(var.ssh_key_path)}"
  }

  provisioner "file" {
    source = "./install-k8s.sh"
    destination = "/tmp/install-k8s.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/install-k8s.sh",
      "kubeadm join --discovery-token-unsafe-skip-ca-verification --token=${var.k8s_token} ${var.k8s_master_ip}:6443"
    ]
  }
}
