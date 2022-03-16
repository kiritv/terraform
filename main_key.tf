resource "tls_private_key" "main-key" {
  count     = var.install-in-number-of-availability-zone > 0 ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "store-main-key" {
  count    = var.install-in-number-of-availability-zone > 0 ? 1 : 0
  content  = tls_private_key.main-key.*.private_key_pem[count.index]
  filename = "main-key.pem"

  depends_on = [
    tls_private_key.main-key
  ]
}
resource "aws_key_pair" "generate-main-key" {
  count      = var.install-in-number-of-availability-zone > 0 ? 1 : 0
  key_name   = "main-key"
  public_key = tls_private_key.main-key.*.public_key_openssh[count.index]

  depends_on = [
    tls_private_key.main-key
  ]
}
