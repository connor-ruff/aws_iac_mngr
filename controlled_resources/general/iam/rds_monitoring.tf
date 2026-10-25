resource "aws_iam_role" "rds_monitoring" {
  name = "rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = ""
        Effect    = "Allow"
        Principal = { Service = "monitoring.rds.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_enhanced" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

import {
  to = aws_iam_role.rds_monitoring
  id = "rds-monitoring-role"
}

import {
  to = aws_iam_role_policy_attachment.rds_monitoring_enhanced
  id = "rds-monitoring-role/arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
