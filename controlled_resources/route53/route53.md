# Route 53 Module

This module manages the two public hosted zones created by Route 53 Registrar, and the A records that point each domain at its Lightsail instance.

NS and SOA records are auto-managed by AWS and are intentionally not declared here.

## Hosted zones

| Terraform resource | Domain | Hosted zone ID | Points to |
|---|---|---|---|
| `fishybowl_social` | fishybowl.social | Z085297434OU8TICI41US | 44.203.242.160 (fishybowl Lightsail) |
| `teenytanks_social` | teenytanks.social | Z01870773NH7OPZ866F8P | 54.196.95.235 (teeny-tanks Lightsail static IP) |

## File structure

| File | Contents |
|---|---|
| `main.tf` | S3 backend, AWS provider |
| `zone_fishybowl_social.tf` | `fishybowl.social` hosted zone + A record + imports |
| `zone_teenytanks_social.tf` | `teenytanks.social` hosted zone + A record + imports |
| `route53.md` | This file |
