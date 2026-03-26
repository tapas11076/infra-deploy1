# infra-deploy1

## Overview

**infra-deploy1** is an infrastructure-as-code solution for deploying a secure Azure Virtual Network (VNet) and a Network Security Group (NSG) with a focused SSH rule, using Bicep, parameterization, and Azure DevOps CI/CD pipelines.

- **Language:** Bicep (`infra-deploy1.bicep`)
- **CI/CD:** Azure Pipelines (`azure-pipelines-1.yml`, `azure-pipelines-1.yml`)
- **Parameters:** Configurable via `parameter.json` or pipeline variables

---

## Features

- Deploys a VNet (`10.0.0.0/16`) with a single subnet (`10.0.240.0/20`)
- Attaches an NSG (`Main1NSG`) with one SSH inbound rule, restricted by user-supplied CIDR
- All parameters are externally overrideable for environment safety
- Hardened: No hardcoded SSH wide-open defaults; all sensitive values passed securely at deploy time

---

## Architecture

```text
+------------------------------+
|   Resource Group             |
|   (user-defined)             |
|                              |
|   +---------------------+    |
|   |   Virtual Network   |    |
|   |   10.0.0.0/16       |    |
|   |   +-------------+   |    |
|   |   | Subnet      |   |    |
|   |   | 10.0.240.0/20|  |    |
|   |   +-------------+   |    |
|   +---------------------+    |
|           |                  |
|        [NSG]                 |
|  (Main1NSG, with only        |
|   SSH inbound from CIDR)     |
+------------------------------+
```

---

## File Structure & Purpose

- `infra-deploy1.bicep` — Bicep template, parameterizes everything needed for the VNet and NSG
- `parameter.json` — Example deployment parameters (edit before use)
- `azure-pipelines.yml` — Minimal starter Azure Pipeline
- `azure-pipelines-1.yml` — Full Azure DevOps deployment pipeline, showing best practices for param injection

---

## Parameters

| Name              | Type    | Example           | Description                                    |
|-------------------|---------|-------------------|------------------------------------------------|
| `vnetName`        | string  | `project-try-5`   | Name for the Azure VNet                        |
| `location`        | string  | `eastus`          | Azure region, defaulted from resource group    |
| `sourceSSHAddress`| string  | `203.0.113.4/32`  | CIDR for SSH access. **Required. Never use `0.0.0.0/0`!** |

#### Important security note:
- This template purposely leaves `sourceSSHAddress` **unset by default**.  
- Always provide a secure, trusted /32 or precise whitelist at deploy time (do NOT use broad ranges).

---

## How to Deploy

### 1. Manual Deployment via Azure CLI

#### Validate the template:
```sh
az bicep build --file infra-deploy1.bicep
az deployment group validate \
  --resource-group <RESOURCE_GROUP> \
  --template-file infra-deploy1.bicep \
  --parameters vnetName=<VNET_NAME> sourceSSHAddress=<IP_CIDR>
```
#### Deploy:
```sh
az deployment group create \
  --resource-group <RESOURCE_GROUP> \
  --template-file infra-deploy1.bicep \
  --parameters vnetName=<VNET_NAME> sourceSSHAddress=<IP_CIDR>
```
**Example:**  
`sourceSSHAddress="203.0.113.4/32"`

---

### 2. Automated Deployment via Azure DevOps Pipeline

#### Recommended: Use a variable group for parameters

1. In Azure DevOps, create a variable group (e.g. `infra-params`)
   - Add (and if sensitive, mark as secret):
     - `vnetName` (e.g., project-try-5)
     - `sourceSSHAddress` (e.g., your trusted public IP in CIDR format)

2. Link this variable group in your pipeline.

3. Run (queue) the pipeline.

**Key pipeline file:**  
`azure-pipelines-1.yml`

---

## Security Best Practices

- **Never allow SSH (`sourceSSHAddress`) from `0.0.0.0/0`**.
- Use Azure Bastion or Just-In-Time (JIT) access for administrative access where possible.
- Validate NSG rules post-deployment and restrict open ports/CIDRs.
- Do not commit real public IPs or subscription IDs for production into the repo.
- Use Azure Policy to prevent accidental wide-open NSG rules.

---

## Validation & Testing

- View your NSG and rules in the Azure Portal or via CLI:
  ```sh
  az network nsg show --resource-group <RESOURCE_GROUP> --name Main1NSG
  az network nsg rule list --resource-group <RESOURCE_GROUP> --nsg-name Main1NSG
  ```
- Attempt SSH only from allowed IP/CIDR.
- (Optional) Run security scans:
  ```sh
  checkov -d .
  # Or use Az CLI/Bicep linter
  ```

---

## Clean Up

Delete the deployed resources by removing the resource group:
```sh
az group delete --name <RESOURCE_GROUP>
```

---

## Troubleshooting & Support

- Validate parameters and environment before deployment.
- Only permitted IPs in `sourceSSHAddress` will be able to SSH.
- Use Azure DevOps logs for pipeline troubleshooting.
- For questions, open a GitHub issue.

---

## Links & References

- [Bicep documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Network Security Groups](https://docs.microsoft.com/azure/virtual-network/network-security-groups-overview)
- [Azure Bastion](https://learn.microsoft.com/azure/bastion/bastion-overview)
- [Checkov security scanning](https://www.checkov.io/)

---

## Changelog

- Hardened NSG rule destination to align with subnet
- Made `sourceSSHAddress` input required and removed hardcoded IPs from all files
- Pipeline configured for secure parameter injection

---

_Last updated: 2026-03-26 by Copilot_