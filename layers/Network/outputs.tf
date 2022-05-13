output "out_vpc_id" {
  description = "vpc id from principal vpc"
  value       = aws_vpc.principal.id
}

output "public1" {
  description = "Public 1 Subnet"
  value       = aws_subnet.public1.id
}

output "public2" {
  description = "Public 2 Subnet"
  value       = aws_subnet.public2.id
}

output "private1" {
  description = "Private 1 Subnet"
  value       = aws_subnet.private1.id
}

output "private2" {
  description = "Private 2 Subnet"
  value       = aws_subnet.private2.id
}