# Dota Asset Unpacker

A PowerShell script to unpack assets from Dota 2 client package (.vpk) for Windows

## Requirements

Windows PowerShell 5.1 or later.

## Install

1. Clone a repository.
2. Create `ENV.ps1` file based on the `ENV.ps1.example`.
3. Set up environment variables in `ENV.ps1`:
   - `$DOTA_INSTALL_FOLDER` - path to steam library folder. Does not required for `convert` mode.
4. Set up a Decompiler:
   - [Download a build](https://github.com/SteamDatabase/ValveResourceFormat/releases) for your OS. Windows - `Decompiler-windows-x64.zip`. Tested on 0.2.0 version.
   - Unzip the archive to the decompiler folder.
     ```
     ROOT
     |   
     +---decompiler
     |       .gitignore
     |       Decompiler.exe
     |       libSkiaSharp.dll
     ```

## Usage

To run script open Windows PowerShell app or other PowerShell compatible cli.

There are **three modes** in which you can run the script:

### 1. Image List Mode - list (default)
```
powershell -ep Bypass .\unpack.ps1 list
```

In this mode script unpacks images configured by .txt files in `input\list` folder.
Txt files format: one path to the image per line, without extension.
In such format they are being provided in most Valve APIs.

```
econ/items/invoker/esl_relics_back/esl_relics_back1
econ/tools/dpc_2022_spring_lineage_treasure
econ/items/courier/leafy_the_sea_dragon_courier_courier/leafy_the_sea_dragon_courier_courier
```

Decompiled images will be located in `output\list` folder.

### 2. Full VPK Mode - vpk
```
powershell -ep Bypass .\unpack.ps1 vpk
```
Unpack all assets from Dota vpk archives to `output\vpk` folder.
Images will be converted to .png format. Make sure you have enough space on the disk.

### 3. Convert Mode - convert
```
powershell -ep Bypass .\unpack.ps1 convert
```
Convert .vtex_c images in `input\convert` folder to .png.
Converted images will be located in `output\convert` folder.

## License

The MIT License (MIT). Please see [License File](LICENSE.md) for more information.