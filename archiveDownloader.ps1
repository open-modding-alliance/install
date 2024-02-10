<#
    Archive downloader for GitHub - Created by w33zl (Open Modding Alliance)

    USAGE:
        > powershell -command "& {Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/open-modding-alliance/install/master/fsScriptLibrary.ps1' -OutFile 'fsScriptLibrary.ps1'; ./fsScriptLibrary.ps1}"
#>

#NOTE: the following five lines should be put in the top of the archive specific script

###[ USER SETTINGS ]###########################################################
# $appName = "Your Appliction"
# $githubUser = "open-modding-alliance"
# $githubRepo = "install"
###############################################################################


###[ SCRIPT CONFIG ]###########################################################
$outputFolder = ".\temp"
$tempFolder = ".\.oma"
$tempArchivePath = "$tempFolder\archive.zip"
$latestReleaseUrl = "https://api.github.com/repos/$githubUser/$githubRepo/releases/latest"
###############################################################################


try {
    $response = Invoke-RestMethod -Uri $latestReleaseUrl
    $downloadUrl = $response.assets[0].browser_download_url
    $manualDownloadUrl = "https://github.com/$githubUser/$githubRepo/releases/latest"

}
catch {
    Write-Host "Failed to get latest release, you need to manually download it from $manualDownloadUrl"
    exit 1
}

# Write-Host "Repo url: $downloadUrl"

if (!(Test-Path $tempFolder)) {
    New-Item -Path $tempFolder -ItemType Directory
}

Set-ItemProperty -Path $tempFolder -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)

Write-Host "`nDownloading archive from $downloadUrl"

try {
    $oldProgressPreference = $progressPreference
    $ProgressPreference = 'SilentlyContinue'    # Subsequent calls do not display UI.
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempArchivePath         
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Host "Failed to download file from $downloadUrl"
}
finally {
    $ProgressPreference = $oldProgressPreference            # Subsequent calls do display UI.
    <#Do this after the try block regardless of whether an exception occurred or not#>
}


$success = 0

if ((Test-Path $tempArchivePath)) {
    Write-Host "Extracting archive to $outputFolder"

    try {
        Expand-Archive -Path $tempArchivePath -DestinationPath $outputFolder -ErrorAction Inquire # Stop

        Write-Host "Archive '$tempArchivePath' successfully extracted"

        $success = 1
    }
    catch {
        Write-Host "Failed to extract archive, make sure the folder doesn't already contains the '$appName'"
    }

    Remove-Item $tempArchivePath

    if ((Get-ChildItem $tempFolder | Measure-Object).Count -eq 0) {
        Remove-Item $tempFolder -Force -Recurse
    } else {
        Write-Host "Temp folder not empty, leaving it there"
    }

} 

if ($success -eq 0) {
    Write-Host "Could not install $appName, please download it manually from $manualDownloadUrl"
    exit 1
} else {
    Write-Host "Successfully installed $appName"
    exit 0
}



