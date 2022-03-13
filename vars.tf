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
  default = "main-bucket-for-profile-kirit"
}
variable "install-in-number-of-availability-zone" {
  type = number
}
