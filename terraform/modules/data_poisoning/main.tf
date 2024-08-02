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
resource "aws_s3_bucket" "sagemaker_recommendation_bucket" {
  bucket        = "sagemaker-recommendation-bucket-${random_string.suffix.result}"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "rec_bucket_encryption" {
  bucket = aws_s3_bucket.sagemaker_recommendation_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true

  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.sagemaker_recommendation_bucket.id
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutBucketPolicy"
      ],
      "Resource": [
        "${aws_s3_bucket.sagemaker_recommendation_bucket.arn}",
        "${aws_s3_bucket.sagemaker_recommendation_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "${aws_s3_bucket.sagemaker_recommendation_bucket.arn}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
EOF
}


resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.sagemaker_recommendation_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.public_access_allow]
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_allow" {
  bucket = aws_s3_bucket.sagemaker_recommendation_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_object" "lambda_deployment_package" {
  bucket = aws_s3_bucket.sagemaker_recommendation_bucket.id
  key    = "lambda/get_rec_lambda.zip"
  source = "resources/data_poisoning/get_rec_lambda.zip"
}

resource "aws_s3_bucket_object" "sagemaker_recommendation_data" {
  bucket = aws_s3_bucket.sagemaker_recommendation_bucket.id
  key    = "product_ratings.csv"
  source = "resources/data_poisoning/product_ratings.csv"
}

resource "aws_s3_bucket_object" "sagemaker_recommendation_data_solution" {
  bucket = aws_s3_bucket.sagemaker_recommendation_bucket.id
  key    = "old_product_ratings.csv"
  source = "resources/data_poisoning/old_product_ratings.csv"
}

resource "aws_s3_bucket_object" "sagemaker_retraining_data" {
  for_each = fileset("resources/data_poisoning/code", "**/*")
  bucket = aws_s3_bucket.sagemaker_recommendation_bucket.id
  key    = "code/${each.value}"
  source = "resources/data_poisoning/code/${each.value}"
}

# IAM role for SageMaker
resource "aws_iam_role" "sagemaker_recommendation_execution_role" {
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
  role       = aws_iam_role.sagemaker_recommendation_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_role_policy" "sagemaker_recommendation_bucket_policy" {
  name = "SageMakerS3Policy"
  role = aws_iam_role.sagemaker_recommendation_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket", "s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Resource = [
          aws_s3_bucket.sagemaker_recommendation_bucket.arn,
          "${aws_s3_bucket.sagemaker_recommendation_bucket.arn}/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = "iam:GetRole",
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "iam:PassRole",
        Resource = "*"
      }
    ]
  })
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "recommendation-api-role"
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
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sagemaker:InvokeEndpoint"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.sagemaker_recommendation_bucket.arn,
          "${aws_s3_bucket.sagemaker_recommendation_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "sagemaker_additional_policy" {
  name = "SageMakerAdditionalPolicy"
  role = aws_iam_role.sagemaker_recommendation_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*",
          "sagemaker:*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      }
    ]
  })
}

# Lambda function
resource "aws_lambda_function" "recommendation_lambda" {
  s3_bucket        = aws_s3_bucket.sagemaker_recommendation_bucket.id
  s3_key           = aws_s3_bucket_object.lambda_deployment_package.key
  function_name    = "recommendation-lambda"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("resources/data_poisoning/get_rec_lambda.zip")
  timeout          = 900 # Timeout set to 30 seconds
  memory_size      = 2048    # Set memory size to 1 GB
}

# API Gateway for Lambda function
resource "aws_api_gateway_rest_api" "recommendation_api" {
  name        = "recommendations-api"
  description = "API to fetch product recommendations using a SageMaker endpoint"
}

resource "aws_api_gateway_resource" "get_recommendations_resource" {
  rest_api_id = aws_api_gateway_rest_api.recommendation_api.id
  parent_id   = aws_api_gateway_rest_api.recommendation_api.root_resource_id
  path_part   = "get-recommendations"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.recommendation_api.id
  resource_id   = aws_api_gateway_resource.get_recommendations_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.recommendation_api.id
  resource_id             = aws_api_gateway_resource.get_recommendations_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.recommendation_lambda.invoke_arn
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  timeout_milliseconds    = 29000
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.recommendation_api.id
  resource_id = aws_api_gateway_resource.get_recommendations_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "lambda_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.recommendation_api.id
  resource_id = aws_api_gateway_resource.get_recommendations_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]
}


resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration, aws_api_gateway_integration_response.lambda_integration_response]
  rest_api_id = aws_api_gateway_rest_api.recommendation_api.id
  stage_name  = "prod"
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.recommendation_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.recommendation_api.execution_arn}/*/*"
}

resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "sagemaker_recommendation_lifecycle_config" {
  name = "sagemaker-lifecycle-config-recommendations"
  on_create = base64encode(templatefile("resources/data_poisoning/lifecycle_config.sh", {
    s3_bucket_name = aws_s3_bucket.sagemaker_recommendation_bucket.id
  }))
  on_start = base64encode(templatefile("resources/data_poisoning/lifecycle_config.sh", {
    s3_bucket_name = aws_s3_bucket.sagemaker_recommendation_bucket.id
  }))
  depends_on = [aws_s3_bucket.sagemaker_recommendation_bucket]
}

resource "aws_security_group" "sagemaker_recommendation_sg" {
  name        = "sagemaker-recommendation-sg"
  description = "Security group for SageMaker notebook instance"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_sagemaker_notebook_instance" "recommendation_notebook" {
  name                         = "recommendation-search-${random_string.suffix.result}"
  instance_type                = "ml.t2.medium"
  role_arn                     = aws_iam_role.sagemaker_recommendation_execution_role.arn
  lifecycle_config_name        = aws_sagemaker_notebook_instance_lifecycle_configuration.sagemaker_recommendation_lifecycle_config.name
  direct_internet_access       = "Enabled"
  platform_identifier          = "notebook-al2-v1"
  subnet_id                    = var.subd_public
  security_groups              = [aws_security_group.sagemaker_recommendation_sg.id]
}


resource "aws_iam_role_policy" "retrain_lambda_execution_policy" {
  name = "retrain-model-policy-${random_string.suffix.result}"
  role = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect: "Allow",
        Action: [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ],
        Resource: "arn:aws:logs:*:*:*"
      },
      {
        Effect: "Allow",
        Action: [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource: [
          aws_s3_bucket.sagemaker_recommendation_bucket.arn,
          "${aws_s3_bucket.sagemaker_recommendation_bucket.arn}/*"
        ]
      },
      {
        Effect: "Allow",
        Action: [
          "sagemaker:CreateTrainingJob",
          "sagemaker:DescribeTrainingJob",
          "sagemaker:CreateModel",
          "sagemaker:CreateEndpointConfig",
          "sagemaker:UpdateEndpoint",
          "sagemaker:DescribeEndpoint",
          "sagemaker:DeleteEndpointConfig",
          "iam:GetRole",
          "iam:PassRole"
        ],
        Resource: "*"
      }
    ]
  })
}


resource "aws_lambda_function" "retrain_model_lambda" {
  filename         = "resources/data_poisoning/retrain_model_lambda.zip"  # Ensure this file contains your combined Lambda function code
  function_name    = "retrain-model-lambda"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout          = 900 # 15 minutes
  memory_size      = 1024 # 1 GB
  source_code_hash = filebase64sha256("resources/data_poisoning/retrain_model_lambda.zip")

  environment {
    variables = {
      SAGEMAKER_ROLE_NAME = aws_iam_role.sagemaker_recommendation_execution_role.name
      S3_BUCKET_URI       = aws_s3_bucket.sagemaker_recommendation_bucket.bucket
    }
  }
}

# S3 Bucket Notification
resource "aws_s3_bucket_notification" "dataset_bucket_notification" {
  bucket = aws_s3_bucket.sagemaker_recommendation_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.retrain_model_lambda.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:Post"]
    filter_prefix       = "product_ratings.csv"
  }

  depends_on = [
    aws_lambda_function.retrain_model_lambda,
    aws_lambda_permission.allow_s3_invoke
  ]
}

# Allow S3 to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.retrain_model_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.sagemaker_recommendation_bucket.arn
}


output "api_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.recommendation_api.id}.execute-api.${var.region}.amazonaws.com/prod/get-recommendations"
}

output "sagemaker_recommendation_bucket_name" {
  value = aws_s3_bucket.sagemaker_recommendation_bucket.bucket
}