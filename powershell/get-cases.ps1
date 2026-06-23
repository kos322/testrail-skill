[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Arguments = @()
)

. (Join-Path $PSScriptRoot 'Common.ps1')
Invoke-TestrailBashScript -RelativeScriptPath 'scripts\get_cases.sh' -ScriptArguments $Arguments
