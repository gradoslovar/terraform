[CmdletBinding()]
param(
    [parameter(Mandatory=$true)]
    [string]$storageName,

    [parameter(Mandatory=$true)]
    [string]$storageKey,

    [parameter(Mandatory=$false)]
    [string]$fileShareName = "fileshare",

    [parameter(Mandatory=$false)]
    [string]$fileShareDriveLetter = "S"
)

$fileShareEndpoint = [string]::Concat($storageName, ".file.core.windows.net")
$fileShareRoot = [string]::Concat("\\",$fileShareEndpoint, "\", $fileShareName)
if (!(test-path ([string]::Concat("C:\\fileshare\", $fileShareName)))) { 
    New-Item -Path ([string]::Concat("C:\\fileshare\", $fileShareName)) -ItemType Directory
}

cmdkey /add:$fileShareEndpoint /user:$storageName /pass:$storageKey

New-PSDrive -Name $fileShareDriveLetter -PSProvider FileSystem -Root $fileShareRoot -Persist

cmd /c "mklink /D $fileShareData $fileShareRoot"