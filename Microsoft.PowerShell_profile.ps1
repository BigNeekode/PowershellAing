# ============================================
# PowerShell Profile - Ultra Fast Loading
# ============================================
# Optimized for instant startup (<100ms)
# Advanced features lazy-loaded on demand

# ============================================
# Fast Module Loading (Critical Only)
# ============================================

# Only import essential modules synchronously
$ErrorActionPreference = 'SilentlyContinue'

# PSReadLine - Essential for good editing experience
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine

    # Fast PSReadLine config
    Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

    Set-PSReadLineOption -Colors @{
        Command            = 'Yellow'
        Comment            = 'DarkGreen'
        Default            = 'White'
        Error              = 'Red'
        InlinePrediction   = 'DarkGray'
        Keyword            = 'Magenta'
        Number             = 'DarkCyan'
        Operator           = 'DarkMagenta'
        String             = 'Green'
        Variable           = 'DarkYellow'
    }
}

# Lazy load Terminal-Icons and posh-git (loaded on first prompt)
$global:_modulesLoaded = $false

$ErrorActionPreference = 'Continue'

# ============================================
# Remote Session Detection
# ============================================
$global:isRemoteSession = $false
$global:isSSHSession = $false

if ($env:SSH_CONNECTION -or $env:SSH_CLIENT -or $env:SSH_TTY) {
    $global:isSSHSession = $true
    $global:isRemoteSession = $true
}

if ($Host.Name -eq 'ServerRemoteHost') {
    $global:isRemoteSession = $true
}

# ============================================
# Fast Optimized Prompt
# ============================================
function prompt {
    # Lazy load visual modules on first prompt
    if (-not $global:_modulesLoaded) {
        $global:_modulesLoaded = $true
        if (Get-Module -ListAvailable Terminal-Icons) {
            Import-Module Terminal-Icons -ErrorAction SilentlyContinue
        }
        if (Get-Module -ListAvailable posh-git) {
            Import-Module posh-git -ErrorAction SilentlyContinue
        }
    }

    $ESC = [char]27
    $loc = Get-Location

    # Smart path display
    $path = $loc.Path
    $homeDir = $env:USERPROFILE
    if ($path -like "$homeDir*") {
        $path = "~" + $path.Substring($homeDir.Length)
    }

    # Truncate long paths
    if ($global:isRemoteSession -and $path.Length -gt 50) {
        $parts = $path -split '[\\/]'
        if ($parts.Count -gt 3) {
            $path = $parts[0] + "/../" + $parts[-2] + "/" + $parts[-1]
        }
    }

    # Git status (fast, no jobs)
    $gitBranch = ""
    if (Test-Path .git) {
        try {
            $branch = git rev-parse --abbrev-ref HEAD 2>$null
            if ($branch) {
                $status = git status --porcelain 2>$null
                $dirty = if ($status) { "*" } else { "" }
                $gitBranch = " $ESC[35mon $branch$dirty$ESC[0m"
            }
        } catch {
            # Skip git info on error
        }
    }

    # Connection indicator
    $connIcon = if ($global:isSSHSession) { "SSH" } elseif ($global:isRemoteSession) { "REM" } else { "" }

    # Build prompt
    if ($global:isRemoteSession) {
        # Compact for remote
        if ($connIcon) {
            Write-Host "[$connIcon] " -NoNewline -ForegroundColor DarkGray
        }
        Write-Host "$env:USERNAME@$env:COMPUTERNAME" -NoNewline -ForegroundColor Cyan
        Write-Host " $path" -NoNewline -ForegroundColor Yellow
        Write-Host $gitBranch -NoNewline
        Write-Host ""
        return "$ESC[32m>$ESC[0m "
    } else {
        # Local prompt
        Write-Host ""
        Write-Host "$env:USERNAME@$env:COMPUTERNAME" -NoNewline -ForegroundColor Cyan
        Write-Host " $path" -NoNewline -ForegroundColor Yellow
        Write-Host $gitBranch -NoNewline
        Write-Host ""
        return "$ESC[93m>$ESC[0m "
    }
}

# ============================================
# Essential Aliases
# ============================================

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# Listing
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

# Utilities
function which($name) { Get-Command $name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition }
function touch($file) { New-Item -ItemType File -Name $file -Force | Out-Null }
function mkcd($dir) { New-Item -ItemType Directory -Path $dir -Force | Out-Null; Set-Location $dir }

