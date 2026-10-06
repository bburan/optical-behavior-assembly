// Shared helpers for the lickometer 3D-printed parts.
// Reverse-engineered from the supplied STL files. All units are mm.

$fn = 64;
eps = 0.01;

// 2D stadium (slot) shape: width w across, total length l, ends fully rounded.
module stadium2d(w, l) {
    hull() {
        translate([w/2, w/2]) circle(d = w);
        translate([w/2, l - w/2]) circle(d = w);
    }
}

// Extruded 2D outline with a 45-degree chamfer of size c on the bottom edge only.
module bottom_chamfered_extrude(h, c) {
    hull() {
        linear_extrude(c + eps) offset(delta = -c) children();
        translate([0, 0, c]) linear_extrude(h - c) children();
    }
}

// Vertical through hole of diameter d, height h, with optional 45-degree
// chamfers c_bot / c_top at the bottom and top edges.
module chamfered_hole(d, h, c_bot = 0, c_top = 0) {
    translate([0, 0, -eps]) cylinder(d = d, h = h + 2*eps);
    if (c_bot > 0) translate([0, 0, -eps]) cylinder(d1 = d + 2*c_bot + 2*eps, d2 = d, h = c_bot + eps);
    if (c_top > 0) translate([0, 0, h - c_top]) cylinder(d1 = d, d2 = d + 2*c_top + 2*eps, h = c_top + eps);
}

// Rectangular pocket cutter, centred in XY, opening upwards from z = 0 to z = depth.
// Profile from the floor: vertical for `straight`, then a lead-in drafted at
// `draft` degrees, then a top-edge fillet of radius r.
module pocket(size, depth, straight = 0.25, draft = 10, r = 0.4, steps = 8) {
    function off(z) =
        let(zd = max(0, z - straight),                      // drafted part
            zf = z - (depth - r))                           // inside fillet zone
        zd * tan(draft) + (zf > 0 ? r - sqrt(r*r - zf*zf) : 0);
    zs = concat([0, straight],
                [for (i = [0:steps]) let(z = depth - r + r*i/steps) if (z > straight) z]);
    // stack hulls between consecutive levels so the flared (concave) profile is kept
    for (i = [0:len(zs) - 2])
        hull() for (z = [zs[i], zs[i+1]])
            translate([0, 0, z]) linear_extrude(eps)
                offset(delta = off(z)) square(size, center = true);
    translate([0, 0, depth - eps]) linear_extrude(1)
        offset(delta = off(depth)) square(size, center = true);
}

// Common body of the LED / photosensor fiber holders: stadium bar with two
// M3 clearance holes at its rounded ends.
fh_width        = 6.5;    // bar width (X)
fh_length       = 28.1;   // bar length (Y)
fh_height       = 6.25;   // bar thickness (Z)
fh_bottom_chamf = 0.5;    // 45-degree chamfer around the bottom edge
fh_mount_d      = 3.2;    // M3 clearance
fh_mount_chamf  = 0.5;    // chamfer on both ends of the mounting holes
fh_fiber_d      = 1.25;   // optical fiber hole
fh_fiber_chamf  = 0.2;    // chamfer at the fiber entry (bottom)
fh_fiber_csink_d = 2.5;   // 45-degree countersink diameter where the fiber exits into a pocket

module fiber_holder_body() {
    difference() {
        bottom_chamfered_extrude(fh_height, fh_bottom_chamf) stadium2d(fh_width, fh_length);
        for (y = [fh_width/2, fh_length - fh_width/2])
            translate([fh_width/2, y, 0])
                chamfered_hole(fh_mount_d, fh_height, fh_mount_chamf, fh_mount_chamf);
    }
}

// Fiber hole through the full bar height, countersunk into a pocket whose
// floor is at floor_z. Place at the hole centre.
module fiber_hole(floor_z) {
    chamfered_hole(fh_fiber_d, fh_height, c_bot = fh_fiber_chamf);
    csink = (fh_fiber_csink_d - fh_fiber_d)/2;
    translate([0, 0, floor_z - csink])
        cylinder(d1 = fh_fiber_d, d2 = fh_fiber_csink_d + 2*eps, h = csink + eps);
}
