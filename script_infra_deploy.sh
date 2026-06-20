# allow execution access
# chmod +x ./script_infra_deploy.yml

#!/bin/bash

# deploy infrastructure natively
az login
az group create --name amonitor-prod-rg --location eastus
az deployment group create \
  --resource-group amonitor-prod-rg \
  --template-file ./infra/main.bicep \
  --parameters ./infra/main.bicepparam"
