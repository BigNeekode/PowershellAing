# ============================================
# PowerShell Profile
# ============================================

# Import modules with auto-installation
Import-Module PSReadLine -ErrorAction SilentlyContinue

# ============================================
# Enhanced Module Management
# ============================================

# Auto-install and import common modules
$modulesToInstall = @(
    @{Name = "PSReadLine"; RequiredVersion = "2.2.6"},
    @{Name = "Terminal-Icons"; RequiredVersion = "0.11.0"},
    @{Name = "posh-git"; RequiredVersion = "1.1.0"}
)

foreach ($module in $modulesToInstall) {
    $moduleName = $module.Name
    $requiredVersion = $module.RequiredVersion

    if (-not (Get-Module -Name $moduleName -ListAvailable)) {
        Write-Host "Installing module: $moduleName (v$requiredVersion)..." -ForegroundColor Yellow
        try {
            Install-Module -Name $moduleName -RequiredVersion $requiredVersion -Scope CurrentUser -Force -ErrorAction Stop
            Write-Host "✓ $moduleName installed successfully" -ForegroundColor Green
        }
        catch {
            Write-Host "✗ Failed to install $moduleName`: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    if (-not (Get-Module -Name $moduleName)) {
        Import-Module $moduleName -ErrorAction SilentlyContinue
    }
}

# Function to install any missing module
function Install-MissingModule {
    param([string]$ModuleName)
    if (-not (Get-Module -Name $ModuleName -ListAvailable)) {
        Install-Module -Name $ModuleName -Scope CurrentUser -Force
        Import-Module $ModuleName
        Write-Host "Installed and imported: $ModuleName" -ForegroundColor Green
    } else {
        Write-Host "Module already available: $ModuleName" -ForegroundColor Cyan
    }
}

# Update all installed modules
function Update-AllModules {
    Write-Host "Updating all installed modules..." -ForegroundColor Yellow
    Update-Module -Scope CurrentUser -Force
    Write-Host "All modules updated!" -ForegroundColor Green
}

# ============================================
# PSReadLine Configuration (Better editing)
# ============================================
if (Get-Module -Name PSReadLine) {
    # Enable predictive IntelliSense
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView

    # Better history search
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    # Tab completion
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

    # Colors
    Set-PSReadLineOption -Colors @{
        Command            = 'Yellow'
        Parameter          = 'Gray'
        Operator           = 'Magenta'
        Variable           = 'Green'
        String             = 'Cyan'
        Number             = 'Cyan'
        Type               = 'DarkGray'
        Comment            = 'DarkGreen'
        InlinePrediction   = 'DarkGray'
    }
}

# ============================================
# Custom Prompt
# ============================================
function prompt {
    $ESC = [char]27
    $location = Get-Location

    # Get git branch if in a git repo
    $gitBranch = ""
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $branch = git branch --show-current 2>$null
        if ($branch) {
            $gitStatus = git status --porcelain 2>$null
            $statusSymbol = if ($gitStatus) { "*" } else { "" }
            $gitBranch = "$ESC[35m($branch$statusSymbol)$ESC[0m"
        }
    }

    # Color the path
    $path = "$ESC[36m$location$ESC[0m"

    # Username and computer
    $user = "$ESC[32m$env:USERNAME$ESC[0m"

    # Build prompt
    Write-Host ""
    Write-Host "$user $path$gitBranch" -NoNewline
    return "`n> "
}

# ============================================
# Aliases
# ============================================

# Navigation shortcuts
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# List files with colors
function ll { Get-ChildItem -Force | Format-Table -AutoSize }
function la { Get-ChildItem -Force }

# Git shortcuts
function gs { git status }
function ga { git add $args }
function gc { git commit -m $args }
function gp { git push }
function gpl { git pull }
function gd { git diff }
function gco { git checkout $args }
function gb { git branch $args }
function gl { git log --oneline --graph --decorate -10 }

# System shortcuts
function which($name) { Get-Command $name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition }
function touch($file) { New-Item -ItemType File -Name $file -Force | Out-Null }
function rm-rf($path) { Remove-Item -Recurse -Force $path }

# Directory shortcuts
function mkcd($dir) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Set-Location $dir
}

# Quick edit profile
function Edit-Profile { notepad $PROFILE }

# Reload profile
function Reload-Profile { . $PROFILE; Write-Host "Profile reloaded!" -ForegroundColor Green }

# ============================================
# REST API and Cloud Integration Helpers
# ============================================

