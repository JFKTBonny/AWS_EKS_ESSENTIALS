
output "subnets" {
  value = data.aws_availability_zones.available.names[1]

}

output "public_ip" {
  value = aws_instance.instances.public_
}