param apimName string
param apimLocation string = resourceGroup().location
param publisherName string
param publisherEmail string
@description('The pricing tier of this API Management service')
@allowed([
  'Basic'
  'Consumption'
  'Developer'
  'Standard'
  'Premium'
])
param sku string = 'Consumption'

param appInsightsName string

resource storeapim 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: apimName
  location: apimLocation
  sku: {
    name: sku
    capacity: ((sku == 'Consumption') ? 0 : 1)
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightsName
}

resource storeapimLogger 'Microsoft.ApiManagement/service/loggers@2020-12-01' = {
  name: appInsightsName
  parent: storeapim
  properties: {
    loggerType: 'applicationInsights'
    credentials: {
      instrumentationKey: appInsights.properties.InstrumentationKey
    }
    description: 'sends logs to ${appInsightsName}'
    resourceId: appInsights.id
  }
}

output apimId string = storeapim.id
output fqdn string = storeapim.properties.gatewayUrl
