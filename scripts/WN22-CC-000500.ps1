<#
.SYNOPSIS
    Ensures Basic authentication is disabled for the WinRM service.

.DESCRIPTION
    This script sets the 'AllowBasic' registry value to 0 under the 
    \SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\ path.
    Disabling Basic authentication prevents the use of clear-text credentials in WinRM communications, 
    reducing the risk of credential theft.

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
    STIG-ID         : WN22-CC-000500

.LINK
    https://stigaview.com/products/winserv2022/v2r4/WN22-CC-000500/

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.PARAMETER Enable
    Use `$true` to **disable** Basic authentication (compliant).
    Use `$false` to **enable** Basic authentication (non-compliant/test only).

.EXAMPLE
    PS C:\> .\WN22-CC-000500.ps1 -Enable $true
#>

# Accepts a boolean parameter to enable or disable Basic authentication for WinRM
param (
    [Parameter(Mandatory = $true, HelpMessage = "Use `$true` to disable Basic authentication for WinRM (compliant), `$false` to enable (non-compliant/test only)")]
    [bool]$Enable
)

# Function to set the registry value for WinRM Basic authentication
function Set-WinRMAllowBasicAuth {
    param (
        [Parameter(Mandatory = $true)]
        [bool]$State
    )

    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" # Registry path for WinRM service
    $valueName    = "AllowBasic" # Registry value name
    $desiredValue = if ($State) { 0 } else { 1 } # 0 disables Basic auth, 1 enables

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
            Write-Host "[$valueName] Setting WinRM Basic authentication to $desiredValue (compliant: $($State -eq $true))"
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
Set-WinRMAllowBasicAuth -State:$Enable
