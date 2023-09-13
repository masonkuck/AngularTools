# Split inline component files into a new directory and individual files.
Function Split-Angular-File ($path, [bool]$skipWarning = $false, [bool]$verbose = $false) { 
    # Bootstrap
    if ($path -eq 0) {
        Write-Host "First parameter must be a path" -ForegroundColor Red
        Write-Host "`n"
        return
    }

    if (!$skipWarning) {
        Write-Host 'This script can alter uncommited git files. Ensure you push in progress changes before running this script. Continue? [Y] or [N]:' -ForegroundColor Yellow
        $response = Read-Host
        if ($response -eq 'N' || $response -eq 'n' || $response -eq ''){
            return;
        }
    }

    # Variables
    [string]$originalPath = (Get-Location).Path 
    [string]$filePath = $path
    [string]$fileName = Split-Path $filePath -leaf
    [string]$filePrefix = $fileName.Replace(".component.ts", "")
    [string]$folderPath = Split-Path $filePath -Parent

    $newFolder = "$folderPath\$filePrefix"
    $newComponent = "$newFolder\$filePrefix.component.ts"
    $newTemplate = "$newFolder\$filePrefix.component.html"

    # Load File
    if (!(Test-Path $filePath -PathType Leaf)) {
        Write-Host "No Component File Found... Searched for the following: $filePath"  -ForegroundColor Yellow
        Write-Host "`n"
        return
    }

    [string]$fileContents = (Get-Content $filePath) -join "`n"

    if (!($fileContents.Contains("template:"))) {
        Write-Host "No template found within the Component File: $filePath" -ForegroundColor Red
        return;
    }

    Write-Host "Processing component file $path"
    Write-Host "`n"
    
    $templateData = $fileContents.Split('`')[1]
    $fileContents = $fileContents.Replace($templateData, "")
    $fileContents = $fileContents.Replace("template: ````", "templateUrl: ""$filePrefix.component.html""")
    $fileContents = $fileContents.Replace("from ""../", "from ""../../")
    $fileContents = $fileContents.Replace("from ""./", "from ""../")

    # Create New Directory
    if (!(Test-Path $newFolder -PathType Container)) {
        New-Item -ItemType Directory -Path $newFolder
        Write-Host "Created new Directory file $newComponent" -ForegroundColor Green
        Write-Host "`n" 
    } else {
        Write-Host "New Directory already exists" -ForegroundColor Yellow
        Write-Host "`n"
    }

    # Create New File(s)
    Set-Content -path $newComponent -Value $fileContents
    Write-Host "Created new Component file $newComponent" -ForegroundColor Green
    Write-Host "`n"

    Set-Content -path $newTemplate -Value $templateData
    Write-Host "Created new Template file $newTemplate" -ForegroundColor Green
    Write-Host "`n"

    # Format Template File to remove extra whitespace
    $templateData = Get-Content $newTemplate
    if ([string]::IsNullOrEmpty(($templateData | Select-Object -First 1))){
        $templateData = $templateData | Select-Object -Skip 1
    }
    
    $index = ($templateData | Select-Object -First 1).IndexOf('<')

    for ($lineNumber = 0; $lineNumber -lt $templateData.Count; $lineNumber++) {
        if($templateData[$lineNumber].Length-1 -gt $index){
            $templateData[$lineNumber] = $templateData[$lineNumber].Substring($index)
        }
    }

    Set-Content -path $newTemplate -Value $templateData

    # Update module import statements with better relative paths
    $newPath = Get-ChildItem $newComponent
    
    $fileList = Get-ChildItem -Filter *.ts -Recurse | Where-Object { $_.fullName -notlike "*node_modules*" }
    $fileList | ForEach-Object -Process {
        $moduleContent = Get-Content $_.fullName -Raw
        $moduleContent = $moduleContent.SubString(0, $moduleContent.Length - 1)

        Set-Location $_.directory.fullName
        $relativeOldPath = Resolve-Path $filePath -Relative 
        $relativeNewPath = Resolve-Path $newPath.fullName -Relative 

        $relativeOldPath = $relativeOldPath.Replace("\", "/").Replace(".ts", "")
        $relativeNewPath = $relativeNewPath.Replace("\", "/").Replace(".ts", "")

        if ($verbose -eq $true){
            Write-Host "Checking Module for references: $($_.fullName)"
            Write-Host "Old Path: $relativeOldPath"
            Write-Host "New Path: $relativeNewPath"
            Write-Host "`n"
        }

        $newModuleContent = $moduleContent.Replace("from ""$relativeOldPath""", "from ""$relativeNewPath""")
        if ($newModuleContent -ne $moduleContent) {
            Write-Host "Updated Module File References $($_.fullName)" -ForegroundColor Green
            Write-Host "`n"
            Set-Content -path $_.fullName -value $newModuleContent.SubString(0, $newModuleContent.Length - 1)
        }
    }

    # Return to original path
    Set-Location $originalPath

    # Remove content from old file.
    Remove-Item -Path $filePath
    Write-Host "Removed Original Component File $filePath" -ForegroundColor Green
    Write-Host "`n"
 
    if (!$skipWarning) {
        Write-Host "Ensure that you build and test all generated changes. Template Files may need to be formatted. You may need to manually create style files." -ForegroundColor DarkYellow
        Write-Host "`n"
    }

}
