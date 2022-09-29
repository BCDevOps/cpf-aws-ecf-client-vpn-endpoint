data "aws_caller_identity" "current" {}

data "aws_vpc" "central" {
  filter {
    name   = "tag:Name"
    values = ["Central_vpc"]
  }
}
data "aws_subnet" "app_central" {
  filter {
    name   = "tag:Name"
    values = ["App_Central_aza_net"]
  }
}
data "aws_security_group" "app_sg" {
  filter {
    name   = "tag:Name"
    values = ["App_sg"]
  }
}
resource "aws_ec2_client_vpn_endpoint" "opensiem_vpn" {
  description            = "opensiem-clientvpn"
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block      = "10.5.0.0/20"
  split_tunnel           = true
  session_timeout_hours  = 8
  self_service_portal    = "enabled"
  vpc_id                 = data.aws_vpc.central.id
  security_group_ids     = [data.aws_security_group.app_sg.id]
  vpn_port               = 443
  transport_protocol     = "udp"

  authentication_options {
    type                           = "federated-authentication"
    saml_provider_arn              = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:saml-provider/BCGovKeyCloak-${var.keycloak_realm_id}"
    self_service_saml_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:saml-provider/BCGovKeyCloak-${var.keycloak_realm_id}"
  }

  connection_log_options {
    enabled              = false
    cloudwatch_log_group = aws_cloudwatch_log_group.vpn.name
  }
  depends_on = [
    resource.aws_acm_certificate.server
  ]
}

resource "aws_ec2_client_vpn_network_association" "subnet_association" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.opensiem_vpn.id
  subnet_id              = data.aws_subnet.app_central.id
}

resource "aws_ec2_client_vpn_authorization_rule" "rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.opensiem_vpn.id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
}