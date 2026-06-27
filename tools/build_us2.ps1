<#
.SYNOPSIS
  Windows helper for building the SPM Quick Map Menu US2 REL.

.DESCRIPTION
  The real build is implemented by tools/build_us2.sh because devkitPPC and
  the SPM REL Loader workflow are Unix-like. This wrapper lets Windows users
  launch it from PowerShell by using Git Bash/MSYS2 bash when available, or WSL
  as a fallback.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

function Convert-ToMsysPath {
    param([Parameter(Mandatory = $true)][string]$WindowsPath)

    $fullPath = [System.IO.Path]::GetFullPath($WindowsPath)
    if ($fullPath -match '^([A-Za-z]):\\(.*)$') {
        $drive = $Matches[1].ToLowerInvariant()
        $rest = $Matches[2] -replace '\\', '/'
        return "/$drive/$rest"
    }

    return ($fullPath -replace '\\', '/')
}

function Quote-BashSingleQuoted {
    param([Parameter(Mandatory = $true)][string]$Value)
    return "'" + ($Value -replace "'", "'\\''") + "'"
}

function Get-WindowsPythonForBash {
    $python = Get-Command python.exe -ErrorAction SilentlyContinue
    if ($python -and $python.Source) {
        return @{ Exe = (Convert-ToMsysPath -WindowsPath $python.Source); Arg = $null; Label = $python.Source }
    }

    $py = Get-Command py.exe -ErrorAction SilentlyContinue
    if ($py -and $py.Source) {
        return @{ Exe = (Convert-ToMsysPath -WindowsPath $py.Source); Arg = '-3'; Label = "$($py.Source) -3" }
    }

    return $null
}

function Invoke-BashScript {
    param(
        [Parameter(Mandatory = $true)][string]$BashExe,
        [Parameter(Mandatory = $true)][string]$RepoRoot
    )

    $repoForBash = Convert-ToMsysPath -WindowsPath $RepoRoot
    $quotedRepo = Quote-BashSingleQuoted -Value $repoForBash
    $pythonForBash = Get-WindowsPythonForBash

    $oldPythonExe = $env:SPM_PYTHON_EXE
    $oldPythonArg = $env:SPM_PYTHON_ARG
    try {
        if ($pythonForBash) {
            Write-Host "Passing Windows Python to bash: $($pythonForBash.Label)"
            $env:SPM_PYTHON_EXE = $pythonForBash.Exe
            if ($pythonForBash.Arg) {
                $env:SPM_PYTHON_ARG = $pythonForBash.Arg
            } else {
                Remove-Item Env:SPM_PYTHON_ARG -ErrorAction SilentlyContinue
            }
        }

        & $BashExe -lc "cd $quotedRepo && ./tools/build_us2.sh"
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    finally {
        if ($null -ne $oldPythonExe) { $env:SPM_PYTHON_EXE = $oldPythonExe } else { Remove-Item Env:SPM_PYTHON_EXE -ErrorAction SilentlyContinue }
        if ($null -ne $oldPythonArg) { $env:SPM_PYTHON_ARG = $oldPythonArg } else { Remove-Item Env:SPM_PYTHON_ARG -ErrorAction SilentlyContinue }
    }
}

$bash = Get-Command bash.exe -ErrorAction SilentlyContinue
if ($bash) {
    Write-Host "Using bash from PATH: $($bash.Source)"
    Invoke-BashScript -BashExe $bash.Source -RepoRoot $Root
    exit 0
}

$commonGitBash = @(
    "$env:ProgramFiles\Git\bin\bash.exe",
    "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
    "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
) | Where-Object { $_ -and (Test-Path $_) }

if (@($commonGitBash).Count -gt 0) {
    $gitBash = @($commonGitBash)[0]
    Write-Host "Using Git Bash: $gitBash"
    Invoke-BashScript -BashExe $gitBash -RepoRoot $Root
    exit 0
}

$wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
if ($wsl) {
    $repoForWsl = (& wsl.exe wslpath -a "$Root").Trim()
    $quotedRepo = Quote-BashSingleQuoted -Value $repoForWsl
    & wsl.exe bash -lc "cd $quotedRepo && ./tools/build_us2.sh"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    exit 0
}

Write-Error @'
No bash-compatible environment was found.

Install one of these, then run this script again:
  1. WSL 2 with Ubuntu (recommended for devkitPPC), or
  2. Git for Windows, which includes Git Bash.

After installing WSL, open Ubuntu and run:
  cd /mnt/c/path/to/this/repo
  ./tools/build_us2.sh
'@
