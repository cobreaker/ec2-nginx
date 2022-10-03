
provider "aws" {
  region     = "eu-central-1"
  access_key = ""
  secret_key = ""
  version    = "~> 3.1"

}

locals {
  ssh_user         = "ubuntu"
  private_key_path = "~/webserver04.pem"
  vpc_id           = "vpc-02944b5a73f51e65b"
  subnet_id        = "subnet-09e06357d2b5ccb38"
  key_name         = "webserver04"
}


resource "aws_security_group" "web" {

  name   = "web_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
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


resource "aws_instance" "web" {
  ami                         = "ami-0caef02b518350c8b"
  subnet_id                   = local.subnet_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.web.id]
  key_name                    = local.key_name

  tags = {
    Name = "Ao-week-4-web: Web Server"
  }


  provisioner "remote-exec" {
    inline = ["echo 'SSH is up'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.web.public_ip
    }


  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.web.public_ip}, --private-key ${local.private_key_path} deployment.yaml"

  }

}




output "publicIp" {
  value = aws_instance.web.public_ip
}
