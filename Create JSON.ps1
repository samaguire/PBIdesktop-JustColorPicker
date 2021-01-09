$baseName = "jcpicker"

# Set bulk of json values
$version = "5.5-03"
$name = "Just Color Picker"
$description = "Opens the Just Color Picker application (https://annystudio.com/software/colorpicker/)"
$path = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"

# Get json value for arguments
$ps1 = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$server,
        [Parameter(Mandatory = $true)]
        [string]$database
    )
    
    # tmp variables
    # $baseName = "jcpicker"
    
    # Check current environment
    $ver = Get-Content "$env:TEMP\$baseName.ver" -ErrorAction SilentlyContinue
    $exe = -not (Test-Path "$env:TEMP\$baseName.exe" -PathType Leaf)
    
    # Get latest release details https://docs.github.com/en/free-pro-team@latest/rest/reference/repos#releases
    $repo = "samaguire/PBIdesktop-JustColorPicker"
    # $releases = Invoke-WebRequest "https://api.github.com/repos/$repo/releases" | ConvertFrom-Json
    $releases = Invoke-WebRequest "https://api.github.com/repos/$repo/releases/latest" | ConvertFrom-Json # is the most recent non-prerelease, non-draft release
    $tag = $releases[0].tag_name
    $zipurl = "https://annystudio.com/jcpicker.zip"
    
    # Download latest version if newer than the current version or required files are missing and update the pbit
    if ($tag -gt $ver -or $exe) {
    
        # Clear existing files
        Get-ChildItem $env:TEMP -Filter "$baseName.*" | Where-Object Extension -NE ".ini" | Remove-Item -Recurse
    
        # Download latest version
        $file = "$env:TEMP\$baseName.zip"
        Invoke-WebRequest $zipurl -Out $file
    
        # Extract latest version
        Expand-Archive $file -DestinationPath "$env:TEMP\$baseName"
        Get-ChildItem "$env:TEMP\$baseName" -Recurse -Filter "$baseName.exe" | Move-Item -Destination "$env:TEMP"
    
        # Save version file
        Set-Content "$env:TEMP\$baseName.ver" -Value $tag
    
    }
    
    # Launch
    Start-Process -FilePath "explorer.exe" -ArgumentList @("$env:TEMP\$baseName.exe")
}
$ps1String = $ps1.ToString().Replace('$baseName', $baseName).Replace('$version', $version)
$ps1Base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ps1String))
$command = { Invoke-Command -ScriptBlock ([Scriptblock]::Create([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($ps1Base64)))) -ArgumentList @('%server%', '%database%') }
$commandString = $command.ToString().Replace('$ps1Base64', "'$ps1Base64'")
# $arguments = "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command &{$commandString}"
$arguments = "-NoProfile -ExecutionPolicy Bypass -Command &{$commandString}"

# Get json value for iconData
$imageType = "png"
$imageBase64 = [System.Convert]::ToBase64String((Get-Content -Raw -Encoding Byte "$PSScriptRoot\resources\$baseName.$imageType"))
$iconData = "data:image/$imageType;base64,$imageBase64"

# Create json file
$json = @"
{
  "version": "$version",
  "name": "$name",
  "description": "$description",
  "path": "$path",
  "arguments": "$arguments",
  "iconData": "$iconData"
}
"@
Set-Content "$PSScriptRoot\$baseName.pbitool.json" -Value $json

# Test command that gets launched by powershell
&$command
