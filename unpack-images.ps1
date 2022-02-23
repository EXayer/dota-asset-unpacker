. "$($PSScriptRoot)\ENV.ps1"

$isEnvHasDotaInstallFolder = Get-Variable -Name DOTA_INSTALL_FOLDER -Scope Global -ErrorAction SilentlyContinue

if ($null -eq $isEnvHasDotaInstallFolder)
{
  Write-Host "Error: DOTA_INSTALL_FOLDER variable is not defined. Define it in ENV.ps1 file."

  exit
}

# i/o
$inputDir = "$($PSScriptRoot)\input";
$outputRoot = "$($PSScriptRoot)\output"

# decompiler
$decompilerPath = "$($PSScriptRoot)\decompiler\Decompiler.exe"

if (-Not (Test-Path -Path $decompilerPath -PathType Leaf))
{
  Write-Host "Error: Decompiler.exe not found - $decompilerPath. Check README install guide."

  exit
}

# dota 2 vpk path
$dotaMainVpkPath = "$($DOTA_INSTALL_FOLDER)\dota 2 beta\game\dota\pak01_dir.vpk"

if (-Not (Test-Path -Path $dotaMainVpkPath -PathType Leaf))
{
  Write-Host "Error: Dota 2 files not found - $dotaMainVpkPath. Check DOTA_INSTALL_FOLDER variable in ENV.ps1 file."

  exit
}

$baseCommand = "`"$($decompilerPath)`" -i `"$($dotaMainVpkPath)`" -o `"$($outputRoot)`""

# decompile images
$filePathes = Get-ChildItem -Path "$($inputDir)\images\*.txt" -Recurse -Force

# TODO: prompt user

foreach ($filePath in $filePathes)
{
  $vpkPathes = Get-Content $filePath;
  $toDecompileCount = $vpkPathes.Count;

  Write-Host "Starting - $($filePath): $($toDecompileCount) items"

  foreach ($vpkPath in $vpkPathes)
  {
    $imagePath = "panorama/images/$($vpkPath)_png.vtex_c";
    $command = "$($baseCommand) --vpk_filepath `"$($imagePath)`" --vpk_decompile"

    cmd /c $command 
  }
}

# post process
# remove suffix '_png' in file names
Get-ChildItem -Path $outputRoot -Recurse -Include "*_png.png" | Rename-Item -NewName { $_.Name.replace("_png.png", ".png") }
Write-Host "Removed '_png' suffix"
