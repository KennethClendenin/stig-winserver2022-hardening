<#
.SYNOPSIS
    Enables UAC Admin Approval Mode for the built-in Administrator account.

.DESCRIPTION
    Sets the 'FilterAdministratorToken' registry value to 1 under:
    HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System

    This enables Admin Approval Mode for the built-in Administrator account,
    a critical component of UAC that mitigates privilege escalation risks.

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
    STIG-ID         : WN22-SO-000380

.LINK
    https://stigaview.com/products/winserv2022/v2r4/WN22-SO-000380/

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.PARAMETER Enable
    Use `$true` to enable UAC Admin Approval Mode (compliant).
    Use `$false` to disable (non-compliant/test only).

.EXAMPLE
    PS C:\> .\WN22-SO-000380.ps1 -Enable $true
#>

# Accepts a boolean parameter to enable or disable UAC Admin Approval Mode
param (
    [Parameter(Mandatory = $true, HelpMessage = "Use `$true` to enable UAC Admin Approval Mode (compliant), `$false` to disable (non-compliant/test only)")]
    [bool]$Enable
)

# Function to set the registry value for UAC Admin Approval Mode
function Set-UACAdminApprovalMode {
    param (
        [Parameter(Mandatory = $true)]
        [bool]$State
    )

    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" # Registry path for UAC policy
    $valueName    = "FilterAdministratorToken" # Registry value name
    $desiredValue = if ($State) { 1 } else { 0 } # 1 enables Admin Approval Mode, 0 disables

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
            Write-Host "[$valueName] Setting UAC Admin Approval Mode to $desiredValue (compliant: $($State -eq $true))"
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
Set-UACAdminApprovalMode -State:$Enable
