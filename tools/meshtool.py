"""Measure STL meshes: bounding box, axis-aligned planar faces and cross-sections.

This is how the original lickometer STLs were reverse-engineered. Typical use:

    python tools/meshtool.py part.stl planes
        bounding box + every axis-aligned planar face (axis, facing, coordinate, area)

    python tools/meshtool.py part.stl slice z 0.5,3,5.5
        closed loops in the given cross-sections; circles are fitted and reported
        with centre and diameter (holes, bosses)

    python tools/meshtool.py part.stl plot y 1.0,2.5 sections.png
        the same cross-sections drawn into one PNG (needs matplotlib)

Binary and ASCII STL are both supported. Coordinates are those of the STL.
"""
import sys
from collections import defaultdict

import numpy as np

_DT = np.dtype([("n", "<f4", 3), ("v", "<f4", (3, 3)), ("a", "<u2")])


def load(path):
    """Return the triangles of an STL file as an (n, 3, 3) float array."""
    raw = open(path, "rb").read()
    n = int.from_bytes(raw[80:84], "little")
    if len(raw) == 84 + 50 * n:
        return np.frombuffer(raw, dtype=_DT, offset=84)["v"].astype(float)
    verts = [list(map(float, line.split()[1:])) for line in raw.decode(errors="ignore").splitlines()
             if line.strip().startswith("vertex")]
    return np.array(verts).reshape(-1, 3, 3)


def normals_areas(tris):
    n = np.cross(tris[:, 1] - tris[:, 0], tris[:, 2] - tris[:, 0])
    a = np.linalg.norm(n, axis=1) / 2
    return n / np.maximum(2 * a, 1e-12)[:, None], a


def volume(tris):
    return np.einsum("ij,ij->i", tris[:, 0], np.cross(tris[:, 1], tris[:, 2])).sum() / 6


def planes(tris, min_area=0.5):
    """Axis-aligned planar faces grouped by coordinate: [(axis, '+'/'-', coord, area)]."""
    n, a = normals_areas(tris)
    out = []
    for ax in range(3):
        for sign in (1, -1):
            m = n[:, ax] * sign > 0.999
            groups = defaultdict(float)
            for c, ai in zip(np.round(tris[m][:, 0, ax], 2), a[m]):
                groups[c] += ai
            out += [("xyz"[ax], "+" if sign > 0 else "-", c, round(groups[c], 2))
                    for c in sorted(groups) if groups[c] >= min_area]
    return out


def slice_segments(tris, ax, h):
    """Segments where the plane coordinate[ax] == h cuts the mesh, in the other two axes."""
    d = tris[:, :, ax] - h
    segs = []
    for t, dd in zip(tris, d):
        pts = []
        for i in range(3):
            j = (i + 1) % 3
            if (dd[i] > 0) != (dd[j] > 0):
                u = dd[i] / (dd[i] - dd[j])
                pts.append(t[i] + u * (t[j] - t[i]))
        if len(pts) == 2:
            segs.append(pts)
    other = [k for k in range(3) if k != ax]
    return (np.array(segs)[:, :, other] if segs else np.zeros((0, 2, 2))), other


def loops(segs, tol=1e-4):
    """Chain cut segments into polylines (closed loops for a watertight mesh)."""
    key = lambda p: (round(p[0] / tol), round(p[1] / tol))
    adj = defaultdict(list)
    for i, (p, q) in enumerate(segs):
        adj[key(p)].append(i)
        adj[key(q)].append(i)
    used = np.zeros(len(segs), bool)
    result = []
    for s in range(len(segs)):
        if used[s]:
            continue
        used[s] = True
        pts, cur = [segs[s][0], segs[s][1]], segs[s][1]
        while True:
            nxt = [i for i in adj[key(cur)] if not used[i]]
            if not nxt:
                break
            used[nxt[0]] = True
            p, q = segs[nxt[0]]
            cur = q if key(p) == key(cur) else p
            pts.append(cur)
        result.append(np.array(pts))
    return result


def fit_circle(pts):
    """Least-squares circle: (centre, radius, max radial error)."""
    A = np.c_[2 * pts, np.ones(len(pts))]
    c, *_ = np.linalg.lstsq(A, (pts ** 2).sum(1), rcond=None)
    r = np.sqrt(c[2] + c[0] ** 2 + c[1] ** 2)
    return c[:2], r, np.abs(np.linalg.norm(pts - c[:2], axis=1) - r).max()


def loop_area(p):
    x, y = p[:, 0], p[:, 1]
    return 0.5 * (x * np.roll(y, -1) - np.roll(x, -1) * y).sum()


def describe(tris, ax, h):
    segs, other = slice_segments(tris, ax, h)
    ls = [p for p in loops(segs) if abs(loop_area(p)) > 1e-3]
    print(f"slice {'xyz'[ax]}={h}: {len(ls)} loops (axes {'xyz'[other[0]]},{'xyz'[other[1]]})")
    for p in sorted(ls, key=lambda p: -abs(loop_area(p))):
        c, r, e = fit_circle(p)
        lo, hi = p.min(0), p.max(0)
        s = f"  area={loop_area(p):9.2f} bbox=({lo[0]:.2f},{lo[1]:.2f})-({hi[0]:.2f},{hi[1]:.2f}) n={len(p)}"
        if e < 0.02 * max(r, 0.1) and len(p) > 8:
            s += f"  CIRCLE c=({c[0]:.3f},{c[1]:.3f}) d={2 * r:.3f}"
        print(s)


def plot(tris, ax, hs, out):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    cols = min(len(hs), 3)
    rows = (len(hs) + cols - 1) // cols
    fig, axs = plt.subplots(rows, cols, figsize=(5.5 * cols, 4.6 * rows), squeeze=False)
    for a, h in zip(axs.flat, hs):
        segs, other = slice_segments(tris, ax, h)
        for s in segs:
            a.plot(s[:, 0], s[:, 1], "-k", lw=0.7)
        a.set_aspect("equal")
        a.minorticks_on()
        a.grid(True, lw=0.3)
        a.grid(True, which="minor", lw=0.1)
        a.set_title(f"{'xyz'[ax]}={h}  ({'xyz'[other[0]]} right, {'xyz'[other[1]]} up)", fontsize=9)
    for a in axs.flat[len(hs):]:
        a.axis("off")
    fig.tight_layout()
    fig.savefig(out, dpi=75)


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 1
    tris = load(argv[1])
    v = tris.reshape(-1, 3)
    print("bbox", v.min(0).round(3), v.max(0).round(3), "size", (v.max(0) - v.min(0)).round(3),
          "triangles", len(tris), "volume", round(volume(tris), 2))
    cmd = argv[2] if len(argv) > 2 else "planes"
    if cmd == "planes":
        for p in planes(tris):
            print("  ", *p)
        n, a = normals_areas(tris)
        print("   non-axis-aligned area", round(a[np.abs(n).max(1) < 0.999].sum(), 2), "of", round(a.sum(), 2))
    elif cmd in ("slice", "plot"):
        ax = "xyz".index(argv[3])
        hs = [float(h) for h in argv[4].split(",")]
        if cmd == "slice":
            for h in hs:
                describe(tris, ax, h)
        else:
            plot(tris, ax, hs, argv[5])
            print("wrote", argv[5])
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
