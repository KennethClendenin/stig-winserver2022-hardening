<#
.SYNOPSIS
    Disables the Application Compatibility Program Inventory to prevent data collection and transmission to Microsoft.

.DESCRIPTION
    This script configures the 'DisableInventory' registry value to 1, effectively disabling the Inventory Collector.
    Preventing this data collection supports data privacy and aligns with enterprise security policies by stopping unsolicited data transmissions to Microsoft.

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
    STIG-ID         : WN22-CC-000200

.LINK
    https://stigaview.com/products/winserv2022/v2r4/WN22-CC-000200/

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.PARAMETER Enable
    Use `$true` to disable the Inventory Collector (compliant).
    Use `$false` to enable the collector (non-compliant/test).

.EXAMPLE
    PS C:\> .\WN22-CC-000200.ps1 -Enable $true
#>

# Accepts a boolean parameter to enable or disable the Inventory Collector
param (
    [Parameter(Mandatory = $true, HelpMessage = "Use `$true` to disable the Inventory Collector (compliant), `$false` to enable it (non-compliant/test only)")]
    [bool]$Enable
)

# Function to set the registry value for Application Compatibility Inventory Collector
function Set-AppCompatInventoryCollector {
    param (
        [Parameter(Mandatory = $true)]
        [bool]$State
    )

    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" # Registry path for AppCompat policy
    $valueName    = "DisableInventory" # Registry value name
    $desiredValue = if ($State) { 1 } else { 0 } # 1 disables inventory, 0 enables

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
            Write-Host "[$valueName] Setting Application Compatibility Inventory Collector to $desiredValue (compliant: $($State -eq $true))"
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
Set-AppCompatInventoryCollector -State:$Enable
