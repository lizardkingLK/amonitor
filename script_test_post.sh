# allow execution access
# chmod +x ./script_test_post.sh

#!/bin/bash

# sample http post requests for localhost test on this port
curl --request POST --url http://localhost/api/azure-alerts --header 'content-type: application/json' --data '{
  "schemaId": "azureMonitorCommonAlertSchema",
  "data": {
    "essentials": {
      "alertId": "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.AlertsManagement/alerts/mem-9988",
      "alertRule": "High-Memory-Usage-Rule",
      "alertRuleId": "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/my-rg/providers/microsoft.insights/metricalerts/High-Memory-Usage-Rule",
      "severity": "Sev2",
      "signalType": "Metric",
      "monitorCondition": "Fired",
      "monitoringService": "Platform",
      "alertTargetIDs": ["/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/my-rg/providers/microsoft.compute/virtualmachines/production-vm-01"],
      "targetResourceName": "production-vm-01",
      "targetResource": "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/my-rg/providers/microsoft.compute/virtualmachines/production-vm-01",
      "targetResourceGroup": "my-rg",
      "targetResourceType": "microsoft.compute/virtualmachines",
      "configurationItems": ["production-vm-01"],
      "originAlertId": "11111111-1111-1111-1111-111111111111",
      "firedDateTime": "2026-06-16T10:15:00Z",
      "resolvedDateTime": null,
      "description": "Available RAM dropped below 10% for production-vm-01.",
      "essentialsVersion": "1.0",
      "alertContextVersion": "1.0"
    },
    "customProperties": {"environment": "production", "team": "devops"},
    "alertContext": {"Threshold": "90", "Operator": "GreaterThan"}
  }
}'
sleep 1

curl --request POST --url http://localhost/api/azure-alerts --header 'content-type: application/json' --data '{
  "schemaId": "azureMonitorCommonAlertSchema",
  "data": {
    "essentials": {
      "alertId": "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.AlertsManagement/alerts/disk-4433",
      "alertRule": "Critical-Disk-Space-Rule",
      "alertRuleId": "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/data-rg/providers/microsoft.insights/metricalerts/Critical-Disk-Space-Rule",
      "severity": "Sev1",
      "signalType": "Metric",
      "monitorCondition": "Fired",
      "monitoringService": "Platform",
      "alertTargetIDs": ["/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/data-rg/providers/microsoft.storage/storageaccounts/prod-db-disk-01"],
      "targetResourceName": "prod-db-disk-01",
      "targetResource": "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/data-rg/providers/microsoft.storage/storageaccounts/prod-db-disk-01",
      "targetResourceGroup": "data-rg",
      "targetResourceType": "microsoft.storage/storageaccounts",
      "configurationItems": ["prod-db-disk-01"],
      "originAlertId": "22222222-2222-2222-2222-222222222222",
      "firedDateTime": "2026-06-16T11:00:00Z",
      "resolvedDateTime": null,
      "description": "Storage space left on root directory is under 5%.",
      "essentialsVersion": "1.0",
      "alertContextVersion": "1.0"
    },
    "customProperties": {"environment": "production", "team": "data-infrastructure"},
    "alertContext": {"Threshold": "95", "Operator": "GreaterThan"}
  }
}'
sleep 1

curl --request POST --url http://localhost/api/azure-alerts --header 'content-type: application/json' --data '{
  "schemaId": "azureMonitorCommonAlertSchema",
  "data": {
    "essentials": {
      "alertId": "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.AlertsManagement/alerts/net-7766",
      "alertRule": "Network-Ingress-Spike",
      "alertRuleId": "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/network-rg/providers/microsoft.insights/metricalerts/Network-Ingress-Spike",
      "severity": "Sev3",
      "signalType": "Metric",
      "monitorCondition": "Fired",
      "monitoringService": "Platform",
      "alertTargetIDs": ["/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/network-rg/providers/microsoft.network/networkinterfaces/gateway-nic"],
      "targetResourceName": "gateway-nic",
      "targetResource": "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/network-rg/providers/microsoft.network/networkinterfaces/gateway-nic",
      "targetResourceGroup": "network-rg",
      "targetResourceType": "microsoft.network/networkinterfaces",
      "configurationItems": ["gateway-nic"],
      "originAlertId": "33333333-3333-3333-3333-333333333333",
      "firedDateTime": "2026-06-16T11:20:00Z",
      "resolvedDateTime": null,
      "description": "Inbound network packets exceeded safety limits.",
      "essentialsVersion": "1.0",
      "alertContextVersion": "1.0"
    },
    "customProperties": {"environment": "staging", "team": "networking"},
    "alertContext": {"Threshold": "500000000", "Operator": "GreaterThan"}
  }
}'
sleep 1

