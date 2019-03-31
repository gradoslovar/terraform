[CmdletBinding()]
param(
    [parameter(Mandatory=$true)]
    [string]$storageName,

    [parameter(Mandatory=$true)]
    [string]$storageKey,

    [parameter(Mandatory=$false)]
    [string]$fileShare = "fileshare"
)

$fileShareEndpoint = [string]::Concat($storageName, ".file.core.windows.net")
$fileShareRoot = [string]::Concat("\\",$fileShareEndpoint, "\", $fileShare)
if (!(test-path ([string]::Concat("C:\\fileshare\", $fileShare)))) { 
    New-Item -Path ([string]::Concat("C:\\fileshare\", $fileShare)) -ItemType Directory
}

cmdkey /add:$fileShareEndpoint /user:$storageName /pass:$storageKey

New-PSDrive -Name S -PSProvider FileSystem -Root $fileShareRoot -Persist

cmd /c "mklink /D $fileShareData $fileShareRoot"