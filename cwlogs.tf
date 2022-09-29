resource "aws_cloudwatch_log_group" "vpn" {
  name              = "/aws/vpn/${var.name}/logs"
}