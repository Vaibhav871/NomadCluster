resource "aws_instance" "nomad_client" {
  count                       = var.nomad_client_count
  ami                         = var.nomad_ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.nomad_sg.id]
  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/../cloud-init/nomad-client.sh", {
    NOMAD_SERVER_IP = aws_instance.nomad_server.private_ip
  }))


  depends_on = [aws_instance.nomad_server]

  tags = {
    Name = "nomad-client-${count.index}"
  }
}
