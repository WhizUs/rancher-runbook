# Kubernetes Cluster Installation

Using terraform and ansible to install a high availability kubernetes cluster followed this instruction: https://kubernetes.io/docs/setup/independent/high-availability/

## Prerequisites

* Terraform version v0.11.8 (other version may work as well, but not tested)
* Installed Exoscale Provider - [Exoscale Terraform provider installation](#exoscale-terraform-provider-installation)
* Configured Exoscale terraform provider - [Exoscale Provider Configuration](#exoscale-provider-configuration)

## Run example

     terraform init
     terraform get
     terraform plan -var-file='./exoscale.tfvars' -out=next-steps.plan
     terraform apply -parallelism=10 next-steps.plan

## Exoscale Provider Configuration

To configure the cloudstack provider just create a file exoscale.tfvars inside the
root directory of this example, which contains information about the API. Eg.

      exoscale_api_key = "EXO02a0186f1234ab2a606700a9"
      exoscale_secret_key = "6uRPl00k9EddcljHJlywFJEFFOUzJnV9GXICXyicgvY"

## Exoscale Terraform provider installation

Run following commands to install the current exoscale provider

     mkdir -p $GOPATH/src/github.com/exoscale; cd $GOPATH/src/github.com/exoscale
     git clone git@github.com:exoscale/terraform-provider-exoscale
     cd $GOPATH/src/github.com/exoscale/terraform-provider-exoscale

After the build the binary terraform-provider-exoscale is available in $GOPATH/bin.

Now you need to place the binary into .terraform.d/plugins and to run `terraform init` to initialize it.

## Contribute

Before contribution run

      terraform fmt
      terraform validate -var-file='./exoscale.tfvars'

## Clean up

      terraform destroy -parallelism=10 -var-file='./exoscale.tfvars'
