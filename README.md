# Nomad Cluster Infrastructure Project

This project provisions a **secure, scalable, and resilient HashiCorp Nomad cluster on AWS using Terraform**. It demonstrates distributed systems provisioning, secure networking, infrastructure-as-code best practices, and automation with optional observability (Prometheus + Grafana).  

---

## Features

- **Infrastructure as Code (IaC):** Reproducible Terraform scripts for AWS deployment.  
- **Networking:** Isolated **VPC** with subnets, route tables, and security groups.  
- **Secure Access:** Bastion host for controlled SSH access to internal nodes.  
- **Nomad Cluster:**  
  - Nomad Server (control plane, bootstrap mode: 1 server for demo; 3+ recommended for production).  
  - Nomad Client (executes workloads with Docker).  
- **Workload Deployment:** Nomad job to run a sample **hello-world web app**.  
- **Observability:** Prometheus & Grafana .

---

## Architecture

The deployed infrastructure includes:

- **VPC** with subnets, internet gateway, and associated route table.  
- **Bastion host** (public subnet, SSH accessible).  
- **Nomad server** (private subnet, runs cluster control plane).  
- **Nomad client** (private subnet, runs workloads via Docker).  
- **Security groups:** Granular, least-privilege access policies.  
- **monitoring stack:** Grafana + Prometheus .  

---

## Components Provisioned

- **VPC**  
- **Subnets** (public/private)  
- **Internet gateway & route table**  
- **Security groups**  
- **EC2 instances:**  
  - Bastion (with public IP)  
  - Nomad Server (control plane)  
  - Nomad Client (workloads)  
- **AWS key pair** (from local public key)  
- **Bootstrapping scripts:**  
  - Nomad Server + Docker  
  - Nomad Client + Docker  
- **Nomad job file:** deploys hello-world web app  
- **monitoring stack:** Prometheus + Grafana  

---

## Prerequisites

- AWS account with permissions to create VPC, EC2, and related components.  
- Terraform (>= v1.5 recommended).  
- Existing AWS SSH key pair (public key added to variables).  
- Local machine with SSH & `/usr/bin/ssh-agent` available.  



