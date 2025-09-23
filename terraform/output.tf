output "bastion_public_ip" {
  description = "Public IP address of Bastion host"
  value       = aws_instance.bastion.public_ip
}

output "nomad_server_private_ip" {
  description = "Private IP address of Nomad server"
  value       = aws_instance.nomad_server.private_ip
}


output "nomad_ui_port" {
  description = "Nomad UI port"
  value       = 4646
}