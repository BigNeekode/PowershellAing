# ============================================
# 🚀 PowerShell Profile - SSH/VPS Optimized
# ============================================
# Lightweight, efficient, and visually enhanced for remote sessions
# Optimized for performance over SSH connections

# ============================================
# 🔧 SSH/Remote Detection
# ============================================
$isRemoteSession = $false
$isSSHSession = $false

# Detect if running in SSH session
if ($env:SSH_CONNECTION -or $env:SSH_CLIENT -or $env:SSH_TTY) {
    $isSSHSession = $true
    $isRemoteSession = $true
}

# Detect PowerShell remoting
if ($Host.Name -eq 'ServerRemoteHost') {
    $isRemoteSession = $true
}

# ============================================
# ⚡ Performance Optimization for Remote Sessions
# ============================================

# Disable progress bars for faster operations
$ProgressPreference = 'SilentlyContinue'

# Better encoding for international characters
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Concise error view for cleaner output
$ErrorView = 'ConciseView'

# Optimize history settings
$MaximumHistoryCount = 10000

# ============================================
# 🎨 Visual Enhancements (Lightweight)
# ============================================

# Color scheme optimized for SSH terminals
$global:ColorScheme = @{
    Success = 'Green'
    Error = 'Red'
    Warning = 'Yellow'
    Info = 'Cyan'
    Highlight = 'Magenta'
    Muted = 'DarkGray'
    Primary = 'White'
}

# Quick status indicators
function Write-StatusLine {
    param(
        [string]$Icon,
        [string]$Label,
        [string]$Value,
        [string]$Color = 'White'
    )
    Write-Host "$Icon " -ForegroundColor $Color -NoNewline
    Write-Host $Label -ForegroundColor DarkGray -NoNewline
    Write-Host ": " -ForegroundColor DarkGray -NoNewline
    Write-Host $Value -ForegroundColor $Color
}

# ============================================
# 🎯 Enhanced Prompt for SSH
# ============================================
function prompt {
    $ESC = [char]27
    
    # Get current location with smart truncation
    $location = $pwd.Path
    $homeDir = $env:HOME -replace '\\', '/'
    if ($location -like "$homeDir*") {
        $location = "~" + $location.Substring($homeDir.Length)
    }
    
    # Truncate long paths for SSH terminals
    if ($location.Length -gt 50) {
        $parts = $location -split '[\\/]'
        if ($parts.Count -gt 3) {
            $location = $parts[0] + "/../" + $parts[-2] + "/" + $parts[-1]
        }
    }
    
    # User and host info
    $user = $env:USER ?? $env:USERNAME
    $hostname = $env:HOSTNAME ?? $env:COMPUTERNAME
    
    # Connection indicator
    $connIcon = if ($isSSHSession) { "🔐" } elseif ($isRemoteSession) { "🔌" } else { "💻" }
    
    # Git branch (lightweight check)
    $gitBranch = ""
    if (Test-Path .git) {
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($branch) {
            $gitBranch = " $ESC[35m(🌿 $branch)$ESC[0m"
        }
    }
    
    # Color-coded status
    $statusColor = if ($?) { "32" } else { "31" }
    $promptSymbol = "$ESC[${statusColor}m▶$ESC[0m"
    
    # Build compact prompt
    Write-Host "$connIcon " -NoNewline -ForegroundColor Cyan
    Write-Host "$user@$hostname" -NoNewline -ForegroundColor Green
    Write-Host " in " -NoNewline -ForegroundColor DarkGray
    Write-Host $location -NoNewline -ForegroundColor Yellow
    Write-Host $gitBranch -NoNewline
    Write-Host ""
    return "$promptSymbol "
}

# ============================================
# 📊 System Information (Lightweight)
# ============================================

function Get-SystemInfo {
    param([switch]$Detailed)
    
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║         🖥️  System Information           ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Basic info
    Write-StatusLine "🏷️" "Hostname" ($env:HOSTNAME ?? $env:COMPUTERNAME) "Green"
    Write-StatusLine "👤" "User" ($env:USER ?? $env:USERNAME) "Yellow"
    Write-StatusLine "💻" "Shell" "$($PSVersionTable.PSVersion)" "Cyan"
    Write-StatusLine "📁" "Location" (Get-Location) "Magenta"
    
    if ($Detailed) {
        # Network info
        try {
            $ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias (Get-NetAdapter | Where-Object Status -eq 'Up' | Select-Object -First 1).Name).IPAddress
            Write-StatusLine "🌐" "IP Address" $ip "White"
        } catch {
            Write-StatusLine "🌐" "IP Address" "N/A" "DarkGray"
        }
        
        # Uptime
        try {
            $uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
            Write-StatusLine "⏱️" "Uptime" "$($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" "White"
        } catch {
            Write-StatusLine "⏱️" "Uptime" "N/A" "DarkGray"
        }
    }
    
    Write-Host ""
}

