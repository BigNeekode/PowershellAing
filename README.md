# 🚀 Ultimate PowerShell Profile

A comprehensive, feature-rich PowerShell profile designed for developers, system administrators, and power users. This profile transforms your standard PowerShell experience into a powerful, productive development environment with extensive functionality across multiple domains.

## ✨ Features

### 🔧 **Module Management**
- **Auto-installation** of essential PowerShell modules
- **Smart module detection** and dependency management
- **One-click updates** for all installed modules
- **Graceful fallback** when modules aren't available

### 💻 **Development Workflow**
- **Multi-language support** (Node.js, Python, .NET, Rust, Go, Java, PHP, Ruby)
- **Package manager integration** (npm, pip, cargo, composer, bundler, etc.)
- **Docker integration** with container lifecycle management
- **Database deployment** shortcuts (MongoDB, PostgreSQL, Redis)
- **Project scaffolding** for React, Next.js, and other frameworks
- **Virtual environment** management for Python

### ⚙️ **System Administration**
- **Process management** and monitoring
- **Service administration** with safety checks
- **Network diagnostics** and port testing
- **Performance monitoring** (CPU, Memory, Disk)
- **Windows-specific utilities** (Event logs, updates, registry)
- **System cleanup** and maintenance tools

### 🎯 **Productivity Enhancements**
- **Directory bookmarks** with persistent storage
- **Enhanced history** search and management
- **Smart file operations** with safety confirmations
- **Quick project status** checks
- **Visual feedback** and progress indicators

### 🛡️ **Safety Features**
- **Confirmation prompts** for dangerous operations
- **Safe deletion** with recycle bin integration
- **Automatic backups** before file operations
- **Protected aliases** for common commands

### 🌐 **API & Cloud Integration**
- **REST API testing** utilities
- **GitHub integration** (repo info, search)
- **Weather API** integration
- **Clipboard management** tools
- **JSON processing** and validation
- **Cloud service** helpers (Azure, AWS ready)

### 🎨 **Enhanced UI/UX**
- **Color-coded output** for better readability
- **Progress bars** for long-running operations
- **Visual notifications** for task completion
- **Organized command structure** with clear sections

## 🚀 Quick Start

### Installation

1. **Clone or download** this repository
2. **Copy the profile** to your PowerShell directory:
   ```powershell
   # Backup your existing profile (if any)
   mv $PROFILE $PROFILE.backup

   # Copy the enhanced profile
   cp Microsoft.PowerShell_profile.ps1 $PROFILE
   ```
3. **Restart PowerShell** or reload your profile:
   ```powershell
   . $PROFILE
   ```

### First Run

The profile will automatically:
- ✅ Install essential modules (PSReadLine, Terminal-Icons, posh-git)
- ✅ Configure enhanced PSReadLine settings
- ✅ Set up color schemes and formatting
- ✅ Display welcome message with quick commands

## 📚 Command Reference

### 📦 **Package Management**
```powershell
install-pkgs          # Install packages for current project
Install-MissingModule # Install any missing PowerShell module
Update-AllModules     # Update all installed modules
```

### 🐳 **Docker Integration**
```powershell
docker-status         # Show containers and images
Start-DockerContainer # Start a new container
Stop-DockerContainer  # Stop and remove container
Start-MongoDB        # Quick MongoDB container
Start-PostgreSQL     # Quick PostgreSQL container
Start-Redis          # Quick Redis container
```

### 🔧 **Development Tools**
```powershell
dev                   # Start development server
test                  # Run project tests
build                 # Build project
Create-ReactApp myapp # Create new React app
Create-NextApp myapp  # Create new Next.js app
New-PythonVenv        # Create Python virtual environment
```

### ⚙️ **System Administration**
```powershell
top                   # Show top CPU processes
perf                  # System performance overview
services              # Show service status
netinfo               # Network configuration
uptime                # System uptime
clean-temp            # Clean temporary files
Show-EventLog         # Display event logs
```

