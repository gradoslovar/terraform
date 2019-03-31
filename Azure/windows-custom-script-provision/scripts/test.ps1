[CmdletBinding()]
param(
    [parameter(Mandatory=$false)]
    [string]$folderName = "DUDA",

    [parameter(Mandatory=$false)]
    [string]$driveLetter = "C"
)

$folderPath = [string]::Concat($driveLetter, ":\", $folderName)
New-Item -Path $folderPath -ItemType Directory