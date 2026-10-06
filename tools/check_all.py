"""Re-export every poke part and run all checks.

    python tools/check_all.py               check only; report stale STLs
    python tools/check_all.py --update      also write the fresh STLs into stl/<animal>/
    python tools/check_all.py -D fiber_bend_r=15 -D cover_t=0
                                            check a parameter variant (STL staleness is
                                            then reported but expected; never use --update
                                            with -D unless you mean to publish that variant)

Checks, for every animal preset:
  1. every part renders without OpenSCAD errors, warnings or failed asserts;
  2. the exported STL matches stl/<animal>/ exactly (vertex sets), i.e. stl/ is up to date;
  3. no two parts overlap (parts may only touch at faces), including the printed spout
     and the friction/spout clamp plate against the body;
  4. the overlap test itself works (a spout pushed 1 mm into its seat must overlap);
  5. the spout and friction plate print without support (no overhang > 45 deg from vertical).

OpenSCAD is taken from $OPENSCAD, else the Windows nightly install, else `openscad` on PATH.
Exit code 0 = all checks passed.
"""
import argparse
import os
import shutil
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from meshtool import load, volume            # noqa: E402
from overhang import overhangs               # noqa: E402
from stl_diff import identical               # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
POKE = os.path.join(ROOT, "poke.scad")
LAYERS = ["bottom_block", "fiber_plate_a", "fiber_plate_b", "fiber_cover", "top_block"]

# (stl folder, file name, part, animal preset)
EXPORTS = []
for animal in ("rat", "ferret"):
    for p in LAYERS + ["friction_plate", "spout"]:
        EXPORTS.append((animal, f"poke_{p}.stl", p, animal))
for p in ["bottom_block", "fiber_plate_a", "fiber_plate_b", "fiber_cover", "friction_plate"]:
    EXPORTS.append(("mouse", f"poke_{p}.stl", p, "mouse_M"))     # shared by mouse_M and mouse_F
for s in ("M", "F"):
    EXPORTS.append(("mouse", f"poke_top_block_{s}.stl", "top_block", f"mouse_{s}"))

PRINTED_SPOUT = ("rat", "ferret")
SPOUT = "translate([x_c, spout_y, -spout_below]) spout()"
CLAMP = "translate([x_c, spout_y, -fc_t]) friction_plate()"
BODY = "union(){for(l=layers) poke_part(l);}"


def find_openscad():
    for c in (os.environ.get("OPENSCAD"), r"C:\Program Files\OpenSCAD (Nightly)\openscad.com",
              r"C:\Program Files\OpenSCAD\openscad.com", shutil.which("openscad")):
        if c and os.path.exists(c):
            return c
    sys.exit("OpenSCAD not found; set the OPENSCAD environment variable")


def run_openscad(args):
    r = subprocess.run([OPENSCAD, "--backend=manifold", "--export-format=binstl"] + args,
                       capture_output=True, text=True)
    out = r.stdout + r.stderr
    bad = [line for line in out.splitlines()
           if line.startswith(("ERROR", "WARNING")) or "Assertion" in line]
    empty = "top level object is empty" in out
    return r.returncode, bad, empty


def defines(extra):
    out = []
    for d in extra:
        out += ["-D", d]
    return out


def export(job, tmp, extra):
    folder, name, part, animal = job
    path = os.path.join(tmp, folder, name)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    code, bad, empty = run_openscad(["-o", path, "-D", f'part="{part}"', "-D", f'animal="{animal}"']
                                    + defines(extra) + [POKE])
    return job, path, code, bad, empty