# REST API testing utilities
function Invoke-RestMethodPretty {
    param(
        [string]$Uri,
        [string]$Method = "GET",
        [string]$Body = $null,
        [hashtable]$Headers = @{}
    )

    $params = @{
        Uri = $Uri
        Method = $Method
        ContentType = "application/json"
    }

    if ($Headers.Count -gt 0) {
        $params.Headers = $Headers
    }

    if ($Body) {
        $params.Body = $Body
    }

    Write-Host "=== $Method $Uri ===" -ForegroundColor Cyan
    Write-Host "Headers:" -ForegroundColor Yellow
    $params.Headers.GetEnumerator() | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor Gray
    }

    if ($Body) {
        Write-Host ""
        Write-Host "Body:" -ForegroundColor Yellow
        Write-Host $Body -ForegroundColor Gray
    }

    try {
        $response = Invoke-RestMethod @params
        Write-Host ""
        Write-Host "Response:" -ForegroundColor Green
        $response | ConvertTo-Json -Depth 3 | ForEach-Object {
            Write-Host $_ -ForegroundColor White
        }
        return $response
    }
    catch {
        Write-Host ""
        Write-Host "Error:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        return $null
    }
}

function Test-ApiEndpoint {
    param(
        [string]$Uri,
        [string[]]$Methods = @("GET", "POST", "PUT", "DELETE")
    )

    Write-Host "=== Testing API Endpoint: $Uri ===" -ForegroundColor Cyan

    foreach ($method in $Methods) {
        Write-Host ""
        Write-Host "Testing $method..." -ForegroundColor Yellow
        try {
            $response = Invoke-WebRequest -Uri $Uri -Method $method -TimeoutSec 10
            Write-Host "✓ $method $($response.StatusCode) $($response.StatusDescription)" -ForegroundColor Green
        }
        catch {
            Write-Host "✗ $method $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Cloud service integrations
function Get-AzureResourceGroups {
    if (Get-Module -Name Az -ListAvailable) {
        Connect-AzAccount -ErrorAction SilentlyContinue
        Get-AzResourceGroup | Format-Table ResourceGroupName, Location, ProvisioningState -AutoSize
    } else {
        Write-Host "Azure PowerShell module not installed. Install with: Install-Module -Name Az" -ForegroundColor Yellow
    }
}

function Get-AWSInstances {
    if (Get-Module -Name AWS.Tools.EC2 -ListAvailable) {
        $instances = Get-EC2Instance | Select-Object -ExpandProperty Instances
        $instances | Format-Table InstanceId, InstanceType, State, LaunchTime -AutoSize
    } else {
        Write-Host "AWS Tools for PowerShell not installed. Install with: Install-Module -Name AWS.Tools.EC2" -ForegroundColor Yellow
    }
}

# GitHub API helpers
function Get-GitHubRepoInfo {
    param([string]$Owner, [string]$Repo)

    $apiUrl = "https://api.github.com/repos/$Owner/$Repo"
    $response = Invoke-RestMethod -Uri $apiUrl -Method GET

    Write-Host "=== GitHub Repository: $Owner/$Repo ===" -ForegroundColor Cyan
    Write-Host "Name: $($response.name)" -ForegroundColor White
    Write-Host "Description: $($response.description)" -ForegroundColor White
    Write-Host "Stars: $($response.stargazers_count)" -ForegroundColor Yellow
    Write-Host "Forks: $($response.forks_count)" -ForegroundColor Yellow
    Write-Host "Language: $($response.language)" -ForegroundColor Green
    Write-Host "License: $($response.license.name)" -ForegroundColor Magenta
    Write-Host "Last Updated: $($response.updated_at)" -ForegroundColor Gray

    return $response
}

function Search-GitHubRepos {
    param(
        [string]$Query,
        [int]$Results = 10
    )

    $apiUrl = "https://api.github.com/search/repositories?q=$([uri]::EscapeDataString($Query))&sort=stars&order=desc&per_page=$Results"
    $response = Invoke-RestMethod -Uri $apiUrl -Method GET

    Write-Host "=== GitHub Search: $Query ===" -ForegroundColor Cyan
    $response.items | ForEach-Object {
        Write-Host ""
        Write-Host "$($_.full_name)" -ForegroundColor Yellow
        Write-Host "  $($_.description)" -ForegroundColor White
        Write-Host "  Stars: $($_.stargazers_count) | Language: $($_.language)" -ForegroundColor Gray
    }

    return $response.items
}

# Weather API integration
function Get-Weather {
    param(
        [string]$City = "Jakarta",
        [string]$ApiKey = $null
    )

    if (!$ApiKey) {
        # Use a free weather API (no key required)
        $apiUrl = "https://wttr.in/$([uri]::EscapeDataString($City))?format=3"
        try {
            $weather = Invoke-RestMethod -Uri $apiUrl -Method GET
            Write-Host "Weather in $City`: $weather" -ForegroundColor Cyan
            return $weather
        }
        catch {
            Write-Host "Could not fetch weather data for $City" -ForegroundColor Red
        }
    } else {
        # Use OpenWeatherMap API (requires free API key)
        $apiUrl = "https://api.openweathermap.org/data/2.5/weather?q=$([uri]::EscapeDataString($City))&appid=$ApiKey&units=metric"
        try {
            $weather = Invoke-RestMethod -Uri $apiUrl -Method GET
            Write-Host "Weather in $City`: $($weather.weather[0].description), $($weather.main.temp)°C" -ForegroundColor Cyan
            return $weather
        }
        catch {
            Write-Host "Could not fetch weather data for $City. Check API key." -ForegroundColor Red
        }
    }
}

# Clipboard and text processing utilities
function Get-ClipboardText {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Clipboard]::GetText()
}

function Set-ClipboardText {
    param([string]$Text)
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Clipboard]::SetText($Text)
    Write-Host "Text copied to clipboard" -ForegroundColor Green
}

function ConvertFrom-Base64 {
    param([string]$Base64String)
    $bytes = [Convert]::FromBase64String($Base64String)
    [Text.Encoding]::UTF8.GetString($bytes)
}

function ConvertTo-Base64 {
    param([string]$Text)
    $bytes = [Text.Encoding]::UTF8.GetBytes($Text)
    [Convert]::ToBase64String($bytes)
}

# URL encoding/decoding
function Encode-Url {
    param([string]$Text)
    [uri]::EscapeDataString($Text)
}

function Decode-Url {
    param([string]$Text)
    [uri]::UnescapeDataString($Text)
}

# JSON formatting utilities
function Format-JsonPretty {
    param([string]$Json)
    $jsonObject = $Json | ConvertFrom-Json
    $jsonObject | ConvertTo-Json -Depth 10
}

function Validate-Json {
    param([string]$Json)
    try {
        ConvertFrom-Json $Json -ErrorAction Stop
        Write-Host "✓ Valid JSON" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ Invalid JSON: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# API testing aliases
Set-Alias -Name api-test -Value Test-ApiEndpoint -ErrorAction SilentlyContinue
Set-Alias -Name api-call -Value Invoke-RestMethodPretty -ErrorAction SilentlyContinue
Set-Alias -Name github-repo -Value Get-GitHubRepoInfo -ErrorAction SilentlyContinue
Set-Alias -Name github-search -Value Search-GitHubRepos -ErrorAction SilentlyContinue
Set-Alias -Name weather -Value Get-Weather -ErrorAction SilentlyContinue

# ============================================
# Claude Code Compatibility Functions
# ============================================

# Show project structure in a clean tree format
function Show-Tree {
    param(
        [string]$Path = ".",
        [int]$Depth = 3
    )

    # Try to use Windows tree.com command
    if (Get-Command tree.com -ErrorAction SilentlyContinue) {
        & tree.com $Path /F /A | Select-Object -First 100
    } else {
        # Fallback to PowerShell method
        Get-ChildItem -Path $Path -Recurse -Depth $Depth -ErrorAction SilentlyContinue |
            Select-Object FullName |
            ForEach-Object {
                $relPath = $_.FullName.Replace((Get-Location).Path, ".")
                "    " * ($relPath.Split([IO.Path]::DirectorySeparatorChar).Count - 2) + [IO.Path]::GetFileName($relPath)
            }
    }
}

# Show git status in clean format
function Show-GitStatus {
    if (Test-Path .git) {
        Write-Host "`n=== Git Status ===" -ForegroundColor Yellow
        git status --short --branch
        Write-Host ""
    } else {
        Write-Host "Not a git repository" -ForegroundColor Red
    }
}

# Show project info - useful for Claude to understand project
function Show-ProjectInfo {
    Write-Host "`n=== Project Information ===" -ForegroundColor Cyan
    Write-Host "Location: $(Get-Location)" -ForegroundColor White

    # Check for common project files
    $projectFiles = @("package.json", "requirements.txt", "Cargo.toml", "pom.xml", "build.gradle", "*.csproj", "*.sln", "go.mod", "Gemfile", "composer.json")

    foreach ($file in $projectFiles) {
        $found = Get-ChildItem -Filter $file -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            Write-Host "Type: $($found.Name)" -ForegroundColor Green
            break
        }
    }

    # Git info
    if (Test-Path .git) {
        $branch = git branch --show-current 2>$null
        Write-Host "Git Branch: $branch" -ForegroundColor Magenta
    }

    # Count files
    $fileCount = (Get-ChildItem -File -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Host "Total Files: $fileCount" -ForegroundColor White
    Write-Host ""
}

# Clean test runner
function Run-Tests {
    param([string]$Filter = "")

    if (Test-Path "package.json") {
        npm test $Filter
    } elseif (Test-Path "requirements.txt") {
        pytest $Filter
    } elseif (Test-Path "Cargo.toml") {
        cargo test $Filter
    } elseif (Get-ChildItem -Filter "*.csproj") {
        dotnet test $Filter
    } else {
        Write-Host "No test framework detected" -ForegroundColor Yellow
    }
}

# Clean build runner
function Run-Build {
    if (Test-Path "package.json") {
        npm run build
    } elseif (Test-Path "Cargo.toml") {
        cargo build
    } elseif (Get-ChildItem -Filter "*.csproj") {
        dotnet build
    } elseif (Test-Path "go.mod") {
        go build
    } else {
        Write-Host "No build system detected" -ForegroundColor Yellow
    }
}

# Show file with line numbers (useful for debugging)
function Show-File {
    param([string]$Path, [int]$Lines = 50)

    if (Test-Path $Path) {
        Get-Content $Path -TotalCount $Lines | ForEach-Object -Begin { $lineNum = 1 } -Process {
            Write-Host ("{0,4}: {1}" -f $lineNum, $_)
            $lineNum++
        }
    } else {
        Write-Host "File not found: $Path" -ForegroundColor Red
    }
}

# Quick grep with line numbers
function Search-Content {
    param(
        [string]$Pattern,
        [string]$Path = ".",
        [string]$Include = "*"
    )

    Get-ChildItem -Path $Path -Recurse -Include $Include -File -ErrorAction SilentlyContinue |
        Select-String -Pattern $Pattern |
        Select-Object -First 50 |
        ForEach-Object {
            Write-Host "$($_.Filename):$($_.LineNumber)" -ForegroundColor Yellow -NoNewline
            Write-Host " $($_.Line.Trim())"
        }
}

# Quick diagnostics - run all checks at once
function Show-QuickStatus {
    Write-Host "`n=== Quick Status ===" -ForegroundColor Cyan
    Write-Host "Directory: $(Get-Location)" -ForegroundColor White

    # Git status
    if (Test-Path .git) {
        $branch = git branch --show-current 2>$null
        $status = git status --porcelain 2>$null
        $statusText = if ($status) { "uncommitted changes" } else { "clean" }
        Write-Host "Git: $branch ($statusText)" -ForegroundColor $(if ($status) { "Yellow" } else { "Green" })
    }

    # Project type
    if (Test-Path "package.json") { Write-Host "Project: Node.js/npm" -ForegroundColor Green }
    elseif (Test-Path "requirements.txt") { Write-Host "Project: Python" -ForegroundColor Green }
    elseif (Test-Path "Cargo.toml") { Write-Host "Project: Rust" -ForegroundColor Green }
    elseif (Get-ChildItem -Filter "*.csproj") { Write-Host "Project: .NET/C#" -ForegroundColor Green }
    elseif (Test-Path "go.mod") { Write-Host "Project: Go" -ForegroundColor Green }

    # Recent files modified
    $recentFiles = Get-ChildItem -File -Recurse -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 3
    if ($recentFiles) {
        Write-Host "`nRecently modified:" -ForegroundColor DarkGray
        $recentFiles | ForEach-Object {
            $relPath = $_.FullName.Replace((Get-Location).Path, ".").Replace("\", "/")
            Write-Host "  $relPath" -ForegroundColor DarkGray
        }
    }
    Write-Host ""
}

# ============================================
# Enhanced Development Workflow
# ============================================

# Multi-language package manager shortcuts
function Get-PackageManager {
    if (Test-Path "package.json") { return "npm" }
    elseif (Test-Path "requirements.txt") { return "pip" }
    elseif (Test-Path "Cargo.toml") { return "cargo" }
    elseif (Test-Path "composer.json") { return "composer" }
    elseif (Test-Path "Gemfile") { return "bundle" }
    elseif (Test-Path "go.mod") { return "go" }
    elseif (Get-ChildItem -Filter "*.csproj") { return "dotnet" }
    elseif (Get-ChildItem -Filter "pom.xml") { return "mvn" }
    elseif (Get-ChildItem -Filter "build.gradle") { return "gradle" }
    else { return $null }
}

function Install-Packages {
    $pm = Get-PackageManager
    if ($pm) {
        Write-Host "Installing packages with $pm..." -ForegroundColor Yellow
        switch ($pm) {
            "npm" { npm install }
            "pip" { pip install -r requirements.txt }
            "cargo" { cargo build }
            "composer" { composer install }
            "bundle" { bundle install }
            "go" { go mod download }
            "dotnet" { dotnet restore }
            "mvn" { mvn dependency:resolve }
            "gradle" { gradle build }
        }
    } else {
        Write-Host "No recognized package manager found" -ForegroundColor Red
    }
}

# Docker integration
function Start-DockerContainer {
    param(
        [string]$Name,
        [string]$Image = "ubuntu:latest",
        [switch]$Detach = $true
    )
    $detachFlag = if ($Detach) { "-d" } else { "" }
    docker run --name $Name $detachFlag $Image
}

function Stop-DockerContainer {
    param([string]$Name)
    docker stop $Name
    docker rm $Name
}

function Show-DockerStatus {
    Write-Host "=== Docker Containers ===" -ForegroundColor Cyan
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    Write-Host ""
    Write-Host "=== Docker Images ===" -ForegroundColor Cyan
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
}

# Database management shortcuts
function Start-MongoDB {
    docker run -d -p 27017:27017 --name mongodb mongo:latest
}

function Start-PostgreSQL {
    docker run -d -p 5432:5432 --name postgres -e POSTGRES_PASSWORD=password postgres:latest
}

function Start-Redis {
    docker run -d -p 6379:6379 --name redis redis:latest
}

# Node.js development helpers
function Start-DevServer {
    $pm = Get-PackageManager
    if ($pm -eq "npm") {
        npm run dev
    } else {
        Write-Host "No npm project found" -ForegroundColor Yellow
    }
}

function Create-ReactApp {
    param([string]$Name)
    npx create-react-app $Name
    Set-Location $Name
}

function Create-NextApp {
    param([string]$Name)
    npx create-next-app@latest $Name
    Set-Location $Name
}

# Python virtual environment helpers
function New-PythonVenv {
    param([string]$Name = "venv")
    python -m venv $Name
    Write-Host "Virtual environment '$Name' created" -ForegroundColor Green
}

function Activate-PythonVenv {
    param([string]$Name = "venv")
    if (Test-Path "$Name/Scripts/Activate.ps1") {
        & "$Name/Scripts/Activate.ps1"
    } else {
        Write-Host "Virtual environment not found: $Name" -ForegroundColor Red
    }
}

# Git workflow enhancements
function Git-SetupStream {
    param([string]$Email, [string]$Name)
    git config user.email $Email
    git config user.name $Name
    git config core.editor "code --wait"
    Write-Host "Git configured for $Name <$Email>" -ForegroundColor Green
}

# Aliases for Claude-friendly commands
Set-Alias -Name tree -Value Show-Tree -ErrorAction SilentlyContinue
Set-Alias -Name gss -Value Show-GitStatus -ErrorAction SilentlyContinue
Set-Alias -Name pinfo -Value Show-ProjectInfo -ErrorAction SilentlyContinue
Set-Alias -Name qs -Value Show-QuickStatus -ErrorAction SilentlyContinue
Set-Alias -Name test -Value Run-Tests -ErrorAction SilentlyContinue
Set-Alias -Name build -Value Run-Build -ErrorAction SilentlyContinue
Set-Alias -Name cat -Value Show-File -ErrorAction SilentlyContinue
Set-Alias -Name grep -Value Search-Content -ErrorAction SilentlyContinue

# Development workflow aliases
Set-Alias -Name install-pkgs -Value Install-Packages -ErrorAction SilentlyContinue
Set-Alias -Name dev -Value Start-DevServer -ErrorAction SilentlyContinue
Set-Alias -Name docker-status -Value Show-DockerStatus -ErrorAction SilentlyContinue

# ============================================
# Utility Functions
# ============================================

# Get public IP
function Get-PublicIP {
    (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
}

# Find files by name
function Find-File($name) {
    Get-ChildItem -Recurse -Filter "*$name*" -ErrorAction SilentlyContinue
}

# Get directory size
function Get-DirSize($path = ".") {
    $size = (Get-ChildItem -Path $path -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $sizeInMB = [math]::Round($size / 1MB, 2)
    Write-Host "$sizeInMB MB" -ForegroundColor Cyan
}

# Extract archives
function Extract-Archive($file) {
    $fullPath = Resolve-Path $file
    $destination = [System.IO.Path]::GetFileNameWithoutExtension($fullPath)
    Expand-Archive -Path $fullPath -DestinationPath $destination -Force
    Write-Host "Extracted to: $destination" -ForegroundColor Green
}

# Quick python server
function Start-WebServer($port = 8000) {
    python -m http.server $port
}

# ============================================
# Advanced System Administration Utilities
# ============================================

# Process management
function Show-TopProcesses {
    param([int]$Count = 10)
    Get-Process | Sort-Object CPU -Descending | Select-Object -First $Count |
        Format-Table Name, CPU, Memory, Id -AutoSize
}

function Kill-ProcessByName {
    param([string]$Name)
    Get-Process -Name "*$Name*" | ForEach-Object {
        Stop-Process -Id $_.Id -Force
        Write-Host "Killed process: $($_.Name) (PID: $($_.Id))" -ForegroundColor Red
    }
}

function Show-ProcessTree {
    param([int]$ProcessId = $PID)
    Get-Process -Id $ProcessId | Format-Table Name, Id, Parent, StartTime -AutoSize
}

# Service management
function Show-ServiceStatus {
    param([string]$ServiceName = "*")
    Get-Service -Name "*$ServiceName*" | Sort-Object Status, Name |
        Format-Table Name, DisplayName, Status, StartType -AutoSize
}

function Start-ServiceSafe {
    param([string]$ServiceName)
    $service = Get-Service -Name $ServiceName
    if ($service.Status -ne "Running") {
        Start-Service -Name $ServiceName
        Write-Host "Started service: $ServiceName" -ForegroundColor Green
    } else {
        Write-Host "Service already running: $ServiceName" -ForegroundColor Cyan
    }
}

function Stop-ServiceSafe {
    param([string]$ServiceName)
    $service = Get-Service -Name $ServiceName
    if ($service.Status -eq "Running") {
        Stop-Service -Name $ServiceName
        Write-Host "Stopped service: $ServiceName" -ForegroundColor Yellow
    } else {
        Write-Host "Service already stopped: $ServiceName" -ForegroundColor Cyan
    }
}

# Network utilities
function Show-NetworkInfo {
    Write-Host "=== Network Configuration ===" -ForegroundColor Cyan
    Get-NetIPConfiguration | Format-Table InterfaceAlias, IPv4Address, IPv6Address -AutoSize

    Write-Host ""
    Write-Host "=== Active Connections ===" -ForegroundColor Cyan
    Get-NetTCPConnection | Where-Object State -eq "Listen" |
        Format-Table LocalAddress, LocalPort, State -AutoSize
}

function Test-Port {
    param(
        [string]$ComputerName = "localhost",
        [int]$Port = 80
    )
    $result = Test-NetConnection -ComputerName $ComputerName -Port $Port
    if ($result.TcpTestSucceeded) {
        Write-Host "Port $Port on $ComputerName is open" -ForegroundColor Green
    } else {
        Write-Host "Port $Port on $ComputerName is closed or unreachable" -ForegroundColor Red
    }
    return $result.TcpTestSucceeded
}

# System performance monitoring
function Show-SystemPerformance {
    Write-Host "=== CPU Usage ===" -ForegroundColor Cyan
    Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average |
        Select-Object @{Name="Avg CPU Usage"; Expression={"{0:P}" -f ($_.Average / 100)}}

    Write-Host ""
    Write-Host "=== Memory Usage ===" -ForegroundColor Cyan
    $memory = Get-WmiObject Win32_OperatingSystem
    $usedMemory = $memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory
    $memoryUsage = ($usedMemory / $memory.TotalVisibleMemorySize) * 100
    Write-Host "Used: $([math]::Round($usedMemory / 1MB, 2)) GB / $([math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)) GB ($([math]::Round($memoryUsage, 2))%)"

    Write-Host ""
    Write-Host "=== Disk Usage ===" -ForegroundColor Cyan
    Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
        $sizeGB = [math]::Round($_.Size / 1GB, 2)
        $freeGB = [math]::Round($_.FreeSpace / 1GB, 2)
        $usedGB = $sizeGB - $freeGB
        $usagePercent = [math]::Round(($usedGB / $sizeGB) * 100, 2)
        Write-Host "$($_.DeviceID): $usedGB GB / $sizeGB GB ($usagePercent%)"
    }
}

# Windows-specific utilities
function Show-WindowsUpdates {
    Write-Host "=== Installed Windows Updates ===" -ForegroundColor Cyan
    Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10 |
        Format-Table HotFixID, Description, InstalledOn -AutoSize
}

function Get-SystemUptime {
    $uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    Write-Host "System uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" -ForegroundColor Green
}

function Show-EventLog {
    param(
        [string]$LogName = "Application",
        [int]$Newest = 10
    )
    Get-EventLog -LogName $LogName -Newest $Newest | Format-Table TimeGenerated, EntryType, Source, Message -AutoSize
}

# System cleanup utilities
function Clear-TempFiles {
    $tempPaths = @("$env:TEMP", "$env:TMP", "$env:LOCALAPPDATA\Temp")
    $totalCleaned = 0

    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            $before = (Get-ChildItem $path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
            Get-ChildItem $path -Recurse -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
            $after = (Get-ChildItem $path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
            $cleaned = $before - $after
            if ($cleaned -gt 0) {
                $totalCleaned += $cleaned
                Write-Host "Cleaned $([math]::Round($cleaned / 1MB, 2)) MB from $path" -ForegroundColor Green
            }
        }
    }

    Write-Host "Total cleaned: $([math]::Round($totalCleaned / 1MB, 2)) MB" -ForegroundColor Cyan
}

# Registry helpers
function Get-RegistryValue {
    param(
        [string]$Path,
        [string]$Name
    )
    Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
}

function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "String"
    )
    if (!(Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type
}

# System aliases
Set-Alias -Name top -Value Show-TopProcesses -ErrorAction SilentlyContinue
Set-Alias -Name kill -Value Kill-ProcessByName -ErrorAction SilentlyContinue
Set-Alias -Name services -Value Show-ServiceStatus -ErrorAction SilentlyContinue
Set-Alias -Name netinfo -Value Show-NetworkInfo -ErrorAction SilentlyContinue
Set-Alias -Name perf -Value Show-SystemPerformance -ErrorAction SilentlyContinue
Set-Alias -Name uptime -Value Get-SystemUptime -ErrorAction SilentlyContinue
Set-Alias -Name clean-temp -Value Clear-TempFiles -ErrorAction SilentlyContinue

# ============================================
# Environment Setup
# ============================================

# Set better encoding for Claude Code compatibility
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Better error formatting - more concise for Claude
$ErrorView = 'ConciseView'

# Disable progress bars for cleaner output
$ProgressPreference = 'SilentlyContinue'

# Set default parameters for cleaner output
$PSDefaultParameterValues = @{
    'Out-Default:OutVariable' = 'LastResult'
    'Format-Table:AutoSize' = $true
}

# ============================================
# Productivity Enhancements
# ============================================

# Enhanced directory bookmarks
$global:DirectoryBookmarks = @{}
$bookmarksFile = "$env:APPDATA\PowerShell\bookmarks.json"

# Load bookmarks from file
if (Test-Path $bookmarksFile) {
    try {
        $global:DirectoryBookmarks = Get-Content $bookmarksFile | ConvertFrom-Json -AsHashtable
    } catch {
        $global:DirectoryBookmarks = @{}
    }
}

function Set-DirectoryBookmark {
    param([string]$Name, [string]$Path = (Get-Location).Path)
    $global:DirectoryBookmarks[$Name] = $Path
    $global:DirectoryBookmarks | ConvertTo-Json | Set-Content $bookmarksFile
    Write-Host "Bookmark set: $Name -> $Path" -ForegroundColor Green
}

function Get-DirectoryBookmark {
    param([string]$Name)
    if ($global:DirectoryBookmarks.ContainsKey($Name)) {
        Set-Location $global:DirectoryBookmarks[$Name]
    } else {
        Write-Host "Bookmark not found: $Name" -ForegroundColor Red
        Write-Host "Available bookmarks:" -ForegroundColor Yellow
        $global:DirectoryBookmarks.Keys | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
    }
}

function Show-DirectoryBookmarks {
    if ($global:DirectoryBookmarks.Count -eq 0) {
        Write-Host "No bookmarks set" -ForegroundColor Yellow
        return
    }

    Write-Host "=== Directory Bookmarks ===" -ForegroundColor Cyan
    foreach ($bookmark in $global:DirectoryBookmarks.GetEnumerator()) {
        $current = if ($bookmark.Value -eq (Get-Location).Path) { " (current)" } else { "" }
        Write-Host "  $($bookmark.Key): $($bookmark.Value)$current" -ForegroundColor White
    }
}

# Enhanced history management
function Show-CommandHistory {
    param([int]$Count = 20)
    Get-History | Select-Object -Last $Count | Format-Table Id, CommandLine -AutoSize
}

function Search-CommandHistory {
    param([string]$Pattern)
    Get-History | Where-Object { $_.CommandLine -match $Pattern } | Format-Table Id, CommandLine -AutoSize
}

# Quick file operations with safety
function New-File {
    param([string]$Path)
    if (Test-Path $Path) {
        $overwrite = Read-Host "File exists. Overwrite? (y/N)"
        if ($overwrite -ne 'y') { return }
    }
    New-Item -ItemType File -Path $Path -Force | Out-Null
    Write-Host "Created: $Path" -ForegroundColor Green
}

function New-Directory {
    param([string]$Path)
    if (Test-Path $Path) {
        Write-Host "Directory exists: $Path" -ForegroundColor Yellow
        return
    }
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Write-Host "Created directory: $Path" -ForegroundColor Green
}

# Enhanced tab completion for bookmarks
if (Get-Module -Name PSReadLine) {
    Set-PSReadLineKeyHandler -Key Ctrl+B `
        -BriefDescription ShowBookmarks `
        -Description "Show directory bookmarks" `
        -ScriptBlock {
            Show-DirectoryBookmarks
        }
}

# ============================================
# Safety Features and Confirmations
# ============================================

# Safe versions of dangerous commands
function Remove-ItemSafe {
    param(
        [string]$Path,
        [switch]$Recurse = $false
    )

    if (!(Test-Path $Path)) {
        Write-Host "Path not found: $Path" -ForegroundColor Red
        return
    }

    $item = Get-Item $Path
    $isDirectory = $item -is [System.IO.DirectoryInfo]
    $recurseText = if ($Recurse -and $isDirectory) { " recursively" } else { "" }

    Write-Host "Delete: $($item.FullName)$recurseText" -ForegroundColor Red
    $confirm = Read-Host "Are you sure? (y/N)"
    if ($confirm -eq 'y') {
        if ($Recurse -and $isDirectory) {
            Remove-Item -Path $Path -Recurse -Force
        } else {
            Remove-Item -Path $Path -Force
        }
        Write-Host "Deleted successfully" -ForegroundColor Green
    } else {
        Write-Host "Operation cancelled" -ForegroundColor Yellow
    }
}

function Clear-RecycleBin {
    $confirm = Read-Host "Clear recycle bin? This cannot be undone. (y/N)"
    if ($confirm -eq 'y') {
        Clear-RecycleBin -Force
        Write-Host "Recycle bin cleared" -ForegroundColor Green
    }
}

# Backup function
function Backup-File {
    param(
        [string]$Path,
        [string]$BackupPath = ""
    )

    if (!(Test-Path $Path)) {
        Write-Host "File not found: $Path" -ForegroundColor Red
        return
    }

    if ($BackupPath -eq "") {
        $file = Get-Item $Path
        $backupName = "$($file.BaseName).backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')$($file.Extension)"
        $BackupPath = Join-Path $file.DirectoryName $backupName
    }

    Copy-Item -Path $Path -Destination $BackupPath -Force
    Write-Host "Backup created: $BackupPath" -ForegroundColor Green
}

# ============================================
# Enhanced UI/UX Features
# ============================================

# Progress indicator for long operations
function Show-Progress {
    param(
        [string]$Activity,
        [string]$Status = "",
        [int]$PercentComplete = -1
    )

    if ($PercentComplete -eq -1) {
        Write-Host "[$([char]0x25B6)] $Activity" -ForegroundColor Cyan -NoNewline
        if ($Status) { Write-Host " - $Status" -ForegroundColor Gray }
        else { Write-Host "" }
    } else {
        $progressBar = "[$([char]0x25A0)" * ($PercentComplete / 10) + " " * (10 - $PercentComplete / 10) + "]"
        Write-Host "$progressBar $PercentComplete% $Activity" -ForegroundColor Cyan -NoNewline
        if ($Status) { Write-Host " - $Status" -ForegroundColor Gray }
        else { Write-Host "" }
    }
}

# Color-coded file size display
function Get-FileSizeColor {
    param([double]$SizeInBytes)

    if ($SizeInBytes -gt 1GB) { return "Red" }
    elseif ($SizeInBytes -gt 100MB) { return "Yellow" }
    elseif ($SizeInBytes -gt 10MB) { return "Magenta" }
    else { return "Green" }
}

function Format-FileSize {
    param([double]$SizeInBytes)

    $color = Get-FileSizeColor -SizeInBytes $SizeInBytes

    if ($SizeInBytes -gt 1GB) {
        $size = "{0:N2} GB" -f ($SizeInBytes / 1GB)
    }
    elseif ($SizeInBytes -gt 1MB) {
        $size = "{0:N2} MB" -f ($SizeInBytes / 1MB)
    }
    elseif ($SizeInBytes -gt 1KB) {
        $size = "{0:N2} KB" -f ($SizeInBytes / 1KB)
    }
    else {
        $size = "{0} B" -f $SizeInBytes
    }

    return @{Size = $size; Color = $color}
}

# Enhanced file listing with colors and metadata
function Show-FilesDetailed {
    param([string]$Path = ".")

    Get-ChildItem $Path -Force | ForEach-Object {
        $fileSize = Format-FileSize -SizeInBytes $_.Length
        $lastWrite = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm")

        # Color coding based on file type
        $color = switch ($_.Extension) {
            ".exe" { "Red" }
            ".dll" { "Cyan" }
            ".ps1" { "Green" }
            ".md" { "Yellow" }
            ".json" { "Magenta" }
            ".log" { "DarkGray" }
            Default { "White" }
        }

        Write-Host ("{0,-4} {1,-12} {2,-8}" -f $_.Mode, $lastWrite, $fileSize.Size) -NoNewline -ForegroundColor DarkGray
        Write-Host $_.Name -ForegroundColor $color
    }
}

# Notification system for long-running tasks
function Invoke-WithNotification {
    param(
        [ScriptBlock]$ScriptBlock,
        [string]$TaskName = "Task"
    )

    $startTime = Get-Date
    Show-Progress -Activity "$TaskName starting..."

    try {
        & $ScriptBlock
        $endTime = Get-Date
        $duration = $endTime - $startTime

        if ($duration.TotalSeconds -gt 5) {
            Show-Progress -Activity "$TaskName completed" -Status "($([math]::Round($duration.TotalSeconds, 1))s)"
            # Optional: Add sound notification here
            # [console]::beep(800,300)
        } else {
            Write-Host "✓ $TaskName completed" -ForegroundColor Green
        }
    }
    catch {
        Show-Progress -Activity "$TaskName failed" -Status $_.Exception.Message
        Write-Host "✗ $TaskName failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Enhanced aliases with safety
Set-Alias -Name rm -Value Remove-ItemSafe -ErrorAction SilentlyContinue
Set-Alias -Name mkdir -Value New-Directory -ErrorAction SilentlyContinue
Set-Alias -Name touch -Value New-File -ErrorAction SilentlyContinue
Set-Alias -Name bookmarks -Value Show-DirectoryBookmarks -ErrorAction SilentlyContinue
Set-Alias -Name hist -Value Show-CommandHistory -ErrorAction SilentlyContinue
Set-Alias -Name search-hist -Value Search-CommandHistory -ErrorAction SilentlyContinue
Set-Alias -Name ls-detailed -Value Show-FilesDetailed -ErrorAction SilentlyContinue

# Clear screen on startup (optional - comment out if you don't want this)
# Clear-Host

# ============================================
# Welcome Message
# ============================================
Write-Host ""
Write-Host "PowerShell $($PSVersionTable.PSVersion.ToString())" -ForegroundColor Cyan
Write-Host "Optimized for Claude Code" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Quick commands: " -NoNewline -ForegroundColor DarkGray
Write-Host "qs" -NoNewline -ForegroundColor Yellow
Write-Host " (quick status) | " -NoNewline -ForegroundColor DarkGray
Write-Host "tree" -NoNewline -ForegroundColor Yellow
Write-Host " (structure) | " -NoNewline -ForegroundColor DarkGray
Write-Host "test" -NoNewline -ForegroundColor Yellow
Write-Host "/" -NoNewline -ForegroundColor DarkGray
Write-Host "build" -NoNewline -ForegroundColor Yellow
Write-Host " (run tests/build)" -ForegroundColor DarkGray
Write-Host ""
