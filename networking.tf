resource "aws_vpc" "VPC" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "IGW"
  }
}

# Define the availability zones
variable "availability_zones" {
  default = ["eu-west-2a", "eu-west-2b"] # Replace with your desired availability zones
}

# Create two public and two private subnets in different AZs
resource "aws_subnet" "public_subnets" {
  count = 2

  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = "10.1.${1 + count.index}.0/24"
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_route_table" "Public_RT" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "Public_RT"
  }
}

resource "aws_route_table_association" "Public_RTA" {
  subnet_id      = aws_subnet.public_subnets[0].id
  route_table_id = aws_route_table.Public_RT.id
}

resource "aws_route_table_association" "Public_RTA2" {
  subnet_id      = aws_subnet.public_subnets[1].id
  route_table_id = aws_route_table.Public_RT.id
}

######################################################

resource "aws_route53_record" "domain_validation" {
  for_each = {
    for dvo in aws_acm_certificate.domain.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.public.zone_id
}

resource "aws_route53_record" "webhook_alias" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "webhook.${var.domain_name}"
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_lb_hosted_zone_id.ingress_nginx.id
    evaluate_target_health = true
  }

  depends_on = [
    helm_release.ingress_nginx
  ]
}
