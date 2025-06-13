<#
.SYNOPSIS
    Enforces Remote Desktop client connection encryption level to "High Level".

.DESCRIPTION
    This script sets the 'MinEncryptionLevel' registry value to 3 under:
    \SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\
    This ensures that RDP sessions are encrypted in both directions with high-level encryption.

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
    STIG-ID         : WN22-CC-000380

.LINK
    https://stigaview.com/products/winserv2022/v2r4/WN22-CC-000380/

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.PARAMETER Enable
    Use `$true` to set encryption to High Level (compliant).
    Use `$false` to revert to low-level encryption (non-compliant/test only).

.EXAMPLE
    PS C:\> .\WN22-CC-000380.ps1 -Enable $true
#>

# Accepts a boolean parameter to enable or disable high-level encryption
param (
    [Parameter(Mandatory = $true, HelpMessage = "Use `$true` to enforce High encryption level (compliant), `$false` to revert (non-compliant/test only)")]
    [bool]$Enable
)

# Function to set the RDP encryption level in the registry
function Set-RDPEncryptionLevel {
    param (
        [Parameter(Mandatory = $true)]
        [bool]$State
    )

    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" # Registry path for RDP settings
    $valueName    = "MinEncryptionLevel" # Registry value name
    $desiredValue = if ($State) { 3 } else { 1 }  # 3 = High Level; 1 = Low Level (test/non-compliant)

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
            Write-Host "[$valueName] Setting RDP encryption level to $desiredValue (compliant: $($State -eq $true))"
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
Set-RDPEncryptionLevel -State:$Enable
