output "server_ip" {
  value       = aws_instance.todo_server.public_ip
  description = "Public IP address of the microservice server"
}

output "server_id" {
  value       = aws_instance.todo_server.id
  description = "ID of the EC2 instance"
}

output "security_group_id" {
  value       = aws_security_group.micro_service.id
  description = "ID of the security group"
}

output "ssh_connection" {
  value       = "ssh -i ${var.private_key_path} ${var.ssh_user}@${aws_instance.todo_server.public_ip}"
  description = "SSH connection command"
}

output "ansible_inventory_path" {
  value       = var.ansible_inventory_path
  description = "Path to the generated Ansible inventory file"
}