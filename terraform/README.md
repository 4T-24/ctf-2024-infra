# Terraform config

## Usage

In order to specify the configuration for the terraform script, you can export the following environment variables:

```bash
export TF_VAR_workers="2"
export TF_VAR_worker-flavor="a1-ram2-disk20-perf1"
export TF_VAR_control-planes="2"
export TF_VAR_control-plane-flavor="a1-ram2-disk20-perf1"
export TF_VAR_load-balancers="1"
export TF_VAR_load-balancer-flavor="a1-ram2-disk20-perf1"
```