# ============================================
# 🚀 SSH & Remote Connection Helpers
# ============================================

# SSH connection manager
$global:SSHConnections = @{}
$sshConfigFile = "$env:USERPROFILE\.ssh\ps_connections.json"

function Save-SSHConnections {
    $global:SSHConnections | ConvertTo-Json | Set-Content $sshConfigFile
}

function Load-SSHConnections {
    if (Test-Path $sshConfigFile) {
        try {
            $global:SSHConnections = Get-Content $sshConfigFile | ConvertFrom-Json -AsHashtable
        } catch {
            $global:SSHConnections = @{}
        }
    }
}

# Load saved connections
Load-SSHConnections

# Add SSH connection
function Add-SSHConnection {
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        
        [Parameter(Mandatory)]
        [string]$HostName,
        
        [string]$User = $env:USERNAME,
        [int]$Port = 22,
        [string]$IdentityFile = ""
    )
    
    $global:SSHConnections[$Name] = @{
        Host = $HostName
        User = $User
        Port = $Port
        IdentityFile = $IdentityFile
    }
    
    Save-SSHConnections
    Write-Host "✅ SSH connection '$Name' saved" -ForegroundColor Green
}

# Get VPS status information
function Get-VPSStatus {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )
    
    if (-not $global:SSHConnections.ContainsKey($Name)) {
        return $null
    }
    
    $conn = $global:SSHConnections[$Name]
    
    # Build SSH command for system info
    $sshBase = "ssh -p $($conn.Port)"
    if ($conn.IdentityFile) { $sshBase += " -i `"$($conn.IdentityFile)`"" }
    $sshBase += " $($conn.User)@$($conn.Host)"
    
    try {
        # Get system stats - build command carefully to avoid escaping issues
        $cmd1 = "echo ===STATS=== && uptime"
        $cmd2 = "echo ===CPU=== && top -bn2 | grep 'Cpu(s)' | tail -1 | awk '{print 100-`$8}'"
        $cmd3 = "echo ===MEM=== && free -m | awk 'NR==2{print `$3,`$2,`$3*100/`$2}'"
        $cmd4 = "echo ===DISK=== && df -h / | awk 'NR==2{print `$3,`$2,`$5}'"
        $cmd5 = "echo ===OS=== && grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\`"'"
        $cmd6 = "echo ===KERNEL=== && uname -r"
        $cmd7 = "echo ===END==="
        
        $remoteCmd = "$cmd1 && $cmd2 && $cmd3 && $cmd4 && $cmd5 && $cmd6 && $cmd7"
        $statsCmd = "$sshBase `"$remoteCmd`""
        $output = Invoke-Expression $statsCmd 2>&1
        
        if ($output -match "===STATS===(.*?)===CPU===(.*?)===MEM===(.*?)===DISK===(.*?)===OS===(.*?)===KERNEL===(.*?)===END===") {
            $uptime = $Matches[1].Trim()
            $cpuUsage = [math]::Round([double]$Matches[2].Trim(), 1)
            $memParts = $Matches[3].Trim() -split '\s+'
            $diskParts = $Matches[4].Trim() -split '\s+'
            $osName = $Matches[5].Trim()
            $kernel = $Matches[6].Trim()
            
            return @{
                Uptime = $uptime
                CPU = $cpuUsage
                MemUsed = $memParts[0]
                MemTotal = $memParts[1]
                MemPercent = [math]::Round([double]$memParts[2], 1)
                DiskUsed = $diskParts[0]
                DiskTotal = $diskParts[1]
                DiskPercent = $diskParts[2]
                OS = $osName
                Kernel = $kernel
            }
        }
    } catch {
        return $null
    }
    
    return $null
}

# Show VPS dashboard
function Show-VPSDashboard {
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [hashtable]$Stats
    )
    
    $conn = $global:SSHConnections[$Name]
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║            🖥️  VPS Status Dashboard                       ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Connection info
    Write-Host "  🔐 " -NoNewline -ForegroundColor Green
    Write-Host "Connection: " -NoNewline -ForegroundColor DarkGray
    Write-Host "$Name " -NoNewline -ForegroundColor Yellow
    Write-Host "($($conn.User)@$($conn.Host):$($conn.Port))" -ForegroundColor White
    
    if ($Stats) {
        # OS Info
        Write-Host "  🐧 " -NoNewline -ForegroundColor Blue
        Write-Host "System:     " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($Stats.OS)" -ForegroundColor White
        
        Write-Host "  🔧 " -NoNewline -ForegroundColor Magenta
        Write-Host "Kernel:     " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($Stats.Kernel)" -ForegroundColor White
        
        # Uptime
        Write-Host "  ⏱️  " -NoNewline -ForegroundColor Cyan
        Write-Host "Uptime:     " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($Stats.Uptime)" -ForegroundColor White
        
        Write-Host ""
        Write-Host "  📊 Resource Usage:" -ForegroundColor Yellow
        Write-Host "  ─────────────────────────────────────────────────────────" -ForegroundColor DarkGray
        
        # CPU Usage
        $cpuColor = if ($Stats.CPU -gt 80) { "Red" } elseif ($Stats.CPU -gt 60) { "Yellow" } else { "Green" }
        $cpuBar = [string]::new('█', [math]::Floor($Stats.CPU / 5)) + [string]::new('░', 20 - [math]::Floor($Stats.CPU / 5))
        Write-Host "  💻 " -NoNewline -ForegroundColor $cpuColor
        Write-Host "CPU:        " -NoNewline -ForegroundColor DarkGray
        Write-Host "[$cpuBar] " -NoNewline -ForegroundColor $cpuColor
        Write-Host "$($Stats.CPU)%" -ForegroundColor $cpuColor
        
        # Memory Usage
        $memColor = if ($Stats.MemPercent -gt 80) { "Red" } elseif ($Stats.MemPercent -gt 60) { "Yellow" } else { "Green" }
        $memBar = [string]::new('█', [math]::Floor($Stats.MemPercent / 5)) + [string]::new('░', 20 - [math]::Floor($Stats.MemPercent / 5))
        Write-Host "  🧠 " -NoNewline -ForegroundColor $memColor
        Write-Host "Memory:     " -NoNewline -ForegroundColor DarkGray
        Write-Host "[$memBar] " -NoNewline -ForegroundColor $memColor
        Write-Host "$($Stats.MemPercent)% " -NoNewline -ForegroundColor $memColor
        Write-Host "($($Stats.MemUsed)M / $($Stats.MemTotal)M)" -ForegroundColor DarkGray
        
        # Disk Usage
        $diskPercent = [double]($Stats.DiskPercent -replace '%', '')
        $diskColor = if ($diskPercent -gt 80) { "Red" } elseif ($diskPercent -gt 60) { "Yellow" } else { "Green" }
        $diskBar = [string]::new('█', [math]::Floor($diskPercent / 5)) + [string]::new('░', 20 - [math]::Floor($diskPercent / 5))
        Write-Host "  💾 " -NoNewline -ForegroundColor $diskColor
        Write-Host "Disk:       " -NoNewline -ForegroundColor DarkGray
        Write-Host "[$diskBar] " -NoNewline -ForegroundColor $diskColor
        Write-Host "$($Stats.DiskPercent) " -NoNewline -ForegroundColor $diskColor
        Write-Host "($($Stats.DiskUsed) / $($Stats.DiskTotal))" -ForegroundColor DarkGray
    } else {
        Write-Host "  ⚠️  " -NoNewline -ForegroundColor Yellow
        Write-Host "Could not fetch system stats" -ForegroundColor DarkGray
    }
    
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

# Connect to saved SSH host
function Connect-SSH {
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        
        [switch]$NoStatus
    )
    
    if (-not $global:SSHConnections.ContainsKey($Name)) {
        Write-Host "❌ Connection '$Name' not found" -ForegroundColor Red
        Write-Host "Available connections: $($global:SSHConnections.Keys -join ', ')" -ForegroundColor Yellow
        return
    }
    
    $conn = $global:SSHConnections[$Name]
    
    Write-Host "🔐 Connecting to " -NoNewline -ForegroundColor Cyan
    Write-Host "$Name" -NoNewline -ForegroundColor Yellow
    Write-Host " ($($conn.Host))..." -ForegroundColor Cyan
    
    # Get VPS status before connecting (unless disabled)
    if (-not $NoStatus) {
        Write-Host "📊 Fetching VPS status..." -ForegroundColor DarkGray
        $stats = Get-VPSStatus -Name $Name
        Show-VPSDashboard -Name $Name -Stats $stats
    }
    
    # Build SSH command
    $sshCmd = "ssh -p $($conn.Port) $($conn.User)@$($conn.Host)"
    
    if ($conn.IdentityFile) {
        $sshCmd += " -i `"$($conn.IdentityFile)`""
    }
    
    # Connect
    Write-Host "� Establishing SSH session..." -ForegroundColor Green
    Write-Host ""
    Invoke-Expression $sshCmd
}

