# ⚡ Ultra-Fast PowerShell Profile

A **blazing-fast**, streamlined PowerShell profile optimized for instant startup (<100ms). Clean, efficient, and focused on essential developer productivity without the bloat.

## 🚀 Performance

- **~50ms load time** after initial cache
- **246 lines** (90% smaller than typical profiles)
- **Lazy loading** for non-critical modules
- **Zero parse errors** with proper UTF-8 encoding
- **No background jobs** slowing down your prompt

### Benchmark Results
```
Test 1: 309.8ms (first load with module caching)
Test 2: 51.66ms
Test 3: 50.96ms
Test 4: 49.04ms
Test 5: 53.65ms

Average: 103ms (subsequent loads ~50ms)
```

## ✨ Features

### 🎨 Smart Prompt
- **Git-aware** - Shows branch and dirty status
- **Path truncation** - Smart path shortening for readability
- **SSH/Remote detection** - Adapts for remote sessions
- **Color-coded** - Clear visual hierarchy
- **Fast git operations** - Direct calls, no job overhead

### 📦 Module Management
- **PSReadLine** - Enhanced command-line editing with IntelliSense
- **Terminal-Icons** - File icons (lazy-loaded on first prompt)
- **posh-git** - Git integration (lazy-loaded on first prompt)
- **Manual install function** - Install optional modules on demand

### ⚡ Essential Shortcuts

**Navigation:**
```powershell
..          # Go up one directory
...         # Go up two directories
....        # Go up three directories
mkcd mydir  # Create and enter directory
```

**File Operations:**
```powershell
ll          # List files with details
la          # List all files including hidden
ff myfile   # Find files by name pattern
which cmd   # Show command location
touch file  # Create empty file
```

**Git Shortcuts:**
```powershell
gs          # git status
ga .        # git add
gc "msg"    # git commit -m
gp          # git push
gpl         # git pull
gd          # git diff
gco branch  # git checkout
gb          # git branch
gl          # git log (pretty graph, last 10)
```

**Profile Management:**
```powershell
Edit-Profile        # Open profile in VS Code
Reload-Profile      # Reload profile without restarting
```

### 🛠️ Lazy-Loaded Utilities

These load only when you call them (no startup overhead):

**System Info:**
```powershell
sysinfo             # Show OS, uptime, CPU, RAM
top                 # Top processes by CPU
top 20              # Top 20 processes
netinfo             # Network configuration
Test-Port host 80   # Test if port is open
Get-DirSize         # Get current directory size
Get-DirSize C:\     # Get specific directory size
```

**SSH Helpers:**
```powershell
Get-SSHHosts        # List SSH hosts from config
Add-SSHKey          # Add SSH key to agent
```

**Development:**
```powershell
serve               # Start Python HTTP server on port 8000
serve 3000          # Start HTTP server on port 3000
```

**Module Management:**
```powershell
Install-ProfileModules  # Install all optional modules
```

## 📥 Installation

### Quick Install

1. **Backup your existing profile:**
   ```powershell
   Copy-Item $PROFILE "$PROFILE.backup" -ErrorAction SilentlyContinue
   ```

2. **Copy the new profile:**
   ```powershell
   Copy-Item Microsoft.PowerShell_profile.ps1 $PROFILE
   ```

3. **Restart PowerShell** - Your profile now loads instantly!

### First Run

On first run, the profile will:
- ✅ Load PSReadLine if available
- ✅ Configure intelligent history and tab completion
- ✅ Set up color scheme
- ✅ Cache module locations for faster subsequent loads

**Optional modules** (installed on demand):
```powershell
Install-ProfileModules
```

This will install: PSReadLine, Terminal-Icons, posh-git, PSFzf, PSScriptAnalyzer, ImportExcel

## 🎯 Design Philosophy

This profile is built on three principles:

1. **Speed First** - Every millisecond of startup time matters
2. **Lazy Loading** - Load features only when needed
3. **Zero Bloat** - Only essential features, nothing extra

### What Was Removed?

To achieve <100ms load times, we removed:
- ❌ Background job-based git status (too slow)
- ❌ Auto-installation on every startup
- ❌ Heavy modules loaded synchronously
- ❌ Extensive function libraries (2000+ lines removed)
- ❌ Complex visual indicators with spinners
- ❌ API integrations, Docker helpers, etc.

**You can still add these back** if needed, but they'll be lazy-loaded only when called.

## 🔧 Configuration

### PSReadLine Settings

The profile includes optimized PSReadLine configuration:
- **Predictive IntelliSense** from history
- **ListView style** for suggestions
- **Smart history search** with up/down arrows
- **Tab completion** with menu
- **Color-coded syntax** highlighting

### Customizing the Prompt

Edit the `prompt` function in [Microsoft.PowerShell_profile.ps1](Microsoft.PowerShell_profile.ps1#L62-L130) to customize:
- Colors
- Path display format
- Git branch formatting
- Remote session indicators

### Adding Custom Functions

Add your functions at the end of the profile. For best performance:
- Keep them small and focused
- Use lazy loading for heavy operations
- Avoid module imports at the top level

## 📊 Performance Testing

Test your profile load time:
```powershell
.\test-profile-speed.ps1
```

This will run 5 load tests and show average time.

## 🛠️ Troubleshooting

### Profile loads slowly
```powershell
# Test load time
Measure-Command { . $PROFILE }

# Check for slow git repos
# The prompt checks .git - slow in large repos with many changes
```

### Git status not showing
```powershell
# Make sure you're in a git repository
git status

# Check git is in PATH
which git
```

### Modules not loading
```powershell
# Install missing modules
Install-ProfileModules

# Check module path
$env:PSModulePath

# List available modules
Get-Module -ListAvailable
```

### Colors not working
```powershell
# Ensure you're using a modern terminal
# Windows Terminal, VS Code terminal recommended
# Legacy console.exe has limited color support
```

## 📈 Performance Comparison

| Metric | Old Profile | New Profile | Improvement |
|--------|-------------|-------------|-------------|
| **Lines** | 2,419 | 246 | 90% reduction |
| **Load Time** | ~323ms | ~50ms | 6.5x faster |
| **Modules (sync)** | 10+ | 1 | 90% reduction |
| **Parse Errors** | Multiple | 0 | ✅ Fixed |
| **Background Jobs** | Yes | No | ✅ Removed |

## 🤝 Contributing

Want to add features? Great! Just remember:

1. **Keep it fast** - Prefer lazy loading
2. **Test performance** - Use test-profile-speed.ps1
3. **No auto-install** - Let users choose when to install
4. **Document it** - Update this README

## 📄 Files

- **[Microsoft.PowerShell_profile.ps1](Microsoft.PowerShell_profile.ps1)** - Main profile (246 lines)
- **[test-profile-speed.ps1](test-profile-speed.ps1)** - Performance testing script
- **profile_performance_test.md** - Performance test documentation

## 🎓 Learning Resources

- [about_Profiles (Microsoft Docs)](https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_profiles)
- [PSReadLine Documentation](https://docs.microsoft.com/powershell/module/psreadline/)
- [PowerShell Performance Tips](https://docs.microsoft.com/powershell/scripting/dev-cross-plat/performance/performance-tips)

## 📜 License

MIT License - Feel free to use and modify

---

**⚡ Instant PowerShell, Zero Wait Time**

*Optimized for developers who value their time. Every millisecond matters.*
