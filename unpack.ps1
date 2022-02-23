param ([string]$mode = "input-images")

# modes
$INPUT_IMAGES_MODE = "input-images";
$FULL_VPK_MODE = "full-vpk";

$supportedModes = @{
  $INPUT_IMAGES_MODE = $INPUT_IMAGES_MODE
  $FULL_VPK_MODE = $FULL_VPK_MODE
}

if (-Not $supportedModes.ContainsKey($mode))
{
  $supportedModesStr = ($supportedModes.Keys -join "', '")
  Write-Host "Error: Unknown mode - '$($mode)'. Supported modes: '$($supportedModesStr)'."

  exit
}

# env
. "$($PSScriptRoot)\ENV.ps1"

$isEnvHasDotaInstallFolder = Get-Variable -Name DOTA_INSTALL_FOLDER -Scope Global -ErrorAction SilentlyContinue

if ($null -eq $isEnvHasDotaInstallFolder)
{
  Write-Host "Error: DOTA_INSTALL_FOLDER variable is not defined. Define it in ENV.ps1 file."

  exit

}

# i/o
$inputRoot = "$($PSScriptRoot)\input";
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

$baseCommand = "`"$($decompilerPath)`" -i `"$($dotaMainVpkPath)`""

switch ($mode)
{
  $INPUT_IMAGES_MODE # decompile images configured by input\images files
  {
    $filePathes = Get-ChildItem -Path "$($inputRoot)\images\*.txt" -Recurse -Force
    $outputPath = "$($outputRoot)\images"

    foreach ($filePath in $filePathes)
    {
      $vpkPathes = Get-Content $filePath;
      $toDecompileCount = $vpkPathes.Count;

      Write-Host "Starting - $($filePath): $($toDecompileCount) items"

      $counter = 0;
      foreach ($vpkPath in $vpkPathes)
      {
        $baseImageOutputPath = "$($outputRoot)\panorama\images\$($vpkPath)"

        if ((Test-Path -Path ("$($baseImageOutputPath)_png.png") -PathType Leaf) -or (Test-Path -Path ("$($baseImageOutputPath).png") -PathType Leaf))
        {
          continue;
        }

        $imageVpkPath = "panorama/images/$($vpkPath)_png.vtex_c";
        $command = "$($baseCommand) -o `"$($outputPath)`" --vpk_filepath `"$($imageVpkPath)`" --vpk_decompile"

        cmd /c $command
        ++$counter;
      }

      Write-Host "Finished - $($filePath): $($counter)/$($toDecompileCount) items"
    }
  
    Break
  }

  $FULL_VPK_MODE # decompile all assets, convert images to png
  {
    Write-Host "Warning: You need have enough space on the disk ~20Gb"
    $outputPath = "$($outputRoot)\vpk"
    $command = "$($baseCommand) -o `"$($outputPath)`" --vpk_decompile --threads 24 --vpk_cache"

    cmd /c $command
  
    Break
  }

  Default {
    Write-Host "Unknown mode"
  }
}

# post process
# remove suffix '_png' in file names
Get-ChildItem -Path $outputRoot -Recurse -Include "*.png" -Filter "*_png.png" | Rename-Item -NewName { $_.Name.replace("_png.png", ".png") }
Write-Host "Removed '_png' suffix"
