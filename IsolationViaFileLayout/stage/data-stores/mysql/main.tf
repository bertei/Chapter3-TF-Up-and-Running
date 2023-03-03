provider "aws" {
  region = "us-east-1"
}

terraform {
    backend "s3" {
        bucket  = "btei-tfstate-bucket"
        key     = "stage/data-stores/mysql/terraform.tfstate"
        encrypt = true

        dynamodb_table = "dynamodb-table-tf-state-lock"
    }
}

resource "aws_db_instance" "example-db" {
    identifier_prefix = "example-db"
    engine = "mysql"
    allocated_storage = 20
    instance_class = "db.t2.micro"
    skip_final_snapshot = true
    db_name = "exampleMysqlDB"

    #User config
    username = "test" #testing purposes
    password = "testing123" #testing purposes
}