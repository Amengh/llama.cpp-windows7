# Patch Summary

This directory contains 7 patches that add Windows 7 compatibility to llama.cpp.

## Patch List

| # | File | Description |
|---|------|-------------|
| 01 | `01-httplib-root.patch` | Root httplib.h - Conditional afunix.h inclusion and AF_UNIX handling |
| 02 | `02-vendor-httplib-h.patch` | Vendor httplib.h - Remove Windows 10 requirement error |
| 03 | `03-vendor-httplib-cpp.patch` | Vendor httplib.cpp - Replace Windows 8+ APIs with Win7 compatible versions |
| 04 | `04-server-http.patch` | Server - Add Windows 7 runtime check for Unix domain sockets |
| 05 | `05-cmake-root.patch` | Root CMakeLists.txt - Add LLAMA_WIN7_COMPAT option |
| 06 | `06-cmake-vendor-httplib.patch` | Vendor CMakeLists.txt - Propagate Win7 flags |
| 07 | `07-cmake-ggml.patch` | GGML CMakeLists.txt - Propagate Win7 flags |

## Applying Patches

### Automatic (All Platforms)

```bash
# Linux/macOS/MSYS2/Git Bash
bash apply_patches.sh
```

```batch
:: Windows Command Prompt (requires Git for Windows)
apply_patches.bat
```

### Manual (Any Platform)

```bash
# Apply in order
patch -p1 < patches/01-httplib-root.patch
patch -p1 < patches/02-vendor-httplib-h.patch
patch -p1 < patches/03-vendor-httplib-cpp.patch
patch -p1 < patches/04-server-http.patch
patch -p1 < patches/05-cmake-root.patch
patch -p1 < patches/06-cmake-vendor-httplib.patch
patch -p1 < patches/07-cmake-ggml.patch
```

Or using Git:

```bash
git apply patches/01-httplib-root.patch
git apply patches/02-vendor-httplib-h.patch
...
```

## Reversing Patches

```bash
patch -p1 -R < patches/01-httplib-root.patch
```

## API Replacements (Patch 03 Details)

Patch 03 contains the most important changes:

| Old API (Windows 8+) | New API (Windows 7+) | Line |
|---------------------|---------------------|------|
| `CreateFile2` | `CreateFileW` | ~1467 |
| `CreateFileMappingFromApp` | `CreateFileMapping` | ~1485 |
| `MapViewOfFileFromApp` | `MapViewOfFile` | ~1499 |

## Verification

After applying patches, verify with:

```bash
# Check for Windows 7 compatibility macro
grep -r "_WIN32_WINNT=0x0601" CMakeLists.txt ggml/CMakeLists.txt

# Check for API replacement
grep "CreateFileW" vendor/cpp-httplib/httplib.cpp

# Check for AF_UNIX conditional
grep "_WIN32_WINNT >= 0x0602" httplib.h
```
