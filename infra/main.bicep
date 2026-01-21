// ============================================================================
// Main Bicep Template for ZavaStorefront Application
// Deploys: App Service Plan, Web App, Log Analytics, Application Insights
// ============================================================================

targetScope = 'subscription'

// ============================================================================
// Parameters
// ============================================================================

@minLength(1)
@maxLength(64)
@description('Name of the environment (e.g., dev, staging, prod)')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Name of the application')
param appName string = 'zavastorefront'

@description('App Service Plan SKU name')
@allowed([
  'F1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1v3'
  'P2v3'
  'P3v3'
])
param appServicePlanSku string = 'B1'

// ============================================================================
// Variables
// ============================================================================

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
  application: appName
  environment: environmentName
}

// Resource naming
var resourceGroupName = '${abbrs.resourceGroup}${appName}-${environmentName}'
var appServicePlanName = '${abbrs.appServicePlan}${appName}-${environmentName}-${resourceToken}'
var webAppName = '${abbrs.webApp}${appName}-${environmentName}-${resourceToken}'
var logAnalyticsName = '${abbrs.logAnalyticsWorkspace}${appName}-${environmentName}-${resourceToken}'
var appInsightsName = '${abbrs.appInsights}${appName}-${environmentName}-${resourceToken}'

// ============================================================================
// Resource Group
// ============================================================================

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// ============================================================================
// Monitoring Resources
// ============================================================================

module logAnalytics 'resources/logAnalytics.bicep' = {
  name: 'logAnalytics'
  scope: rg
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
  }
}

module appInsights 'resources/appInsights.bicep' = {
  name: 'appInsights'
  scope: rg
  params: {
    name: appInsightsName
    location: location
    tags: tags
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

// ============================================================================
// App Service Resources
// ============================================================================

module appServicePlan 'resources/appServicePlan.bicep' = {
  name: 'appServicePlan'
  scope: rg
  params: {
    name: appServicePlanName
    location: location
    tags: tags
    sku: appServicePlanSku
  }
}

module webApp 'resources/webApp.bicep' = {
  name: 'webApp'
  scope: rg
  params: {
    name: webAppName
    location: location
    tags: tags
    appServicePlanId: appServicePlan.outputs.id
    appInsightsConnectionString: appInsights.outputs.connectionString
  }
}

// ============================================================================
// Outputs
// ============================================================================

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_RESOURCE_GROUP string = rg.name

output SERVICE_WEB_NAME string = webApp.outputs.name
output SERVICE_WEB_URI string = webApp.outputs.uri

output LOG_ANALYTICS_WORKSPACE_ID string = logAnalytics.outputs.id
output APPLICATION_INSIGHTS_NAME string = appInsights.outputs.name
