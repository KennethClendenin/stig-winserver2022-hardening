<#
.SYNOPSIS
    Enforces LAN Manager authentication level to NTLMv2 only and refuses LM/NTLM.

.DESCRIPTION
    Configures the 'LmCompatibilityLevel' registry value to 5, which corresponds to:
    "Send NTLMv2 response only. Refuse LM & NTLM".

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
    STIG-ID         : WN22-SO-000310

.LINK
    https://stigaview.com/products/winserv2022/v2r4/WN22-SO-000310/

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.PARAMETER Enable
    Use `$true` to set the LAN Manager authentication level to "Send NTLMv2 response only. Refuse LM & NTLM" (compliant).
    Use `$false` to revert to a lower compatibility level (non-compliant/test only).

.EXAMPLE
    PS C:\> .\WN22-SO-000310.ps1 -Enable $true
#>

# Accepts a boolean parameter to enable or disable strict NTLMv2 authentication
param (
    [Parameter(Mandatory = $true, HelpMessage = "Use `$true` to enforce NTLMv2 only (compliant), `$false` to allow lower security levels (non-compliant/test only)")]
    [bool]$Enable
)

# Function to set the registry value for LAN Manager authentication level
function Set-LMCompatibilityLevel {
    param (
        [Parameter(Mandatory = $true)]
        [bool]$State
    )

    $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" # Registry path for LSA
    $valueName    = "LmCompatibilityLevel" # Registry value name
    $desiredValue = if ($State) { 5 } else { 1 }  # 1 = Send LM & NTLM responses; use NTLMv2 if negotiated (less secure)

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
            Write-Host "[$valueName] Setting LMCompatibilityLevel to $desiredValue (compliant: $($State -eq $true))"
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
Set-LMCompatibilityLevel -State:$Enable
