aws_region             = "eu-north-1"
ami_id                 = "ami-0581e088266b4baf2"  # Update to latest Ubuntu AMI
instance_type          = "t3.medium"
key_name               = "microservice"
private_key_path       = "~/.ssh/microservice.pem"  # Use ~ instead of ${path.home}
ssh_user               = "ubuntu"
ansible_inventory_path = "./../ansible/inventory.ini"
server_name            = "micro_service_server"