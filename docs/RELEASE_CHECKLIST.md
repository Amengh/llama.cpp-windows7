# GitHub Release Checklist

Use this checklist when preparing a GitHub release.

## Pre-Release

- [ ] All 7 patches applied and tested
- [ ] Build succeeds on Windows 7 SP1
- [ ] Build succeeds on Windows 10/11
- [ ] Executables run without DLL errors
- [ ] Server responds to HTTP requests
- [ ] CLI generates text correctly

## Files to Include

### Required
- [ ] `README.md` - Main project README
- [ ] `LICENSE` - MIT License (from upstream)
- [ ] `patches/` - All 7 patch files
- [ ] `docs/WINDOWS7_BUILD_GUIDE.md`
- [ ] `docs/WINDOWS7_API_CHANGES.md`
- [ ] `docs/WINDOWS7_TROUBLESHOOTING.md`
- [ ] `apply_patches.sh`
- [ ] `apply_patches.bat`
- [ ] `build_win7_final.bat`

### Optional
- [ ] Pre-built binaries (for releases)
- [ ] Example models/configurations
- [ ] Screenshots of successful builds

## GitHub Repository Setup

1. **Create new repository**:
   ```
   Name: llama.cpp-win7
   Description: Windows 7 compatible fork of llama.cpp
   ```

2. **Topics/Tags**:
   - `llama.cpp`
   - `windows-7`
   - `llm`
   - `ai`
   - `mingw`
   - `compatibility`

3. **README sections**:
   - Project description
   - Quick start
   - Build instructions
   - What's different from upstream
   - Known limitations
   - Credits

## Release Notes Template

```markdown
## llama.cpp Windows 7 Compatibility Release v{VERSION}

This release adds Windows 7 SP1 compatibility to llama.cpp while maintaining full Windows 10/11 support.

### Changes from Upstream
- Modified 8 files for Windows 7 compatibility
- Replaced Windows 8+ APIs with Windows 7 compatible alternatives
- Added LLAMA_WIN7_COMPAT CMake option
- Conditional Unix domain socket support

### Build Requirements
- CMake 3.19.x (last version supporting Windows 7)
- MinGW-w64 GCC or Visual Studio 2019
- Windows 7 SP1 or later

### Downloads
- Source code (with patches applied)
- Pre-built binaries (optional)

### Verification
```

## Post-Release

- [ ] Test download and build from clean environment
- [ ] Verify all links in README work
- [ ] Monitor for issues

## Maintenance

When upstream llama.cpp updates:

1. Check if modified files changed
2. Rebase or merge upstream changes
3. Test patches still apply cleanly
4. Update version tags
