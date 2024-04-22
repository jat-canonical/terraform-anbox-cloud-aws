output "instance_id" {
  description = "Instance id of machine"
  value       = aws_instance.juju_machine.id
}

output "instance_ip" {
  description = "Public IP of machine"
  value       = aws_instance.juju_machine.public_ip
}

