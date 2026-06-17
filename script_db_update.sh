# allow execution access
# chmod +x ./script_db_update.sh

#!/bin/bash

# migrates migrated shape to the running database
dotnet ef database update --project ./AMonitor.API/AMonitor.API.csproj --verbose