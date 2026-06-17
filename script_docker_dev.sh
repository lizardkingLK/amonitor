# allow execution access
# chmod +x ./script_docker_dev.yml

#!/bin/bash

# starts docker for local environment
docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build