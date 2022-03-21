variable "region" {
  default = "us-east-1"
}
variable "vpc_cidr" {
}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "bucket-name" {
  default = "main-bucket"
}

variable "install-in-number-of-availability-zone" {
  type    = number
  default = 2
}
variable "install-s3" {
  type    = bool
  default = true
}
variable "install-asg-alb" {
  type    = bool
  default = true
}
