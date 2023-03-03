## Isolation Via File Layout
* Put the Terraform configuration files for each environment into a separate folder. For example, all of the configurations for the staging environment can be in a folder called stage and all the configurations for the production environment can be in a folder called prod.
* Configure a different backend for each environment, using different authentica‐ tion mechanisms and access controls: e.g., each environment could live in a separate AWS account with a separate S3 bucket as a backend.
* It's recommended to use separate Terraform folders (and therefore separate state files) for each environment (staging, production, etc.) and for each component (VPC, services, databases) within that environment.

## Terraform_remote_state Data Source
* We've used data sources to fetch read-only information from AWS, such as the aws_subnets data source, which returns a list of subnets in your VPC. There is another data source that is particularly useful when working with state: terraform_remote_state. You can use this data source to fetch the Terraform state file stored by another set of Terraform configurations.
* We'll use terrafrom_remote_state to fetch database resources information.
* Code example:
```
#TF_remote_state to read outputs from the database's state file.
data "terraform_remote_state" "db-remote-state" {
    backend = "s3"

    config = {
        bucket  = "btei-tfstate-bucket" #bucket where it's stored the statefile
        key     = "stage/data-stores/mysql/terraform.tfstate" #location of the state it'll fetch the info
        region  = "us-east-1"
    }
}
```
* All of the database’s output variables are stored in the state file, and you can read them from the terraform_remote_state data source using an attribute reference of the form:
```
data.terraform_remote_state.<NAME>.outputs.<ATTRIBUTE>
```