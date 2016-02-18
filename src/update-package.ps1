param (
    [switch]$safeMode = $false,
    [Parameter(Mandatory=$true)][string]$packageName,`
    [string]$nugetFeeds = "https://nuget.hallmarkbusiness.com:443/HBC-Nuget/nuget;https://www.nuget.org/api/v2",
    [string]$workingDirectory = ".",
    [string]$repositoryPath = $(Join-Path -Path $(if($workingDirectory) { $workingDirectory } else { ".\" }) -childPath "nuget_packages" )   
)

# Checks if the working directory exitsts.  If it doesn't then it will terminate.
if(!(Test-Path $workingDirectory)) {
    Write-Host "Could not find the working directory $workingDirectory"
    Exit
}

# Outputs current configuration for updating nuget packages.
Write-Host ""
Write-Host "Grindstone setup:"
Write-Host "Location nuget packages will be stored $repositoryPath."
Write-Host "Working directory $workingDirectory."
Write-Host "NuGet feeds to check for packages $nugetFeeds."
Write-Host ""

# Tracking how long the update process takes.
$Timer = [System.Diagnostics.Stopwatch]::StartNew()


# Scanning sub directories for packages.config that contain the package tryign to be updated.  This also counts the packages needing updated.
Write-Host "Scanning $workingDirectory for **\packages.config containing $packageName."
$configFiles = Get-ChildItem -Path $workingDirectory -Filter packages.config -Recurse -ErrorAction SilentlyContinue -Force | 
               Where-Object { Get-Content $_.FullName | Select-String -Pattern "id=`"$packageName`"" } |
               ForEach-Object {
                $_.FullName
                $projectCount++
               }

Write-Host "Found $packageName in $projectCount projects."
Write-Host ""

# Updates each package to the latest version.  If safe mode is on it will update to the most recent version based on the 
# major.minor build (e.g 1.1603.1.0 -> 1.1603.2.0 even if the latest is 1.1604.0.0).
foreach($configFile in $configFiles) {
    Write-Host "Updating $configFile"
    Write-Host update $configFile -source $nugetFeeds -id $packageName -NonInteractive -FileConflictAction Overwrite -RepositoryPath $repositoryPath  $(if ($safeMode) { "-Safe" })
    &nuget update $configFile -source $nugetFeeds -id $packageName -NonInteractive -FileConflictAction Overwrite -RepositoryPath $repositoryPath $(if ($safeMode) { "-Safe" }) 
}

Write-Host "Finished update.  Elapsed time $([string]::Format("`rTime: {0:d2}:{1:d2}:{2:d2}", $Timer.Elapsed.hours, $Timer.Elapsed.minutes, $Timer.Elapsed.seconds))."
pause