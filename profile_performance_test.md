# PowerShell Profile Loading Performance Test

## Identified Performance Issues

### 1. Git Branch Detection in Prompt Function (Critical)
- **Location**: Lines 249-258 in Microsoft.PowerShell_profile.ps1
- **Issue**: Every time the prompt is displayed, it runs:
  - `git rev-parse --abbrev-ref HEAD 2>$null`
  - `git status --porcelain 2>$null`
- **Impact**: This executes synchronously every time a prompt is shown, causing hangs if:
  - Git repository is large/slow
  - Network issues with remote repositories
  - Git commands hang for any reason

### 2. Module Loading Loop (Moderate)
- **Location**: Lines 105-118
- **Issue**: `Get-Module -Name $moduleName -ListAvailable` can be slow on systems with many modules
- **Impact**: Initial profile loading delay

### 3. SSH Connections JSON Loading (Low)
- **Location**: Lines 2046-2055, Load-SSHConnections function
- **Issue**: JSON file parsing and loading
- **Impact**: Minimal unless file is corrupted, but checked and appears fine

### 4. Network-Dependent Operations (Variable)
- **GitHub API calls**: Weather, repo info, public IP lookups
- **VPS SSH status checks**: Get-VPSStatus function with Invoke-Expression
- **Impact**: Can timeout and block if network is slow/unavailable

## Root Cause Analysis

**Most Likely Cause**: The prompt function's git operations are blocking PowerShell startup because:
1. PowerShell starts in `C:\Users\Game 01` (not a git repo, so this shouldn't be the issue)
2. But if VS Code or another process changes directory during startup, the prompt could trigger git commands
3. The git commands don't have timeouts, so they can hang indefinitely

## Implemented Fixes

### ✅ Fixed: Add Timeouts to Git Operations
Implemented timeout logic using PowerShell jobs in the prompt function (lines 249-275):
- Git branch detection now has a 2-second timeout
- Uses background jobs to prevent blocking
- Falls back gracefully if git operations fail or timeout

### ✅ Fixed: Optimize Module Loading
Refactored module loading (lines 105-140):
- Separated critical modules (PSReadLine, Terminal-Icons, posh-git) for synchronous loading
- Optional modules now load asynchronously in background jobs
- Critical modules load first to ensure prompt functionality

### ✅ Fixed: Add Timeouts to SSH Config Loading
Enhanced Load-SSHConnections function (lines 2046-2068):
- JSON file loading now has a 3-second timeout
- Graceful fallback to empty config if loading fails
- Prevents hanging on corrupted config files

### ✅ Fixed: Add Timeouts to VPS Status Checks
Enhanced Connect-SSH function (lines 2258-2278):
- VPS status fetching now has a 5-second timeout
- Connection proceeds even if status check fails
- Prevents network timeouts from blocking SSH connections

### Alternative Fix: Lazy Load Git Info (Future Enhancement)
Consider implementing lazy loading where git status is only checked when explicitly requested rather than on every prompt display.

### Long-term Fix: Network Resilience (Future Enhancement)
Consider caching network-dependent data and implementing retry logic with exponential backoff for API calls.

## Testing Plan

1. Temporarily comment out git operations in prompt function
2. Add timeout wrappers around git commands
3. Test profile loading speed
4. Monitor for network timeouts in other operations