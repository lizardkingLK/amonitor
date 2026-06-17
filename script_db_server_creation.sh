# allow execution access
# chmod +x ./script_db_server_creation.sh

#!/bin/bash

# spins up a quick docker postgresql database instance
docker run --name temp-timescaledb -e POSTGRES_PASSWORD=secret -p 5432:5432 -d postgres:latest