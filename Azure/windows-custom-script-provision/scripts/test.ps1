[CmdletBinding()]
param(
    [parameter(Mandatory=$true)]
    [string]$folderName,

    [parameter(Mandatory=$false)]
    [string]$driveLetter = "C"
)

$folderPath = [string]::Concat($driveLetter, ":\", $folderName)
New-Item -Path $folderPath -ItemType Directory