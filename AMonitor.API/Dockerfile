# Stage 1: Build the application using the .NET SDK
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build-env
WORKDIR /app

# Copy and restore project files
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build the release
COPY . ./
RUN dotnet publish -c Release -o out

# Stage 2: Create the runtime image using the ASP.NET base
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build-env /app/out .

# Expose the API port
EXPOSE 5136

# Start the application
ENTRYPOINT ["dotnet", "AMonitor.API.dll"]
