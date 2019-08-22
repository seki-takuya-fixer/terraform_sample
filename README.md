# terraform_sample

Azure x Terraform sample code

## Requirement

- OS
    - Windows 10
- Powershell

## How to use

1. Install required software
    1. Install Terraform
        - reference : https://www.terraform.io/downloads.html
        
        ```powershell
        PS> .\setup\Install-Terraform.ps1
        ```
      
    1. Install Az cli
        - reference : https://docs.microsoft.com/ja-jp/cli/azure/install-azure-cli-windows?view=azure-cli-latest

        ```powershell
        PS> .\setup\Install-AzCli.ps1
        ```

1. Add Azure ServicePrincipal
    - reference : https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest

    ```powershell
    PS> .\azure\Add-AzureServicePrincipal.ps1 -SubscriptionId {YOUR SUBSCRIPTION ID}
    ```

1. Run Terraform template
    - reference : https://www.terraform.io/docs/providers/azurerm/index.html
    
    ```powershell
    PS> .\azure\Invoke-Terraform.ps1
    ```