def overlap(a, b, animal, tmp, extra, tag):
    """Volume (mm^3) of the intersection of two SCAD expressions; 0 if they only touch."""
    scad = os.path.join(tmp, f"i_{tag}.scad")
    stl = os.path.join(tmp, f"i_{tag}.stl")
    inc = POKE.replace("\\", "/")
    lines = [f"include <{inc}>", 'part="none";', f'animal="{animal}";']
    lines += [d.replace("=", " = ", 1) + ";" for d in extra]
    lines.append(f"intersection(){{{a};{b};}}")
    open(scad, "w").write("\n".join(lines) + "\n")
    code, bad, empty = run_openscad(["-o", stl, scad])
    if bad:
        return None, bad                     # e.g. a broken include would silently give "empty"
    if empty:
        return 0.0, []
    return abs(volume(load(stl))), []


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--update", action="store_true", help="write fresh STLs into stl/")
    ap.add_argument("-D", dest="defines", action="append", default=[], metavar="NAME=VALUE",
                    help="OpenSCAD parameter override (repeatable)")
    args = ap.parse_args()
    failures = 0
    tmp = tempfile.mkdtemp(prefix="poke_check_")

    print(f"OpenSCAD: {OPENSCAD}\nexporting {len(EXPORTS)} parts ...")
    with ThreadPoolExecutor(8) as pool:
        results = list(pool.map(lambda j: export(j, tmp, args.defines), EXPORTS))
    stale = []
    for (folder, name, part, animal), path, code, bad, empty in results:
        label = f"{folder}/{name}"
        if code or bad or empty:
            failures += 1
            print(f"  FAIL render {label}: {'empty' if empty else ''} {' | '.join(bad)[:300]}")
            continue
        ref = os.path.join(ROOT, "stl", folder, name)
        same = os.path.exists(ref) and identical(load(ref), load(path))[0]
        if not same:
            stale.append(label)
            if args.update:
                os.makedirs(os.path.dirname(ref), exist_ok=True)
                shutil.copyfile(path, ref)
    if stale:
        verb = "updated" if args.update else "STALE (run with --update)"
        print(f"  {len(stale)} STL(s) {verb}: " + ", ".join(stale))
        if not args.update and not args.defines:
            failures += 1
    else:
        print("  all STLs in stl/ are up to date")

    print("checking part overlaps ...")
    jobs = []
    for animal in ("mouse_M", "mouse_F", "rat", "ferret"):
        for i in range(len(LAYERS)):
            for j in range(i + 1, len(LAYERS)):
                jobs.append((animal, f'poke_part("{LAYERS[i]}")', f'poke_part("{LAYERS[j]}")',
                             f"{LAYERS[i]} x {LAYERS[j]}"))
        jobs.append((animal, BODY, CLAMP, "body x friction_plate"))
        if animal in PRINTED_SPOUT:
            jobs.append((animal, BODY, SPOUT, "body x spout"))
            jobs.append((animal, CLAMP, SPOUT, "friction_plate x spout"))
    sanity = ("ferret", CLAMP, "translate([x_c, spout_y, -spout_below - 1]) spout()", "SANITY spout pushed into seat")

    def do(job):
        k, (animal, a, b, label) = job
        return animal, label, *overlap(a, b, animal, tmp, args.defines, k)

    with ThreadPoolExecutor(8) as pool:
        res = list(pool.map(do, enumerate(jobs + [sanity])))
    for animal, label, vol, bad in res[:-1]:
        if vol is None or vol > 1e-3:
            failures += 1
            print(f"  FAIL {animal}: {label}: " + (f"overlap {vol:.3f} mm^3" if vol is not None else " | ".join(bad)[:300]))
    print(f"  {len(jobs)} part pairs checked")
    animal, label, vol, bad = res[-1]
    if vol is None or vol < 1.0:
        failures += 1
        print(f"  FAIL overlap test sanity check: expected a real overlap, got {vol} {bad}")
    else:
        print(f"  overlap test sanity check ok ({vol:.1f} mm^3 when the spout is pushed into its seat)")

    print("checking printability without support (spout, friction plate) ...")
    for (folder, name, part, animal), path, code, bad, empty in results:
        if part in ("spout", "friction_plate") and os.path.exists(path):
            area, groups = overhangs(load(path), 45.0)
            if area > 0.05:
                failures += 1
                worst = ", ".join(f"z~{z} {a:.1f} mm^2" for (z, _), a in sorted(groups.items()))
                print(f"  FAIL {folder}/{name}: {area:.2f} mm^2 of overhang ({worst})")
    print("  done")

    shutil.rmtree(tmp, ignore_errors=True)
    print("ALL CHECKS PASSED" if not failures else f"{failures} CHECK(S) FAILED")
    return 1 if failures else 0


OPENSCAD = find_openscad()

if __name__ == "__main__":
    sys.exit(main())
