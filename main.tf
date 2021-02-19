
provider "aws" {
  region = "eu-central-1"
}

# Generate new private key
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
}
# Generate a key-pair with above key
resource "aws_key_pair" "deployer" {
  key_name   = "efs-key"
  public_key = tls_private_key.my_key.public_key_openssh
}
# Saving Key Pair for ssh login for Client if needed
resource "null_resource" "save_key_pair"  {
  provisioner "local-exec" {
    command = "echo  ${tls_private_key.my_key.private_key_pem} > mykey.pem"
  }
}

resource "local_file" "foo" {
  content     = tls_private_key.my_key.private_key_pem
  filename = "${path.module}/ssh_key.pem"
}

resource "aws_security_group" "web-sg" {
  name = "web-sg"
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "EFS mount target"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners           = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  user_data     = file("init-script.sh")
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web-sg.id]
}

### efs
resource "aws_efs_file_system" "efs" {
  creation_token   = "EFS Shared Data"
  performance_mode = "generalPurpose"
}
resource "aws_efs_mount_target" "efs" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_instance.web.subnet_id
  security_groups = [aws_security_group.web-sg.id]
}

data "template_file" "script" {
  template = file("script.tpl")
  vars = {
    efs_id = aws_efs_file_system.efs.id
  }
}

### output

output "domain-name" {
  value = aws_instance.web.public_dns
}

output "application-url" {
  value = "${aws_instance.web.public_dns}/index.php"
}
