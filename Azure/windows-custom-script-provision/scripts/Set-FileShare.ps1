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

#cmdkey /add:$fileShareEndpoint /user:$storageName /pass:$storageKey
"cmdkey /add:$($fileShareEndpoint) " + "/user:AZURE\$($storageName) /pass:$($storageKey)" | Out-File "C:\Users\nenad\test.txt"
$HOME | Out-File "C:\Users\nenad\test2.txt"
Invoke-Expression -Command ("cmdkey /add:$($fileShareEndpoint) " + "/user:AZURE\$($storageName) /pass:$($storageKey)")

New-PSDrive -Name $fileShareDriveLetter -PSProvider FileSystem -Root $fileShareRoot -Persist -Scope Global

cmd /c "mklink /D $fileShareFolder $fileShareRoot"