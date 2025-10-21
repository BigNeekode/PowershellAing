# 🚀 PowerShell SSH/VPS Enhancement Guide

## 📋 Overview

Your PowerShell profile has been enhanced with SSH/VPS management capabilities while maintaining visual appeal and efficiency for remote sessions.

## ✨ Key Improvements

### 🔐 Remote Session Detection
- Automatically detects SSH and remote PowerShell sessions
- Adapts prompt style (compact for SSH, full for local)
- Optimizes performance for remote connections

### 🎨 Visual Enhancements
- **Session Indicators:**
  - 🔐 SSH session
  - 🔌 Remote PowerShell session
  - 💻 Local session
- Color-coded status messages
- Smart path truncation for long directory names in SSH
- Compact prompt layout for remote sessions

### ⚡ Performance Optimizations
- Disabled progress bars (`$ProgressPreference = 'SilentlyContinue'`)
- UTF-8 encoding for international characters
- Concise error view for cleaner output
- Faster module loading with conditional imports

---

## 🔧 SSH Connection Management

### Save SSH Connection
```powershell
# Basic connection
ssha myvps 192.168.1.100

# With custom user and port
ssha myserver example.com -User admin -Port 2222

# With SSH key
ssha prod 10.0.0.5 -User root -Port 22 -IdentityFile "$HOME\.ssh\id_rsa"

# With description
ssha web1 webserver.com -User deploy -Description "Production Web Server"
```

### List Saved Connections
```powershell
sshl    # Shows all saved connections with details
```

### Connect to Saved Host
```powershell
sshc myvps    # Connects to saved connection 'myvps'
```

### Remove Connection
```powershell
sshr myvps    # Removes saved connection
```

---

## 📤 File Transfer (SCP)

### Upload to Remote
```powershell
# Upload single file
scpup C:\localfile.txt /home/user/remote.txt myvps

# Upload directory recursively
scpup C:\folder /home/user/folder myvps -Recurse
```

### Download from Remote
```powershell
# Download single file
scpdown /home/user/remote.txt C:\localfile.txt myvps

# Download directory recursively
scpdown /var/www/html C:\backup\html myvps -Recurse
```

---

## 🔑 SSH Key Management

### Generate New Key Pair
```powershell
# Generate ed25519 key (recommended)
sshkey -Name id_vps -Type ed25519 -Comment "VPS access key"

# Generate RSA key
sshkey -Name id_rsa_work -Type rsa -Comment "Work VPS"
```

### View Public Key
```powershell
sshpub           # Shows default id_rsa.pub
sshpub -Name id_vps   # Shows specific key
```

### Copy Public Key to Remote
```powershell
# Copy key to VPS (enables passwordless login)
sshcopy myvps
sshcopy myvps -KeyName id_vps    # Use specific key
```

---

## ⚡ Remote Command Execution

### Execute Single Command
```powershell
# Check disk space
sshcmd myvps "df -h"

# Check running processes
sshcmd myvps "ps aux | grep nginx"

# Restart service
sshcmd myvps "sudo systemctl restart apache2"

# Get system info
sshcmd myvps "uname -a"
```

---

## 🌐 Network Utilities

### Test SSH Port
```powershell
Test-SSHPort example.com          # Test port 22
Test-SSHPort example.com -Port 2222 -Timeout 10
```

### Get Public IP
```powershell
Get-PublicIP    # Shows your public IP address
```

### Test Latency
```powershell
Test-Latency example.com          # Ping 4 times
Test-Latency example.com -Count 10
```

---

## 📁 Enhanced Navigation

### Directory Bookmarks
```powershell
# Bookmark current directory
bm projects    # Saves current location as 'projects'

# Go to bookmark
go projects    # Changes to bookmarked directory

# List bookmarks
bms           # Shows all bookmarks
```

### Quick Navigation
```powershell
..      # Go up one directory
...     # Go up two directories
....    # Go up three directories

ll      # List files with size formatting
la      # List all files including hidden

mkcd newdir    # Create and enter directory
```

---

## 📊 Quick Status

### System Information
```powershell
sysinfo           # Basic system info
sysinfo -Detailed # Detailed with IP, uptime

qs               # Quick project status
disk             # Disk space usage
top              # Top 10 processes
top -Count 20    # Top 20 processes
```

### File Operations
```powershell
# Find files
find config           # Search for files matching 'config'
find *.log -Path /var/log

# Search in files
grep "error" -Include *.log
grep "function" -Path . -Include *.ps1

# File operations
touch newfile.txt     # Create or update file
```

---

## 🎨 Visual Features

### Color-Coded Messages
- ✅ **Green:** Success messages
- ❌ **Red:** Error messages
- ⚠️ **Yellow:** Warning messages
- ℹ️ **Cyan:** Information messages

### Status Indicators
- 📁 Current location
- 🌿 Git branch and status
- 🔐 SSH connection info
- 📊 File statistics

---

## 🌿 Git Shortcuts

```powershell
gs      # git status (short format)
ga .    # git add
gc "message"  # git commit
gp      # git push
gpl     # git pull
gd      # git diff
gco main      # git checkout
gb      # git branch
gl      # git log (last 10 commits)
glog    # git log (last 20, all branches)
```

