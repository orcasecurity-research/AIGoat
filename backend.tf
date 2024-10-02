terraform {
    backend "s3" {
        bucket          = "mycomponents-tfstate"
        key             = "state/terraform.tfstate"
        region          = "us-east-1"
        dynamodb_table  = "mycomponents_tf_lockid"
        encrypt         = true
    }
}