# Profile management
function Edit-Profile { code $PROFILE }
function Reload-Profile { . $PROFILE; Write-Host "Profile reloaded!" -ForegroundColor Green }

# ============================================
# Lazy-Loaded Advanced Functions
# ============================================

# Install missing modules (run manually)
function Install-ProfileModules {
    $modules = @('PSReadLine', 'Terminal-Icons', 'posh-git', 'PSFzf', 'PSScriptAnalyzer', 'ImportExcel')

    Write-Host "Installing PowerShell modules..." -ForegroundColor Cyan
    foreach ($mod in $modules) {
        if (-not (Get-Module -ListAvailable $mod)) {
            Write-Host "Installing $mod..." -ForegroundColor Yellow
            Install-Module -Name $mod -Scope CurrentUser -Force -ErrorAction SilentlyContinue
            Write-Host "  Installed $mod" -ForegroundColor Green
        } else {
            Write-Host "  $mod already installed" -ForegroundColor DarkGray
        }
    }
    Write-Host "Done! Restart PowerShell to use new modules." -ForegroundColor Green
}

# System info (lazy loaded)
function sysinfo {
    Write-Host "`n=== System Information ===" -ForegroundColor Cyan
    Write-Host "OS: " -NoNewline; Write-Host (Get-CimInstance Win32_OperatingSystem).Caption -ForegroundColor White
    Write-Host "Uptime: " -NoNewline
    $uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    Write-Host "$($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" -ForegroundColor Green
    Write-Host "CPU: " -NoNewline
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    Write-Host "$($cpu.Name)" -ForegroundColor White
    Write-Host "RAM: " -NoNewline
    $os = Get-CimInstance Win32_OperatingSystem
    $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    Write-Host "$($totalRAM - $freeRAM)GB / $($totalRAM)GB" -ForegroundColor White
}

# Show top processes
function top {
    param([int]$n = 10)
    Get-Process | Sort-Object CPU -Descending | Select-Object -First $n |
        Format-Table Name, CPU, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}, Id -AutoSize
}

# Network info
function netinfo {
    Write-Host "`n=== Network Configuration ===" -ForegroundColor Cyan
    Get-NetIPConfiguration | Format-Table InterfaceAlias, IPv4Address, IPv6Address -AutoSize
}

# Test port
function Test-Port {
    param([string]$ComputerName = "localhost", [int]$Port = 80)
    $result = Test-NetConnection -ComputerName $ComputerName -Port $Port -WarningAction SilentlyContinue
    if ($result.TcpTestSucceeded) {
        Write-Host "Port $Port on $ComputerName is OPEN" -ForegroundColor Green
    } else {
        Write-Host "Port $Port on $ComputerName is CLOSED" -ForegroundColor Red
    }
}

# Get directory size
function Get-DirSize {
    param([string]$path = ".")
    $size = (Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue |
             Measure-Object -Property Length -Sum).Sum
    $sizeMB = [math]::Round($size / 1MB, 2)
    Write-Host "$sizeMB MB" -ForegroundColor Cyan
}

# Find files
function ff {
    param([string]$name)
    Get-ChildItem -Recurse -Filter "*$name*" -ErrorAction SilentlyContinue
}

# ============================================
# SSH/VPS Helpers (Lazy loaded)
# ============================================

# SSH connection manager (only load if needed)
function Get-SSHHosts {
    if (Test-Path ~/.ssh/config) {
        Write-Host "`n=== SSH Hosts ===" -ForegroundColor Cyan
        Get-Content ~/.ssh/config | Select-String "^Host " | ForEach-Object {
            $hostName = $_ -replace "Host ", ""
            Write-Host "  $hostName" -ForegroundColor Green
        }
    } else {
        Write-Host "No SSH config found at ~/.ssh/config" -ForegroundColor Yellow
    }
}

function Add-SSHKey {
    param([string]$keyPath = "~/.ssh/id_rsa")
    ssh-add $keyPath
}

# ============================================
# Development Helpers
# ============================================

# Quick HTTP server
function serve {
    param([int]$port = 8000)
    if (Get-Command python -ErrorAction SilentlyContinue) {
        python -m http.server $port
    } else {
        Write-Host "Python not found. Install Python to use this feature." -ForegroundColor Red
    }
}

# ============================================
# Completion
# ============================================

# Load complete - silent mode
# Uncomment below to see load time on startup
# $loadTime = (Get-History -Count 1).Duration.TotalMilliseconds
# Write-Host "Profile loaded in $([math]::Round($loadTime, 2))ms" -ForegroundColor DarkGray
