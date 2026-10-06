# iac-security-azuredevops

# Real-World IaC Security with Azure Pipelines

## Project Overview

This project demonstrates how Infrastructure as Code security can be integrated into an Azure DevOps CI/CD pipeline.

The project uses **Terraform** to define Azure infrastructure and **Microsoft Security DevOps** to scan the Terraform code for security misconfigurations before deployment.

The pipeline is configured to fail when high-severity IaC security issues are detected.

## Objectives

This project focuses on:

- Scanning Terraform files in Azure Pipelines
- Detecting insecure Azure infrastructure configurations
- Failing the pipeline when serious security findings are discovered
- Remediating IaC security issues
- Re-running the pipeline after fixes
- Understanding security gates in DevSecOps
- Documenting justified security exceptions

## Tools Used

- Terraform
- Azure DevOps
- Azure Pipelines
- Microsoft Security DevOps
- Checkov
- AzureRM Provider
- Git
- GitHub / Azure Repos

## Project Structure

```text
iac-security-azuredevops/
│
├── infra/
│   ├── main.tf
│   └── variables.tf
│
├── azure-pipelines.yml
└── README.md
```

## Security Issues Tested

The Terraform configuration was intentionally created with insecure settings such as:

- Public storage access enabled
- HTTPS enforcement disabled
- Shared storage keys enabled
- Public network access enabled
- SSH access allowed from any IP address
- Missing Customer-Managed Key encryption

These issues were introduced only for testing the security pipeline.

## Azure Pipeline

The pipeline uses Microsoft Security DevOps to scan Infrastructure as Code.

Example:

```yaml
- task: MicrosoftSecurityDevOps@1
  displayName: "Microsoft Security DevOps - IaC Scan"

  inputs:
    categories: 'IaC'
    break: true
    publish: true
    artifactName: 'CodeAnalysisLogs'
```

The most important option is:

```yaml
break: true
```

This causes the pipeline to fail when blocking high-severity security findings are detected.

## Initial Pipeline Result

The first pipeline run failed because the Terraform configuration contained insecure settings.

Example:

```text
Checkov Error
CKV2_AZURE_1

Ensure storage for critical data is encrypted
with a Customer Managed Key.
```

The pipeline successfully blocked the insecure configuration.

```text
Terraform Code
      ↓
Azure Pipeline
      ↓
Microsoft Security DevOps
      ↓
Checkov
      ↓
Security Finding
      ↓
PIPELINE FAILED
```

This confirmed that the security gate was working correctly.

## Remediation

The Terraform configuration was updated to improve security.

Examples included:

```hcl
https_traffic_only_enabled = true
```

```hcl
allow_nested_items_to_be_public = false
```

```hcl
shared_access_key_enabled = false
```

```hcl
public_network_access_enabled = false
```

SSH access was also changed from:

```hcl
source_address_prefix = "*"
```

to a restricted management network:

```hcl
source_address_prefix = var.management_cidr
```

## Documented Security Exception

Checkov also detected:

```text
CKV2_AZURE_1
Ensure storage for critical data is encrypted
with Customer Managed Key.
```

Because this project is a training environment and does not contain critical production data, a documented exception was added:

```hcl
# checkov:skip=CKV2_AZURE_1:Training lab storage account; no critical data is stored, so CMK is not required for this project.
```

This demonstrates how security findings can be reviewed and either:

```text
Remediated
```

or:

```text
Documented as an approved exception
```

rather than simply being ignored.

## Commit the Fixes

After remediation:

```bash
git add .

git commit -m "Remediate IaC security findings"

git push
```

The push triggers the Azure Pipeline again.

## Security Workflow

The final workflow is:

```text
Developer
    ↓
Terraform
    ↓
Git Repository
    ↓
Azure Pipeline
    ↓
Microsoft Security DevOps
    ↓
Checkov / IaC Security Scan
    ↓
Security Gate
  ┌──────┴──────┐
 FAIL           PASS
  ↓              ↓
Fix Code     Continue
```

## Troubleshooting

### MicrosoftSecurityDevOps task not found

Make sure the **Microsoft Security DevOps** extension is installed in the Azure DevOps organization.

### Pipeline reports findings but does not fail

Verify:

```yaml
break: true
```

is enabled.

### Checkov rule continues to fail

Run Checkov locally:

```bash
checkov -d infra \
  --framework terraform \
  --compact
```

Review the failed rule and either remediate the issue or create a justified resource-level exception.

### Security exception not detected

Ensure the Checkov suppression comment is placed inside the correct Terraform resource:

```hcl
resource "azurerm_storage_account" "logs" {

  # checkov:skip=CKV2_AZURE_1:Training lab exception.

  ...
}
```

## Key Learning

This project demonstrates that security can be enforced before infrastructure is deployed.

Instead of:

```text
Deploy
   ↓
Find security issue
   ↓
Repair infrastructure
```

the workflow becomes:

```text
Write Terraform
   ↓
Scan
   ↓
Detect issue
   ↓
Fix
   ↓
Re-scan
   ↓
Deploy
```

This approach is known as **shift-left security**.

## Skills Demonstrated

- Infrastructure as Code Security
- Terraform
- Azure DevOps
- Azure Pipelines
- Microsoft Security DevOps
- Checkov
- DevSecOps
- Security Gates
- Cloud Security
- Security Misconfiguration Detection
- Security Remediation
- Risk Acceptance and Security Exceptions
- Shift-Left Security

## Outcome

The project successfully demonstrated how Azure Pipelines can automatically detect and block insecure Terraform configurations before deployment.

It also demonstrated how security findings can be remediated or formally documented when a control is not applicable to the environment.