---

## 💡 Tips & Best Practices

### 1. **Set Up Passwordless SSH**
```powershell
# Generate key
sshkey -Name id_vps -Type ed25519

# Add connection
ssha myvps example.com -User admin -IdentityFile "$HOME\.ssh\id_vps"

# Copy key to server
sshcopy myvps -KeyName id_vps

# Now connect without password
sshc myvps
```

### 2. **Quick VPS Setup**
```powershell
# Save your VPS
ssha prod vps.example.com -User root -Port 22

# Copy SSH key
sshcopy prod

# Execute commands
sshcmd prod "apt update && apt upgrade -y"
sshcmd prod "ufw status"

# Transfer files
scpup C:\deploy\app.zip /opt/app.zip prod
```

### 3. **Efficient Remote Work**
```powershell
# Check multiple VPS
sshcmd vps1 "df -h"
sshcmd vps2 "df -h"
sshcmd vps3 "df -h"

# Backup from remote
scpdown /var/www/html C:\backups\html-$(Get-Date -F 'yyyyMMdd') vps1 -Recurse
```

### 4. **Performance on Slow Connections**
- The profile automatically uses compact prompt on SSH
- Progress bars are disabled for faster operations
- Git status is optimized with quick checks

---

## 🆘 Help Commands

```powershell
help-ssh       # SSH command reference
help-all       # All available commands
Get-Command -Module *   # List all available commands
```

---

## 📝 Configuration Files

### SSH Connections Storage
Saved connections are stored in:
```
$HOME\.ssh\ps_connections.json
```

You can manually edit this file if needed.

### SSH Config Integration
For system-wide SSH config, edit:
```
$HOME\.ssh\config
```

Example SSH config:
```
Host myvps
    HostName 192.168.1.100
    User admin
    Port 22
    IdentityFile ~/.ssh/id_vps
```

---

## 🎯 Common Workflows

### **Workflow 1: Initial VPS Setup**
```powershell
# 1. Test connection
Test-SSHPort myvps.com -Port 22

# 2. Add connection (with password first)
ssha myvps myvps.com -User root

# 3. Generate and copy SSH key
sshkey -Name id_myvps -Type ed25519
sshcopy myvps -KeyName id_myvps

# 4. Update connection with key
ssha myvps myvps.com -User root -IdentityFile "$HOME\.ssh\id_myvps"

# 5. Test passwordless connection
sshc myvps
```

### **Workflow 2: Deploy Application**
```powershell
# 1. Create deployment package
Compress-Archive -Path C:\app\* -DestinationPath C:\deploy\app.zip

# 2. Upload to VPS
scpup C:\deploy\app.zip /tmp/app.zip prod

# 3. Extract and deploy remotely
sshcmd prod "cd /opt && unzip -o /tmp/app.zip && systemctl restart myapp"

# 4. Check status
sshcmd prod "systemctl status myapp"
```

### **Workflow 3: Backup VPS Data**
```powershell
# Create backup directory
$backupDir = "C:\backups\vps-$(Get-Date -F 'yyyyMMdd-HHmmss')"
mkcd $backupDir

# Download important files
scpdown /etc/nginx/nginx.conf .\nginx.conf prod
scpdown /var/www/html .\html prod -Recurse
scpdown /home/user/scripts .\scripts prod -Recurse

# Create archive
Compress-Archive -Path $backupDir\* -DestinationPath "C:\backups\vps-backup-$(Get-Date -F 'yyyyMMdd').zip"
```

---

## 🔒 Security Best Practices

1. **Use SSH Keys Instead of Passwords**
   - More secure than passwords
   - Enables passwordless login
   - Can be revoked easily

2. **Use Strong Key Types**
   - Prefer `ed25519` over `rsa`
   - Minimum RSA key size: 4096 bits

3. **Protect Your Private Keys**
   - Never share private keys
   - Keep them in `$HOME\.ssh\`
   - Set proper permissions

4. **Use Non-Standard SSH Ports**
   - Reduces automated attacks
   - Configure with `-Port` parameter

5. **Regular Updates**
   ```powershell
   sshcmd myvps "apt update && apt upgrade -y"    # Debian/Ubuntu
   sshcmd myvps "yum update -y"                   # CentOS/RHEL
   ```

---

## 🚀 Next Steps

1. **Save Your Frequent Connections**
   ```powershell
   sshl    # Check what you've saved
   ```

2. **Set Up SSH Keys**
   ```powershell
   sshkey -Type ed25519
   sshcopy <connection>
   ```

3. **Explore the Visual Features**
   - Notice the different prompt in SSH vs local
   - Try the status indicators
   - Use quick status with `qs`

4. **Customize Your Profile**
   - Edit: `$PROFILE`
   - Add your own functions and aliases
   - Save frequently used commands

---

## 🎉 You're Ready!

Your PowerShell is now optimized for SSH/VPS access with:
- ✅ Beautiful visual enhancements
- ✅ Efficient remote session handling
- ✅ Powerful SSH connection management
- ✅ Quick file transfer capabilities
- ✅ Comprehensive key management
- ✅ Remote command execution

Type `help-ssh` anytime for quick reference!

Enjoy your enhanced PowerShell experience! 🚀
