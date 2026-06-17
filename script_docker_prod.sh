# allow execution access
# chmod +x ./script_docker_prod.yml

#!/bin/bash

# starts docker for prod environment
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
