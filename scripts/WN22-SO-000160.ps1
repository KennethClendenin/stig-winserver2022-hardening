<#
.SYNOPSIS
    Enforces the requirement for SMB clients to digitally sign communications at all times.

.DESCRIPTION
    This script sets the 'RequireSecuritySignature' registry value to 1 under the 
    \SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters\ path. 
    Enabling this ensures the SMB client will only communicate with servers that perform packet signing, 
    mitigating risks such as man-in-the-middle attacks.

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
    STIG-ID         : WN22-SO-000160

.LINK
    https://stigaview.com/products/winserv2022/v2r4/WN22-SO-000160/

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. :

.PARAMETER Enable
    Use `$true` to enforce required SMB signing (compliant).
    Use `$false` to disable required signing (non-compliant/test only).

.EXAMPLE
    PS C:\> .\WN22-SO-000160.ps1 -Enable $true
#>

# Accepts a boolean parameter to enable or disable required SMB signing
param (
    [Parameter(Mandatory = $true, HelpMessage = "Use `$true` to require SMB packet signing for all client communication (compliant), `$false` to disable (non-compliant/test only)")]
    [bool]$Enable
)

# Function to set the registry value for SMB client signing requirement
function Set-SMBClientSigningRequirement {
    param (
        [Parameter(Mandatory = $true)]
        [bool]$State
    )

    $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" # Registry path for SMB client
    $valueName    = "RequireSecuritySignature" # Registry value name
    $desiredValue = if ($State) { 1 } else { 0 } # 1 requires signing, 0 disables

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
            Write-Host "[$valueName] Setting SMB client signing requirement to $desiredValue (compliant: $($State -eq $true))"
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
Set-SMBClientSigningRequirement -State:$Enable
