# AMonitor

[![Secure Production CD Pipeline](https://github.com/lizardkingLK/amonitor/actions/workflows/deploy.yml/badge.svg)](https://github.com/lizardkingLK/amonitor/actions/workflows/deploy.yml)

### A simple dashboard for azure monitor

AMonitor is a high-performance, resilient, and secure observability platform designed to ingest, process, and display Azure Monitor alerts in real-time. Built using a modern .NET 10 Native AOT core, it processes telemetry payloads asynchronously and streams them directly into a TimescaleDB database for advanced analytical tracking.

---

## Core Architecture Overview

AMonitor employs an asynchronous, event-driven pattern designed to guarantee zero data loss during server maintenance windows or heavy cloud alert spikes:

```text
[Azure Subscription Alerts]
          | (Subscription-Wide Net: rule_default Intercepts Event)
[Azure Logic App Gateway]
          | (Wraps JSON telemetry body safely)
[Azure Storage Queue] (Safe In-Flight Telemetry Buffer Drive)
          |
[Azure Ubuntu VM]
   ├── [Nginx Proxy Gateway] (Secure HTTPS Port 443 Ingress)
   ├── [.NET 10 API Ingestion Daemon] (High-Performance Worker / Native AOT)
   ├── [TimescaleDB Database Core] (Time-Series Optimization Tables)
   └── [Grafana Analytics Workspace] (Live Real-Time Dashboards Panel)
```

---

## Repository File Workspace Directory Structure

```text
amonitor/
├── .github/workflows/
│   └── deploy.yml               # Automated Secure GitHub Actions CD Pipeline
├── AMonitor.API/
│   ├── Extensions/              # Database, Logging, and Ingestion Services
│   ├── Jobs/
│   │   ├── ArchiveProcessorWorker.cs # 24-Hour Blob Data Archiving Engine
│   │   └── QueueProcessorWorker.cs # Background Thread Storage Queue Poller
│   ├── Models/                  # Type-Safe Option Binding Framework Mapping Classes
|   ├── Outputs/                 # Backed up Production Visualization Panels
│   ├── Services/                # Core Database Row Processor Logic
│   ├── Dockerfile               # High-Efficiency Native AOT Compiling Target
│   └── appsettings.json         # Safe Local Workspace Development Parameter Template
├── infra/
│   ├── main.bicep               # One-Click Infrastructure as Code Template File
│   └── main.bicepparam          # Private Environment Variable Inputs Schema
├── nginx.dev.conf               # Local Desktop Testing Routing Pipeline Configuration
├── nginx.prod.conf              # Cloud Secure Port 443 HTTPS Padlock Route Paths
├── docker-compose.yml           # Shared Structural Core Containers Settings Engine
├── docker-compose.dev.yml       # Local Loopback Testing Environment Settings Tweak
└── docker-compose.prod.yml      # Azure Cloud Virtual Machine Live Production Override
```

---

## Infrastructure Automation Deployment Quick Start

### 1. Provision the Azure Cloud Resources (IaC)
Ensure the Azure CLI is installed on your local laptop, open your terminal workspace directory, and execute the automated Bicep compilation script layout task:

```bash
# Authenticate your terminal context shell with your Azure subscription
az login

# Create a clean Resource Group wrapper storage home region
az group create --name amonitor-production-rg --location eastus

# Compile and launch the cloud architecture infrastructure fabric 
az deployment group create \
  --resource-group amonitor-production-rg \
  --template-file ./infra/main.bicep \
  --parameters ./infra/main.bicepparam
```

or simply check the `main.bicepparam` file and configure it with ssh key and use the script `script_infra_deploy.sh`.

### 2. Configure GitHub CD Variable Environment Secrets
To activate your automated deployment pipeline, navigate to your **GitHub Repository Settings -> Secrets and variables -> Actions** page, and map these secure parameters:
* `SSH_HOST`: Your newly generated Azure VM Static Public IP address string.
* `SSH_USERNAME`: Your specified VM terminal username (Default: `azureuser`).
* `SSH_KEY`: The contents of your private identity key file (`.pem`).
* `REPO_URL`: The HTTPS link format of your repo/fork: `https://github.com/<username>/amonitor.git`.
* `DB_CONNECTION_STRING`: `Host=timescaledb;Database=alerts_db;Username=postgres;Password=secret`
* `QUEUE_CONNECTION_STRING`: Your private Azure Storage Queue SAS credentials block.
* `QUEUE_NAME`: Name of the configured queue storage (Default: `amonitorqueue`).
* `STORAGE_CONNECTION_STRING`: Your Azure Storage Blob Account Access Keys string path.
* `STORAGE_NAME`: Name of the configured blob storage (Default: `amonitor-cold-storage`)
---

## Local Desktop Workspace Coding Run Controls

To spin up a local development database test mesh environment on your local machine laptop with zero cloud keys requirements, use the split compose templates loop script format:

```bash
# Launches Nginx, TimescaleDB, Grafana and the API on localhost:80
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
```

or use the script `script_docker_dev.sh`

*Your local worker loop will print out a safe placeholder warning, turning off cloud queue polling while keeping your endpoints and database active for native terminal debugging tests!*

---

## Automated Let's Encrypt Certificate Management

Production telemetry uses a custom shell automated job engine to ensure your secure HTTPS padlock paths never drop connection lines. The scheduled execution loop steps run on a weekly schedule inside your host VM crontab:

```text
0 2 * * 1 /home/azureuser/amonitor-app/renew_certs.sh >> /home/azureuser/amonitor-app/cron_renewal.log 2>&1
```
