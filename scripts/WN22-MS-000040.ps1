<#
.SYNOPSIS
    Restricts unauthenticated RPC clients from connecting to the RPC server.

.DESCRIPTION
    This script sets the 'RestrictRemoteClients' registry value to 1 under the 
    \SOFTWARE\Policies\Microsoft\Windows NT\Rpc\ path. This enforces RPC client authentication 
    and prevents anonymous connections, enhancing system security.

.NOTES
    Author          : Kenneth Clendenin
    AI Contribution : Script generated with assistance from GitHub Copilot and OpenAI ChatGPT.
    Validation      : Final version reviewed, refined, and validated as functional based on Tenable scan results.
    LinkedIn        : https://www.linkedin.com/in/kenneth-clendenin/
    GitHub          : https://github.com/KennethClendenin
    Date Created    : 2025-06-12
    Last Modified   : 2025-06-13
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN22-MS-000040

.LINK
    https://stigaview.com/products/winserv2022/v2r4/WN22-MS-000040/

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.PARAMETER Enable
    Use `$true` to enforce authentication for all remote RPC clients (compliant).
    Use `$false` to allow unauthenticated RPC connections (non-compliant/test only).

.EXAMPLE
    PS C:\> .\WN22-MS-000040.ps1 -Enable $true
#>

# Accepts a boolean parameter to enable or disable restriction of unauthenticated RPC clients
param (
    [Parameter(Mandatory = $true, HelpMessage = "Use `$true` to restrict unauthenticated RPC clients (compliant), `$false` to allow them (non-compliant/test only)")]
    [bool]$Enable
)

# Function to set the registry value for RPC client authentication restriction
function Set-RPCClientAuthenticationRestriction {
    param (
        [Parameter(Mandatory = $true)]
        [bool]$State
    )

    $registryPath  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" # Registry path for RPC policy
    $valueName     = "RestrictRemoteClients" # Registry value name
    $desiredValue  = if ($State) { 1 } else { 0 } # 1 restricts unauthenticated, 0 allows

    try {
        # Create the registry path if it doesn't exist
        if (-not (Test-Path -Path $registryPath)) {
            Write-Verbose "Registry path not found. Creating: $registryPath"
            New-Item -Path $registryPath -Force | Out-Null
        }

        # Get the current value (if any)
        $currentValue = (Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue).$valueName

        # Set the value if it is not already set as desired
        if ($currentValue -ne $desiredValue) {
            Write-Host "[$valueName] Setting unauthenticated RPC restriction to $desiredValue (compliant: $($State -eq $true))"
            Set-ItemProperty -Path $registryPath -Name $valueName -Value $desiredValue -Type DWord -Force
        }
        else {
            Write-Host "[$valueName] Value is already set to $desiredValue. No changes made."
        }
    }
    catch {
        Write-Error "[$valueName] Failed to set registry value: $_"
    }
}

# Apply the setting using the provided parameter
Set-RPCClientAuthenticationRestriction -State:$Enable
