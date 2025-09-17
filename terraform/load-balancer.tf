# # -------------------------
# # ALB Security Group
# # -------------------------
# resource "aws_security_group" "alb_sg" {
#   name        = "alb-sg"
#   description = "Allow HTTP/HTTPS traffic in"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description = "HTTP from anywhere"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # -------------------------
# # Allow ALB to reach Nomad clients on app port 8080
# # -------------------------
# resource "aws_security_group_rule" "allow_alb_to_clients" {
#   type                     = "ingress"
#   from_port                = 8080
#   to_port                  = 8080
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.nomad_sg.id
#   source_security_group_id = aws_security_group.alb_sg.id
#   description              = "Allow ALB to reach Nomad clients on app port"
# }

# # -------------------------
# # ALB + Target Group
# # -------------------------
# resource "aws_lb" "app" {
#   name               = "nomad-client-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb_sg.id]
#   subnets            = [aws_subnet.public.id]
# }

# resource "aws_lb_target_group" "client" {
#   name     = "client-target-group"
#   port     = 8080
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.main.id

#   health_check {
#     path                = "/"
#     protocol            = "HTTP"
#     matcher             = "200"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }
# }

# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.app.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.client.arn
#   }
# }

# resource "aws_lb_target_group_attachment" "client" {
#   count            = var.nomad_client_count
#   target_group_arn = aws_lb_target_group.client.arn
#   target_id        = aws_instance.nomad_client[count.index].id
#   port             = 8080
# }