# List saved connections
function Get-SSHConnections {
    if ($global:SSHConnections.Count -eq 0) {
        Write-Host "No saved SSH connections" -ForegroundColor Yellow
        Write-Host "Use Add-SSHConnection to add one" -ForegroundColor Cyan
        return
    }
    
    Write-Host ""
    Write-Host "📋 Saved SSH Connections" -ForegroundColor Cyan
    Write-Host "═" * 60 -ForegroundColor DarkCyan
    Write-Host ""
    
    foreach ($conn in $global:SSHConnections.GetEnumerator()) {
        $details = $conn.Value
        Write-Host "🔐 " -NoNewline -ForegroundColor Green
        Write-Host $conn.Key -NoNewline -ForegroundColor Yellow
        Write-Host " → " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($details.User)@$($details.Host):$($details.Port)" -ForegroundColor White
        if ($details.IdentityFile) {
            Write-Host "   🔑 Key: $($details.IdentityFile)" -ForegroundColor DarkGray
        }
    }
    Write-Host ""
}

# Remove SSH connection
function Remove-SSHConnection {
    param([Parameter(Mandatory)][string]$Name)
    
    if ($global:SSHConnections.ContainsKey($Name)) {
        $global:SSHConnections.Remove($Name)
        Save-SSHConnections
        Write-Host "✅ Connection '$Name' removed" -ForegroundColor Green
    } else {
        Write-Host "❌ Connection '$Name' not found" -ForegroundColor Red
    }
}

