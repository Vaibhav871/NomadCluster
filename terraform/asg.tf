resource "aws_launch_template" "nomad_client" {
  name          = "nomad-client"
  image_id      = var.nomad_client_ami            # Your Packer-built Nomad AMI ID
  instance_type = var.nomad_client_instance_type  # e.g., "t3.micro"
  key_name      = var.key_name

  # Cloud-init or override config not needed if baked into AMI
  iam_instance_profile = aws_iam_instance_profile.nomad_client_profile.id
  security_group_names = [aws_security_group.nomad_client_sg.name]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "nomad-client"
      NomadClient = "true"
    }
  }
}

resource "aws_autoscaling_group" "nomad_clients" {
  desired_capacity     = var.nomad_client_desired_count  # Set in tfvars
  min_size             = 1
  max_size             = 10
  vpc_zone_identifier  = [aws_subnet.public.id]          # List of subnet IDs for ASG

  launch_template {
    id      = aws_launch_template.nomad_client.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "nomad-client"
    propagate_at_launch = true
  }
}

# Example variables (add to variables.tf)
variable "nomad_client_ami" {}
variable "nomad_client_instance_type" { default = "t3.micro" }
variable "nomad_client_desired_count" { default = 2 }
variable "key_name" {} # For SSH if required

# IAM Instance Profile, Security Group, and Subnet resources assumed configured elsewhere.
