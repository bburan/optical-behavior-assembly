"""Compare two STL files.

    python tools/stl_diff.py a.stl b.stl [dx dy dz]

Reports whether the meshes have identical vertex sets (exact regression check:
OpenSCAD output can differ byte-wise only by triangle order), and otherwise the
volume difference and surface deviation in mm, estimated from dense point samples.
The optional offset is subtracted from a.stl first (e.g. to align an original STL
that was exported in assembly coordinates).

Exit code 0 = identical, 1 = different.
"""
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from meshtool import load, volume


def vertex_set(tris):
    return np.unique(tris.reshape(-1, 3), axis=0)


def identical(a, b, tol=1e-5):
    from scipy.spatial import cKDTree
    va, vb = vertex_set(a), vertex_set(b)
    if len(va) != len(vb):
        return False, float("inf")
    d = max(cKDTree(vb).query(va)[0].max(), cKDTree(va).query(vb)[0].max())
    return d <= tol, d


def sample(tris, n, rng):
    a = np.linalg.norm(np.cross(tris[:, 1] - tris[:, 0], tris[:, 2] - tris[:, 0]), axis=1) / 2
    i = rng.choice(len(tris), n, p=a / a.sum())
    u, v = rng.random((2, n))
    flip = u + v > 1
    u[flip], v[flip] = 1 - u[flip], 1 - v[flip]
    t = tris[i]
    return t[:, 0] + u[:, None] * (t[:, 1] - t[:, 0]) + v[:, None] * (t[:, 2] - t[:, 0])


def deviation(a, b, n=400000):
    """Percentiles (50/95/99/max) of point-to-surface distance a->b and b->a."""
    from scipy.spatial import cKDTree
    rng = np.random.default_rng(0)
    pa, pb = sample(a, n, rng), sample(b, n, rng)
    da = cKDTree(pb).query(pa)[0]
    db = cKDTree(pa).query(pb)[0]
    return np.percentile(da, [50, 95, 99, 100]), np.percentile(db, [50, 95, 99, 100])


def main(argv):
    if len(argv) < 3:
        print(__doc__)
        return 2
    a, b = load(argv[1]), load(argv[2])
    if len(argv) >= 6:
        a = a - np.array([float(x) for x in argv[3:6]])
    same, d = identical(a, b)
    if same:
        print("identical vertex sets")
        return 0
    va, vb = volume(a), volume(b)
    print(f"DIFFERENT (max vertex distance {d:.3g} mm)")
    print(f"bbox a {a.reshape(-1, 3).min(0).round(3)} .. {a.reshape(-1, 3).max(0).round(3)}")
    print(f"bbox b {b.reshape(-1, 3).min(0).round(3)} .. {b.reshape(-1, 3).max(0).round(3)}")
    print(f"volume a={va:.2f} b={vb:.2f} diff={100 * (vb - va) / va:+.2f}%")
    ab, ba = deviation(a, b)
    print(f"a->b median/95/99/max = {ab.round(3)} mm")
    print(f"b->a median/95/99/max = {ba.round(3)} mm   (median ~0.02-0.05 is sampling noise)")
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
