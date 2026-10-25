# Lightsail Module

This module manages two Lightsail instances in `us-east-1`. Both run Ubuntu on the `nano_3_0` bundle (0.5 GB RAM, 2 vCPU, 20 GB SSD).

## Instances

| Terraform resource | Instance name | OS | Public IP | Static IP? |
|---|---|---|---|---|
| `fishybowl` | `fishybowl` | Ubuntu 24.04 | 44.203.242.160 | No — IP can change on stop/start |
| `teeny_tanks` | `teeny-tanks` | Ubuntu 22.04 | 54.196.95.235 | Yes — `StaticIp-teeny-tanks` |

## Firewall ports

| Instance | Port | Protocol | IPv4 | IPv6 |
|---|---|---|---|---|
| fishybowl | 22 | tcp | 0.0.0.0/0 | ::/0 |
| fishybowl | 80 | tcp | 0.0.0.0/0 | ::/0 |
| teeny-tanks | 22 | tcp | 0.0.0.0/0 | ::/0 |
| teeny-tanks | 80 | tcp | 0.0.0.0/0 | ::/0 |
| teeny-tanks | 443 | tcp | 0.0.0.0/0 | — |

## Static IP

`teeny-tanks` has a static IP (`StaticIp-teeny-tanks`, `54.196.95.235`) attached. The `aws_lightsail_static_ip` resource type does not support import in the current provider version, so it is documented here but not managed by OpenTofu.

## Firewall port management

`aws_lightsail_instance_public_ports` does not support import. The port declarations are included in each instance file, and the first `tofu apply` will replace the live port configuration with the declared values (which match current state, so no observable change).

## File structure

| File | Contents |
|---|---|
| `main.tf` | S3 backend, AWS provider (us-east-1) |
| `instance_fishybowl.tf` | `fishybowl` instance + firewall ports + import |
| `instance_teeny_tanks.tf` | `teeny-tanks` instance + firewall ports + import |
| `lightsail.md` | This file |
