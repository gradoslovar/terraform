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
$fileShareData = [string]::Concat("C:\\fileshare\", $fileShare)

cmdkey /add:$fileShareEndpoint /user:$storageName /pass:$storageKey

New-PSDrive -Name S -PSProvider FileSystem -Root $fileShareRoot -Persist

cmd /c "mklink /D $fileShareData $fileShareRoot"