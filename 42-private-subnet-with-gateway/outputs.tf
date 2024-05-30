output "instance_public_ip" {
  value = aws_instance.nat-gateway-public.public_ip
}

output "nat-gateway_eip" {
  value = aws_nat_gateway.nat-gateway.public_ip
}

output "ssh-key" {
  value = aws_instance.nat-gateway-public.key_name
}