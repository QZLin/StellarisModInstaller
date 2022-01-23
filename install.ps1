param(
    [Parameter(Mandatory = $true)][string]$mod_zip,
    [string]$_7zip = "C:\Program Files\7-Zip\7z.exe",
    [string]$game_mod_path = $PSScriptRoot,
    [switch]$Folder
)

if (-not $Folder) {
    # Unzip Mod Zip
    Write-Output "I: Install`"$mod_zip`""
    Remove-Item -r $mod_folder -ErrorAction SilentlyContinue
    try { Expand-Archive $mod_zip -DestinationPath $mod_folder }
    catch {
        Write-Output "Powershell fail to unzip, try 7zip"
        Remove-Item -r $mod_folder -ErrorAction SilentlyContinue
        & $_7zip x -o$mod_folder $mod_zip
    }
    $mod_folder = "_tmpmod"
}
else {
    $mod_folder = $mod_zip
}

# Get Mod Name in descriptor.mod
$descriptor = Get-Content (Join-Path $mod_folder "descriptor.mod")
$r = Select-String -Pattern 'name\s*=\s*"(.*?)"' -InputObject $descriptor
if ($r.Matches) {
    $modname = $r.Matches.Groups[1].Value
    $codename = $modname `
        -replace " ", "_" -replace "-", "_" -replace "'", "" -replace ":", "_"
    Write-Output "I: `"$modname`"->`"$codename`""

    $descriptor = $descriptor -replace "\s*path\s*=\s*(?:\S|.)*", ""
    $descriptor += "path=`"mod/$codename`""

    if (! (Join-Path (Convert-Path $mod_folder) "" ) -eq (Join-Path (Convert-Path (Join-Path $game_mod_path $codename)) "")) {
        try { Move-Item $mod_folder $codename -ErrorAction Stop }
        catch { Move-Item $mod_folder $codename -Force -Confirm }
    }
    
    $descriptor > "$codename.mod"
    Write-Output "I: Sucuss"
}
else {
    Write-Output "E: descriptor.mod not avaliable, exit..."
}
