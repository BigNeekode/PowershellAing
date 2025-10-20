# ============================================
# 🚀 Enhanced PowerShell Profile
# ============================================
# 🎨 Visual enhancements with icons, colors, and modern UI
# 🛠️  Optimized for Claude Code with clean output

# Import modules with auto-installation and visual feedback
Import-Module PSReadLine -ErrorAction SilentlyContinue

# ============================================
# Enhanced Module Management
# ============================================

# 🚀 Auto-install and import UX enhancement modules
$modulesToInstall = @(
    # Core functionality
    @{Name = "PSReadLine"; RequiredVersion = "2.2.6"},
    @{Name = "Terminal-Icons"; RequiredVersion = "0.11.0"},
    @{Name = "posh-git"; RequiredVersion = "1.1.0"},

    # UX Enhancement modules
    @{Name = "PSWriteColor"; RequiredVersion = "1.0.1"},           # Enhanced text coloring
    @{Name = "PSFzf"; RequiredVersion = "2.5.15"},                # Fuzzy finder
    @{Name = "PSScriptAnalyzer"; RequiredVersion = "1.21.0"},     # Code analysis
    @{Name = "ImportExcel"; RequiredVersion = "7.8.6"},           # Excel file handling

    # Optional but useful modules (install if available)
    @{Name = "BurntToast"; RequiredVersion = "0.8.5"},            # Windows notifications
    @{Name = "PSMenu"; RequiredVersion = "1.4.1"},                # Interactive menus
    @{Name = "PSCalendar"; RequiredVersion = "1.0.0"}             # Calendar utilities
)

