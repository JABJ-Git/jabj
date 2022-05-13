variable "app_name" {
  description = "The name of the application"
  type        = string
}

variable "aws_account_id" {
  description = "The account ID you are building into."
  type        = string
}

variable "region" {
  description = "The AWS region the state should reside in."
  type        = string
}

variable "environment" {
  description = "The name of the environment"
  type        = string
}

variable "ami_amazonlinux2" {
  description = "AMI from the AWS Marketplace"
  type        = string
}

variable "net_vpc_id" {
  description = "VPC id from base_net"
  type        = string
}

variable "subnet_private1_id" {
  description = "ID subnet private 1"
  type        = string
}

variable "subnet_private2_id" {
  description = "ID subnet private 2"
  type        = string
}

variable "subnet_public1_id" {
  description = "ID subnet public 1"
  type        = string
}

variable "subnet_public2_id" {
  description = "ID subnet public 2"
  type        = string
}