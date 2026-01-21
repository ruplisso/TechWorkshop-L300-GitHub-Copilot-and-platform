# GitHub Actions Deployment Setup

This workflow builds the .NET app as a container and deploys it to Azure App Service using OIDC authentication (federated credentials).

## Prerequisites

1. Azure App Service provisioned (via `azd provision`)
2. Azure AD App Registration with federated credentials for GitHub Actions

## Configure GitHub Secrets

In your repository, go to **Settings > Secrets and variables > Actions > Secrets tab > New repository secret** and add:

| Secret | Description | How to get the value |
|--------|-------------|----------------------|
| `AZURE_CLIENT_ID` | App registration (service principal) client ID | After creating the app registration, find it in **Azure Portal > Microsoft Entra ID > App registrations > Your app > Overview > Application (client) ID** |
| `AZURE_TENANT_ID` | Microsoft Entra ID (Azure AD) tenant ID | Run `az account show --query tenantId -o tsv` or find in **Azure Portal > Microsoft Entra ID > Overview > Tenant ID** |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID | Run `az account show --query id -o tsv` or find in **Azure Portal > Subscriptions > Your subscription > Subscription ID** |

## Configure GitHub Variables

Under **Settings > Secrets and variables > Actions > Variables tab > New repository variable**, add:

| Variable | Description | How to get the value |
|----------|-------------|----------------------|
| `AZURE_WEBAPP_NAME` | Name of your Azure Web App | Run `azd env get-values` and copy the `SERVICE_WEB_NAME` value, or find in **Azure Portal > App Services > Your app > Name** |

## Create Azure Federated Credentials

```bash
# Create app registration
az ad app create --display-name "github-actions-deploy"

# Get the app ID
APP_ID=$(az ad app list --display-name "github-actions-deploy" --query "[0].appId" -o tsv)

# Create service principal
az ad sp create --id $APP_ID

# Assign Contributor role to resource group
az role assignment create \
  --assignee $APP_ID \
  --role Contributor \
  --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group-name>

# Add federated credential for GitHub Actions
az ad app federated-credential create --id $APP_ID --parameters '{
  "name": "github-actions-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:<owner>/<repo>:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}'
```

Replace `<subscription-id>`, `<resource-group-name>`, `<owner>`, and `<repo>` with your values.
