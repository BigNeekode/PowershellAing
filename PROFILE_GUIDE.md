# 🚀 Enhanced PowerShell Profile Guide

Complete guide to using your visually enhanced, Claude Code-optimized PowerShell profile.

## ✨ What's New - Visual Enhancements

🎨 **Beautiful Visual Interface**
- Stunning prompt with Unicode icons and structured layout
- Animated progress indicators and visual status feedback
- Comprehensive file type icons for better file identification
- Modern welcome screen with ASCII art borders
- Enhanced color scheme throughout all functions

🎯 **Key Visual Features**
- 📊 Enhanced Quick Status with project icons and visual hierarchy
- 🌈 Improved PSReadLine colors for better syntax highlighting
- ⚡ Visual status indicators (✅❌⚠️ℹ️) throughout
- 📁 Rich file listings with 40+ file type icons
- 🎉 Welcome screen with organized sections and tips

## Table of Contents
- [Quick Start](#quick-start)
- [Visual Enhancements](#visual-enhancements)
- [Claude Code Optimizations](#claude-code-optimizations)
- [Navigation Commands](#navigation-commands)
- [Git Commands](#git-commands)
- [Project Commands](#project-commands)
- [Search & File Commands](#search--file-commands)
- [Utility Functions](#utility-functions)
- [Customization](#customization)

---

## 🎨 Visual Enhancements

Your PowerShell profile now features a modern, visually appealing interface with enhanced usability.

### Enhanced Prompt Display
The prompt now shows:
- 👤 **User info** with computer name
- 📁 **Current directory** with visual path indicators
- 🏠 **Home directory detection** with special formatting
- 🌿 **Git branch** with status indicators (✅ clean, ✏️ modified)
- 🎯 **Structured layout** with visual borders

**Example:**
```
┌─ 👤 Game 01 💻 DESKTOP-ABC
│  📁 C:\Projects\MyApp 📁src
│  🌿 main ✅
└─ ▶
```

### Visual Status Indicators
Throughout the profile, you'll see consistent visual indicators:
- ✅ **Success** operations
- ❌ **Error** conditions
- ⚠️ **Warnings** and alerts
- ℹ️ **Information** messages
- 📦 **Installation** processes
- 🔧 **Progress** indicators

### Enhanced File Listings
The `ls-detailed` command now shows:
- 📁 **Directory icons** for folders
- 🔷 **Script files** (.ps1, .js, .py, etc.)
- 📝 **Documentation** (.md, .txt)
- 🖼️ **Media files** (.jpg, .png, .mp4)
- 📦 **Archives** (.zip, .rar)
- ⚙️ **Configuration** (.json, .xml)
- And 30+ more file type icons!

### Enhanced Quick Status
The `qs` command now displays:
- 📊 **Visual project information** with icons
- 🟢 **Node.js projects** detection
- 🐍 **Python projects** detection
- 🦀 **Rust projects** detection
- 💎 **C#/.NET projects** detection
- 🐹 **Go projects** detection
- 📁 **Generic projects**
- 🕐 **Recently modified files** with timestamps

### Progress Indicators
Long-running operations now show:
- ⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏ **Animated spinners**
- █░░░ **Progress bars** with color coding
- 📊 **Percentage completion**
- 🎨 **Color-coded status** (red→yellow→green)

### Welcome Screen
First-time startup displays:
- 🎉 **ASCII art borders** and organized layout
- 💻 **System information** with current time
- ⚡ **Quick command reference** with visual icons
- 💡 **Pro tips** for enhanced usage
- 🚀 **Ready message** with visual flair

---

## Quick Start

### Most Useful Commands

```powershell
# 🎨 Get visual project overview
qs

# 🌳 See project structure with icons
tree

# 🌿 Check git status (enhanced visual)
gss

# 🧪 Run tests (auto-detects framework)
test

# 🔨 Build project (auto-detects build system)
build

# 🔍 Search for text in files
grep "searchterm"

# 📖 View file with line numbers and syntax highlighting
cat filename.js

# 📊 Enhanced file listing with icons
ls-detailed

# 📦 Install missing modules with visual feedback
Install-MissingModule "ModuleName"
```

---

## Claude Code Optimizations

These features make your terminal output cleaner and easier for Claude to parse:

### Clean Output
- **Concise errors**: Errors show only essential info
- **No progress bars**: Cleaner command output
- **UTF-8 encoding**: Proper character support
- **Auto-sized tables**: Better formatting

### Why This Matters
Claude Code works better when terminal output is:
- Structured and consistent
- Free from visual clutter
- Easy to parse programmatically
- Shows line numbers and file paths clearly

---

## Navigation Commands

### Directory Navigation
```powershell
# Go up one directory
..

# Go up two directories
...

# Go up three directories
....

# Make directory and enter it
mkcd mynewfolder
```

### List Files
```powershell
# List all files with details (table format)
ll

# List all files including hidden
la

# Standard listing
ls
```

---

## Git Commands

### Quick Shortcuts
```powershell
# Git status
gs

# Git status (clean format for Claude)
gss

# Add files
ga file.txt
ga .

# Commit with message
gc "your commit message"

# Push
gp

# Pull
gpl

# Diff
gd

# Checkout
gco branch-name

# Branch
gb              # list branches
gb new-branch   # create branch

# Pretty log (last 10 commits)
gl
```

### Your Prompt Shows Git Info
The prompt automatically displays:
- Current git branch in **magenta**
- `*` symbol if uncommitted changes exist

---

## Project Commands

### Quick Status
```powershell
# See everything at a glance
qs
```
Shows:
- Current directory
- Git branch and status
- Project type (Node, Python, Rust, etc.)
- 3 most recently modified files

### Project Info
```powershell
# Detailed project information
pinfo
```
Shows:
- Project location
- Project type (detects package.json, requirements.txt, etc.)
- Git branch
- Total file count

### Project Structure
```powershell
# Show directory tree
tree

# Tree with custom depth
tree -Depth 5

# Tree of specific directory
tree -Path ./src
```

### Run Tests
```powershell
# Auto-detect and run tests
test

# Run specific test
test "test name"
```
Supports: npm, pytest, cargo, dotnet

### Build Project
```powershell
# Auto-detect and build
build
```
Supports: npm, cargo, dotnet, go

---

## Search & File Commands

### View Files
```powershell
# Show file with line numbers (first 50 lines)
cat myfile.js

# Show specific number of lines
cat myfile.js -Lines 100
```

### Search Content
```powershell
# Search for text in all files
grep "searchterm"

# Search in specific path
grep "searchterm" -Path ./src

# Search specific file types
grep "function" -Include "*.js"

# Examples
grep "TODO"                    # Find all TODOs
grep "import" -Include "*.ts"  # Find imports in TypeScript
grep "error" -Path ./logs      # Search in logs directory
```

### Find Files
```powershell
# Find files by name
Find-File config

# This searches recursively for any file with "config" in the name
```

---

## Utility Functions

### System Info
```powershell
# Get your public IP
Get-PublicIP

# Get directory size
Get-DirSize
Get-DirSize ./node_modules
```

### File Operations
```powershell
# Create empty file (like Unix touch)
touch newfile.txt

# Remove directory and contents
rm-rf folder-name

# Extract zip/archive
Extract-Archive file.zip
```

### Development
```powershell
# Start simple web server on port 8000
Start-WebServer

# Start on custom port
Start-WebServer 3000

# Find where a command is located
which git
which node
which python
```

### Profile Management
```powershell
# Edit this profile
Edit-Profile

# Reload profile after editing
Reload-Profile
```

---

## Customization

### Edit Your Profile
```powershell
Edit-Profile
```
Or manually edit: `C:\Users\Game 01\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

### Common Customizations

#### Change Prompt Colors
Edit the `prompt` function (around line 41):
```powershell
$user = "$ESC[32m$env:USERNAME$ESC[0m"  # 32 = green, try 33 (yellow), 34 (blue)
$path = "$ESC[36m$location$ESC[0m"      # 36 = cyan
$gitBranch = " $ESC[35m($branch...)$ESC[0m"  # 35 = magenta
```

Color codes:
- 30 = Black
- 31 = Red
- 32 = Green
- 33 = Yellow
- 34 = Blue
- 35 = Magenta
- 36 = Cyan
- 37 = White

#### Add Your Own Aliases
Add to the profile:
```powershell
# Custom alias examples
function mycommand { Write-Host "Hello!" }
Set-Alias -Name mc -Value mycommand

# Project-specific shortcuts
function dev { npm run dev }
function lint { npm run lint }
```

#### Disable Welcome Message
Comment out or remove the welcome section (lines 335-348):
```powershell
# Write-Host ""
# Write-Host "PowerShell $($PSVersionTable.PSVersion.ToString())" -ForegroundColor Cyan
# ...
```

#### Clear Screen on Startup
Uncomment line 295:
```powershell
Clear-Host
```

---

## Tips for Working with Claude Code

### 1. Use Quick Status Before Asking Claude
```powershell
qs
```
This gives Claude context about your project instantly.

### 2. Share File Structure
```powershell
tree
```
Helps Claude understand your project organization.

### 3. Show Files with Line Numbers
```powershell
cat myfile.js
```
Makes it easy to reference specific lines when discussing code.

### 4. Clean Git Status
```powershell
gss
```
Shows what's changed in a format Claude can easily parse.

### 5. Search Before Asking
```powershell
grep "functionName"
```
Find where code is located before asking Claude to modify it.

### 6. Use Test and Build Commands
```powershell
test
build
```
Let Claude verify changes worked by running these commands.

---

## Keyboard Shortcuts (PSReadLine)

These work automatically in your terminal:

- **↑/↓ arrows**: Search command history (start typing, then arrow up)
- **Tab**: Autocomplete with menu
- **Ctrl+Space**: Show suggestions
- **Ctrl+R**: Search command history
- **Ctrl+Left/Right**: Move by word

---

## Troubleshooting

### Profile Not Loading
```powershell
# Check if profile exists
Test-Path $PROFILE

# View profile location
$PROFILE

# Load profile manually
. $PROFILE
```

### Command Not Found
Some commands require external tools:
- `git` commands need Git installed
- `tree` uses Windows tree.exe or PowerShell fallback
- `test` and `build` need the respective tools (npm, cargo, etc.)

### Permission Errors
If you can't run scripts:
```powershell
# Check execution policy
Get-ExecutionPolicy

# Set to allow local scripts (run as Administrator)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Reset to Default
If something breaks:
1. Backup your profile: `Copy-Item $PROFILE "$PROFILE.backup"`
2. Delete it: `Remove-Item $PROFILE`
3. Restart PowerShell
4. Restore from backup or recreate

---

## Advanced Usage

### Chain Commands
```powershell
# Run multiple commands
gs && gd

# Build then test
build && test

# Navigate and list
cd myproject && ll
```

### Use in Scripts
All functions are available in your scripts:
```powershell
# myscript.ps1
Show-QuickStatus
$files = Find-File "config"
foreach ($file in $files) {
    cat $file
}
```

### Pipe Output
```powershell
# Search and count results
grep "TODO" | Measure-Object

# Find large files
Get-ChildItem -Recurse | Where-Object { $_.Length -gt 1MB }
```

---

## Profile Location

**Profile Path**: `C:\Users\Game 01\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

**This Guide**: `C:\Users\Game 01\Documents\PowerShell\PROFILE_GUIDE.md`

---

## Quick Reference Card

| Command | Description |
|---------|-------------|
| 🎨 **`qs`** | Enhanced visual status overview |
| 🌳 **`tree`** | Show directory structure |
| 🌿 **`gss`** | Git status with visual indicators |
| 📖 **`cat file`** | Show file with line numbers & colors |
| 🔍 **`grep "text"`** | Search in files |
| 🧪 **`test`** | Run tests (auto-detect) |
| 🔨 **`build`** | Build project (auto-detect) |
| 📊 **`ls-detailed`** | Enhanced file listing with icons |
| ⬆️ **`..`** | Go up directory |
| 📁 **`ll`** | List files (table format) |
| 🌿 **`gs`** | Git status |
| ➕ **`ga .`** | Git add all |
| 💾 **`gc "msg"`** | Git commit with message |
| 🚀 **`gp`** | Git push |
| 📋 **`pinfo`** | Detailed project info |
| ⚙️ **`Edit-Profile`** | Edit this profile |
| 🔄 **`Reload-Profile`** | Reload after edits |
| 📦 **`Install-MissingModule`** | Install modules with visual feedback |
| ✅ **`Show-Success`** | Show success message |
| ❌ **`Show-Error`** | Show error message |
| ⚠️ **`Show-Warning`** | Show warning message |
| ℹ️ **`Show-Info`** | Show info message |

### Visual Indicators Reference
- ✅ **Success** - Operations completed successfully
- ❌ **Error** - Operations failed or encountered issues
- ⚠️ **Warning** - Important notices or cautions
- ℹ️ **Info** - General information
- 📦 **Installing** - Module installation in progress
- 🔧 **Progress** - Long-running operations
- 📁 **Directory** - Folder/directory indicator
- 🔷 **PowerShell** - .ps1 script files
- 📝 **Document** - .md, .txt files
- 🐍 **Python** - .py files
- 💎 **C#** - .cs files
- 🟢 **Node.js** - npm projects
- 🦀 **Rust** - Cargo projects

---

**Enjoy your optimized PowerShell experience!**

For issues or improvements, edit your profile with `Edit-Profile` and reload with `Reload-Profile`.