curl --request POST --url http://localhost/api/azure-alerts --header 'content-type: application/json' --data '{
  "schemaId": "azureMonitorCommonAlertSchema",
  "data": {
    "essentials": {
      "alertId": "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.AlertsManagement/alerts/12345",
      "alertRule": "High-CPU-Usage-Rule",
      "alertRuleId": "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/my-rg/providers/microsoft.insights/metricalerts/High-CPU-Usage-Rule",
      "severity": "Sev3",
      "signalType": "Metric",
      "monitorCondition": "Resolved",
      "monitoringService": "Platform",
      "alertTargetIDs": ["/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/my-rg/providers/microsoft.compute/virtualmachines/production-vm-01"],
      "targetResourceName": "production-vm-01",
      "targetResource": "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/my-rg/providers/microsoft.compute/virtualmachines/production-vm-01",
      "targetResourceGroup": "my-rg",
      "targetResourceType": "microsoft.compute/virtualmachines",
      "configurationItems": ["production-vm-01"],
      "originAlertId": "00000000-0000-0000-0000-000000000000",
      "firedDateTime": "2026-06-15T23:30:00Z",
      "resolvedDateTime": "2026-06-16T11:45:00Z",
      "description": "The CPU usage dropped back below 85%.",
      "essentialsVersion": "1.0",
      "alertContextVersion": "1.0"
    },
    "customProperties": {"environment": "production", "team": "devops"},
    "alertContext": {"Threshold": "85", "Operator": "LessThan"}
  }
}'
sleep 1

curl --request POST --url http://localhost/api/azure-alerts --header 'content-type: application/json' --data '{
  "schemaId": "azureMonitorCommonAlertSchema",
  "data": {
    "essentials": {
      "alertId": "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.AlertsManagement/alerts/db-0011",
      "alertRule": "Database-Connection-Timeout",
      "alertRuleId": "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/data-rg/providers/microsoft.insights/metricalerts/Database-Connection-Timeout",
      "severity": "Sev0",
      "signalType": "Log",
      "monitorCondition": "Fired",
      "monitoringService": "Log Analytics",
      "alertTargetIDs": ["/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/data-rg/providers/microsoft.sql/servers/sql-prod-srv"],
      "targetResourceName": "sql-prod-srv",
      "targetResource": "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/data-rg/providers/microsoft.sql/servers/sql-prod-srv",
      "targetResourceGroup": "data-rg",
      "targetResourceType": "microsoft.sql/servers",
      "configurationItems": ["sql-prod-srv"],
      "originAlertId": "55555555-5555-5555-5555-555555555555",
      "firedDateTime": "2026-06-16T11:50:00Z",
      "resolvedDateTime": null,
      "description": "Application logs indicate a total failure connecting to backend database.",
      "essentialsVersion": "1.0",
      "alertContextVersion": "1.0"
    },
    "customProperties": {"environment": "production", "team": "backend-dev"},
    "alertContext": {"Query": "Heartbeat | where Status == Down"}
  }
}'
sleep 1

curl --request POST --url http://localhost/api/azure-alerts --header 'content-type: application/json' --data '{
  "schemaId": "azureMonitorCommonAlertSchema",
  "data": {
    "essentials": {
      "alertId": "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.AlertsManagement/alerts/mem-9988",
      "alertRule": "High-Memory-Usage-Rule",
      "alertRuleId": "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/my-rg/providers/microsoft.insights/metricalerts/High-Memory-Usage-Rule",
      "severity": "Sev2",
      "signalType": "Metric",
      "monitorCondition": "Resolved",
      "monitoringService": "Platform",
      "alertTargetIDs": ["/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/my-rg/providers/microsoft.compute/virtualmachines/production-vm-01"],
      "targetResourceName": "production-vm-01",
      "targetResource": "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/my-rg/providers/microsoft.compute/virtualmachines/production-vm-01",
      "targetResourceGroup": "my-rg",
      "targetResourceType": "microsoft.compute/virtualmachines",
      "configurationItems": ["production-vm-01"],
      "originAlertId": "11111111-1111-1111-1111-111111111111",
      "firedDateTime": "2026-06-16T10:15:00Z",
      "resolvedDateTime": "2026-06-16T11:52:00Z",
      "description": "Memory buffer space cleared out successfully.",
      "essentialsVersion": "1.0",
      "alertContextVersion": "1.0"
    },
    "customProperties": {
      "environment": "production",
      "team": "devops"
    },
    "alertContext": {
      "Threshold": "90",
      "Operator": "LessThan"
    }
  }
}'
sleep 1

curl --request POST --url http://localhost/api/azure-alerts --header 'content-type: application/json' --data '
{
  "schemaId": "azureMonitorCommonAlertSchema",
  "data": {
    "essentials": {
      "alertId": "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.AlertsManagement/alerts/lat-2211",
      "alertRule": "High-API-Latency",
      "alertRuleId": "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/my-rg/providers/microsoft.insights/metricalerts/High-API-Latency",
      "severity": "Sev4",
      "signalType": "Metric",
      "monitorCondition": "Fired",
      "monitoringService": "Platform",
      "alertTargetIDs": [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/my-rg/providers/microsoft.web/sites/api-gateway-prod"
      ],
      "targetResourceName": "api-gateway-prod",
      "targetResource": "/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/my-rg/providers/microsoft.web/sites/api-gateway-prod",
      "targetResourceGroup": "my-rg",
      "targetResourceType": "microsoft.web/sites",
      "configurationItems": ["api-gateway-prod"],
      "originAlertId": "77777777-7777-7777-7777-777777777777",
      "firedDateTime": "2026-06-16T11:54:00Z",
      "resolvedDateTime": null,
      "description": "Average HTTP API response time exceeded 2.5 seconds.",
      "essentialsVersion": "1.0",
      "alertContextVersion": "1.0"
    },
    "customProperties": { "environment": "production", "team": "frontend-dev" },
    "alertContext": { "Threshold": "2500", "Operator": "GreaterThan" }
  }
}'