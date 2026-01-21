## Summary

Provision Azure infrastructure for the ZavaStorefront .NET web application using Azure Developer CLI (AZD) with Bicep templates.

## Requirements

### Compute and Deployment
- [ ] **Linux App Service** - Host the ZavaStorefront web application
- [ ] **Azure Container Registry (ACR)** - Store container images for deployment
- [ ] **Docker-based deployment** without requiring local Docker installation (use ACR Tasks for cloud-based builds)
- [ ] **Azure RBAC authentication** - App Service should use managed identity to pull images from ACR (no passwords/admin credentials)

### Monitoring
- [ ] **Application Insights** - Monitor application performance and telemetry
- [ ] **Log Analytics Workspace** - Required for Application Insights

### AI Services
- [ ] **Microsoft Foundry** - Deploy AI Hub and Project for GPT-4 and Phi model access

### Infrastructure Configuration
- [ ] **Region**: `westus3`
- [ ] **Single Resource Group** - All resources deployed together in the same region
- [ ] **Environment**: Development (`dev`)

### IaC Requirements
- [ ] Use **Azure Developer CLI (AZD)** for deployment orchestration
- [ ] Define all infrastructure using **Bicep** templates
- [ ] Create modular Bicep files for reusability

## Proposed Architecture

```
Resource Group (rg-zavastorefrontdev-westus3)
├── Azure Container Registry
│   └── RBAC: AcrPull role assigned to App Service managed identity
├── App Service Plan (Linux)
│   └── App Service (container deployment)
│       └── System-assigned Managed Identity
├── Application Insights
│   └── Log Analytics Workspace
└── Microsoft Foundry
    ├── AI Hub
    └── AI Project (GPT-4, Phi models)
```

## Acceptance Criteria

1. Running `azd up` provisions all resources successfully
2. App Service can pull container images from ACR using managed identity (no admin credentials)
3. ACR Tasks can build images without local Docker
4. Application Insights collects telemetry from the web app
5. Foundry project has access to GPT-4 and Phi models in westus3
6. All resources are in the same resource group and region

## Technical Notes

- Use `AcrPull` role assignment for managed identity authentication
- Enable ACR admin access disabled, rely solely on RBAC
- Configure App Service with `DOCKER_REGISTRY_SERVER_URL` pointing to ACR
- Set up Application Insights connection string in App Service configuration
