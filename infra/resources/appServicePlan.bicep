// ============================================================================
// App Service Plan Module
// ============================================================================

@description('Name of the App Service Plan')
param name string

@description('Location for the resource')
param location string

@description('Tags for the resource')
param tags object = {}

@description('SKU name for the App Service Plan')
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
param sku string = 'B1'

@description('Kind of App Service Plan')
param kind string = 'app'

@description('Is the plan reserved (Linux)?')
param reserved bool = false

// ============================================================================
// Variables
// ============================================================================

var skuTiers = {
  F1: 'Free'
  B1: 'Basic'
  B2: 'Basic'
  B3: 'Basic'
  S1: 'Standard'
  S2: 'Standard'
  S3: 'Standard'
  P1v3: 'PremiumV3'
  P2v3: 'PremiumV3'
  P3v3: 'PremiumV3'
}

// ============================================================================
// Resource
// ============================================================================

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  sku: {
    name: sku
    tier: skuTiers[sku]
  }
  properties: {
    reserved: reserved
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Resource ID of the App Service Plan')
output id string = appServicePlan.id

@description('Name of the App Service Plan')
output name string = appServicePlan.name
