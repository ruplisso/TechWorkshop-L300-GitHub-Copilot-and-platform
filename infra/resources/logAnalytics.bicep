// ============================================================================
// Log Analytics Workspace Module
// ============================================================================

@description('Name of the Log Analytics Workspace')
param name string

@description('Location for the resource')
param location string

@description('Tags for the resource')
param tags object = {}

@description('SKU name for Log Analytics')
@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param skuName string = 'PerGB2018'

@description('Retention period in days')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

// ============================================================================
// Resource
// ============================================================================

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: skuName
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Resource ID of the Log Analytics Workspace')
output id string = logAnalyticsWorkspace.id

@description('Name of the Log Analytics Workspace')
output name string = logAnalyticsWorkspace.name
