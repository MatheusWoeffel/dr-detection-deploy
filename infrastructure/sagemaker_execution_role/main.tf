data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sagemaker-role" {
  name = "sagemaker-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "s3_full_access" {
  name        = "s3-full-access"
  path        = "/"
  description = "Policy which gives access to all s3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
    for_each = toset([
        "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess", 
        "${aws_iam_policy.s3_full_access.arn}"
    ])
  role       = aws_iam_role.sagemaker-role.name
  policy_arn = each.value
}