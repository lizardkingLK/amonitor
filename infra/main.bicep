@description('The name prefix for all generated monitoring resources')
param projectPrefix string = 'amonitor'

@description('The location region for the cloud infrastructure')
param location string = resourceGroup().location

@description('The admin username for your virtual machine login')
param adminUsername string = 'azureuser'

@description('The secure public SSH key data string for your pc')
@secure()
param adminSshKey string

// VIRTUAL NETWORK SWITCH PORTS
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: '${projectPrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

// NETWORK SECURITY GROUP (NSG) GATEWAY FIREWALL
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: '${projectPrefix}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH-22'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'Allow-HTTP-80'
        properties: {
          priority: 110
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'Allow-HTTP-443'
        properties: {
          priority: 120
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
    ]
  }
}

// PUBLIC STATIC IP ROUTER
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: '${projectPrefix}-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// VIRTUAL INTERFACE CARD (NIC) LINK
resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: '${projectPrefix}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

// UBUNTU LINUX ENGINE MACHINE
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: '${projectPrefix}-vm'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: '${projectPrefix}-vm'
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminSshKey
            }
          ]
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// AZURE STORAGE ACCOUNT (QUEUES & BLOB COLD STORAGE)
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${take(projectPrefix, 4)}st${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// INGESTION BUFFER QUEUE SERVICE
resource queueService 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-01-01' = {
  name: '${storageAccount.name}/default/amonitorqueue'
}

// HISTORICAL COLD STORAGE BLOB CONTAINER
resource blobService 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccount.name}/default/amonitor-cold-storage'
}

// AUTOMATED LOGIC APP ENVELOPE BRIDGE (CLEAN & DYNAMIC)
resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: '${projectPrefix}-queue-bridge'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {}
          }
        }
      }
      actions: {
        Push_To_Storage_Queue: {
          type: 'Http'
          inputs: {
            method: 'POST'
            uri: 'https://${storageAccount.name}.queue.${environment().suffixes.storage}/amonitorqueue/messages'
            headers: {
              'Content-Type': 'application/xml'
              'x-ms-version': '2023-08-03'
            }
            body: '<QueueMessage><MessageText>@{base64(string(triggerBody()))}</MessageText></QueueMessage>'
            authentication: {
              type: 'ManagedServiceIdentity'
              audience: 'https://storage.azure.com'
            }
          }
        }
      }
    }
  }
}

// AUTOMATED STORAGE QUEUE RBAC ROLE ASSIGNMENT
var storageQueueDataContributorRoleId = '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, logicApp.id, storageQueueDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageQueueDataContributorRoleId)
    principalId: logicApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// AUTOMATES ACTION GROUP WEBHOOK GATEWAY
resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: '${projectPrefix}-ActionGroup'
  location: 'Global'
  properties: {
    groupShortName: 'amonitor'
    enabled: true
    webhookReceivers: [
      {
        name: 'LogicAppBridge'
        serviceUri: listCallbackUrl(resourceId('Microsoft.Logic/workflows/triggers', '${projectPrefix}-queue-bridge', 'manual'), '2019-05-01').value
        useCommonAlertSchema: true
      }
    ]
  }
}

// AUTOMATED SUBSCRIPTION-WIDE ALERT PROCESSING RULE
resource ruleDefault 'Microsoft.AlertsManagement/actionRules@2021-08-08' = {
  name: 'rule_default'
  location: 'Global'
  properties: {
    scopes: [
      subscription().id
    ]
    description: 'Intercepts all fired cloud alerts and forces them into the AMonitor queue bridge.'
    enabled: true
    actions: [
      {
        actionType: 'AddActionGroups'
        actionGroupIds: [
          actionGroup.id
        ] 
      }
    ]
  }
}

// AUTOMATED DOCKER ENGINE BOOTSTRAPPER AND CERTBOT EXTENSION
resource vmDockerSetup 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  parent: vm
  name: 'InstallDockerAndPrepareEnvironment'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'sudo apt-get update && sudo apt-get install -y docker.io docker-compose-v2 certbot && sudo usermod -aG docker azureuser && mkdir -p /home/azureuser/amonitor-app && chown -R azureuser:azureuser /home/azureuser/amonitor-app'
    }
  }
}

output vmPublicIP string = publicIp.properties.ipAddress
output STORAGE_NAME string = storageAccount.name
output QUEUE_NAME string = 'amonitorqueue'
