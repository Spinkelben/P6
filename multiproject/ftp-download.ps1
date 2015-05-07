# Downloads the newest APKs to the folder where this script is located.
# Author: Group sw609f15

param(
    [string] $baseurl = 'ftp://cs-cust06-int.cs.aau.dk',
    [string] $remotedir = 'newest_releases',
    [string] $username = 'ftpuser',
    [string] $password = '9scWKbP',
    [switch] $verbose = $false
)

function DownloadFile($sourcepath, $targetpath) {
    # Setup FTP request
    $ftprequest = [System.Net.FtpWebRequest]::create($sourcepath)
    $ftprequest.Credentials = New-Object System.Net.NetworkCredential($username, $password)
    $ftprequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
    $ftprequest.UseBinary = $true
    $ftprequest.KeepAlive = $false
    $ftprequest.Timeout = 5000
    $ftprequest.ReadWriteTimeout = 5000

    # Send the FTP request to the server
    $ftpresponse = $ftprequest.GetResponse()
    $responsestream = $ftpresponse.GetResponseStream()

    # Create download buffer and local file to download to
    try {
        $targetfile = New-Object IO.FileStream ($targetpath, 'Create')
        if ($verbose) { Write-Host "File created: $targetpath" }
        [byte[]]$readbuffer = New-Object byte[] 1024

        # Loop through the download stream and send the data to the target file
        do {
            $readlength = $responsestream.Read($readbuffer, 0, 1024)
            $targetfile.Write($readbuffer, 0, $readlength)
        }
        while ($readlength -ne 0)

        $targetfile.close()
    } catch {
        $_ | fl * -Force
    }
    
    $ftpresponse.Close()
}

function ListFiles($path) {
    # Setup FTP request
    $ftprequest = [System.Net.FtpWebRequest]::create($path)
    $ftprequest.Credentials = New-Object System.Net.NetworkCredential($username, $password)
    $ftprequest.Method = [Net.WebRequestMethods+Ftp]::ListDirectory
    $ftprequest.UseBinary = $true
    $ftprequest.KeepAlive = $false
    $ftprequest.Timeout = 5000
    $ftprequest.ReadWriteTimeout = 5000

    # Send the FTP request to the server
    $ftpresponse = $ftprequest.GetResponse()
    $responsestream = $ftpresponse.GetResponseStream()

    # Parse the FTP response
    $FTPReader = New-Object System.IO.Streamreader($ResponseStream)
    $list = @()
    while ($line = $FTPReader.ReadLine()) {
        $list += $line
    }

    $FTPReader.Close()
    $ftpresponse.Close()
    
    return $list
}

# List all files in the FTP directory
$remotepath = $baseurl + '/' + $remotedir
$list = ListFiles $remotepath

if ($verbose) {
    Write-Host '------------------------------------------------------'
    Write-Host 'Found the following files on FTP:'
    Write-Host '------------------------------------------------------'
    Foreach ($item in $list) { Write-Host $item }
}

# Find ADB executable
$adb = Get-Command adb -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition -First 1
if (!$adb) {
    # ADB not in path. Try default installation path
    $appdata = Join-Path ${env:localappdata} Android/android-sdk/platform-tools/adb.exe
    $adb = Get-Command $appdata -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition -First 1
}
if (!$adb) {
    Write-Host 'ERROR: Could not find adb executable. Please put it in PATH.'
}

# Download these files
$count = 0
Foreach ($item in $list) {
    # Determine the remote path for this item
    $remoteitem = $baseurl + '/' + $item
    
    # Determine the local path for this item
    $filename = Split-Path $remoteitem -leaf
    $localitem = Join-Path $PSScriptRoot $filename
    
    DownloadFile $remoteitem $localitem
    $count += 1

    # Uninstall old versions and install new version    
    if ($adb) {
        $packagename = [io.path]::GetFileNameWithoutExtension($filename)
        & $adb 'uninstall' "$packagename"
        & $adb 'install' '-r' "$localitem"
    }
}
Write-Host "Found and downloaded $count files."