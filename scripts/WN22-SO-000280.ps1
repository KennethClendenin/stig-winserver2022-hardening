<#
.SYNOPSIS
    Prevents PKU2U authentication using online identities on Windows Server 2022.

.DESCRIPTION
    This script sets the 'AllowOnlineID' registry value to 0 under:
    HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\LSA\pku2u

    This disables the use of online identities for PKU2U authentication,
    enforcing centralized Windows account-based authentication.

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
    STIG-ID         : WN22-SO-000280

.LINK
    https://stigaview.com/products/winserv2022/v2r4/WN22-SO-000280/

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.PARAMETER Enable
    Use `$true` to disable PKU2U online identity authentication (compliant).
    Use `$false` to enable PKU2U online identity authentication (non-compliant/test only).

.EXAMPLE
    PS C:\> .\WN22-SO-000280.ps1 -Enable $true
#>

# Accepts a boolean parameter to enable or disable PKU2U online identity authentication
param (
    [Parameter(Mandatory = $true, HelpMessage = "Use `$true` to disable PKU2U online authentication (compliant), `$false` to enable (non-compliant/test only)")]
    [bool]$Enable
)

# Function to set the registry value for PKU2U online ID authentication
function Set-PKU2UOnlineID {
    param (
        [Parameter(Mandatory = $true)]
        [bool]$State
    )

    $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\LSA\pku2u" # Registry path for PKU2U
    $valueName    = "AllowOnlineID" # Registry value name
    $desiredValue = if ($State) { 0 } else { 1 } # 0 disables online ID, 1 enables

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
            Write-Host "[$valueName] Setting PKU2U online ID usage to $desiredValue (compliant: $($State -eq $true))"
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

# Apply the configuration using the provided parameter
Set-PKU2UOnlineID -State:$Enable