# Quick SSH with auto-save
function ssh-quick {
    param(
        [string]$Target,
        [string]$Name = "",
        [switch]$Save
    )
    
    if ($Save -and $Name) {
        # Parse target (user@host:port)
        $parts = $Target -split '@'
        $user = if ($parts.Count -gt 1) { $parts[0] } else { $env:USERNAME }
        $hostPart = if ($parts.Count -gt 1) { $parts[1] } else { $parts[0] }
        $hostPortParts = $hostPart -split ':'
        $host = $hostPortParts[0]
        $port = if ($hostPortParts.Count -gt 1) { [int]$hostPortParts[1] } else { 22 }
        
        Add-SSHConnection -Name $Name -Host $host -User $user -Port $port
    }
    
    ssh $Target
}

# ============================================
# 📦 File Transfer Utilities
# ============================================

# SCP wrapper with progress
function Copy-ToRemote {
    param(
        [Parameter(Mandatory)]
        [string]$Source,
        
        [Parameter(Mandatory)]
        [string]$Destination,
        
        [Parameter(Mandatory)]
        [string]$Connection,
        
        [switch]$Recurse
    )
    
    if (-not $global:SSHConnections.ContainsKey($Connection)) {
        Write-Host "❌ Connection '$Connection' not found" -ForegroundColor Red
        return
    }
    
    $conn = $global:SSHConnections[$Connection]
    $remoteTarget = "$($conn.User)@$($conn.Host):$Destination"
    
    $scpCmd = "scp -P $($conn.Port)"
    if ($Recurse) { $scpCmd += " -r" }
    if ($conn.IdentityFile) { $scpCmd += " -i `"$($conn.IdentityFile)`"" }
    $scpCmd += " `"$Source`" `"$remoteTarget`""
    
    Write-Host "📤 Uploading $Source..." -ForegroundColor Cyan
    Invoke-Expression $scpCmd
}

# Download from remote
function Copy-FromRemote {
    param(
        [Parameter(Mandatory)]
        [string]$Source,
        
        [Parameter(Mandatory)]
        [string]$Destination,
        
        [Parameter(Mandatory)]
        [string]$Connection,
        
        [switch]$Recurse
    )
    
    if (-not $global:SSHConnections.ContainsKey($Connection)) {
        Write-Host "❌ Connection '$Connection' not found" -ForegroundColor Red
        return
    }
    
    $conn = $global:SSHConnections[$Connection]
    $remoteSource = "$($conn.User)@$($conn.Host):$Source"
    
    $scpCmd = "scp -P $($conn.Port)"
    if ($Recurse) { $scpCmd += " -r" }
    if ($conn.IdentityFile) { $scpCmd += " -i `"$($conn.IdentityFile)`"" }
    $scpCmd += " `"$remoteSource`" `"$Destination`""
    
    Write-Host "📥 Downloading $Source..." -ForegroundColor Cyan
    Invoke-Expression $scpCmd
}

# ============================================
# 🔍 Remote Command Execution
# ============================================

function Invoke-SSHCommand {
    param(
        [Parameter(Mandatory)]
        [string]$Connection,
        
        [Parameter(Mandatory)]
        [string]$Command
    )
    
    if (-not $global:SSHConnections.ContainsKey($Connection)) {
        Write-Host "❌ Connection '$Connection' not found" -ForegroundColor Red
        return
    }
    
    $conn = $global:SSHConnections[$Connection]
    $sshCmd = "ssh -p $($conn.Port)"
    if ($conn.IdentityFile) { $sshCmd += " -i `"$($conn.IdentityFile)`"" }
    $sshCmd += " $($conn.User)@$($conn.Host) `"$Command`""
    
    Write-Host "⚡ Executing on $Connection..." -ForegroundColor Cyan
    Invoke-Expression $sshCmd
}

# ============================================
# 🔐 SSH Key Management
# ============================================

function New-SSHKeyPair {
    param(
        [string]$Name = "id_rsa",
        [string]$Type = "ed25519",
        [string]$Comment = ""
    )
    
    $sshDir = "$env:USERPROFILE\.ssh"
    if (-not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir | Out-Null
    }
    
    $keyPath = Join-Path $sshDir $Name
    if (Test-Path $keyPath) {
        Write-Host "⚠️  Key already exists: $keyPath" -ForegroundColor Yellow
        $overwrite = Read-Host "Overwrite? (y/N)"
        if ($overwrite -ne 'y') { return }
    }
    
    $commentArg = if ($Comment) { "-C `"$Comment`"" } else { "" }
    $cmd = "ssh-keygen -t $Type -f `"$keyPath`" $commentArg"
    
    Write-Host "🔑 Generating SSH key pair..." -ForegroundColor Cyan
    Invoke-Expression $cmd
    
    Write-Host ""
    Write-Host "✅ Key pair created:" -ForegroundColor Green
    Write-Host "   Private: $keyPath" -ForegroundColor White
    Write-Host "   Public:  $keyPath.pub" -ForegroundColor White
}

function Show-SSHPublicKey {
    param([string]$Name = "id_rsa")
    
    $keyPath = "$env:USERPROFILE\.ssh\$Name.pub"
    if (Test-Path $keyPath) {
        Write-Host "📋 Public Key ($Name):" -ForegroundColor Cyan
        Write-Host ""
        Get-Content $keyPath
        Write-Host ""
        Write-Host "💡 Copy this to your remote server's ~/.ssh/authorized_keys" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Key not found: $keyPath" -ForegroundColor Red
    }
}

function Copy-SSHPublicKey {
    param(
        [Parameter(Mandatory)]
        [string]$Connection,
        [string]$KeyName = "id_rsa"
    )
    
    $keyPath = "$env:USERPROFILE\.ssh\$KeyName.pub"
    if (-not (Test-Path $keyPath)) {
        Write-Host "❌ Key not found: $keyPath" -ForegroundColor Red
        return
    }
    
    if (-not $global:SSHConnections.ContainsKey($Connection)) {
        Write-Host "❌ Connection '$Connection' not found" -ForegroundColor Red
        return
    }
    
    $conn = $global:SSHConnections[$Connection]
    Write-Host "🔑 Copying public key to $Connection..." -ForegroundColor Cyan
    
    $sshCopyIdCmd = "type `"$keyPath`" | ssh -p $($conn.Port) $($conn.User)@$($conn.Host) `"mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys`""
    Invoke-Expression $sshCopyIdCmd
    
    Write-Host "✅ Public key copied successfully" -ForegroundColor Green
}

# ============================================
# 🌐 Network Utilities
# ============================================

function Test-SSHPort {
    param(
        [Parameter(Mandatory)]
        [string]$HostName,
        [int]$Port = 22,
        [int]$Timeout = 5
    )
    
    Write-Host "🔍 Testing SSH connection to $HostName`:$Port..." -ForegroundColor Cyan
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connection = $tcpClient.BeginConnect($HostName, $Port, $null, $null)
        $wait = $connection.AsyncWaitHandle.WaitOne($Timeout * 1000, $false)
        
        if ($wait) {
            $tcpClient.EndConnect($connection)
            $tcpClient.Close()
            Write-Host "✅ Port $Port is open and accessible" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Connection timeout" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Get-PublicIP {
    Write-Host "🌐 Fetching public IP..." -ForegroundColor Cyan
    try {
        $ip = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5).Trim()
        Write-Host "📍 Your public IP: " -NoNewline -ForegroundColor Yellow
        Write-Host $ip -ForegroundColor Green
        return $ip
    } catch {
        Write-Host "❌ Failed to fetch public IP" -ForegroundColor Red
    }
}

function Test-Latency {
    param(
        [Parameter(Mandatory)]
        [string]$HostName,
        [int]$Count = 4
    )
    
    Write-Host "📊 Testing latency to $HostName..." -ForegroundColor Cyan
    Test-Connection -ComputerName $HostName -Count $Count | Format-Table -AutoSize
}

# ============================================
# 📁 Enhanced Navigation
# ============================================

function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

function ll { 
    Get-ChildItem -Force | Format-Table Mode, 
        @{Label="Size";Expression={
            if ($_.PSIsContainer) { "-" }
            else {
                $size = $_.Length
                if ($size -gt 1GB) { "{0:N2} GB" -f ($size / 1GB) }
                elseif ($size -gt 1MB) { "{0:N2} MB" -f ($size / 1MB) }
                elseif ($size -gt 1KB) { "{0:N2} KB" -f ($size / 1KB) }
                else { "$size B" }
            }
        };Align="Right"},
        LastWriteTime,
        Name -AutoSize
}

function la { Get-ChildItem -Force }

# Quick directory navigation with bookmarks
$global:NavBookmarks = @{}

function Set-NavBookmark {
    param([string]$Name)
    $global:NavBookmarks[$Name] = (Get-Location).Path
    Write-Host "📌 Bookmark '$Name' saved" -ForegroundColor Green
}

function Go-NavBookmark {
    param([string]$Name)
    if ($global:NavBookmarks.ContainsKey($Name)) {
        Set-Location $global:NavBookmarks[$Name]
    } else {
        Write-Host "❌ Bookmark '$Name' not found" -ForegroundColor Red
        if ($global:NavBookmarks.Count -gt 0) {
            Write-Host "Available bookmarks: $($global:NavBookmarks.Keys -join ', ')" -ForegroundColor Yellow
        }
    }
}

function Show-NavBookmarks {
    if ($global:NavBookmarks.Count -eq 0) {
        Write-Host "No navigation bookmarks set" -ForegroundColor Yellow
        return
    }
    
    Write-Host ""
    Write-Host "📌 Navigation Bookmarks" -ForegroundColor Cyan
    Write-Host "═" * 50 -ForegroundColor DarkCyan
    Write-Host ""
    
    foreach ($bm in $global:NavBookmarks.GetEnumerator()) {
        Write-Host "  $($bm.Key) → $($bm.Value)" -ForegroundColor White
    }
    Write-Host ""
}

# ============================================
# 🔧 System Utilities
# ============================================

function Get-DiskSpace {
    Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 } |
        Select-Object Name, 
            @{Name="Size (GB)";Expression={[math]::Round($_.Used/1GB + $_.Free/1GB, 2)}},
            @{Name="Used (GB)";Expression={[math]::Round($_.Used/1GB, 2)}},
            @{Name="Free (GB)";Expression={[math]::Round($_.Free/1GB, 2)}},
            @{Name="Usage %";Expression={[math]::Round(($_.Used/($_.Used+$_.Free))*100, 1)}} |
        Format-Table -AutoSize
}

function Get-TopProcesses {
    param([int]$Count = 10)
    Get-Process | Sort-Object CPU -Descending | Select-Object -First $Count |
        Format-Table Name, 
            @{Label="CPU(s)";Expression={$_.CPU};FormatString="N2"},
            @{Label="Memory(MB)";Expression={$_.WorkingSet/1MB};FormatString="N2"},
            Id -AutoSize
}

function Find-File {
    param(
        [Parameter(Mandatory)]
        [string]$Pattern,
        [string]$Path = "."
    )
    
    Write-Host "🔍 Searching for '$Pattern' in $Path..." -ForegroundColor Cyan
    Get-ChildItem -Path $Path -Recurse -Filter "*$Pattern*" -File -ErrorAction SilentlyContinue |
        Select-Object FullName, Length, LastWriteTime |
        Format-Table -AutoSize
}

function Search-Content {
    param(
        [Parameter(Mandatory)]
        [string]$Pattern,
        [string]$Path = ".",
        [string]$Include = "*"
    )
    
    Write-Host "🔍 Searching for pattern '$Pattern'..." -ForegroundColor Cyan
    Get-ChildItem -Path $Path -Recurse -Include $Include -File -ErrorAction SilentlyContinue |
        Select-String -Pattern $Pattern |
        Select-Object -First 20 |
        Format-Table Filename, LineNumber, Line -AutoSize
}

# ============================================
# 📝 Git Shortcuts
# ============================================

function gs { git status -sb }
function ga { git add $args }
function gc { git commit -m $args }
function gp { git push }
function gpl { git pull }
function gd { git diff }
function gco { git checkout $args }
function gb { git branch $args }
function gl { git log --oneline --graph --decorate -10 }
function glog { git log --oneline --graph --decorate --all -20 }

# ============================================
# 🎨 Enhanced File Operations
# ============================================

function touch {
    param([string]$Path)
    if (Test-Path $Path) {
        (Get-Item $Path).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $Path | Out-Null
        Write-Host "✅ Created: $Path" -ForegroundColor Green
    }
}

function mkcd {
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
    Write-Host "✅ Created and entered: $Path" -ForegroundColor Green
}

# ============================================
# 📊 Quick Status Display
# ============================================

function qs {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║         📊 Quick Status                  ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Location
    Write-StatusLine "📁" "Location" (Get-Location) "Yellow"
    
    # Git status
    if (Test-Path .git) {
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        $status = git status --porcelain 2>$null
        $statusText = if ($status) { "Modified" } else { "Clean" }
        $statusColor = if ($status) { "Yellow" } else { "Green" }
        Write-StatusLine "🌿" "Git" "$branch ($statusText)" $statusColor
    }
    
    # File count
    $fileCount = (Get-ChildItem -File -ErrorAction SilentlyContinue).Count
    $dirCount = (Get-ChildItem -Directory -ErrorAction SilentlyContinue).Count
    Write-StatusLine "📂" "Contents" "$dirCount dirs, $fileCount files" "Cyan"
    
    # SSH connections
    if ($global:SSHConnections.Count -gt 0) {
        Write-StatusLine "🔐" "SSH Connections" "$($global:SSHConnections.Count) saved" "Magenta"
    }
    
    Write-Host ""
}

# ============================================
# 🚀 Aliases (SSH Optimized)
# ============================================

# Check VPS status without connecting
function Get-VPSInfo {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )
    
    if (-not $global:SSHConnections.ContainsKey($Name)) {
        Write-Host "❌ Connection '$Name' not found" -ForegroundColor Red
        return
    }
    
    Write-Host "📊 Fetching status for " -NoNewline -ForegroundColor Cyan
    Write-Host "$Name" -NoNewline -ForegroundColor Yellow
    Write-Host "..." -ForegroundColor Cyan
    
    $stats = Get-VPSStatus -Name $Name
    Show-VPSDashboard -Name $Name -Stats $stats
}

# Monitor VPS in real-time
function Watch-VPS {
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        
        [int]$Interval = 3
    )
    
    if (-not $global:SSHConnections.ContainsKey($Name)) {
        Write-Host "❌ Connection '$Name' not found" -ForegroundColor Red
        return
    }
    
    Write-Host "📊 Monitoring " -NoNewline -ForegroundColor Cyan
    Write-Host "$Name" -NoNewline -ForegroundColor Yellow
    Write-Host " (Press Ctrl+C to stop)" -ForegroundColor Cyan
    Write-Host ""
    
    while ($true) {
        Clear-Host
        Write-Host "🔄 Refreshing every $Interval seconds..." -ForegroundColor DarkGray
        $stats = Get-VPSStatus -Name $Name
        Show-VPSDashboard -Name $Name -Stats $stats
        Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor DarkGray
        Start-Sleep -Seconds $Interval
    }
}

# SSH management
Set-Alias -Name ssha -Value Add-SSHConnection -ErrorAction SilentlyContinue
Set-Alias -Name sshl -Value Get-SSHConnections -ErrorAction SilentlyContinue
Set-Alias -Name sshc -Value Connect-SSH -ErrorAction SilentlyContinue
Set-Alias -Name sshr -Value Remove-SSHConnection -ErrorAction SilentlyContinue
Set-Alias -Name sshcmd -Value Invoke-SSHCommand -ErrorAction SilentlyContinue
Set-Alias -Name sshstat -Value Get-VPSInfo -ErrorAction SilentlyContinue
Set-Alias -Name sshwatch -Value Watch-VPS -ErrorAction SilentlyContinue

# File transfer
Set-Alias -Name scpup -Value Copy-ToRemote -ErrorAction SilentlyContinue
Set-Alias -Name scpdown -Value Copy-FromRemote -ErrorAction SilentlyContinue

# SSH key management
Set-Alias -Name sshkey -Value New-SSHKeyPair -ErrorAction SilentlyContinue
Set-Alias -Name sshpub -Value Show-SSHPublicKey -ErrorAction SilentlyContinue
Set-Alias -Name sshcopy -Value Copy-SSHPublicKey -ErrorAction SilentlyContinue

# Navigation
Set-Alias -Name bm -Value Set-NavBookmark -ErrorAction SilentlyContinue
Set-Alias -Name go -Value Go-NavBookmark -ErrorAction SilentlyContinue
Set-Alias -Name bms -Value Show-NavBookmarks -ErrorAction SilentlyContinue

# Utilities
Set-Alias -Name sysinfo -Value Get-SystemInfo -ErrorAction SilentlyContinue
Set-Alias -Name myip -Value Get-PublicIP -ErrorAction SilentlyContinue
Set-Alias -Name ping-test -Value Test-Latency -ErrorAction SilentlyContinue
Set-Alias -Name disk -Value Get-DiskSpace -ErrorAction SilentlyContinue
Set-Alias -Name top -Value Get-TopProcesses -ErrorAction SilentlyContinue
Set-Alias -Name find -Value Find-File -ErrorAction SilentlyContinue
Set-Alias -Name grep -Value Search-Content -ErrorAction SilentlyContinue

# ============================================
# 🎉 Startup Message
# ============================================

function Show-StartupMessage {
    $sessionType = if ($isSSHSession) { "SSH" } elseif ($isRemoteSession) { "Remote" } else { "Local" }
    $sessionIcon = if ($isSSHSession) { "🔐" } elseif ($isRemoteSession) { "🔌" } else { "💻" }
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║    $sessionIcon PowerShell - $sessionType Session" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    if ($isSSHSession) {
        Write-Host "🔐 SSH Session Active" -ForegroundColor Green
        Write-Host "💡 Optimized for remote performance" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "⚡ Quick Commands:" -ForegroundColor Yellow
    Write-Host "  sshl        - List SSH connections" -ForegroundColor DarkGray
    Write-Host "  sshc <name> - Connect to saved host" -ForegroundColor DarkGray
    Write-Host "  qs          - Quick status" -ForegroundColor DarkGray
    Write-Host "  sysinfo -d  - Detailed system info" -ForegroundColor DarkGray
    Write-Host "  help-ssh    - SSH command reference" -ForegroundColor DarkGray
    Write-Host ""
}

# ============================================
# 📖 Help System
# ============================================

function help-ssh {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║           🔐 SSH Command Reference                    ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📝 Connection Management:" -ForegroundColor Yellow
    Write-Host "  ssha <name> <hostname> [-User <user>] [-Port <port>]" -ForegroundColor White
    Write-Host "  sshl                  - List saved connections" -ForegroundColor White
    Write-Host "  sshc <name>           - Connect to saved host" -ForegroundColor White
    Write-Host "  sshr <name>           - Remove saved connection" -ForegroundColor White
    Write-Host ""
    
    Write-Host "📤 File Transfer:" -ForegroundColor Yellow
    Write-Host "  scpup <source> <dest> <connection> [-Recurse]" -ForegroundColor White
    Write-Host "  scpdown <source> <dest> <connection> [-Recurse]" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🔑 Key Management:" -ForegroundColor Yellow
    Write-Host "  sshkey [-Name <name>] [-Type <type>]" -ForegroundColor White
    Write-Host "  sshpub [-Name <name>]" -ForegroundColor White
    Write-Host "  sshcopy <connection> [-KeyName <name>]" -ForegroundColor White
    Write-Host ""
    
    Write-Host "⚡ Remote Execution:" -ForegroundColor Yellow
    Write-Host "  sshcmd <connection> <command>" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🌐 Network Tools:" -ForegroundColor Yellow
    Write-Host "  Test-SSHPort <hostname> [-Port <port>]" -ForegroundColor White
    Write-Host "  myip                  - Show public IP" -ForegroundColor White
    Write-Host "  ping-test <host>      - Test latency" -ForegroundColor White
    Write-Host ""
}

function help-all {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║           📚 All Available Commands                   ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "🔐 SSH Commands: " -NoNewline -ForegroundColor Yellow
    Write-Host "help-ssh" -ForegroundColor White
    Write-Host ""
    
    Write-Host "📁 Navigation:" -ForegroundColor Yellow
    Write-Host "  .., ..., ....         - Go up directories" -ForegroundColor White
    Write-Host "  ll, la                - List files" -ForegroundColor White
    Write-Host "  bm <name>             - Bookmark current directory" -ForegroundColor White
    Write-Host "  go <name>             - Go to bookmarked directory" -ForegroundColor White
    Write-Host "  bms                   - Show bookmarks" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🌿 Git Commands:" -ForegroundColor Yellow
    Write-Host "  gs, ga, gc, gp, gpl   - Git shortcuts" -ForegroundColor White
    Write-Host "  gd, gco, gb, gl       - Git diff, checkout, branch, log" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🛠️  Utilities:" -ForegroundColor Yellow
    Write-Host "  qs                    - Quick status" -ForegroundColor White
    Write-Host "  sysinfo [-Detailed]   - System information" -ForegroundColor White
    Write-Host "  disk                  - Disk space" -ForegroundColor White
    Write-Host "  top [<count>]         - Top processes" -ForegroundColor White
    Write-Host "  find <pattern>        - Find files" -ForegroundColor White
    Write-Host "  grep <pattern>        - Search in files" -ForegroundColor White
    Write-Host "  touch <file>          - Create/update file" -ForegroundColor White
    Write-Host "  mkcd <dir>            - Create and enter directory" -ForegroundColor White
    Write-Host ""
}

# ============================================
# 🚀 Initialize Profile
# ============================================

# Show startup message
Show-StartupMessage

# Hint about available commands
Write-Host "💡 Type " -NoNewline -ForegroundColor DarkGray
Write-Host "help-all" -NoNewline -ForegroundColor Yellow
Write-Host " to see all available commands" -ForegroundColor DarkGray
Write-Host ""
