# allow execution access
# chmod +x ./script_db_migration.sh

#!/bin/bash

# migrates database shape to the running database
dotnet ef migrations add Update_For_FiredDate --project ./AMonitor.API/AMonitor.API.csproj
