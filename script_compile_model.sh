# allow execution access
# chmod +x ./script_compile_model.sh

#!/bin/bash

# execute this command with dotnet tool 'dotnet-ef' pre-installed
dotnet ef dbcontext optimize --project ./AMonitor.API/AMonitor.API.csproj \
--output-dir ./Data/Compiled \
--namespace AMonitor.API.Data.Compiled