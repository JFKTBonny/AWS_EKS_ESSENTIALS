
output "subnets" {
  value = data.aws_availability_zones.available.names[1]
<<<<<<< HEAD
=======
}

output "public_ip" {
  value = aws_instance.instances.public_ip
>>>>>>> 78964a0 (initial commit)
}