# GitHub Actions Deployment Setup

This workflow builds the .NET app as a container and deploys it to Azure App Service using OIDC authentication (federated credentials).

## Prerequisites

1. Azure App Service provisioned (via `azd provision`)
2. Azure AD App Registration with federated credentials for GitHub Actions

## Configure GitHub Secrets

In your repository, go to **Settings > Secrets and variables > Actions** and add these secrets:

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | App registration client ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |

## Configure GitHub Variables

Under **Settings > Secrets and variables > Actions > Variables**, add:

| Variable | Description |
|----------|-------------|
| `AZURE_WEBAPP_NAME` | Name of your Azure Web App (from `azd provision` output: `SERVICE_WEB_NAME`) |

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
