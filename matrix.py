#!/usr/bin/env python3
import yaml
from collections import defaultdict

lib_versions = ["2.0.5","2.0.6","2.0.7","2.0.8","2.0.9","2.0.10","2.0.11"]
stable_lib   = "2.0.10"
next_lib     = "2.0.11"
lib_rules = [
    ("2.0.1",  "2.0.4", ["ubuntu-20.04","debian-10"]),
    ("2.0.3",  "2.0.10",["ubuntu-22.04","debian-11"]),
    ("2.0.11", None,     ["ubuntu-24.04","debian-12"]),
]
boost_versions = [
    "1.69.0","1.70.0","1.71.0","1.72.0","1.73.0","1.74.0",
    "1.75.0","1.76.0","1.77.0","1.78.0","1.79.0","1.80.0",
    "1.81.0","1.82.0","1.83.0","1.84.0","1.85.0","1.86.0",
    "1.87.0","1.88.0_rc1"
]
rc_boost = "1.88.0_rc1"
boost_rules = [
    ("1.69.0", "1.75.0", ["ubuntu-20.04","debian-10"]),
    ("1.75.0", "1.82.0", ["ubuntu-22.04","debian-11"]),
    ("1.82.0", None,     ["ubuntu-24.04","debian-12"]),
]
def parse(v):
    return tuple(int(x) for x in v.split("_")[0].split("."))
def ge(a,b): return parse(a) >= parse(b)
def le(a,b): return parse(a) <= parse(b)
support_boost    = defaultdict(list)
support_rc_boost = set()
for vmin, vmax, oses in boost_rules:
    for bv in boost_versions:
        if bv == rc_boost:
            if ge(bv, vmin) and (vmax is None or le(bv, vmax)):
                support_rc_boost.update(oses)
            continue
        if ge(bv, vmin) and (vmax is None or le(bv, vmax)):
            for os in oses:
                support_boost[os].append(bv)
boost_map = {
    os: sorted(set(vs), key=parse)[-1]
    for os, vs in support_boost.items()
}
support_lib = defaultdict(list)
modern_lib_oses = set()
for vmin, vmax, oses in lib_rules:
    if vmax is None:
        modern_lib_oses.update(oses)
    for lv in lib_versions:
        if ge(lv, vmin) and (vmax is None or le(lv, vmax)):
            for os in oses:
                support_lib[os].append(lv)
matrix = []
for os, vers in support_lib.items():
    sorted_lv = sorted(set(vers), key=parse)
    for lv in sorted_lv:
        if lv == next_lib and os in modern_lib_oses:
            stability = "next"
        elif lv == stable_lib and not (lv == next_lib and os in modern_lib_oses):
            stability = "stable"
        else:
            stability = "oldstable"
        if lv == next_lib and os in support_rc_boost:
            bv = rc_boost
        else:
            bv = boost_map[os]

        matrix.append({
            "libtorrent_version": lv,
            "os":                  os,
            "boost_version":       bv,
            "stability":           stability
        })

print(yaml.safe_dump({"include": matrix}, sort_keys=False))
