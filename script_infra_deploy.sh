# allow execution access
# chmod +x ./script_infra_deploy.yml

#!/bin/bash

# deploy infrastructure natively
echo "info. deployment has started..."
if ! command -v jq &> /dev/null; then
    echo "'jq' utility is missing. attempting automated installation..."
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get update && sudo apt-get install -y jq
    elif [ -x "$(command -v brew)" ]; then
        brew install jq
    else
        echo "error. system package manager not found. please install 'jq' manually."
        exit 1
    fi
fi

echo "info. required utility 'jq' is verified and ready."

RESOURCE_GROUP="amonitor-prod-rg"
LOCATION="eastus"
PROJECT_PREFIX="amonitor"
OUTPUT_FILE="./deployed_infrastructure_secrets.txt"

az login

az group create --name $RESOURCE_GROUP --location $LOCATION

DEPLOY_OUTPUT=$(az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file ./infra/main.bicep \
  --parameters ./infra/main.bicepparam \
  --output json)

if [ $? -ne 0 ]; then
  echo "error. deployment failed. please check logs"
  exit 1
fi

VM_PUBLIC_IP=$(echo $DEPLOY_OUTPUT | jq -r '.properties.outputs.vmPublicIP.value')
if [ -z "$VM_PUBLIC_IP" ] || [ "$VM_PUBLIC_IP" == "null" ]; then
    VM_PUBLIC_IP=$(az network public-ip list --resource-group $RESOURCE_GROUP --query "[0].ipAddress" --output tsv)
fi

STORAGE_NAME=$(echo $DEPLOY_OUTPUT | jq -r '.properties.outputs.STORAGE_NAME.value')
if [ -z "$STORAGE_NAME" ] || [ "$STORAGE_NAME" == "null" ]; then
    STORAGE_NAME=$(az storage account list --resource-group $RESOURCE_GROUP --query "[0].name" --output tsv)
fi

QUEUE_NAME="amonitorqueue"
CONNECTION_STRING=""
if [ ! -z "$STORAGE_NAME" ] && [ "$STORAGE_NAME" != "null" ]; then
    CONNECTION_STRING=$(az storage account show-connection-string \
      --name "$STORAGE_NAME" \
      --resource-group "$RESOURCE_GROUP" \
      --query "connectionString" \
      --output tsv)
fi

echo "====================================================" > $OUTPUT_FILE
echo "             AMONITOR INFRASTRUCTURE KEYS           " >> $OUTPUT_FILE
echo "====================================================" >> $OUTPUT_FILE
echo "VM_PUBLIC_IP: $VM_PUBLIC_IP" >> $OUTPUT_FILE
echo "STORAGE_NAME: $STORAGE_NAME" >> $OUTPUT_FILE
echo "QUEUE_NAME: $QUEUE_NAME" >> $OUTPUT_FILE
echo "STORAGE_CONNECTION_STRING: $CONNECTION_STRING" >> $OUTPUT_FILE
echo "QUEUE_CONNECTION_STRING: $CONNECTION_STRING" >> $OUTPUT_FILE
echo "====================================================" >> $OUTPUT_FILE

clear
echo "=========================================================================="
echo "info. deployment successful..."
echo "=========================================================================="
echo ""
echo "info. secrets are written in: $OUTPUT_FILE"
echo ""
echo "info. follow below steps to configure your pipeline:"
echo ""
echo "1. copy the generated keys out of '$OUTPUT_FILE'."
echo "2. go to your GitHub repository/fork's settings page."
echo "3. navigate to: Settings -> Secrets and Variables -> Actions."
echo "4. create/update these Repository Action Secrets:"
echo "     • SSH_HOST                   = $VM_PUBLIC_IP"
echo "     • SSH_USERNAME               = azureuser"
echo "     • SSH_KEY                    = The contents of your private identity key file (.pem)"
echo "     • SSH_PASSPHRASE             = The passphrase of your ssh key and empty if not configured"
echo "     • REPO_URL                   = The HTTPS link format of your repo/fork: https://github.com/<username>/amonitor.git"
echo "     • DB_CONNECTION_STRING       = Host=timescaledb;Database=alerts_db;Username=postgres;Password=secret"
echo "     • QUEUE_CONNECTION_STRING    = $CONNECTION_STRING"
echo "     • QUEUE_NAME                 = amonitorqueue"
echo "     • STORAGE_CONNECTION_STRING  = $CONNECTION_STRING"
echo "     • STORAGE_NAME               = $STORAGE_NAME"
echo ""
echo "5. push a new commit or code push to the main branch to start the CD deploy."
echo ""
echo "--------------------------------------------------------------------------"
echo "info. to log in and secure the linux operating system manually:"
echo "--------------------------------------------------------------------------"
echo "run this command from your laptop terminal window:"
echo "ssh -i <your_private_key_path> azureuser@$VM_PUBLIC_IP"
echo "=========================================================================="