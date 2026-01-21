// ============================================================================
// Application Insights Module
// ============================================================================

@description('Name of the Application Insights resource')
param name string

@description('Location for the resource')
param location string

@description('Tags for the resource')
param tags object = {}

@description('Resource ID of the Log Analytics Workspace')
param logAnalyticsWorkspaceId string

@description('Application type')
@allowed([
  'web'
  'other'
])
param applicationType string = 'web'

// ============================================================================
// Resource
// ============================================================================

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: applicationType
    WorkspaceResourceId: logAnalyticsWorkspaceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Resource ID of Application Insights')
output id string = appInsights.id

@description('Name of Application Insights')
output name string = appInsights.name

@description('Instrumentation Key for Application Insights')
output instrumentationKey string = appInsights.properties.InstrumentationKey

@description('Connection String for Application Insights')
output connectionString string = appInsights.properties.ConnectionString