### 📁 **Productivity**
```powershell
bookmarks             # Manage directory bookmarks
Set-DirectoryBookmark # Set a bookmark
Get-DirectoryBookmark # Jump to bookmark
hist                  # Show command history
search-hist pattern   # Search history
qs                    # Quick project status
```

### 🌐 **API & Cloud**
```powershell
api-test https://api.example.com  # Test API endpoints
github-search "search term"       # Search GitHub repositories
weather "City Name"               # Get weather information
Get-PublicIP                      # Show public IP address
```

### 🛡️ **Safety & Backup**
```powershell
rm path/to/file       # Safe deletion with confirmation
backup-file file.txt  # Create timestamped backup
Clear-RecycleBin      # Clear recycle bin (with confirmation)
```

## 🎨 **Visual Features**

### Color-Coded Output
- 🟢 **Green**: Success operations, safe files
- 🟡 **Yellow**: Warnings, large files
- 🔴 **Red**: Errors, dangerous operations
- 🔵 **Cyan**: Information and progress
- 🟣 **Magenta**: API responses and JSON

### Progress Indicators
- `[▶]` Activity indicators for running tasks
- `[■]` Progress bars for long operations
- `✓` Success confirmations
- `✗` Error notifications

## ⚙️ **Configuration**

### Environment Variables
The profile respects these environment variables:
- `PSModulePath` - Module search paths
- `Path` - System PATH variable
- `TEMP/TMP` - Temporary file locations

### Customizable Settings
Edit these sections in the profile to customize:
- **Module versions** in `$modulesToInstall`
- **Color schemes** in PSReadLine configuration
- **Default behaviors** for various functions

## 🔗 **Integration Examples**

### GitHub API Integration
```powershell
# Get repository information
github-repo "microsoft" "powershell"

# Search for repositories
github-search "powershell profile"
```

### REST API Testing
```powershell
# Test API endpoints
api-test "https://jsonplaceholder.typicode.com/posts"

# Make custom API calls
api-call "https://api.github.com/user" -Headers @{"Authorization" = "token $token"}
```

### Project Management
```powershell
# Quick project overview
qs

# Show project structure
tree

# Show Git status
gss

# Run tests
test

# Build project
build
```

## 🛠️ **Troubleshooting**

### Common Issues

**Profile won't load:**
```powershell
# Check syntax
powershell -NoProfile -Command "Test-Path $PROFILE"

# Validate profile syntax
powershell -NoProfile -Command "& { $ast = [System.Management.Automation.Language.Parser]::ParseFile(\"$PROFILE\", [ref]$null, [ref]$null); $ast }"
```

**Modules won't install:**
```powershell
# Check execution policy
Get-ExecutionPolicy

# Set to RemoteSigned if needed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Docker commands fail:**
```powershell
# Check if Docker Desktop is running
docker version

# Start Docker Desktop if needed
Start-DockerDesktop
```

### Debug Mode
Add this to the top of your profile for debugging:
```powershell
$DebugPreference = "Continue"
```

## 📈 **Performance Tips**

1. **Module Loading**: Modules are loaded only once and cached
2. **Lazy Loading**: Heavy operations use lazy evaluation
3. **Error Handling**: Silent failures for optional components
4. **Memory Management**: Automatic cleanup of temporary objects

## 🤝 **Contributing**

Feel free to contribute improvements:

1. **Fork** the repository
2. **Create** a feature branch
3. **Test** your changes thoroughly
4. **Submit** a pull request

### Adding New Features
- Follow the existing code structure
- Add proper error handling
- Include documentation
- Test across different PowerShell versions

## 📄 **License**

This project is open source and available under the [MIT License](LICENSE).

## 🙏 **Acknowledgments**

- **PSReadLine Team** for enhanced command-line editing
- **PowerShell Community** for modules and inspiration
- **Claude Code** for development environment optimization

---

**Happy PowerShelling!** 🚀

*This profile is designed to make your PowerShell experience more productive, safe, and enjoyable. If you have suggestions or find issues, please contribute to make it even better!*