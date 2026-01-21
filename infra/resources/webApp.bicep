// ============================================================================
// Web App Module
// ============================================================================

@description('Name of the Web App')
param name string

@description('Location for the resource')
param location string

@description('Tags for the resource')
param tags object = {}

@description('Resource ID of the App Service Plan')
param appServicePlanId string

@description('Application Insights Connection String')
param appInsightsConnectionString string

@description('The runtime stack of the web app')
param linuxFxVersion string = ''

@description('.NET Framework version (for Windows)')
param netFrameworkVersion string = 'v8.0'

// ============================================================================
// Resource
// ============================================================================

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: name
  location: location
  tags: union(tags, {
    'azd-service-name': 'web'
  })
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      http20Enabled: true
      netFrameworkVersion: netFrameworkVersion
      linuxFxVersion: linuxFxVersion
      alwaysOn: true
      healthCheckPath: '/'
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnetcore'
        }
      ]
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Development'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'Recommended'
        }
      ]
    }
    publicNetworkAccess: 'Enabled'
  }
}

// Disable basic authentication for FTP
resource ftpPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: webApp
  name: 'ftp'
  properties: {
    allow: false
  }
}

// Disable basic authentication for SCM
resource scmPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: webApp
  name: 'scm'
  properties: {
    allow: false
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Resource ID of the Web App')
output id string = webApp.id

@description('Name of the Web App')
output name string = webApp.name

@description('Default hostname of the Web App')
output uri string = 'https://${webApp.properties.defaultHostName}'

@description('Principal ID of the system-assigned managed identity')
output identityPrincipalId string = webApp.identity.principalId
