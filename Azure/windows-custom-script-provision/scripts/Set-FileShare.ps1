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

# Create batch file
@"
@echo off
cmdkey /add:$fileShareEndpoint /user:$storageName /pass:$storageKey
net use ${fileShareDriveLetter}: $fileShareRoot
"@ | Out-File "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\attachdrive.bat" -Encoding ascii

# Create symobolic link
cmd /c "mklink /D $fileShareFolder $fileShareRoot"