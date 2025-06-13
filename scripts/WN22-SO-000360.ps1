<#
.SYNOPSIS
    Enforces the use of FIPS-compliant algorithms for encryption, hashing, and signing.

.DESCRIPTION
    This script enables the 'System cryptography: Use FIPS compliant algorithms' setting by setting the registry value
    'Enabled' to 1 under the FIPSAlgorithmPolicy key. FIPS-compliant algorithms meet U.S. Government standards and
    must be used in secure environments for cryptographic operations.

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
    STIG-ID         : WN22-SO-000360

.LINK
    https://stigaview.com/products/winserv2022/v2r4/WN22-SO-000360/

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.PARAMETER Enable
    Use `$true` to enforce FIPS-compliant algorithms (compliant).
    Use `$false` to disable enforcement (non-compliant/test only).

.EXAMPLE
    PS C:\> .\WN22-SO-000360.ps1 -Enable $true
#>

# Accepts a boolean parameter to enable or disable FIPS-compliant algorithms
param (
    [Parameter(Mandatory = $true, HelpMessage = "Use `$true` to enable FIPS mode (compliant), `$false` to disable it (non-compliant/test only)")]
    [bool]$Enable
)

# Function to set the registry value for FIPS algorithm policy
function Set-FIPSAlgorithmPolicy {
    param (
        [Parameter(Mandatory = $true)]
        [bool]$State
    )

    $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" # Registry path for FIPS policy
    $valueName    = "Enabled" # Registry value name
    $desiredValue = if ($State) { 1 } else { 0 } # 1 enables FIPS, 0 disables

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
            Write-Host "[$valueName] Setting FIPS-compliant cryptographic mode to $desiredValue (compliant: $($State -eq $true))"
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
Set-FIPSAlgorithmPolicy -State:$Enable