foreach ($module in $modulesToInstall) {
    $moduleName = $module.Name
    $requiredVersion = $module.RequiredVersion

    if (-not (Get-Module -Name $moduleName -ListAvailable)) {
        Write-Host "📦 Installing module: " -ForegroundColor Yellow -NoNewline
        Write-Host "$moduleName" -ForegroundColor White -NoNewline
        Write-Host " (v$requiredVersion)..." -ForegroundColor DarkGray
        try {
            Install-Module -Name $moduleName -RequiredVersion $requiredVersion -Scope CurrentUser -Force -ErrorAction Stop
            Show-Success "$moduleName installed successfully"
        }
        catch {
            Show-Error "Failed to install $moduleName`: $($_.Exception.Message)"
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

    # 🎨 Enhanced Colors for Better Visual Experience
    Set-PSReadLineOption -Colors @{
        Command            = 'Yellow'          # Commands in bright yellow
        Comment            = 'DarkGreen'       # Comments in subtle green
        ContinuationPrompt = 'DarkGray'        # Line continuation
        Default            = 'White'           # Default text
        Emphasis           = 'Cyan'            # Emphasized text
        Error              = 'Red'             # Error text
        InlinePrediction   = 'DarkGray'        # Predictive suggestions
        Keyword            = 'Magenta'         # Keywords like if, for, etc.
        ListPrediction     = 'DarkCyan'        # List predictions
        Member             = 'DarkCyan'        # Object members
        Number             = 'DarkCyan'        # Numbers
        Operator           = 'DarkMagenta'     # Operators like +, -, =, etc.
        Parameter          = 'DarkGray'        # Parameters
        Selection          = 'DarkGray'        # Selected text
        String             = 'Green'           # Strings in quotes
        Type               = 'DarkBlue'        # Types like [string], [int]
        Variable           = 'DarkYellow'      # Variables like $var
    }
}

# ============================================
# 🎨 Enhanced Visual Prompt
# ============================================
function prompt {
    $ESC = [char]27
    $location = Get-Location

    # Visual indicators with Unicode symbols
    $homeIcon = "🏠"
    $folderIcon = "📁"
    $gitIcon = "🌿"
    $modifiedIcon = "✏️"
    $cleanIcon = "✅"

    # Get git branch if in a git repo
    $gitBranch = ""
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $branch = git branch --show-current 2>$null
        if ($branch) {
            $gitStatus = git status --porcelain 2>$null
            $statusIcon = if ($gitStatus) { $modifiedIcon } else { $cleanIcon }
            $gitBranch = "$ESC[95m $gitIcon $branch $statusIcon$ESC[0m"
        }
    }

    # Enhanced path display with icons
    $pathParts = $location.Path.Split([IO.Path]::DirectorySeparatorChar)
    $isHome = $location.Path -eq $env:USERPROFILE

    if ($isHome) {
        $pathDisplay = "$ESC[94m$homeIcon $($env:USERNAME)'s Home$ESC[0m"
    } else {
        $parentPath = [IO.Path]::GetDirectoryName($location.Path)
        $currentFolder = [IO.Path]::GetFileName($location.Path)
        $pathDisplay = "$ESC[96m$parentPath$ESC[0m$ESC[93m$([char]0x2F)$currentFolder$ESC[0m"
    }

    # Enhanced user display with visual flair
    $userIcon = "👤"
    $computerIcon = "💻"
    $user = "$ESC[92m$userIcon $env:USERNAME$ESC[0m"
    $computer = "$ESC[90m$computerIcon $env:COMPUTERNAME$ESC[0m"

    # Build enhanced prompt with better layout
    Write-Host ""
    Write-Host "┌─ $user $computer" -ForegroundColor DarkGray
    Write-Host "│" -ForegroundColor DarkGray -NoNewline
    Write-Host "  $pathDisplay$gitBranch" -NoNewline
    Write-Host ""
    Write-Host "└─" -ForegroundColor DarkGray -NoNewline

    # Enhanced prompt symbol with colors
    $promptSymbol = "$ESC[93m▶$ESC[0m"
    return " $promptSymbol "
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

# 🚀 Enhanced Quick Status Display
# ============================================
function Show-QuickStatus {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor DarkCyan
    Write-Host "║                    📊 Quick Status                       ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor DarkCyan
    Write-Host ""

    $currentPath = Get-Location

    # Enhanced location display
    Write-Host "📍 Location:" -ForegroundColor Yellow -NoNewline
    Write-Host " $currentPath" -ForegroundColor White

    # Enhanced Git status with visual indicators
    if (Test-Path .git) {
        $branch = git branch --show-current 2>$null
        $status = git status --porcelain 2>$null
        $statusIcon = if ($status) { "📝" } else { "✅" }
        $statusText = if ($status) { "modified files" } else { "clean" }
        $statusColor = if ($status) { "Yellow" } else { "Green" }

        Write-Host "🌿 Git:" -ForegroundColor Yellow -NoNewline
        Write-Host " $branch" -ForegroundColor Magenta -NoNewline
        Write-Host " ($statusIcon $statusText)" -ForegroundColor $statusColor
    } else {
        Write-Host "🌿 Git:" -ForegroundColor Yellow -NoNewline
        Write-Host " No repository" -ForegroundColor Red
    }

    # Enhanced project type detection with icons
    $projectType = ""
    $projectIcon = ""
    if (Test-Path "package.json") {
        $projectIcon = "🟢"
        $projectType = "Node.js/npm"
    }
    elseif (Test-Path "requirements.txt") {
        $projectIcon = "🐍"
        $projectType = "Python"
    }
    elseif (Test-Path "Cargo.toml") {
        $projectIcon = "🦀"
        $projectType = "Rust"
    }
    elseif (Get-ChildItem -Filter "*.csproj") {
        $projectIcon = "💎"
        $projectType = ".NET/C#"
    }
    elseif (Test-Path "go.mod") {
        $projectIcon = "🐹"
        $projectType = "Go"
    }
    elseif (Test-Path "composer.json") {
        $projectIcon = "🐘"
        $projectType = "PHP/Composer"
    }
    elseif (Test-Path "Gemfile") {
        $projectIcon = "💎"
        $projectType = "Ruby"
    }
    else {
        $projectIcon = "📁"
        $projectType = "Generic/Unknown"
    }

    Write-Host "$projectIcon Project:" -ForegroundColor Yellow -NoNewline
    Write-Host " $projectType" -ForegroundColor $(if ($projectType -eq "Generic/Unknown") { "DarkGray" } else { "Green" })

    # Enhanced recent files with icons and better formatting
    $recentFiles = Get-ChildItem -File -Recurse -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 5

    if ($recentFiles) {
        Write-Host ""
        Write-Host "🕐 Recently Modified:" -ForegroundColor Yellow
        Write-Host "─" * 50 -ForegroundColor DarkGray

        $recentFiles | ForEach-Object {
            $relPath = $_.FullName.Replace($currentPath.Path, ".").Replace("\", "/")
            $timeSince = New-TimeSpan -Start $_.LastWriteTime -End (Get-Date)
            $timeStr = if ($timeSince.TotalMinutes -lt 60) {
                "{0:N0}m ago" -f $timeSince.TotalMinutes
            } elseif ($timeSince.TotalHours -lt 24) {
                "{0:N0}h ago" -f $timeSince.TotalHours
            } else {
                "{0:N0}d ago" -f $timeSince.TotalDays
            }

            # Get file extension for icon
            $ext = $_.Extension
            $fileIcon = switch ($ext) {
                ".ps1" { "🔷" }
                ".md" { "📝" }
                ".json" { "⚙️" }
                ".js" { "📜" }
                ".ts" { "📘" }
                ".py" { "🐍" }
                ".cs" { "💎" }
                ".html" { "🌐" }
                ".css" { "🎨" }
                Default { "📄" }
            }

            Write-Host "  $fileIcon " -NoNewline
            Write-Host "$relPath" -ForegroundColor White -NoNewline
            Write-Host " ($timeStr)" -ForegroundColor DarkGray
        }
    }

    Write-Host ""
    Write-Host "═" * 60 -ForegroundColor DarkCyan
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

# 🎯 Enhanced Progress Indicators
# ============================================
function Show-Progress {
    param(
        [string]$Activity,
        [string]$Status = "",
        [int]$PercentComplete = -1
    )

    if ($PercentComplete -eq -1) {
        $spinner = @("⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏")
        $spinnerIndex = (Get-Date).Millisecond % $spinner.Length
        Write-Host "[$($spinner[$spinnerIndex])] " -ForegroundColor Cyan -NoNewline
        Write-Host "$Activity" -ForegroundColor White -NoNewline
        if ($Status) { Write-Host " - $Status" -ForegroundColor DarkGray }
        else { Write-Host "" }
    } else {
        $filled = [math]::Floor($PercentComplete / 10)
        $empty = 10 - $filled
        $progressBar = "█" * $filled + "░" * $empty
        Write-Host "[$progressBar] " -ForegroundColor $(if ($PercentComplete -lt 30) { "Red" } elseif ($PercentComplete -lt 70) { "Yellow" } else { "Green" }) -NoNewline
        Write-Host "$PercentComplete% " -ForegroundColor White -NoNewline
        Write-Host "$Activity" -ForegroundColor Cyan -NoNewline
        if ($Status) { Write-Host " - $Status" -ForegroundColor DarkGray }
        else { Write-Host "" }
    }
}

# Visual status indicators
function Show-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Show-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Show-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Show-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
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

# 🎨 Enhanced File Listing with Visual Indicators
# ============================================
function Show-FilesDetailed {
    param([string]$Path = ".")

    Write-Host "📂 Contents of: $(Resolve-Path $Path)" -ForegroundColor Cyan
    Write-Host "═" * 60 -ForegroundColor DarkCyan
    Write-Host ""

    Get-ChildItem $Path -Force | ForEach-Object {
        $fileSize = Format-FileSize -SizeInBytes $_.Length
        $lastWrite = $_.LastWriteTime.ToString("MM/dd HH:mm")
        $isHidden = $_.Attributes -band [System.IO.FileAttributes]::Hidden

        # Enhanced file type detection with icons
        $fileIcon = switch ($_.Extension) {
            ".exe" { "⚙️" }
            ".dll" { "📚" }
            ".ps1" { "🔷" }
            ".md" { "📝" }
            ".json" { "⚙️" }
            ".log" { "📜" }
            ".txt" { "📄" }
            ".jpg" { "🖼️" }
            ".png" { "🖼️" }
            ".gif" { "🖼️" }
            ".zip" { "📦" }
            ".rar" { "📦" }
            ".7z" { "📦" }
            ".pdf" { "📕" }
            ".doc" { "📄" }
            ".docx" { "📄" }
            ".xls" { "📊" }
            ".xlsx" { "📊" }
            ".mp3" { "🎵" }
            ".mp4" { "🎥" }
            ".avi" { "🎥" }
            ".mkv" { "🎥" }
            ".html" { "🌐" }
            ".css" { "🎨" }
            ".js" { "📜" }
            ".ts" { "📘" }
            ".py" { "🐍" }
            ".java" { "☕" }
            ".cpp" { "⚙️" }
            ".c" { "⚙️" }
            ".h" { "⚙️" }
            ".cs" { "💎" }
            ".php" { "🐘" }
            ".rb" { "💎" }
            ".go" { "🐹" }
            ".rs" { "🦀" }
            ".sh" { "📜" }
            ".bat" { "⚙️" }
            ".cmd" { "⚙️" }
            ".yml" { "⚙️" }
            ".yaml" { "⚙️" }
            ".xml" { "⚙️" }
            ".sql" { "🗃️" }
            ".db" { "🗃️" }
            ".sqlite" { "🗃️" }
            Default {
                if ($_.PSIsContainer) { "📁" } else { "📄" }
            }
        }

        # Color coding based on file type
        $color = switch ($_.Extension) {
            ".exe" { "Red" }
            ".dll" { "Cyan" }
            ".ps1" { "Green" }
            ".md" { "Yellow" }
            ".json" { "Magenta" }
            ".log" { "DarkGray" }
            ".txt" { "White" }
            ".html" { "DarkRed" }
            ".css" { "DarkBlue" }
            ".js" { "DarkYellow" }
            ".ts" { "Blue" }
            ".py" { "DarkGreen" }
            ".jpg" { "Magenta" }
            ".png" { "Magenta" }
            ".mp3" { "DarkMagenta" }
            ".mp4" { "DarkMagenta" }
            ".pdf" { "DarkRed" }
            ".zip" { "Green" }
            ".sql" { "DarkCyan" }
            Default { "White" }
        }

        # Hidden file indicator
        $hiddenIndicator = if ($isHidden) { "🔒" } else { "" }

        # Format output with better alignment
        $namePart = "$fileIcon$hiddenIndicator $($_.Name)"
        Write-Host ("{0,-5} {1,-12} {2,-10}" -f $_.Mode, $lastWrite, $fileSize.Size) -ForegroundColor DarkGray -NoNewline
        Write-Host $namePart -ForegroundColor $color
    }

    Write-Host ""
    Write-Host "═" * 60 -ForegroundColor DarkCyan
    $totalSize = (Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    $sizeInfo = Format-FileSize -SizeInBytes $totalSize
    Write-Host "📊 Total size: $($sizeInfo.Size)" -ForegroundColor Cyan
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
# 🎉 Enhanced Welcome Screen
# ============================================
function Show-WelcomeScreen {
    Clear-Host

    # ASCII Art Header
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor DarkCyan
    Write-Host "║                 🚀 Welcome to PowerShell                ║" -ForegroundColor Cyan
    Write-Host "║              Enhanced Visual Experience 🖼️              ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor DarkCyan
    Write-Host ""

    # System Info with Visual Flair
    $psVersion = $PSVersionTable.PSVersion.ToString()
    $currentTime = Get-Date -Format "dddd, MMMM dd, yyyy HH:mm"
    Write-Host "┌─ 💻 System Information" -ForegroundColor DarkGray
    Write-Host "│" -ForegroundColor DarkGray
    Write-Host "│  📅 $currentTime" -ForegroundColor White
    Write-Host "│  🟢 PowerShell $psVersion" -ForegroundColor Green
    Write-Host "│  👤 User: $env:USERNAME" -ForegroundColor Yellow
    Write-Host "│  📁 Location: $(Get-Location)" -ForegroundColor Cyan
    Write-Host "│" -ForegroundColor DarkGray

    # Quick Commands Section
    Write-Host "├─ ⚡ Quick Commands" -ForegroundColor DarkGray
    Write-Host "│" -ForegroundColor DarkGray
    Write-Host "│  📊 " -NoNewline -ForegroundColor DarkGray
    Write-Host "qs" -ForegroundColor Yellow -NoNewline
    Write-Host "     Quick project status" -ForegroundColor DarkGray
    Write-Host "│  🌳 " -NoNewline -ForegroundColor DarkGray
    Write-Host "tree" -ForegroundColor Yellow -NoNewline
    Write-Host "   Project structure" -ForegroundColor DarkGray
    Write-Host "│  🧪 " -NoNewline -ForegroundColor DarkGray
    Write-Host "test" -ForegroundColor Yellow -NoNewline
    Write-Host "   Run tests" -ForegroundColor DarkGray
    Write-Host "│  🔨 " -NoNewline -ForegroundColor DarkGray
    Write-Host "build" -ForegroundColor Yellow -NoNewline
    Write-Host "  Build project" -ForegroundColor DarkGray
    Write-Host "│  🔍 " -NoNewline -ForegroundColor DarkGray
    Write-Host "grep" -ForegroundColor Yellow -NoNewline
    Write-Host "   Search in files" -ForegroundColor DarkGray
    Write-Host "│" -ForegroundColor DarkGray

    # Tips Section
    Write-Host "├─ 💡 Pro Tips" -ForegroundColor DarkGray
    Write-Host "│" -ForegroundColor DarkGray
    Write-Host "│  🎨 " -NoNewline -ForegroundColor DarkGray
    Write-Host "Visual enhancements active!" -ForegroundColor Green
    Write-Host "│  ⚡ " -NoNewline -ForegroundColor DarkGray
    Write-Host "Press Tab for autocompletion" -ForegroundColor Cyan
    Write-Host "│  ⬆️⬇️ " -NoNewline -ForegroundColor DarkGray
    Write-Host "Use arrow keys to search history" -ForegroundColor Cyan
    Write-Host "│  📝 " -NoNewline -ForegroundColor DarkGray
    Write-Host "Type 'help' for more commands" -ForegroundColor Cyan
    Write-Host "│" -ForegroundColor DarkGray
    Write-Host "└─ Ready to code! 🚀" -ForegroundColor Green
    Write-Host ""
}

# ============================================
# 🧩 Enhanced UX Modules Integration
# ============================================

# Enhanced Text Formatting with PSWriteColor
if (Get-Module -Name PSWriteColor -ListAvailable) {
    Import-Module PSWriteColor

    # Enhanced message functions with better colors
    function Show-EnhancedMessage {
        param(
            [string]$Message,
            [string]$Status = "Info"
        )

        switch ($Status) {
            "Success" { Write-Color -Text $Message -Color Green -StartTab 2 }
            "Error" { Write-Color -Text $Message -Color Red -StartTab 2 }
            "Warning" { Write-Color -Text $Message -Color Yellow -StartTab 2 }
            "Info" { Write-Color -Text $Message -Color Cyan -StartTab 2 }
            Default { Write-Color -Text $Message -Color White -StartTab 2 }
        }
    }

    # Rainbow text for fun
    function Show-RainbowText {
        param([string]$Text)
        $colors = @("Red", "Yellow", "Green", "Cyan", "Blue", "Magenta")
        $chars = $Text.ToCharArray()
        for ($i = 0; $i -lt $chars.Length; $i++) {
            Write-Color -Text $chars[$i] -Color $colors[$i % $colors.Length] -NoNewLine
        }
        Write-Host ""
    }
}

# ============================================
# 🍱 Interactive Menu System
# ============================================

# Enhanced project launcher with visual menu
function Show-ProjectMenu {
    Write-Host "🚀 Project Launcher" -ForegroundColor Cyan
    Write-Host "═" * 50 -ForegroundColor DarkCyan
    Write-Host ""

    $options = @(
        @{Name = "📊 Quick Status"; Command = "Show-QuickStatus"},
        @{Name = "🌳 Project Tree"; Command = "Show-Tree"},
        @{Name = "🌿 Git Status"; Command = "Show-GitStatus"},
        @{Name = "🧪 Run Tests"; Command = "Run-Tests"},
        @{Name = "🔨 Build Project"; Command = "Run-Build"},
        @{Name = "📦 Install Packages"; Command = "Install-Packages"},
        @{Name = "🔍 Search Files"; Command = "Search-Content"},
        @{Name = "⚙️  Settings"; Command = "Edit-Profile"}
    )

    for ($i = 0; $i -lt $options.Count; $i++) {
        Write-Host ("{0,2}. {1}" -f ($i + 1), $options[$i].Name) -ForegroundColor Yellow
    }

    Write-Host ""
    $choice = Read-Host "Select option (1-$($options.Count)) or 'q' to quit"

    if ($choice -ne 'q' -and $choice -match '^\d+$' -and $choice -le $options.Count) {
        $selected = $options[$choice - 1]
        Write-Host "Executing: $($selected.Name)" -ForegroundColor Green
        Invoke-Expression $selected.Command
    }
}

# ============================================
# 🎯 Fuzzy Finding with PSFzf
# ============================================

if (Get-Module -Name PSFzf -ListAvailable) {
    Import-Module PSFzf

    # Enhanced file finder with preview
    function Find-FileFuzzy {
        param([string]$Path = ".")

        $result = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
            Invoke-Fzf -Preview 'Get-Content {} -Head 10' -PreviewWindow 'right:50%:wrap'

        if ($result) {
            Write-Host "Selected: " -ForegroundColor Yellow -NoNewline
            Write-Host $result.FullName -ForegroundColor Green
            return $result
        }
    }

    # Enhanced directory finder
    function Find-DirectoryFuzzy {
        param([string]$Path = ".")

        $result = Get-ChildItem -Path $Path -Recurse -Directory -ErrorAction SilentlyContinue |
            Invoke-Fzf -Preview 'Get-ChildItem {} -Force | Format-Table -AutoSize'

        if ($result) {
            Write-Host "Selected directory: " -ForegroundColor Yellow -NoNewline
            Write-Host $result.FullName -ForegroundColor Green
            Set-Location $result.FullName
        }
    }

    # Enhanced history search
    function Search-HistoryFuzzy {
        $history = Get-History | Select-Object -ExpandProperty CommandLine
        $result = $history | Invoke-Fzf -Preview 'Write-Host "Command: {}"' -PreviewWindow 'right:50%:wrap'

        if ($result) {
            Write-Host "Executing: " -ForegroundColor Yellow -NoNewline
            Write-Host $result -ForegroundColor Green
            Invoke-Expression $result
        }
    }
}

# ============================================
# 🔔 Toast Notifications for Windows
# ============================================

if (Get-Module -Name BurntToast -ListAvailable) {
    Import-Module BurntToast

    # Toast notification for long operations
    function Show-ToastNotification {
        param(
            [string]$Title = "PowerShell",
            [string]$Message = "Operation completed",
            [string]$Sound = "Default"
        )

        try {
            New-BurntToastNotification -Text $Title, $Message -Sound $Sound -AppLogo "$env:windir\System32\WindowsPowerShell\v1.0\powershell.exe"
        }
        catch {
            Write-Host "🔔 Notification: $Title - $Message" -ForegroundColor Cyan
        }
    }

    # Enhanced long operation wrapper with notifications
    function Invoke-WithNotification {
        param(
            [ScriptBlock]$ScriptBlock,
            [string]$TaskName = "Task",
            [switch]$NotifyOnComplete = $true
        )

        $startTime = Get-Date
        Show-Progress -Activity "$TaskName starting..."

        try {
            & $ScriptBlock
            $endTime = Get-Date
            $duration = $endTime - $startTime

            if ($duration.TotalSeconds -gt 3 -and $NotifyOnComplete) {
                Show-ToastNotification -Title "Task Completed" -Message "$TaskName finished in $([math]::Round($duration.TotalSeconds, 1))s"
            }

            Show-Success "$TaskName completed ($([math]::Round($duration.TotalSeconds, 1))s)"
        }
        catch {
            if ($NotifyOnComplete) {
                Show-ToastNotification -Title "Task Failed" -Message "$TaskName encountered an error"
            }
            Show-Error "$TaskName failed: $($_.Exception.Message)"
        }
    }
}

# ============================================
# 📊 Excel & CSV Utilities
# ============================================

if (Get-Module -Name ImportExcel -ListAvailable) {
    Import-Module ImportExcel

    # Export data to Excel with formatting
    function Export-DataToExcel {
        param(
            [Parameter(ValueFromPipeline = $true)]
            [object[]]$Data,
            [string]$Path = "output.xlsx",
            [string]$SheetName = "Data"
        )

        Begin {
            $dataArray = @()
        }

        Process {
            $dataArray += $Data
        }

        End {
            if ($dataArray.Count -gt 0) {
                $dataArray | Export-Excel -Path $Path -WorksheetName $SheetName -AutoSize -TableName "DataTable"
                Show-Success "Data exported to Excel: $Path"
                Write-Host "📊 Sheet: $SheetName | Rows: $($dataArray.Count)" -ForegroundColor Cyan
            }
        }
    }

    # Import Excel data with preview
    function Import-ExcelData {
        param(
            [string]$Path,
            [string]$SheetName = "Sheet1"
        )

        if (Test-Path $Path) {
            $data = Import-Excel -Path $Path -WorksheetName $SheetName
            Write-Host "📊 Preview of Excel data:" -ForegroundColor Cyan
            $data | Select-Object -First 5 | Format-Table -AutoSize

            $totalRows = $data.Count
            Write-Host "📈 Total rows: $totalRows" -ForegroundColor Green

            return $data
        } else {
            Show-Error "Excel file not found: $Path"
        }
    }

    # Convert CSV to Excel
    function Convert-CsvToExcel {
        param(
            [string]$CsvPath,
            [string]$ExcelPath = ""
        )

        if (!(Test-Path $CsvPath)) {
            Show-Error "CSV file not found: $CsvPath"
            return
        }

        if ($ExcelPath -eq "") {
            $ExcelPath = [IO.Path]::ChangeExtension($CsvPath, ".xlsx")
        }

        $data = Import-Csv -Path $CsvPath
        $data | Export-Excel -Path $ExcelPath -AutoSize -TableName "ImportedData"

        Show-Success "Converted CSV to Excel"
        Write-Host "📄 Input: $CsvPath" -ForegroundColor White
        Write-Host "📊 Output: $ExcelPath" -ForegroundColor Green
        Write-Host "📈 Rows: $($data.Count)" -ForegroundColor Cyan
    }
}

# ============================================
# 🔍 Code Analysis Tools
# ============================================

if (Get-Module -Name PSScriptAnalyzer -ListAvailable) {
    Import-Module PSScriptAnalyzer

    # Analyze current script
    function Analyze-CurrentScript {
        $scriptPath = $MyInvocation.ScriptName
        if ($scriptPath -and (Test-Path $scriptPath)) {
            Write-Host "🔍 Analyzing: $scriptPath" -ForegroundColor Cyan
            $results = Invoke-ScriptAnalyzer -Path $scriptPath

            if ($results) {
                $results | Format-Table RuleName, Severity, Message, Line -AutoSize
                $errorCount = ($results | Where-Object Severity -eq "Error").Count
                $warningCount = ($results | Where-Object Severity -eq "Warning").Count

                Write-Host ""
                Write-Host "📊 Summary:" -ForegroundColor Yellow
                Write-Host "❌ Errors: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
                Write-Host "⚠️  Warnings: $warningCount" -ForegroundColor $(if ($warningCount -gt 0) { "Yellow" } else { "Green" })
            } else {
                Show-Success "No issues found in script analysis"
            }
        } else {
            Show-Warning "No script file found to analyze"
        }
    }

    # Format PowerShell code
    function Format-PowerShellCode {
        param(
            [Parameter(ValueFromPipeline = $true)]
            [string[]]$Code
        )

        Begin {
            $allCode = ""
        }

        Process {
            $allCode += $Code + "`n"
        }

        End {
            try {
                $formatted = Invoke-Formatter -ScriptDefinition $allCode
                return $formatted
            }
            catch {
                Show-Error "Failed to format code: $($_.Exception.Message)"
                return $allCode
            }
        }
    }

    # Quick script health check
    function Test-ScriptHealth {
        param([string]$Path = ".")

        Write-Host "🏥 Script Health Check for: $Path" -ForegroundColor Cyan
        Write-Host "═" * 50 -ForegroundColor DarkCyan

        $scripts = Get-ChildItem -Path $Path -Recurse -Include "*.ps1" -ErrorAction SilentlyContinue

        if ($scripts) {
            $totalScripts = $scripts.Count
            $analyzed = 0
            $totalIssues = 0

            foreach ($script in $scripts) {
                $results = Invoke-ScriptAnalyzer -Path $script.FullName
                $issues = $results.Count
                $totalIssues += $issues

                if ($issues -gt 0) {
                    Write-Host "📄 $($script.Name): " -NoNewline -ForegroundColor White
                    Write-Host "$issues issues" -ForegroundColor $(if ($issues -gt 5) { "Red" } elseif ($issues -gt 2) { "Yellow" } else { "Green" })
                }

                $analyzed++
            }

            Write-Host ""
            Write-Host "📊 Health Summary:" -ForegroundColor Yellow
            Write-Host "📁 Scripts analyzed: $analyzed" -ForegroundColor White
            Write-Host "❌ Total issues: $totalIssues" -ForegroundColor $(if ($totalIssues -gt 0) { "Red" } else { "Green" })
        } else {
            Show-Warning "No PowerShell scripts found in $Path"
        }
    }
}

# ============================================
# 📅 Calendar & Scheduling Features
# ============================================

if (Get-Module -Name PSCalendar -ListAvailable) {
    Import-Module PSCalendar

    # Show current month calendar
    function Show-Calendar {
        param(
            [int]$Month = (Get-Date).Month,
            [int]$Year = (Get-Date).Year
        )

        Write-Host "📅 Calendar: $(Get-Date -Month $Month -Year $Year -Format 'MMMM yyyy')" -ForegroundColor Cyan
        Write-Host "═" * 50 -ForegroundColor DarkCyan

        Show-Calendar -Month $Month -Year $Year

        Write-Host ""
        $today = Get-Date
        $daysInMonth = [DateTime]::DaysInMonth($Year, $Month)
        $currentDay = if ($Month -eq $today.Month -and $Year -eq $today.Year) { $today.Day } else { $null }

        if ($currentDay) {
            Write-Host "🎯 Today is day $currentDay" -ForegroundColor Green
        }
    }

    # Show upcoming events (placeholder for future integration)
    function Show-UpcomingEvents {
        param([int]$Days = 7)

        Write-Host "📅 Next $Days days:" -ForegroundColor Cyan
        Write-Host "═" * 50 -ForegroundColor DarkCyan

        for ($i = 0; $i -lt $Days; $i++) {
            $date = (Get-Date).AddDays($i)
            $dayName = $date.ToString("dddd")
            $dateStr = $date.ToString("MMM dd")

            if ($i -eq 0) {
                Write-Host "🎯 $dateStr ($dayName) - TODAY" -ForegroundColor Green
            } elseif ($i -eq 1) {
                Write-Host "⏰ $dateStr ($dayName) - TOMORROW" -ForegroundColor Yellow
            } else {
                Write-Host "📅 $dateStr ($dayName)" -ForegroundColor White
            }
        }
    }
}

# ============================================
# 🎮 Enhanced Aliases and Commands
# ============================================

# Enhanced aliases for new UX features
Set-Alias -Name menu -Value Show-ProjectMenu -ErrorAction SilentlyContinue
Set-Alias -Name find-file -Value Find-FileFuzzy -ErrorAction SilentlyContinue
Set-Alias -Name find-dir -Value Find-DirectoryFuzzy -ErrorAction SilentlyContinue
Set-Alias -Name search-history -Value Search-HistoryFuzzy -ErrorAction SilentlyContinue
Set-Alias -Name toast -Value Show-ToastNotification -ErrorAction SilentlyContinue
Set-Alias -Name analyze -Value Analyze-CurrentScript -ErrorAction SilentlyContinue
Set-Alias -Name format-code -Value Format-PowerShellCode -ErrorAction SilentlyContinue
Set-Alias -Name script-health -Value Test-ScriptHealth -ErrorAction SilentlyContinue
Set-Alias -Name calendar -Value Show-Calendar -ErrorAction SilentlyContinue
Set-Alias -Name events -Value Show-UpcomingEvents -ErrorAction SilentlyContinue
Set-Alias -Name rainbow -Value Show-RainbowText -ErrorAction SilentlyContinue

# Enhanced command with notification
function Update-AllModulesWithNotification {
    param([switch]$Notify = $true)

    if ($Notify -and (Get-Module -Name BurntToast -ListAvailable)) {
        Invoke-WithNotification -ScriptBlock {
            Update-AllModules
        } -TaskName "Module Update" -NotifyOnComplete $true
    } else {
        Update-AllModules
    }
}

# Show welcome screen on first load
Show-WelcomeScreen
