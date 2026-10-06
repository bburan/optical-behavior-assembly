"""Find surfaces that need support when an STL is printed as exported (Z up, bed at min Z).

    python tools/overhang.py part.stl [max_angle_from_vertical]

Lists downward-facing surfaces that are more than `max_angle_from_vertical`
degrees (default 45) away from vertical and are not resting on the bed, grouped
by height and facing angle. 45-degree surfaces are not reported at the default
limit; use e.g. 40 to include them.

Exit code 0 = no overhangs, 1 = overhangs found.
"""
import os
import sys
from collections import defaultdict

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from meshtool import load, normals_areas


def overhangs(tris, limit=45.0):
    n, a = normals_areas(tris)
    zmin = tris[:, :, 2].min()
    from_down = np.degrees(np.arccos(np.clip(-n[:, 2], -1, 1)))   # 0 = facing straight down
    cz = tris[:, :, 2].mean(1)
    m = (from_down < 90 - limit) & (cz > zmin + 0.01)
    groups = defaultdict(float)
    for z, ai, ang in zip(cz[m], a[m], from_down[m]):
        groups[(round(z, 1), int(round(ang / 5) * 5))] += ai
    return a[m].sum(), groups


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    limit = float(argv[2]) if len(argv) > 2 else 45.0
    tris = load(argv[1])
    total, groups = overhangs(tris, limit)
    print(f"{argv[1]}: height {np.ptp(tris[:, :, 2]):.2f} mm, unsupported overhang area {total:.2f} mm^2 "
          f"(steeper than {limit:g} deg from vertical)")
    for (z, ang), area in sorted(groups.items()):
        print(f"   z~{z:6.1f}  facing {ang:2d} deg from straight down  {area:7.2f} mm^2")
    return 1 if total > 0.05 else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
