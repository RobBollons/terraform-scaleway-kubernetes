# terraform-scaleway-kubernetes

A simple [Terraform](https://terraform.io) script for provisioning a [Kubernetes](http://kubernetes.io) cluster on [Scaleway](https://scaleway.com) with [Calico](https://www.projectcalico.org/) for networking and [Traefik](https://traefik.io) for routing/load balancing.

By default this will provision a master and a single node running [Grafana](https://grafana.com/), [Prometheus](https://prometheus.io/)

## Getting Started

```bash
git clone git@github.com:RobBollons/terraform-scaleway-kubernetes.git && cd terraform-scaleway-kubernetes # Clone down the repo
cp terraform.tfvars.template terraform.tfvars && $EDITOR terraform.tfvars # Create and edit the tfvars file with your own values
terraform init # Initialise terraform and the saleway provider
terraform apply # Follow the prompt to create your cluster
```
