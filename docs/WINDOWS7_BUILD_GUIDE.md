# Windows 7 Build Guide

Complete step-by-step guide for building llama.cpp on Windows 7 SP1.

## Prerequisites

### 1. CMake 3.19.x (REQUIRED)

**IMPORTANT**: CMake 4.x does NOT support Windows 7.

Download CMake 3.19.8 (last version supporting Windows 7):
- [cmake-3.19.8-win64-x64.msi](https://cmake.org/files/v3.19/cmake-3.19.8-win64-x64.msi)

Install and add to PATH.

### 2. MinGW-w64 GCC

Option A: MSYS2 (Recommended)
```batch
# Install MSYS2 from https://www.msys2.org/
# Then in MSYS2 terminal:
pacman -S mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-make
```

Option B: WinLibs
Download from [winlibs.com](https://winlibs.com/)

### 3. Git for Windows
Download from [git-scm.com](https://git-scm.com/download/win)

## Build Steps

### Step 1: Clone Repository

```batch
git clone https://github.com/YOUR_USERNAME/llama.cpp-win7.git
cd llama.cpp-win7
```

### Step 2: Apply Patches (if not already applied)

```batch
:: Using Git Bash or MSYS2
bash apply_patches.sh

:: Or manually with Git
patch -p1 < patches/01-httplib-root.patch
patch -p1 < patches/02-vendor-httplib-h.patch
patch -p1 < patches/03-vendor-httplib-cpp.patch
patch -p1 < patches/04-server-http.patch
patch -p1 < patches/05-cmake-root.patch
patch -p1 < patches/06-cmake-vendor-httplib.patch
patch -p1 < patches/07-cmake-ggml.patch
```

### Step 3: Configure Build

```batch
mkdir build_win7
cd build_win7

:: Windows 7 configuration
cmake .. -G "MinGW Makefiles" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_C_FLAGS="-D_WIN32_WINNT=0x0601 -static" ^
    -DCMAKE_CXX_FLAGS="-D_WIN32_WINNT=0x0601 -static-libgcc -static-libstdc++ -static" ^
    -DCMAKE_EXE_LINKER_FLAGS="-static" ^
    -DLLAMA_WIN7_COMPAT=ON ^
    -DLLAMA_NATIVE=OFF ^
    -DLLAMA_BUILD_TESTS=OFF ^
    -DLLAMA_BUILD_EXAMPLES=OFF ^
    -DLLAMA_BUILD_TOOLS=ON ^
    -DLLAMA_BUILD_SERVER=ON ^
    -DLLAMA_AVX=ON ^
    -DLLAMA_AVX2=ON ^
    -DLLAMA_FMA=ON ^
    -DLLAMA_F16C=ON ^
    -DLLAMA_OPENSSL=OFF ^
    -DBUILD_SHARED_LIBS=OFF
```

### Step 4: Build

```batch
mingw32-make -j4
```

### Step 5: Copy Required DLLs

```batch
:: Copy OpenMP library (if needed)
copy "C:\msys64\ucrt64\bin\libgomp-1.dll" bin\
```

### Step 6: Verify

```batch
objdump -p bin\llama-server.exe | findstr "DLL Name"
```

Expected: Only system DLLs, no libstdc++-6.dll or libgcc_s_seh-1.dll

## CMake Options Explained

| Option | Value | Description |
|--------|-------|-------------|
| `LLAMA_WIN7_COMPAT` | `ON` | Enable Windows 7 compatibility mode |
| `LLAMA_NATIVE` | `OFF` | Disable native CPU optimizations for broader compatibility |
| `LLAMA_BUILD_TESTS` | `OFF` | Skip tests |
| `LLAMA_BUILD_EXAMPLES` | `OFF` | Skip examples |
| `LLAMA_BUILD_TOOLS` | `ON` | Build tools (quantize, bench, etc.) |
| `LLAMA_BUILD_SERVER` | `ON` | Build HTTP server |
| `BUILD_SHARED_LIBS` | `OFF` | Static linking |

## Static Linking Flags

| Flag | Purpose |
|------|---------|
| `-static` | Static link system libraries |
| `-static-libgcc` | Static link GCC runtime |
| `-static-libstdc++` | Static link C++ standard library |
| `-D_WIN32_WINNT=0x0601` | Target Windows 7 API |

## Usage

```batch
:: Start server
bin\llama-server.exe -m model.gguf --host 127.0.0.1 --port 8080

:: Use CLI
bin\llama-cli.exe -m model.gguf

:: Quantize model
bin\llama-quantize.exe model-f32.gguf model-q4_0.gguf Q4_0
```

**Note**: Always use `--host 127.0.0.1` on Windows 7. Unix domain sockets are not supported.

## Troubleshooting

See [WINDOWS7_TROUBLESHOOTING.md](WINDOWS7_TROUBLESHOOTING.md) for common errors and solutions.
