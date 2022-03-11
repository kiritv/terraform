resource "tls_private_key" "main-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "store-main-key" {
  content  = tls_private_key.main-key.private_key_pem
  filename = "main-key.pem"

  depends_on = [
    tls_private_key.main-key
  ]
}
resource "aws_key_pair" "generate-main-key" {
  key_name   = "main-key"
  public_key = tls_private_key.main-key.public_key_openssh

  depends_on = [
    tls_private_key.main-key
  ]
}
