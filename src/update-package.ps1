$Timer = [System.Diagnostics.Stopwatch]::StartNew()
$packageName = Read-Host 'What package do you want to update?'

$quit = $false
while(!$quit) {
    $safeMode = Read-Host "Do you want update highest version available for same major.minor.* (y/n)?"
    $quit = $safeMode -eq "n" -Or $safeMode -eq "N" -Or $safeMode -eq "y" -Or $safeMode -eq "Y" -Or $safeMode -eq ""
    $safeMode = $safeMode -eq "y" -Or $safeMode -eq "Y"
}

$nugetFeeds =  "https://nuget.hallmarkbusiness.com:443/HBC-Nuget/nuget;https://www.nuget.org/api/v2"
$repositoryPath = "..\nuget_packages"

$configFiles = Get-ChildItem -Path ..\ -Filter packages.config -Recurse -ErrorAction SilentlyContinue -Force | 
Where-Object { Get-Content $_.FullName | Select-String -Pattern "id=`"$packageName`"" } |
ForEach-Object {$_.FullName}

foreach($configFile in $configFiles) {
    &nuget update $configFile -source $nugetFeeds -id $packageName -NonInteractive -FileConflictAction Overwrite -RepositoryPath $repositoryPath
}

Write-Host "Finished update.  Elapsed time $([string]::Format("`rTime: {0:d2}:{1:d2}:{2:d2}", $Timer.Elapsed.hours, $Timer.Elapsed.minutes, $Timer.Elapsed.seconds))."
pause