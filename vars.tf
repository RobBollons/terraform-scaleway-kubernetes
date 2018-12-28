variable "organization_key" {
  description = "Scaleway Organization Key"
  default = "00000000-0000-0000-0000-000000000000"
}

variable "secret_key" {
  description = "Scaleway Secret Key"
  default = "00000000-0000-0000-0000-000000000000"
}

variable "region" {
  description = "Scaleway region"
  default = "ams1"
}

variable "server_type" {
  description = "Scaleway server type"
  default = "START1-S"
}

variable "base_image_id" {
  description = "Base image ID"
  default = "b29a1c4e-43ed-4457-95f5-044ab7806e02"
}

variable "k8s_node_count" {
  description = "Number of nodes to provision in addition to the master"
  default = "1"
}

variable "k8s_token" {
  description = "Kubernetes token for registering new nodes"
  default = "000000.0000000000000000"
}

variable "k8s_master_ip" {
  description = "Kubernetes Master IP Address"
  default = "00.00.000.00"
}

variable "ssh_user" {
  description = "Remote SSH User"
  default = "root"
}

variable "ssh_key_path" {
  description = "SSH Private Key Path"
  default = "~/.ssh/id_rsa"
}

variable "lets_encrypt_username" {
  description = "LetsEncrypt Username"
  default = "user@domain.com"
}

variable "lets_encrypt_domain" {
  description = "LetsEncrypt Domain"
  default = "kube.domain.com"
}

