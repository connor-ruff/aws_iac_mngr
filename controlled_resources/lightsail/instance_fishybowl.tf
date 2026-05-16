resource "aws_lightsail_instance" "fishybowl" {
  name              = "fishybowl"
  availability_zone = "us-east-1a"
  blueprint_id      = "ubuntu_24_04"
  bundle_id         = "nano_3_0"
  key_pair_name     = "LightsailDefaultKeyPair"
  ip_address_type   = "dualstack"
}

# fishybowl does not have a static IP — its public IP can change on stop/start
resource "aws_lightsail_instance_public_ports" "fishybowl" {
  instance_name = aws_lightsail_instance.fishybowl.name

  port_info {
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    cidrs      = ["0.0.0.0/0"]
    ipv6_cidrs = ["::/0"]
  }

  port_info {
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    cidrs      = ["0.0.0.0/0"]
    ipv6_cidrs = ["::/0"]
  }
}

import {
  to = aws_lightsail_instance.fishybowl
  id = "fishybowl"
}

