# Stamp ReplicatedStorage.BuildSha in default.project.json before rojo build.
# Usage:
#   .\scripts\stamp-build.ps1 -Sha <commit>
#   .\scripts\stamp-build.ps1
# A GitHub zip has no .git directory, so pass the commit from the archive name.
# With no -Sha, BUILD_SHA is used, then `git rev-parse HEAD`, then "dev".
# An invalid sha exits 1 and does not write.

param(
	[string]$Sha = ""
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $root
if ([string]::IsNullOrWhiteSpace($Sha)) {
	$Sha = $env:BUILD_SHA
}
if ([string]::IsNullOrWhiteSpace($Sha)) {
	$git = Get-Command git -ErrorAction SilentlyContinue
	if ($null -ne $git) {
		$previous = $ErrorActionPreference
		$ErrorActionPreference = "Continue"
		$resolved = & git rev-parse HEAD 2>$null
		$code = $LASTEXITCODE
		$ErrorActionPreference = $previous
		if ($code -eq 0 -and -not [string]::IsNullOrWhiteSpace($resolved)) {
			$Sha = $resolved.Trim()
		}
	}
}
if ([string]::IsNullOrWhiteSpace($Sha)) {
	$Sha = "dev"
	Write-Warning "stamp-build: no git commit; BuildSha=dev"
}

$Sha = $Sha.ToLowerInvariant()
if ($Sha -ne "dev" -and $Sha -notmatch '^[0-9a-f]{7,40}$') {
	Write-Error "stamp-build: sha must be 'dev' or 7-40 hex characters"
	exit 1
}

function Update-ProjectFile([string]$path) {
	if (-not (Test-Path $path)) {
		return
	}
	$raw = [System.IO.File]::ReadAllText($path)
	if ($raw -notmatch '"BuildSha"') {
		Write-Error "stamp-build: $path has no BuildSha attribute"
		exit 1
	}
	$regex = New-Object System.Text.RegularExpressions.Regex '("BuildSha"\s*:\s*")[^"]*"'
	$updated = $regex.Replace($raw, ('${1}' + $Sha + '"'), 1)
	$utf8 = New-Object System.Text.UTF8Encoding $false
	[System.IO.File]::WriteAllText($path, $updated, $utf8)
}

$defaultFile = Join-Path $root "default.project.json"
if (-not (Test-Path $defaultFile)) {
	Write-Error "stamp-build: default.project.json is missing"
	exit 1
}
Update-ProjectFile $defaultFile
Update-ProjectFile (Join-Path $root "serve.test.project.json")
Write-Output "stamp-build: BuildSha=$Sha"
