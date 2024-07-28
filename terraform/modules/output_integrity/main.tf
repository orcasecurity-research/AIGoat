variable "region" {}
variable "subd_public" {}
variable "vpc_id" {}

# Generate a unique suffix
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
  lower   = true
}

# S3 Bucket for SageMaker data
resource "aws_s3_bucket" "sagemaker_comment_filter_bucket" {
  bucket = "sagemaker-comment-filter-bucket-${random_string.suffix.result}"
  force_destroy = true
}

# IAM role for SageMaker
resource "aws_iam_role" "sagemaker_execution_role" {
  name = "AmazonSageMaker-ExecutionRole-${random_string.suffix.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "sagemaker.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_role_policy_attachment" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_role_policy" "sagemaker_bucket_policy" {
  name = "SageMakerS3Policy"
  role = aws_iam_role.sagemaker_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket", "s3:GetObject", "s3:PutObject"],
        Resource = [
          aws_s3_bucket.sagemaker_comment_filter_bucket.arn,
          "${aws_s3_bucket.sagemaker_comment_filter_bucket.arn}/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = "iam:GetRole",
        Resource = "*"
      }
    ]
  })
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "comment-filter-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_role_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_invoke_sagemaker_policy" {
  name = "LambdaInvokeSageMakerPolicy"
  role = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "sagemaker:InvokeEndpoint",
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy" "sagemaker_additional_policy" {
  name = "SageMakerAdditionalPolicy"
  role = aws_iam_role.sagemaker_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "sagemaker:*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}


# Lambda function
resource "aws_lambda_function" "combined_lambda" {
  filename         = "resources/output_integrity/output_integrity_lambda.zip"  # Ensure this file contains your combined Lambda function code
  function_name    = "comments-filter-lambda"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256("resources/output_integrity/output_integrity_lambda.zip")
}



# API Gateway for Lambda function
resource "aws_api_gateway_rest_api" "comments_filter_api" {
  name        = "comments-filter"
  description = "API to filter comments using a SageMaker endpoint"
}

resource "aws_api_gateway_resource" "comment_resource" {
  rest_api_id = aws_api_gateway_rest_api.comments_filter_api.id
  parent_id   = aws_api_gateway_rest_api.comments_filter_api.root_resource_id
  path_part   = "comment"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.comments_filter_api.id
  resource_id   = aws_api_gateway_resource.comment_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.comments_filter_api.id
  resource_id             = aws_api_gateway_resource.comment_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.combined_lambda.invoke_arn
  request_templates = {
    "application/json" = <<EOF
{
  "operation": "filter_comments",
  "body": $input.json('$')
}
EOF
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.comments_filter_api.id
  stage_name  = "prod"
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.combined_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.comments_filter_api.execution_arn}/*/*"
}


resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "sagemaker_lifecycle_config" {
  name = "sagemaker-lifecycle-config"
  on_create = base64encode(templatefile("resources/output_integrity/lifecycle_config.sh", {
    s3_bucket_name = aws_s3_bucket.sagemaker_comment_filter_bucket.id
  }))
  on_start = base64encode(templatefile("resources/output_integrity/lifecycle_config.sh", {
    s3_bucket_name = aws_s3_bucket.sagemaker_comment_filter_bucket.id
  }))

  depends_on = [aws_s3_bucket.sagemaker_comment_filter_bucket]
}



resource "aws_security_group" "sagemaker_sg" {
  name        = "sagemaker-sg"
  description = "Security group for SageMaker notebook instance"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_sagemaker_notebook_instance" "comments_filter" {
  name                         = "comments-filter-${random_string.suffix.result}"
  instance_type                = "ml.t2.medium"
  role_arn                     = aws_iam_role.sagemaker_execution_role.arn
  lifecycle_config_name        = aws_sagemaker_notebook_instance_lifecycle_configuration.sagemaker_lifecycle_config.name
  direct_internet_access       = "Enabled"
  platform_identifier          = "notebook-al2-v1"
  subnet_id                    = var.subd_public
  security_groups              = [aws_security_group.sagemaker_sg.id]
}

output "api_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.comments_filter_api.id}.execute-api.${var.region}.amazonaws.com/prod/comment"
}


#output "api_invoke_url" {
#  value = "https://${aws_api_gateway_rest_api.comments_filter_api.id}.execute-api.${var.region}.amazonaws.com/prod/comment"
#  description = "The URL of the API endpoint to filter comments"
#}

#
#resource "null_resource" "delete_bucket_contents" {
#  triggers = {
#    bucket = aws_s3_bucket.sagemaker_comment_filter_bucket.id
#  }
#
#  # This provisioner runs at creation time
#  provisioner "local-exec" {
#    command = "echo ${aws_s3_bucket.sagemaker_comment_filter_bucket.id} > /tmp/bucket_name.txt"
#  }
#
#  # This provisioner runs at destruction time
#  provisioner "local-exec" {
#    when    = destroy
#    command = <<EOF
#      BUCKET=$(cat /tmp/bucket_name.txt)
#      aws s3 rm s3://$BUCKET --recursive
#      aws s3api delete-objects --bucket $BUCKET --delete "$(aws s3api list-object-versions --bucket $BUCKET --output=json --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"
#    EOF
#  }
#}
