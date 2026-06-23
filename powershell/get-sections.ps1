[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Arguments = @()
)

. (Join-Path $PSScriptRoot 'Common.ps1')
Invoke-TestrailBashScript -RelativeScriptPath 'scripts\get_sections.sh' -ScriptArguments $Arguments
