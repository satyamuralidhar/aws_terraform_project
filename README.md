# aws_tf_project
#terraform init -backend-config="access_key=<your access key>" -backend-config="secret_key=<your secret key>"

#terraform apply -var-file="var.tfvars" -var "aws_access_key=" -var "aws_secret_key=" --auto-approve

update the new ami_id on tfvars file

export AWS_ACCESS_KEY=''
export AWS_SECRET_KEY=''

#plan the resource
terraform plan --var-file="var.tfvars" -var "aws_access_key=$AWS_ACCESS_KEY" -var "aws_secret_key=$AWS_SECRET_KEY" -out tfplan && terraform show -json tfplan >> tfplan.json

#creating resource
terraform apply --var-file="var.tfvars" -var "aws_access_key=$AWS_ACCESS_KEY" -var "aws_secret_key=$AWS_SECRET_KEY" --auto-approve

#destroying resources

terraform destroy --var-file="var.tfvars" -var "aws_access_key=$AWS_ACCESS_KEY" -var "aws_secret_key=$AWS_SECRET_KEY" --auto-approve