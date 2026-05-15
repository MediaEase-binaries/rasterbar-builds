#!/usr/bin/env python3
import yaml

lib_versions = ["2.0.5", "2.0.6", "2.0.7", "2.0.8", "2.0.9", "2.0.10", "2.0.11"]
boost_version = "1.91.0"

matrix = [
    {
        "libtorrent_version": libtorrent_version,
        "os": "debian-13",
        "codename": "trixie",
        "boost_version": boost_version,
    }
    for libtorrent_version in lib_versions
]

print(yaml.safe_dump({"include": matrix}, sort_keys=False))
