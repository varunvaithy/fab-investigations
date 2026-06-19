# Local Development Setup

## Authentication Setup

The service uses `DefaultAzureCredential` for authentication. For local development:

```bash
# Login to Azure CLI
az login

# Set the correct subscription (if needed)
az account set --subscription <subscription-id>
```

## Configuration

The service uses environment-specific configuration files in `src/StartupApp/Config/`:
- `appsettings.local.json` - For local development
- `appsettings.dev.json` - For test environment  
- `appsettings.msit.json` - For MSIT environment
- `appsettings.sdf.json` - For SDF/production environment

### Key Configuration Sections

Verify the following in `appsettings.local.json`:

**SQL Connection:**
```json
"ConnectionStrings": {
  "DbConnection": "Server=fabdardbsvr.database.windows.net; Database=FAB_DAR_DB;..."
}
```

**Kusto Clusters:**
```json
"Kusto": {
  "Clusters": {
    "D2KKusto": {
      "ClusterUri": "https://idsharedwus.kusto.windows.net/",
      "DefaultDatabase": "D2KRedacted"
    },
    "SpoProd": {
      "ClusterUri": "https://spogdskustocluster.eastus2.kusto.windows.net",
      "DefaultDatabase": "spoprod"
    },
    "OdspFabKusto": {
      "ClusterUri": "https://signalhub-cluster.eastus.kusto.windows.net",
      "DefaultDatabase": "fabdardbdev"
    }
  }
}
```

## Running the Service

```bash
cd src/StartupApp
dotnet run
```

The service will be accessible at `http://localhost:8080`

## MCP Tools

Available tools:
1. **GetTenantBySsid** - Get tenant by Site Subscription ID
2. **QueryD2KTenantById** - Query D2K clusters for tenant identity
3. **QuerySharePointUsageByTenantId** - Query SharePoint usage patterns

## Authentication Flow

`DefaultAzureCredential` chain for local development:
1. Environment variables
2. Managed Identity (used in production)
3. **Azure CLI** ← Used for local development
4. Visual Studio credentials
5. VS Code credentials

## Troubleshooting

### Authentication Errors
```bash
az login
# Or clear cache: az account clear && az login
```

### SQL Connection Failures
- Verify Azure account has SQL database access
- Check IP is whitelisted in SQL Server firewall
- Confirm VPN connection (if required)

### Kusto Query Failures
- Verify Azure CLI login: `az account show`
- Ensure read permissions on Kusto clusters
- Check cluster URLs in configuration

## Before Committing

1. Revert [`Startup.cs`](../src/StartupApp/Hosting/Startup.cs) to production mode
2. Verify no sensitive data in configuration files
3. Run tests if available
