[CmdletBinding()]
param(
    [parameter(Mandatory=$true)]
    [string]$storageName,

    [parameter(Mandatory=$true)]
    [string]$storageKey,

    [parameter(Mandatory=$true)]
    [string]$fileShareName,

    [parameter(Mandatory=$false)]
    [string]$fileShareDriveLetter = "S",

    [parameter(Mandatory=$false)]
    [string]$vmFolder
)

$fileShareEndpoint = [string]::Concat($storageName, ".file.core.windows.net")
$fileShareRoot = [string]::Concat("\\",$fileShareEndpoint, "\", $fileShareName)
if ($vmFolder) {
    New-Item -Path $vmFolder -ItemType Directory -Force
    $fileShareFolder = [string]::Concat($vmFolder, "\", $fileShareName)
} else {
    $fileShareFolder = [string]::Concat("C:\", $fileShareName)
}

cmdkey /add:$fileShareEndpoint /user:$storageName /pass:$storageKey

#New-PSDrive -Name $fileShareDriveLetter -PSProvider FileSystem -Root $fileShareRoot -Persist -Scope Global
net use K: $fileShareRoot /user:$storageName $storageKey /persistent:yes

cmd /c "mklink /D $fileShareFolder $fileShareRoot"

@"
@echo off
net use ${fileShareDriveLetter}: $fileShareRoot /u:$storageName $storageKey /persistent:yes
"@ | Out-File C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\attachdrive.bat -Encoding ascii