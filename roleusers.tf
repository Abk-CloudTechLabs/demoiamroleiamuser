# Fetch the current account details using AWS caller identity
data "aws_caller_identity" "current" {}

# Create an IAM user named 'yashvikothari'
resource "aws_iam_user" "yashvikothari" {
  name = "yashvikothari" # The name of the IAM user
}

# Generate an access key for 'yashvikothari'
resource "aws_iam_access_key" "yashvikothari_key" {
  user = aws_iam_user.yashvikothari.name
}

# Output the access key and secret key
output "yashvikothari_access_key_id" {
  value = aws_iam_access_key.yashvikothari_key.id
}

output "yashvikothari_secret_access_key" {
  value = aws_iam_access_key.yashvikothari_key.secret
  sensitive = true
}

# Create an IAM role named 'tfrolez'
# This role includes an assume role policy that specifically allows the 'yashvikothari' user to assume it
resource "aws_iam_role" "tfrolez" {
  name = "tfrolez"

  # The policy that defines who can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          # Dynamically sets the ARN for 'yashvikothari' based on the user created above
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${aws_iam_user.yashvikothari.name}"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "assume_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.tfrolez.name
}

# Create a custom policy that allows the 'yashvikothari' user to assume the 'tfrolez' role
resource "aws_iam_policy" "yashvikothari_assume_role_policy" {
  name        = "yashvikothari_assume_role_policy"
  description = "Policy that allows yashvikothari to assume the tfrolez role."

  # The policy content
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = aws_iam_role.tfrolez.arn # Specifies the ARN of the role 'yashvikothari' can assume
      }
    ]
  })
}

# Attach the custom policy to the 'yashvikothari' user
# This grants 'yashvikothari' the necessary permissions to assume the 'tfrolez' role
resource "aws_iam_user_policy_attachment" "yashvikothari_assume_role_policy_attachment" {
  user       = aws_iam_user.yashvikothari.name # The user to attach the policy to
  policy_arn = aws_iam_policy.yashvikothari_assume_role_policy.arn # The ARN of the custom policy
}

