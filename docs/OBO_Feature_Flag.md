# OnBehalfOfUser (OBO) Authentication Feature Flag

## Overview

A feature flag has been implemented to control OnBehalfOfUser (OBO) authentication for Kusto clusters across all environments. This allows you to disable OBO authentication globally while maintaining the cluster configuration, providing a graceful fallback to ManagedIdentity authentication.

## Why OnBehalfOfUser (OBO) Authentication is Needed

OnBehalfOfUser authentication provides several key benefits for multi-tenant Kusto query scenarios:

1. **User-Level Authorization**: When users query Kusto clusters through the service, OBO ensures that Kusto enforces row-level security and data access policies based on the **actual end user's identity**, not the service's Managed Identity. This is critical for scenarios where different users should see different subsets of data.

2. **Audit Trail & Compliance**: OBO authentication ensures that all Kusto queries are logged with the **original user's identity** in Kusto's audit logs. This provides:
   - Clear audit trails showing who accessed what data
   - Compliance with security and privacy requirements
   - Better debugging and troubleshooting capabilities

3. **Fine-Grained Access Control**: With OBO, Kusto can apply user-specific permissions and restrictions:
   - Users only see tenants/data they're authorized to access
   - Different users can have different query capabilities
   - Supports complex multi-tenant scenarios with isolation requirements

4. **Security Best Practices**: OBO follows the principle of least privilege by propagating user identity through the call chain, rather than using a single service identity with elevated permissions.

**Current State**: While OBO provides these benefits, it requires proper certificate configuration and Azure AD setup. The feature flag allows us to gracefully fall back to ManagedIdentity authentication in environments where OBO is not yet configured, while maintaining the ability to enable it when ready.

## Configuration

### Feature Flag Location

The feature flag is configured in the `Kusto` section of your appsettings files:

```json
{
  "Kusto": {
    "EnableOnBehalfOfUser": false,
    "Clusters": {
      "SpoProd": {
        "ClusterUri": "https://spogdskustocluster.eastus2.kusto.windows.net",
        "DefaultDatabase": "spoprod",
        "AuthMode": "OnBehalfOfUser",
        "ClientId": ""
      }
    }
  }
}
```

### Feature Flag Values

- **`true`** (default): OnBehalfOfUser authentication is enabled
  - Clusters configured with `AuthMode: "OnBehalfOfUser"` will use OBO authentication
  - Requires valid certificate configuration and user context

- **`false`**: OnBehalfOfUser authentication is disabled
  - All clusters configured with `AuthMode: "OnBehalfOfUser"` will automatically fall back to ManagedIdentity
  - No code changes or cluster reconfiguration needed
  - User context is not required

### Current Configuration Status

The feature flag is currently set to **`false` (Disabled)** in all environments:
- ✅ `appsettings.dev.json` (Test environment)
- ✅ `appsettings.msit.json` (MSIT environment)
- ✅ `appsettings.sdf.json` (SDF environment)

## How It Works

### Authentication Flow

1. **KustoClientFactory** requests a token provider from **TokenProviderRouter**
2. **TokenProviderRouter** checks the feature flag (`EnableOnBehalfOfUser`)
3. If the flag is `false` and the cluster is configured for OBO:
   - **Automatic Fallback**: Uses `ManagedIdentityTokenProvider` instead
   - **Logging**: Warning logged about the fallback
4. If the flag is `true` and the cluster is configured for OBO:
   - Uses `OnBehalfOfUserTokenProvider` as normal
   - Requires user context and valid certificate

### Affected Components

#### 1. **KustoConfiguration** ([`KustoClusterConfig.cs`](../src/FABTenantService.Data.Kusto/Configuration/KustoClusterConfig.cs))
```csharp
public bool EnableOnBehalfOfUser { get; set; } = true;
```

#### 2. **TokenProviderRouter** ([`TokenProviderRouter.cs`](../src/StartupApp/Services/Auth/TokenProviderRouter.cs))
- Checks feature flag before routing to OBO provider
- Falls back to ManagedIdentity when flag is disabled
- Logs warning about fallback behavior

#### 3. **OnBehalfOfUserTokenProvider** ([`OnBehalfOfUserTokenProvider.cs`](../src/StartupApp/Services/Auth/OnBehalfOfUserTokenProvider.cs))
- Additional safety check at token acquisition time
- Throws descriptive error if invoked when flag is disabled
- Helps catch configuration issues

#### 4. **KustoClientFactory** ([`KustoClientFactory.cs`](../src/FABTenantService.Data.Kusto/Client/KustoClientFactory.cs))
- Uses effective AuthMode for caching decisions
- When OBO is disabled:
  - Uses shared cache key (no user-specific caching)
  - Cache entries never expire (ManagedIdentity behavior)

## Logging

When OBO is disabled, you'll see log messages like:

### At Token Provider Selection
```
[Warning] OnBehalfOfUser authentication is disabled via feature flag. 
Falling back to ManagedIdentity for cluster 'https://spogdskustocluster.eastus2.kusto.windows.net'
```

### At Client Creation
```
[Information] Using ManagedIdentityTokenProvider for cluster 'https://spogdskustocluster.eastus2.kusto.windows.net' 
(Configured AuthMode: OnBehalfOfUser, Effective AuthMode: managedidentity)
```

### At Cache Configuration
```
[Information] Creating new Kusto client for cluster '...', database '...' with persistent caching 
(Configured AuthMode: OnBehalfOfUser, Effective AuthMode: ManagedIdentity)
```

## Testing & Validation

### To Enable OBO (for testing)

Update the relevant appsettings file:
```json
{
  "Kusto": {
    "EnableOnBehalfOfUser": true,
    "Clusters": { ... }
  }
}
```

### To Disable OBO (current state)

Keep the flag set to `false`:
```json
{
  "Kusto": {
    "EnableOnBehalfOfUser": false,
    "Clusters": { ... }
  }
}
```

### Verification Steps

1. **Check Logs**: Look for warning messages about OBO being disabled
2. **Verify Authentication**: Confirm queries succeed using ManagedIdentity
3. **Check User Context**: No user context errors should occur when flag is disabled
4. **Monitor Performance**: Verify caching is working correctly

## Troubleshooting

### Issue: OBO still being used despite flag being false

**Possible Causes:**
- Configuration not reloaded (restart application)
- Wrong appsettings file being loaded
- Feature flag in wrong section

**Resolution:**
- Verify the correct appsettings file is active
- Check logs for "OBO Feature Flag: false"
- Restart the application

### Issue: ManagedIdentity authentication failing

**Possible Causes:**
- Managed Identity not assigned to the service
- Missing RBAC roles on Kusto clusters
- Incorrect MSIAppId in configuration

**Resolution:**
- Verify Managed Identity is assigned
- Check RBAC roles on target Kusto clusters
- Confirm MSIAppId matches the environment:
  - Test: `682ce8e4-35d2-489d-88de-37e786fde470`
  - MSIT: `79ad4654-8013-469f-a926-0984d709c0c4`
  - SDF: `cc774171-9355-42e8-b7cd-384843ba4fe3`

## Future Work

When OBO authentication is fixed in non-test environments:

1. Set `EnableOnBehalfOfUser: true` in the target environment's appsettings
2. Verify certificate is correctly configured in KeyVault
3. Confirm API permissions are granted in Azure AD
4. Test with user authentication
5. Monitor logs for successful OBO token acquisition