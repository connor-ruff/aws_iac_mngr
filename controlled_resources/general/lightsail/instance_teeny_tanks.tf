resource "aws_lightsail_instance" "teeny_tanks" {
  name              = "teeny-tanks"
  availability_zone = "us-east-1a"
  blueprint_id      = "ubuntu_22_04"
  bundle_id         = "nano_3_0"
  key_pair_name     = "LightsailDefaultKeyPair"
  ip_address_type   = "dualstack"
}

resource "aws_lightsail_instance_public_ports" "teeny_tanks" {
  instance_name = aws_lightsail_instance.teeny_tanks.name

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

  port_info {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidrs     = ["0.0.0.0/0"]
  }
}

import {
  to = aws_lightsail_instance.teeny_tanks
  id = "teeny-tanks"
}

