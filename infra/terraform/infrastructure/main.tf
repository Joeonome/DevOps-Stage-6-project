provider "aws" {
  region = var.aws_region
}

# Security Group for the microservice
resource "aws_security_group" "micro_service" {
  name        = "micro_service"
  description = "Allow SSH and Web Traffic"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "micro_service_sg"
  }
}

# EC2 Instance for microservice
resource "aws_instance" "todo_server" {
  ami                    = "ami-0fa91bc90632c73c9"
  instance_type          = "t3.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.micro_service.id]

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
    tags = {
      Name = "${var.server_name}-root-volume"
    }
  }

  user_data = <<-EOF
#!/bin/bash
set -e

# Log output
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting user data script..."

# Update system
echo "Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

# Install prerequisites
echo "Installing prerequisites..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

# Add Docker GPG key
echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
echo "Installing Docker..."
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Enable and start Docker
echo "Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# Add ubuntu user to docker group
echo "Adding ubuntu user to docker group..."
sudo usermod -aG docker ubuntu

# Verify installation
echo "Verifying Docker installation..."
docker --version
docker compose version

# Create a flag file to indicate completion
touch /home/ubuntu/.docker-installed

echo "User data script completed successfully!"
EOF

  tags = {
    Name = var.server_name
  }
}

# Generate Ansible inventory file
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/${var.ansible_inventory_path}"
  content  = <<-EOT
[servers]
todo_server ansible_host=${aws_instance.todo_server.public_ip} ansible_user=${var.ssh_user} ansible_ssh_private_key_file=${var.private_key_path}

[servers:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
EOT

  depends_on = [aws_instance.todo_server]
}

resource "null_resource" "wait_for_instance" {
  depends_on = [aws_instance.todo_server, local_file.ansible_inventory]

  provisioner "local-exec" {
    command = <<-EOT
echo "Waiting for instance ${aws_instance.todo_server.public_ip} to be ready..."
sleep 30

max_attempts=60
attempt=0

while [ $attempt -lt $max_attempts ]; do
  echo "Attempt $((attempt + 1))/$max_attempts: Checking SSH connectivity..."
  
  if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i ${var.private_key_path} ${var.ssh_user}@${aws_instance.todo_server.public_ip} "echo 'SSH is ready' && [ -f /home/ubuntu/.docker-installed ]" 2>/dev/null; then
    echo "✅ Instance is ready and Docker is installed!"
    exit 0
  fi
  
  attempt=$((attempt + 1))
  sleep 20
done

echo "❌ Timeout waiting for instance to be ready"
exit 1
EOT
  }

  triggers = {
    instance_id = aws_instance.todo_server.id
  }
}

# Run Ansible playbook
resource "null_resource" "ansible_provision" {
  depends_on = [null_resource.wait_for_instance]

  provisioner "local-exec" {
    command = <<-EOT
echo "Running Ansible playbook against ${aws_instance.todo_server.public_ip}..."
echo "Inventory file location: ${path.module}/${var.ansible_inventory_path}"
echo "Inventory file contents:"
cat ${path.module}/${var.ansible_inventory_path}
echo "---"

ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook \
  -i ${path.module}/${var.ansible_inventory_path} \
  ${path.module}/${var.ansible_playbook_path} \
  --timeout=60 \
  -vv
EOT
  }

  triggers = {
    instance_id = aws_instance.todo_server.id
    
  }
}
