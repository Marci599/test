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
$Root = Resolve-Path (Join-Path $PSScriptRoot '..')
$ShellScript = Join-Path $Root 'tools/build_us2.sh'

function Invoke-BashScript {
    param(
        [Parameter(Mandatory = $true)][string]$BashExe,
        [Parameter(Mandatory = $true)][string]$ScriptPath
    )
    & $BashExe $ScriptPath
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

$bash = Get-Command bash.exe -ErrorAction SilentlyContinue
if ($bash) {
    Write-Host "Using bash from PATH: $($bash.Source)"
    Invoke-BashScript -BashExe $bash.Source -ScriptPath $ShellScript
    exit 0
}

$commonGitBash = @(
    "$env:ProgramFiles\Git\bin\bash.exe",
    "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
    "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
) | Where-Object { $_ -and (Test-Path $_) }

if ($commonGitBash.Count -gt 0) {
    Write-Host "Using Git Bash: $($commonGitBash[0])"
    Invoke-BashScript -BashExe $commonGitBash[0] -ScriptPath $ShellScript
    exit 0
}

$wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
if ($wsl) {
    $repoForWsl = (& wsl.exe wslpath -a "$Root").Trim()
    & wsl.exe bash -lc "cd '$repoForWsl' && ./tools/build_us2.sh"
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
