# allow execution access
# chmod +x ./script_docker_prod.yml

#!/bin/bash

# git uses specific deployment key
git config core.sshCommand "ssh -i ~/.ssh/amonitor_deploy/amonitor_deploy.pub -F /dev/null"

# starts docker for prod environment
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
