param([Parameter(Mandatory = $true)][string]$Target)
$root = Split-Path -Parent $PSScriptRoot
$dest = Join-Path $Target 'Libs/LibVelvet-1.0'
if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
New-Item -ItemType Directory -Force $dest | Out-Null
Copy-Item (Join-Path $root 'lua/LibVelvet-1.0/*') $dest -Recurse
