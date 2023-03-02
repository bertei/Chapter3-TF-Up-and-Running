# What is Terraform State?
* Terraform records information about what infrastructure you created in a **Terraform state file**, specifically in **terraform.tfstate**. This file contains a custom JSON format that records a mapping from the TF resources in your configuration files to the representation of those resources in the real world.
* Every time you run Terraform, terraform can fetch the latest status of a resource from AWS and compare that to what’s in your tf configurations to determine what changes need to be applied.

# Local State File limitations
* Having a single local state file works great for one person, but not for multiple persons.
* **Shared storage for state files**: to update your infra. in a team, each of the team members need access to the same tf state file. Meaning you need to store this file in a shared location.
* **Locking state files**: as soon as data is shared, you run into a new problem: locking. Without locking, if two team members are running tf at the same time, you can run into race conditions as multiple tf processes make concurrent updates to the state files, leading to conflicts, data loss, and state file corruption.
* **Isolating state files**: when making changes to your infra, it’s a best practice to isolate different environments. For example, when making a change in a testing environment, you want to be sure that there is no way you can accidentally break production. But how can you isolate your changes if all of your infrastructure is defined in the same tf state file?

# Shared Storage for State Files
* Version control software is not recommended for storing state files. It is prone to manual errors (not pulling the latest tfstate file, etc), they don’t have locking and secrets support.
* The best way to manage shared storage for state files is to use tf built-in support for remote backends. A terraform backend determines how tf loads and stores state. The default backend, it’s the local backend, which stores state file on your local disk. Remote backends allow you to store the state file in a remote, shared one.
* Remote backend solve the three issues just listed:
    * Manual error: once configured the remote backend, and every time you run “plan or apply” tf automatically will load the “state file” from the backend. Also, after an apply is executed, tf will save the new “state” in the “remote state file”.
    * Locking: all remote backends support locking, this means that when someone does an “tf apply” it will lock the “state file” and until the changes are applied it won’t let other person to do another “tf apply”.
    * Secrets: Most of the remote backends natively support encryption in transit and encryp‐ tion at rest of the state file. Moreover, those backends usually expose ways to configure access permissions (e.g., using IAM policies with an Amazon S3 bucket), so you can control who has access to your state files and the secrets they might contain.
* We'll be using AWS S3 which is aws managed file store.

# Code
* We'll create:
    * S3 bucket to store the state file.
    * DynamoDB table for locking state file. DynamoDB is Amazon's distributed key-value store. It supports strongly consistent reads and conditional writes, which are all ingredients you need for a distributed lock system.
    * **Terraform backend block**: to configure tf to store the state on aws s3 (with encryption and locking), you need to add a backend configuration to tf code.
        * Limitations with terraform's backends. The first one is the two steps you have to make for its setup. And the same two steps to delete it.
            1.  Write Terraform code to create the S3 bucket and DynamoDB table, and deploy that code with a local backend.
            2.  Go back to the Terraform code, add a remote backend configuration to it to use the newly created S3 bucket and DynamoDB table, and run terraform init to copy your local state to S3.
# State File Isolation
* The whole point of having separate environments is that they are isolated from one another, so if you are managing all the environments from a single set of Terraform configurations, you are breaking that isolation.
* Create isolation (“bulkheads”) between your environments by defining each environment in a separate Terraform configuration

# Isolation via Workspaces
* Terraform workspaces allow you to store your Terraform state in multiple, separate, named workspaces. Terraform starts with a single workspace called “default,” and if you never explicitly specify a workspace, the default workspace is the one you’ll use the entire time. To create a new workspace or switch between workspaces, you use the terraform workspace commands.
* It is handy when you already have a Terraform module deployed and you want to do some experiments with it (e.g., try to refactor the code) but you don’t want your experiments to affect the state of the already-deployed infrastructure. Terraform workspaces allow you to run terraform workspace new and deploy a new copy of the exact same infrastructure, but storing the state in a separate file.


