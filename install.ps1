# 
param(
    [Parameter(Mandatory = $true)][string]$mod_zip,
    [string]$_7zip = "C:\Program Files\7-Zip\7z.exe",
    [string]$game_path = $PSScriptRoot
)
 

# if ($args.Length -eq 0) {
#     Write-Output "E: Require argument: ``zipfile path``"
#     exit
# }
Write-Output "I: Install`"$mod_zip`""
Remove-Item -r "_tmpmod" -ErrorAction SilentlyContinue
try { Expand-Archive $mod_zip -DestinationPath "_tmpmod" }
catch {
    Write-Output "Powershell fail to unzip, try 7zip"
    Remove-Item -r "_tmpmod" -ErrorAction SilentlyContinue
    & $_7zip x -o_tmpmod $mod_zip
}


$descriptor = Get-Content "_tmpmod/descriptor.mod"
$r = Select-String -Pattern 'name="(.*?)"' -InputObject $descriptor
if ($r.Matches) {
    $modname = $r.Matches.Groups[1].Value
    $codename = $modname `
        -replace " ", "_" -replace "-", "_" -replace "'", "" -replace ":", "_"
    Write-Output "I: `"$modname`"->`"$codename`""

    $descriptor += "path=`"mod/$codename`""
    try { Move-Item "_tmpmod" $codename -ErrorAction Stop }
    catch { Move-Item "_tmpmod" $codename -Force -Confirm }
    
    $descriptor > "$codename.mod"
    Write-Output "I: Sucuss"
}
else {
    Write-Output "E: descriptor.mod not found, exit..."
}
