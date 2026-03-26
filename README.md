# C++ project template

Features:

- CMake with CMakePresets for cross-platform builds.
  - Configuration presets:
    - `gcc`: (Non-Windows only) GCC + Ninja Multi-Config.
    - `clang`: (Non-Windows only) Clang + Ninja Multi-Config.
    - `win64`: (Windows x64 only) Visual Studio 2022.
    - `cl`: (Windows x64 only) CL Ninja Multi-Config.
    - `clang-cl`: (Windows x64 only) ClangCL Ninja Multi-Config.
  - Building: `cmake --build build/<preset> --config <Debug|RelWithDebInfo|Release>`
- Dependencies fetched automatically via CMake FetchContent.
- Clang-Tidy and Clang-Format.
- GitHub Actions CI for Linux, macOS, and Windows.
