resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH, Prometheus, Grafana from admin workstation"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH from admin workstation"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr] # Only your public IP
  }

  ingress {
    description = "Allow Prometheus from admin workstation"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "Allow Grafana from admin workstation"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

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

resource "aws_security_group" "nomad_client_sg" {
  name        = "nomad-client-sg"
  description = "Allow outbound Nomad ports to server SG and SSH from bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    description     = "Allow Nomad communication to Nomad server SG"
    from_port       = 4646
    to_port         = 4648
    protocol        = "tcp"
    security_groups = [aws_security_group.nomad_server_sg.id]
  }

  egress {
    from_port       = 4648
    to_port         = 4648
    protocol        = "udp"
    security_groups = [aws_security_group.nomad_server_sg.id]
  }

  egress {
    from_port       = 4647
    to_port         = 4647
    protocol        = "tcp"
    security_groups = [aws_security_group.nomad_server_sg.id]
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For public apps access
  }

  tags = {
    Name = "nomad-client-sg"
  }
}

resource "aws_security_group" "nomad_server_sg" {
  name        = "nomad-server-sg"
  description = "Allow Nomad internal cluster traffic and SSH from bastion and Nomad clients"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Nomad UI (4646) from Bastion host"
    from_port       = 4646
    to_port         = 4646
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description     = "Nomad cluster RPC (4647) from Nomad clients"
    from_port       = 4647
    to_port         = 4647
    protocol        = "tcp"
    security_groups = [aws_security_group.nomad_client_sg.id]
  }

  ingress {
    description     = "Serf LAN TCP (4648) from Nomad clients"
    from_port       = 4648
    to_port         = 4648
    protocol        = "tcp"
    security_groups = [aws_security_group.nomad_client_sg.id]
  }

  ingress {
    description     = "Serf LAN UDP (4648) from Nomad clients"
    from_port       = 4648
    to_port         = 4648
    protocol        = "udp"
    security_groups = [aws_security_group.nomad_client_sg.id]
  }

  ingress {
    description     = "Allow SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nomad-server-sg"
  }
}
