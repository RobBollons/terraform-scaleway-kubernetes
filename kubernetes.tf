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

  provisioner "file" {
    source = "./traefik.yaml"
    destination = "/tmp/traefik.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sed -i 's/- .* # External IP/- ${self.public_ip} # External IP' /tmp/traefik.yaml",
      "sed -i 's/main \= \"kube.domain.com\"/main \= \"${var.lets_encrypt_domain}\"' /tmp/traefik.yaml",
      "sed -i 's/email \= \"user@domain.com\"/email \= \"${var.lets_encrypt_username}\"' /tmp/traefik.yaml"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/install-k8s.sh",
      "kubeadm --token=${var.k8s_token} --service-dns-domain=$(scw-metadata --cached ID).pub.cloud.scaleway.com --pod-network-cidr=192.168.0.0/16 init",
      "export KUBECONFIG=/etc/kubernetes/admin.conf",
      "kubectl apply -f https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/hosted/etcd.yaml",
      "kubectl apply -f https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/hosted/calico.yaml",
      "kubectl taint nodes --all node-role.kubernetes.io/master-",
      "kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml",
      "kubectl create -f /tmp/traefik.yaml"
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
