# libtorrent-rasterbar-builds

This repository contains automated builds of [libtorrent-rasterbar](https://github.com/arvidn/libtorrent) for various Linux distributions. The builds are provided as Debian packages (.deb) and include runtime, development, and Python bindings packages.

## Available Packages

For each version of libtorrent-rasterbar, we provide three packages:
- `libtorrent-rasterbar-{stability}`: Runtime library
- `libtorrent-rasterbar-dev-{stability}`: Development files
- `python3-libtorrent-{stability}`: Python bindings

Where `{stability}` can be:
- `oldstable`: For versions 2.0.5 to 2.0.9
- `stable`: For version 2.0.10
- `next`: For version 2.0.11 and future releases

## Supported Distributions

- Ubuntu:
  - 22.04 (Jammy) for versions 2.0.5 to 2.0.10
  - 24.04 (Noble) for version 2.0.11+
- Debian:
  - 11 (Bullseye) for versions 2.0.5 to 2.0.10
  - 12 (Bookworm) for version 2.0.11+

## Installation

### Manual Installation

1. Download the appropriate .deb files for your distribution from the [Releases](https://github.com/MediaEase-binaries/libtorrent-rasterbar-builds/releases) page.
2. Install the packages using:
   ```bash
   sudo dpkg -i libtorrent-rasterbar-{stability}_{version}_{distro}_{arch}.deb
   sudo dpkg -i libtorrent-rasterbar-dev-{stability}_{version}_{distro}_{arch}.deb
   sudo dpkg -i python3-libtorrent-{stability}_{version}_{distro}_{arch}.deb
   ```

## Build Information

### The JSON Metadata

Each package comes with a JSON metadata file that can be used for automated installations. The metadata includes:
- Package name
- Version
- Distribution codename
- Dependencies
- Installation instructions

### Dependencies

The packages are built with the following dependencies:
- Boost ${boost_version} (built from source)
- Python 3.x
- OpenSSL
- zlib

### CMake Configuration

The packages are built using CMake with the following configuration:
```cmake
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_INSTALL_PREFIX=/usr/local
-DCMAKE_CXX_STANDARD=17
-DBUILD_SHARED_LIBS=ON
-DCMAKE_POSITION_INDEPENDENT_CODE=ON
-Dpython-bindings=ON
-Dpython-egg-info=ON
-DBOOST_ROOT="/usr/local"
-DBOOST_INCLUDEDIR="/usr/local/include"
-DBOOST_LIBRARYDIR="/usr/local/lib"
-GNinja
```

## Version Matrix

| libtorrent Version | Boost Version | Stability | Ubuntu | Debian |
|-------------------|---------------|-----------|---------|---------|
| 2.0.5 - 2.0.9 | 1.82.0 | oldstable | 22.04 | 11 |
| 2.0.10 | 1.82.0 | stable | 22.04 | 11 |
| 2.0.11 | 1.88.0_rc1 | next | 24.04 | 12 |
