// Infra: VNet + NSG
param vnetName string = 'Devops-Infra-Deploy-Default'
param location string = resourceGroup().location

@description('CIDR allowed to connect via SSH (e.g. 203.0.113.4/32). Do NOT use 0.0.0.0/0. Provide this at deployment time or via CI variable group.')
param sourceSSHAddress string

var subnetName = '${vnetName}-private'
var subnetPrefix = '10.0.240.0/20'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: Main1NSG.id
          }
        }
      }
    ]
  }
}

resource Main1NSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'Main1NSG'
  location: location
  tags: {
    Project : 'Devops-Infra-Deploy'
  }
  properties: {
    flushConnection: false
    securityRules: [
      {
        id: 'ssh-rule'
        name: 'ssh-rule'
        properties: {
          access: 'Allow'
          description: 'Allow SSH from provided source CIDR'
          destinationAddressPrefix: subnetPrefix
          destinationPortRange: '22'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: sourceSSHAddress
          sourcePortRange: '*'
        }
      }
    ]
  }
}