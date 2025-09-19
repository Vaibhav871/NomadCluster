resource "aws_launch_template" "nomad_client_lt" {
  name_prefix   = "nomad-client-lt-"
  image_id      = var.nomad_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.nomad_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.nomad_client_profile.name
  }

  user_data = base64encode(file("${path.module}/../cloud-init/nomad-client.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "nomad-client"
      Cluster = "nomad-cluster"
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }
}
