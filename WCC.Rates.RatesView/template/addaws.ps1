## This needs to be done after scafold
###################################
# Get name of project
###################################


$param0 = ""
if($args.Count -gt 0 )
{
  $param0=$args[0]
}
if($param0.Length -gt 0) {
    $outfolder = $param0
} else {
  ###################################
  # Required
  ###################################
  Write-Host "output folder is required" -ForegroundColor Red  -BackgroundColor Black
  throw "output folder is required!!!"
}

$param1 = ""
if($args.Count -gt 1 )
{
  $param1=$args[1]
}
if($param1.Length -gt 0) {
    $csprog = "$outfolder\Server\$param1"
} else {
  ###################################
  # Required
  ###################################
  Write-Host "csprog file name is required!!" -ForegroundColor Red  -BackgroundColor Black
  throw "csprog file name is required!!"
}



Write-Host "---------------------------------------------------------------" -ForegroundColor Magenta  -BackgroundColor Black
Write-Host "Adding AWS package to project" -ForegroundColor Green  -BackgroundColor Black 

dotnet add $csprog package Amazon.Lambda.AspNetCoreServer.Hosting

dotnet add $csprog package AWSSDK.Lambda

## Add tag to let lambda know that it is an AWS lambda project 

[xml]$xmlDoc = Get-Content $csprog

$xmlDoc.Save("$csprog.backup")

$element = $xmlDoc.Project.PropertyGroup.AWSProjectType
if ($null -eq $element) {
    Write-Host "Adding AWSProjectType to csproj" -ForegroundColor Green  -BackgroundColor Black 
    $element = $xmlDoc.CreateElement("AWSProjectType")
    $element.InnerText = "Lambda"
    $xmlDoc.Project.PropertyGroup.AppendChild($element)  
}
else {
    Write-Host "AWSProjectType already exists in csproj" -ForegroundColor Blue  -BackgroundColor Black 
}


$element = $xmlDoc.Project.PropertyGroup.AssemblyName
if ($null -eq $element) {
    Write-Host "Adding AssemblyName to csproj" -ForegroundColor Green  -BackgroundColor Black 
    $element = $xmlDoc.CreateElement("AssemblyName")
    $element.InnerText = "bootstrap"
    $xmlDoc.Project.PropertyGroup.AppendChild($element)
} else {
    Write-Host "AssemblyName already exists in csproj" -ForegroundColor Blue  -BackgroundColor Black 
}

$element = $xmlDoc.Project.PropertyGroup.PublishReadyToRun
if ($null -eq $element) {
    Write-Host "Adding PublishReadyToRun to csproj" -ForegroundColor Green  -BackgroundColor Black 
    $element = $xmlDoc.CreateElement("PublishReadyToRun")
    $element.InnerText = "true"
    # Comment the node
    $comment = $xmlDoc.CreateComment($element.OuterXml);
    $comment.InnerText = " Generate ready to run images during publishing to improve cold start time. ";
    $xmlDoc.Project.PropertyGroup.AppendChild($comment)
    $xmlDoc.Project.PropertyGroup.AppendChild($element)
} else {
    Write-Host "PublishReadyToRun already exists in csproj" -ForegroundColor Blue  -BackgroundColor Black 
}

$element = $xmlDoc.Project.PropertyGroup.CopyLocalLockFileAssemblies
if ($null -eq $element) {
    Write-Host "Adding CopyLocalLockFileAssemblies to csproj" -ForegroundColor Green  -BackgroundColor Black 
    $element = $xmlDoc.CreateElement("CopyLocalLockFileAssemblies")
    $element.InnerText = "true"
    $xmlDoc.Project.PropertyGroup.AppendChild($element)
    # Comment the node
    $comment = $xmlDoc.CreateComment($element.OuterXml);
    $comment.InnerText = "  This property makes the build directory similar to a publish directory and helps the AWS .NET Lambda Mock Test Tool find project dependencies.  ";
    $xmlDoc.Project.PropertyGroup.AppendChild($comment)
    $xmlDoc.Project.PropertyGroup.AppendChild($element)
} else {
    Write-Host "CopyLocalLockFileAssemblies already exists in csproj" -ForegroundColor Blue  -BackgroundColor Black 
}

$element = $xmlDoc.Project.PropertyGroup.SatelliteResourceLanguages
if ($null -eq $element) {
    Write-Host "Adding SatelliteResourceLanguages to csproj" -ForegroundColor Green  -BackgroundColor Black 
    $element = $xmlDoc.CreateElement("SatelliteResourceLanguages")
    $element.InnerText = "en"
    $xmlDoc.Project.PropertyGroup.AppendChild($element)
} else {
    Write-Host "SatelliteResourceLanguages already exists in csproj" -ForegroundColor Blue  -BackgroundColor Black
}

$xmlDoc.Save($csprog)

## Add aws-lambda-tools-defaults.json
Write-Host "Adding aws-lambda-tools-defaults.json" -ForegroundColor Green  -BackgroundColor Black 

$awsLambdaToolsDefaults = @'
{
    "Information": [
        "This file provides default values for the deployment wizard inside Visual Studio and the AWS Lambda commands added to the .NET Core CLI.",
        "To learn more about the Lambda commands with the .NET Core CLI execute the following command at the command line in the project root directory.",
        "dotnet lambda help",
        "All the command line options for the Lambda command can be specified in this file."
    ],
    "profile": "sso-dz-dev",
    "region": "ap-southeast-2",
    "configuration": "Release",
    "function-runtime": "provided.al2023",
    "function-architecture": "arm64",
    "function-handler": "bootstrap",
    "msbuild-parameters": "--self-contained true"
}
'@
$awsLambdaToolsDefaults | Out-File  "$outfolder\Server\aws-lambda-tools-defaults.json"

$AddAWSLambdaHosting = @(
    "// Add AWS Lambda support. When application is run in Lambda Kestrel is swapped out as the web server with Amazon.Lambda.AspNetCoreServer. This",
    "// package will act as the webserver translating request and responses between the Lambda event source and ASP.NET Core.",
    "builder.Services.AddAWSLambdaHosting(LambdaEventSource.RestApi);",
    ""

)

$lineToFind = "var app = builder.Build();"
## Enable Api GateWay
$programcs = "$outfolder\Server\Program.cs"

# Read the file content as an array of lines
$fileContent = Get-Content $programcs -Encoding UTF8

# Check if AddAWSLambdaHosting already exists in the file
# -match uses regex
if ($fileContent -match "AddAWSLambdaHosting")  {
    Write-Host "AddAWSLambdaHosting already added" -ForegroundColor Blue  -BackgroundColor Black  
} else {
    
    Write-Host "Adding AddAWSLambdaHosting" -ForegroundColor Green  -BackgroundColor Black 

    # Loop through each line of the file
    for ($i = 0; $i -lt $fileContent.Length; $i++) {
        # If the line matches the string to find, insert the lines before it
 
        if ($fileContent[$i] -contains $lineToFind) {
            $fileContent = $fileContent[0..($i-1)] + $AddAWSLambdaHosting + $fileContent[$i..($fileContent.Length-1)]
            break # Stop the loop after inserting the lines
        }
    }

    # Write the modified content back to the file
    Set-Content $programcs $fileContent 
}

#(Get-Content $programcs) -replace 'var app = builder.Build();', $AddAWSLambdaHosting | Set-Content $programcs


## Find 
## Replace wih
<#

#>