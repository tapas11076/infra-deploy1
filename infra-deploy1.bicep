param vnetName string = 'Devops-Infra-Deploy-Default'
param location string = resourceGroup().location
param sourceSSHAddress string = '1.1.1.1/32'
var subnetName = '${vnetName}-private'
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: vnetName
  location:location
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
          addressPrefix: '10.0.240.0/20'
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
          description: 'Allow SSH from Client'
          destinationAddressPrefix: '10.11.0.0/24'
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
