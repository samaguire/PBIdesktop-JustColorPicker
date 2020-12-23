<#
This script file needs to be encoded as UTF-8 (UTF8) when saved
#>
param (
    [Parameter(Mandatory = $true)]
    [string]
    $server,
    [Parameter(Mandatory = $true)]
    [string]
    $database,
    [Parameter(Mandatory = $true)]
    [string]
    $binFile,
    [Parameter(Mandatory = $true)]
    [string]
    $version,
    [Parameter(Mandatory = $true)]
    [string]
    $baseName
)

# :: if required files don't exist or are an old version then create (overwrite) the files

$exeNotExist = -not (Test-Path -Path "$env:TEMP\$baseName.exe" -PathType Leaf)
$verNotExist = -not (Test-Path -Path "$env:TEMP\$baseName.ver" -PathType Leaf)
$versionOld = $version -gt (Get-Content -Encoding UTF8 -Path "$env:TEMP\$baseName.ver" -ErrorAction SilentlyContinue)

if ( $exeNotExist -or $verNotExist -or $versionOld ) {

    Add-Type -Assembly 'System.IO.Compression.FileSystem'

    # :: expand files from archive

    $zip = [System.IO.Compression.ZipFile]::Open($binFile, 'read')
    $entry = $zip.GetEntry("$baseName.exe"); [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, "$env:TEMP\$($entry.Name)", $true)
    $zip.Dispose()

    # :: save version file

    Set-Content -Encoding UTF8 -Path "$env:TEMP\$baseName.ver" -Value $version

}    

Start-Process -FilePath "explorer.exe" -ArgumentList @("$env:TEMP\$baseName.exe")
