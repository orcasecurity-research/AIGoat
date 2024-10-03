terraform {
    backend "s3" {
        bucket          = "mycomponents-tfstate"
        key             = "state/terraform.tfstate"
        region          = aws_s3_bucket.terraform_state.region
        dynamodb_table  = "mycomponents_tf_lockid"
        encrypt         = true
    }
}
