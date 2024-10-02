terraform {
    backend "s3" {
        bucket          = "mycomponents-tfstate"
        key             = "state/terraform.tfstate"
        region          = "eu-central-1"
        dynamodb_table  = "mycomponents_tf_lockid"
        encrypt         = true
    }
}
