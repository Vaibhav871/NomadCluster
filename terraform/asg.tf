resource "aws_autoscaling_group" "nomad_client_asg" {
  name                      = "nomad-client-asg"
  max_size                  = 5
  min_size                  = var.nomad_client_count
  desired_capacity          = var.nomad_client_count
  health_check_type         = "EC2"
  health_check_grace_period = 120
  vpc_zone_identifier       = [aws_subnet.public.id]

  launch_template {
    id      = aws_launch_template.nomad_client_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "nomad-client"
    propagate_at_launch = true
  }

  tag {
    key                 = "Cluster"
    value               = "nomad-cluster"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_role" "nomad_client_role" {
  name = "nomad-client-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "nomad_client_policy" {
  name        = "nomad-client-policy"
  description = "IAM policy for Nomad client EC2 to describe instances for cluster discovery"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nomad_client_policy_attach" {
  role       = aws_iam_role.nomad_client_role.name
  policy_arn = aws_iam_policy.nomad_client_policy.arn
}

resource "aws_iam_instance_profile" "nomad_client_profile" {
  name = "nomad-client-instance-profile"
  role = aws_iam_role.nomad_client_role.name
}
