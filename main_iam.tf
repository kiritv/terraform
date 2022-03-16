# IAM
resource "aws_iam_role" "ec2-to-s3-access-role" {
  count              = var.install-s3 ? 1 : 0
  name               = "ec2-s3"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_policy" "ec2-to-s3-policy" {
  count       = var.install-s3 ? 1 : 0
  name        = "ec2_S3policy"
  description = "Access to s3 policy from ec2"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "s3:*",
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "ec2-attach" {
  count      = var.install-s3 ? 1 : 0
  role       = aws_iam_role.ec2-to-s3-access-role.*.name[count.index]
  policy_arn = aws_iam_policy.ec2-to-s3-policy.*.arn[count.index]
}
resource "aws_iam_instance_profile" "ec2-s3-profile" {
  count = var.install-s3 ? 1 : 0
  name  = "ec2-s3-profile"
  role  = aws_iam_role.ec2-to-s3-access-role.*.name[count.index]
}
