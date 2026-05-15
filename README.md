# libtorrent-rasterbar-builds

CI builds of [libtorrent](https://github.com/arvidn/libtorrent) (Rasterbar / libtorrent-rasterbar): runtime `.deb`, `-dev`, and Python bindings. **One set of packages per libtorrent version**, built on a **single reference image**; the `.deb` files are meant for recent **Debian and Ubuntu** on **amd64**, without separate builds per distro codename.

## GitHub Actions

The **Build & Release** workflow (`.github/workflows/build.yaml`) runs **only** on **`workflow_dispatch`**. Nothing runs automatically on **push** to `main`: open **Actions** → run the workflow manually (`all` or a specific libtorrent version).

## Matrix (`matrix.py`)

- **OS**: a single CI environment row (recent Debian reference; see `matrix.py`), not one row per end-user distro.
- **Boost**: one shared version for all builds (see `boost_version` in `matrix.py`). CI installs the **`libboost-all-dev_*` artefact** from **boost-builds** (same script as deluge-builds), not a source compile.
- **libtorrent**: several **2.0.x** versions listed in the matrix.

## Debian packages

Each **libtorrent_version** produces three artifacts (release **filenames** use the `krate-` prefix):

| Role        | Typical filename                                   |
| ----------- | -------------------------------------------------- |
| Runtime     | `krate-libtorrent-rasterbar_<ver>-1_amd64.deb`     |
| Development | `krate-libtorrent-rasterbar-dev_<ver>-1_amd64.deb` |
| Python      | `krate-python3-libtorrent_<ver>-1_amd64.deb`       |

Debian **`Package:`** fields remain **`libtorrent-rasterbar`**, **`libtorrent-rasterbar-dev`**, **`python3-libtorrent`** (see the `tools` repo / `control-*` templates).

## Installation

1. Download the `.deb` files for the desired libtorrent version from [Releases](https://github.com/krate-binaries/libtorrent-rasterbar-builds/releases).
2. Install with `sudo dpkg -i …` then `sudo apt-get install -f` if needed.

## JSON metadata

Each `.deb` may ship with JSON from `tools/generate_metadata.sh` (checksums, OS, category, metadata **tag** — typically `release`).

## License

This repository follows the LICENSE file.

libtorrent is licensed under the [BSD license](https://github.com/arvidn/libtorrent/blob/master/LICENSE).
