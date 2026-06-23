Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Convert-ToGitBashPath {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    if ($fullPath -match '^[A-Za-z]:\\') {
        $drive = $fullPath.Substring(0, 1).ToLowerInvariant()
        $rest = $fullPath.Substring(2).Replace('\', '/')
        return "/$drive$rest"
    }

    return $fullPath.Replace('\', '/')
}

function Get-TestrailBashExe {
    $candidates = @()
    if ($env:TESTRAIL_BASH_EXE) {
        $candidates += $env:TESTRAIL_BASH_EXE
    }

    $candidates += @(
        'C:\Program Files\Git\bin\bash.exe',
        'C:\Program Files\Git\usr\bin\bash.exe'
    )

    foreach ($candidate in ($candidates | Select-Object -Unique)) {
        if ($candidate -and (Test-Path $candidate)) {
            return (Resolve-Path $candidate).Path
        }
    }

    throw 'Git Bash not found. Install Git for Windows or set TESTRAIL_BASH_EXE.'
}

function Quote-BashArgument {
    param(
        [Parameter(Mandatory)]
        [string]$Value
    )

    return "'{0}'" -f ($Value -replace "'", "'""'""'")
}

function Invoke-TestrailBashScript {
    param(
        [Parameter(Mandatory)]
        [string]$RelativeScriptPath,

        [string[]]$ScriptArguments = @()
    )

    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
    $bashExe = Get-TestrailBashExe
    $repoRootUnix = Convert-ToGitBashPath $repoRoot
    $scriptUnix = $RelativeScriptPath.Replace('\', '/')

    if (-not $scriptUnix.StartsWith('./')) {
        $scriptUnix = "./$scriptUnix"
    }

    $quotedArgs = @(
        foreach ($argument in $ScriptArguments) {
            Quote-BashArgument $argument
        }
    )

    $command = "cd $(Quote-BashArgument $repoRootUnix) && /usr/bin/env bash $(Quote-BashArgument $scriptUnix)"
    if ($quotedArgs.Count -gt 0) {
        $command += ' ' + ($quotedArgs -join ' ')
    }

    & $bashExe -lc $command
    exit $LASTEXITCODE
}
