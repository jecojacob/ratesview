###################################
# Get name of project
###################################
$param1 = ""
if($args.Count -gt 0 )
{
  $param1=$args[0]
}

$param2 = "" ## --force
if($args.Count -gt 0 )
{
  $param2=$args[1]
}

if($param1.Length -gt 0) {
    $projectName = $param1
} else {
  ###################################
  # Ask user  for stage
  ###################################
  Write-Host "Project name is required!!" -ForegroundColor Red  -BackgroundColor Black
  return
}

Write-Host "---------------------------------------------------------------" -ForegroundColor Magenta  -BackgroundColor Black
Write-Host "Building creating source folder " -ForegroundColor Green  -BackgroundColor Black     

#New-Item -Path 'source' -ItemType Directory -Force
#New-Item -Path 'source/Core' -ItemType Directory -Force
#New-Item -Path 'source/Infrastructure' -ItemType Directory -Force

## Please install BFF template
## dotnet new install Blazor.BFF.AzureAD.Template

## Install or update amazon dotnet tooll
## dotnet tool install/update -g Amazon.Lambda.Tools

## Check for updates
##  dotnet new update --check-only
## --ignore-failed-sources

#pushd .\source
try {
    Write-Host "Creating UI - Blazor BFF Entra projects" -ForegroundColor Green  -BackgroundColor Black  
    dotnet new blazorbffaad -n $projectName $param2 --output source
 
    Write-Host "Creating Core" -ForegroundColor Green  -BackgroundColor Black  
    dotnet new classlib -n "$projectName.Core" --output source/Core  $param2

    Write-Host "Creating Infrastructure" -ForegroundColor Green  -BackgroundColor Black  
    dotnet new classlib -n "$projectName.Infrastructure" --output source/Infrastructure  $param2

    Write-Host "Modifying Solution" -ForegroundColor Green  -BackgroundColor Black  
    dotnet sln ".\source\$projectName.sln" add ".\source\Core\$projectName.Core.csproj" --solution-folder Core
    dotnet sln ".\source\$projectName.sln" add ".\source\Infrastructure\$projectName.Infrastructure.csproj" --solution-folder Infrastructure
   
    dotnet sln ".\source\$projectName.sln" remove ".\source\Shared\$projectName.Shared.csproj" ".\source\Server\$projectName.Server.csproj" ".\source\Client\$projectName.Client.csproj"
    
    dotnet sln ".\source\$projectName.sln" add ".\source\Shared\$projectName.Shared.csproj" --solution-folder Core

    dotnet sln ".\source\$projectName.sln" add ".\source\Server\$projectName.Server.csproj" --solution-folder UI
    dotnet sln ".\source\$projectName.sln" add ".\source\Client\$projectName.Client.csproj" --solution-folder UI
   
    Write-Host "Adding packages" -ForegroundColor Green  -BackgroundColor Black
    dotnet add ".\source\Core\$projectName.Core.csproj" package MediatR
    Write-Host "...."  -ForegroundColor Green  -BackgroundColor Black 
    dotnet add ".\source\Server\$projectName.Server.csproj" package MediatR


    Write-Host "---------------------------------------------------------------" -ForegroundColor Magenta  -BackgroundColor Black
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Host "An error occurred:" -ForegroundColor Red  -BackgroundColor Black
    Write-Host $_  -ForegroundColor Red  -BackgroundColor Black
  
    Write-Host "Exiting"
    return
}
finally {
    <#Do this after the try block regardless of whether an exception occurred or not#>
    #popd 
}

