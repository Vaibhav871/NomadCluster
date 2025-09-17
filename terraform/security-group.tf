# -------------------------
# Bastion Security Group
# -------------------------
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH, Prometheus, Grafana from admin workstation"
  vpc_id      = aws_vpc.main.id

  # SSH from admin workstation
  ingress {
    description = "Allow SSH from admin workstation"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr] # Only your public IP
  }

  # Prometheus UI
  ingress {
    description = "Allow Prometheus from admin workstation"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # Grafana UI
  ingress {
    description = "Allow Grafana from admin workstation"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # Allow outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# -------------------------
# Nomad Cluster Security Group
# -------------------------
resource "aws_security_group" "nomad_sg" {
  name        = "nomad-cluster-sg"
  description = "Allow Nomad internal cluster and SSH from bastion"
  vpc_id      = aws_vpc.main.id

  # UI access from Bastion only (optionally, restrict further using a security group rule)
  ingress {
    description = "Nomad UI (4646) from Bastion host"
    from_port   = 4646
    to_port     = 4646
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id] # Allow from Bastion SG only
  }

  ingress {
    description = "Public access to apps on port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Opens to the world. Restrict as necessary.
  }
  
  # Nomad server RPC (4647, internal only)
  ingress {
    description      = "RPC (4647) within cluster"
    from_port        = 4647
    to_port          = 4647
    protocol         = "tcp"
    self             = true
  }

  # Serf LAN (4648, internal gossip)
  ingress {
    description      = "Serf LAN (4648) within cluster"
    from_port        = 4648
    to_port          = 4648
    protocol         = "tcp"
    self             = true
  }

  # Allow SSH from Bastion security group only
  ingress {
    description = "Allow SSH from Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Egress: Allow all traffic to outside (limit as needed)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nomad-cluster-sg"
  }
}
