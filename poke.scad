// Lickometer poke (dual optical-fiber beam break), parametric redesign.
//
// Simplified from Lickometer_Dual_Detection_Optical_Fiber-1..6.STL, keeping
// only the functional elements:
//   - a stack of four layers: bottom block, two fiber plates, top block
//   - fiber grooves that carry two plastic optical fibers across the lick
//     slot at two depths, exiting straight out of the rear of the poke
//   - 2x M3 clamp screws through the stack (counterbored head, captive nut)
//   - 4x M3 front mounting screws (mouse: matching Acrylic_Plates_Lickometer_5mm_v1)
//   - spout: 16G blunt needle (mouse) or a 3D-printed spout (rat, ferret),
//     held by a clamp plate on the rear face
// PCB mounting features of the original are intentionally omitted.
//
// The lick port, beam gap and spout come from the `animal` preset; body size,
// fiber routing and fastener positions are derived from them.
//
// Coordinate frame (assembly):
//   X  across the poke             (0 .. body_w)
//   Y  stacking direction          (0 = outer face of the bottom block)
//   Z  depth; z = 0 is the rear,   z = top_z is the front face (where the animal licks)
//      (the animal licks in the -Z direction)
//
// Render a single part in print orientation with e.g.
//   openscad -D 'part="top_block"' -D 'animal="ferret"' -o top_ferret.stl poke.scad
include <lickometer_common.scad>

/* [Output] */
part   = "exploded"; // [assembly, exploded, bottom_block, fiber_plate_a, fiber_plate_b, fiber_cover, top_block, friction_plate, spout]
animal = "ferret";  // [mouse_M, mouse_F, rat, ferret]
explode = 8;         // gap between layers in the exploded view

/* [Animal presets] */
// name, acrylic boss, beam gap, port width, port length, port bottom end (from the
// plate stack centre, towards the bottom block), port lead-in, spout type, printed spout bore,
// water tubing ID and OD for the printed spout's barb (OD 0 = unknown)
//   beam gap  = tongue width + clearance (mouse ~2-3 mm, rat ~7.5 mm, ferret 8-12 mm)
presets = [
    ["mouse_M", false, 3.3,  6.0, 12.1,  5.5, 0.75, "needle",  0,   0,   0  ],
    ["mouse_F", false, 3.3,  6.0, 10.6,  5.5, 0.75, "needle",  0,   0,   0  ],
    ["rat",     false, 9.0, 11.0, 16.0,  8.0, 1.0,  "printed", 1.6, 3.2, 0  ],
    ["ferret",  false, 13.5, 16.0, 20.0, 10.0, 1.5, "printed", 2.0, 3.0, 5.0],  // 1/8" ID x 5 mm OD
];

/* [Body] */
depth_min = 24;    // minimum rear-to-front depth (Z); grows with fiber_bend_r
bottom_t_min  = 6.1; // minimum bottom block thickness (Y)
top_t_min = 12.8;// minimum top block thickness
port_bottom_wall = 3.4; // bottom block material between the lick port and its outer face
port_top_wall   = 9;    // top block material between the lick port and its outer face
plate_a_floor = 1.35; // fiber plate A (deeper beam): material behind the groove
plate_b_floor = 1.95; // fiber plate B (shallower beam): material behind the groove
cover_t   = 1.2;   // fiber cover between plate B and the top block (0 = none)
plate_margin = 1.45; // plate material outside the fiber groove
ear_w     = 5.5;   // bottom-block side ears that locate the fiber plates in X
ear_clear = 0.15;  // gap between ears and plates
corner_r  = 1.0;   // rounding of the vertical body edges
wing_depth  = 2.5; // plate locating wings: how far they reach into the ears
wing_base   = 9;   // wing length along Z at the plate edge
wing_top    = 3.5; // wing length along Z at the tip (45-degree flanks for 2.5 depth)
wing_z      = 9.5; // wing centre along Z
wing_fillet = 0.5; // rounding of the wing tip corners

/* [Front mounting] */
panel_t       = 5;     // thickness of the wall/panel the poke mounts behind
boss_d        = 25;    // acrylic boss (mouse presets); panel hole is 26.2
boss_chamfer  = 0.5;
mount_edge_x  = 3.85;  // front mounting screws: distance from the X sides
mount_bottom_y = 4.2;  //   ... from the bottom block's outer face
mount_top_y   = 4.3;   //   ... from the top block's outer face
panel_screw_len = 12;  // M3 countersunk, includes the panel thickness

/* [Lick port] */
port_depth    = 15;    // port bottom (where the spout tip sits) below the front face

/* [Optical fibers] */
fiber_d       = 2.0;   // fiber outer diameter incl. jacket; plate thickness follows
fiber_clear_w = 0.3;   // groove width clearance (0.15 per side, SLA)
fiber_clear_d = 0.15;  // groove depth clearance, so the mating plate does not pinch the fiber
beam_a_depth  = 5.75;  // beam A (plate A) distance below the front face
beam_b_depth  = 2.1;   // beam B (plate B) distance below the front face
fiber_bend_r  = 10;     // bend radius of the groove; body width/depth grow to fit it
fiber_tip_straight  = 3;   // straight groove between the bend and the fiber tip
fiber_exit_straight = 1;   // straight groove between the rear face and the bend
groove_min_wall     = 0.5; // minimum wall between a groove and a clamp/post hole
fiber_clamp_wall = 0.7;// wall between fiber groove and clamp screw hole

/* [Spout] */
needle_d       = 1.75; // bore for a 16G needle (OD 1.65)
spout_od_nom   = 5.3;  // printed spout OD (reduced if the plate stack is thinner)
spout_clear    = 0.15; // printed spout: radial clearance in the stack
spout_protrude = 1.0;  // printed spout: tip height above the port floor
spout_tip_r    = 0.6;  // printed spout: tip edge rounding
tubing_hole_clear = 0.3; // clamp-plate hole around the tubing (on top of its stretched OD)
barb_len       = 8;
flange_extra   = 3;    // flange diameter = spout OD + this
flange_t       = 1.5;
self_support_angle = 50; // printed spout: cone under the flange (and matching seat), degrees
                         // from horizontal, so the flange prints without support

/* [Fasteners] */
m3_clear   = 3.4;
nut_w      = 5.5;      // M3 square nut (DIN 562)
nut_t      = 1.8;
nut_clear  = 0.2;
csk_d      = 6.3;      // M3 countersunk head
fc_countersunk = false; // countersunk clamp-plate screws need a 45-degree overhang on the bed
                        // side; false = plain holes for M3x12 button/socket head screws
clamp_lengths   = [12, 16, 18, 20, 22, 25, 30, 35, 40]; // available M3 socket head lengths
clamp_head_d    = 6.2;
clamp_head_h    = 3.2; // minimum counterbore depth
clamp_x_off_min = 8.0; // from centre line
clamp_z         = 9.5;
post_d      = 2.5;     // locating posts printed on the bottom block; the fiber plates slide on
post_clear  = 0.15;    // radial clearance of the post holes
post_engage = 2.0;     // how far the posts reach into the top block
post_chamfer = 0.4;    // lead-in chamfer at the post tip
post_z      = 14;

/* [Friction / spout clamp plate] */
fc_t        = 4.5;
fc_bottom_min = 5.4;     // screw offsets from the spout
fc_top    = 7.6;
fc_side     = 4.5;
fc_lobe_r   = 4.5;
oring_d     = 5;       // needle: pocket for the silicone tube / O-ring
oring_depth = 1.2;
fc_spout_d  = 1.9;

/* [Hidden] */
preset = [for (p = presets) if (p[0] == animal) p][0];
assert(!is_undef(preset), str("unknown animal: ", animal));
panel_mount = preset[1];
beam_gap    = preset[2];
port_w      = preset[3];
port_len    = preset[4];
port_bottom   = preset[5];
port_flare  = preset[6];
spout_type  = preset[7];
spout_id    = preset[8];
tubing_id   = preset[9];
tubing_od   = preset[10];
printed_spout = spout_type == "printed";

plate_a_t = fiber_d + fiber_clear_d + plate_a_floor;   // groove depth + floor
plate_b_t = fiber_d + fiber_clear_d + plate_b_floor;
plates_t = plate_a_t + plate_b_t + cover_t;   // fiber plates + cover
bottom_t   = max(bottom_t_min, port_bottom - plates_t/2 + port_bottom_wall);
top_t  = max(top_t_min, port_len - port_bottom - plates_t/2 + port_top_wall);
depth    = max(depth_min, fiber_bend_r + beam_a_depth + fiber_exit_straight);
top_z    = depth;
body_h   = panel_mount ? depth - panel_t : depth;   // below the boss, if any
port_floor_z = top_z - port_depth;
mount_z  = body_h;                                  // face the mounting panel rests on
groove_w = fiber_d + fiber_clear_w;
groove_d = fiber_d + fiber_clear_d;
clamp_x_off = max(clamp_x_off_min, port_w/2 + m3_clear/2 + 1.5);
fiber_x_off = max(clamp_x_off + m3_clear/2 + fiber_clamp_wall + groove_w/2,
                  fiber_bend_r + beam_gap/2 + fiber_tip_straight);
body_w   = 2*(fiber_x_off + groove_w/2 + plate_margin + ear_clear + ear_w);
post_x_off = max(5, port_w/2 + post_d/2 + post_clear + 1.0);  // >= 1 mm wall to the lick port

x_c     = body_w / 2;
y_a     = bottom_t;
y_b     = y_a + plate_a_t;
y_c     = y_b + plate_b_t;   // fiber cover
y_f     = y_c + cover_t;
L       = y_f + top_t;
port_y0 = y_a + plates_t/2 - port_bottom;
// needle: in the plate A / plate B interface; printed: centred in the plate stack
spout_y  = printed_spout ? y_a + plates_t/2 : y_b;
spout_od = min(spout_od_nom, plates_t - 2*spout_clear);
spout_bore_d = spout_od + 2*spout_clear;
// round bore when the plates leave >= 0.8 mm on both sides, else a full-thickness channel
spout_round  = plates_t - spout_bore_d >= 1.6;
flange_d = spout_od + flange_extra;
barb_min = tubing_id + 0.2;
barb_max = tubing_id + 0.8;
// clamp-plate hole: lets the tubing slide over the whole barb up to the flange when
// its OD is known, otherwise only clears the barb
fc_tube_hole_d = tubing_od > 0 ? barb_max + (tubing_od - tubing_id) + tubing_hole_clear : barb_max + 0.4;
// self-supporting cone between the barb and the flange, and the matching seat in the clamp plate
flange_cone_h = (flange_d - barb_max)/2 * tan(self_support_angle);
seat_cone_h   = (flange_d + 0.3 - fc_tube_hole_d)/2 * tan(self_support_angle);
spout_below   = barb_len + flange_cone_h + flange_t;   // spout length behind the poke's rear face
fc_bottom  = printed_spout ? max(fc_bottom_min, flange_d/2 + m3_clear/2 + 0.8) : fc_bottom_min;

nut_s    = nut_w + 2*nut_clear;
nut_h    = nut_t + 2*nut_clear;
boss_y   = (mount_bottom_y + L - mount_top_y)/2;
panel_holes = [for (x = [mount_edge_x, body_w - mount_edge_x], y = [mount_bottom_y, L - mount_top_y]) [x, y]];
fc_holes    = [[0, -fc_bottom], [-fc_side, fc_top], [fc_side, fc_top]];
// screw tip positions -> nut heights
panel_nut_z = mount_z - (panel_screw_len - panel_t) + 0.6 + nut_h/2;
fc_nut_z    = 5.0;
// clamp screws: head seated clamp_head_h .. bottom_t - 1.5 deep in the bottom block; the nut
// pocket comes in from the top block's outer face as deep as needed, keeping 3 mm of top block
// between it and the plates. The longest screw that fits is used.
clamp_pmax = top_t - 3;
function clamp_seat(l) = min(bottom_t - 1.5, L - 0.2 - l);
clamp_fits = [for (l = clamp_lengths) let(c = clamp_seat(l))
              if (c >= clamp_head_h - 0.01 && c + l >= L - clamp_pmax + nut_h - 0.01) l];
assert(len(clamp_fits) > 0, str("no clamp screw in clamp_lengths fits a ", L, " mm stack"));
clamp_screw_len = max(clamp_fits);
clamp_cbore = clamp_seat(clamp_screw_len);   // head seat depth in the bottom block
clamp_tip   = clamp_cbore + clamp_screw_len;  // nut sits just below the screw tip

echo(str(animal, ": body ", body_w, " x ", L, " x ", top_z, " mm, beam gap ", beam_gap,
         " mm, fiber bend radius ", fiber_bend_r,
         " mm, clamp screws M3x", clamp_screw_len,
         printed_spout ? str(", printed spout OD ", spout_od, " bore ", spout_id, ", barb ", barb_min, "-", barb_max,
                             " for ", tubing_id, " mm ID tubing") : ", 16G needle spout"));

assert(clamp_cbore < bottom_t - 1, "clamp screw length does not suit the stack");
assert(x_c - fiber_x_off - groove_w/2 - (ear_w + ear_clear) >= 0.5, "fiber groove too close to the plate edge");

// groove path (one half, in u = distance from the centre line, z) vs. holes in the plates
function seg_dist(p, a, b) =
    let(ab = b - a, t = max(0, min(1, ((p - a) * ab) / (ab * ab)))) norm(p - (a + t*ab));
function arc_dist(p, c, r) =   // quarter arc from (c.u + r, c.z) to (c.u, c.z + r)
    (p[0] >= c[0] && p[1] >= c[1]) ? abs(norm(p - c) - r)
                                   : min(norm(p - (c + [r, 0])), norm(p - (c + [0, r])));
function groove_dist(p, zb) = let(F = fiber_x_off, R = fiber_bend_r)
    min(seg_dist(p, [F, -1], [F, zb - R]), arc_dist(p, [F - R, zb - R], R),
        seg_dist(p, [F - R, zb], [beam_gap/2, zb]));
plate_holes = [[clamp_x_off, clamp_z, m3_clear/2], [post_x_off, post_z, post_d/2 + post_clear]];
groove_wall = min([for (zb = [top_z - beam_a_depth, top_z - beam_b_depth], h = plate_holes)
                   groove_dist([h[0], h[1]], zb) - groove_w/2 - h[2]]);
assert(groove_wall >= groove_min_wall - 0.01,
       str("fiber groove only ", groove_wall, " mm from a clamp screw or post hole"));
assert(port_y0 >= 2, "lick port too close to the bottom block's outer face");
assert(!printed_spout || barb_min - spout_id >= 1.0, "spout bore too large for the barb");
assert(!printed_spout || fc_tube_hole_d <= flange_d - 1.0, "tubing too large for the spout flange");
assert(!printed_spout || fc_t - flange_t - seat_cone_h >= 0.4, "clamp plate too thin for the spout seat");

// ---------------------------------------------------------------- envelope

module rounded_rect(w, l, r) {
    offset(r) offset(-r) square([w, l]);
}

module stadium_y(w, l) {  // stadium along Y, starting at y = 0, centred on x = 0
    hull() {
        translate([0, w/2]) circle(d = w);
        translate([0, l - w/2]) circle(d = w);
    }
}

module envelope() {
    linear_extrude(body_h) rounded_rect(body_w, L, corner_r);
    // front boss for the acrylic panel, clipped to the body footprint
    if (panel_mount) intersection() {
        translate([x_c, boss_y, body_h - eps]) hull() {
            cylinder(d = boss_d, h = panel_t - boss_chamfer + eps);
            cylinder(d = boss_d - 2*boss_chamfer, h = panel_t + eps);
        }
        translate([0, 0, body_h - 1]) cube([body_w, L, panel_t + 1]);
    }
}

// 2D (XZ) outline of the locating wings on both plate edges: trapezoids with
// 45-degree flanks that key into matching recesses in the bottom-block ears.
// grow > 0 gives the (larger) recess outline.
module wings_2d(grow = 0) {
    x0 = ear_w + ear_clear;             // plate edge
    hb = wing_base/2;
    ht = wing_top/2;
    module one()
        offset(delta = grow) offset(r = wing_fillet) offset(delta = -wing_fillet)
            polygon([[x0 + 1, wing_z - hb], [x0, wing_z - hb], [x0 - wing_depth, wing_z - ht],
                     [x0 - wing_depth, wing_z + ht], [x0, wing_z + hb], [x0 + 1, wing_z + hb]]);
    one();
    translate([body_w, 0]) mirror([1, 0]) one();
}

module wings(y0, t, grow = 0) {
    translate([0, y0 + t, 0]) rotate([90, 0, 0]) linear_extrude(t) wings_2d(grow);
}

module layer_region(p) {
    big = top_z + 2;
    plate_w = body_w - 2*(ear_w + ear_clear);
    if (p == "bottom_block") difference() {
        union() {
            translate([-1, -1, -1]) cube([body_w + 2, bottom_t + 1, big]);
            for (x = [-1, body_w - ear_w]) translate([x, y_a - eps, -1]) cube([ear_w + 1, y_f - y_a, big]);
        }
        wings(y_a, y_f - y_a + 1, ear_clear);
    }
    if (p == "fiber_plate_a") {
        translate([ear_w + ear_clear, y_a, -1]) cube([plate_w, plate_a_t, big]);
        wings(y_a, plate_a_t);
    }
    if (p == "fiber_plate_b") {
        translate([ear_w + ear_clear, y_b, -1]) cube([plate_w, plate_b_t, big]);
        wings(y_b, plate_b_t);
    }
    if (p == "fiber_cover") {
        translate([ear_w + ear_clear, y_c, -1]) cube([plate_w, cover_t, big]);
        wings(y_c, cover_t);
    }
    if (p == "top_block")   translate([-1, y_f, -1]) cube([body_w + 2, top_t + 1, big]);
}

// ---------------------------------------------------------------- cutters

// square nut slot centred at (x, y, z), nut lying in the XY plane, open
// towards y = y_open (the slot extends from the nut to that face)
module nut_slot_y(x, y, z, y_open) {
    y0 = min(y - nut_s/2, y_open - 1);
    y1 = max(y + nut_s/2, y_open + 1);
    translate([x - nut_s/2, y0, z - nut_h/2]) cube([nut_s, y1 - y0, nut_h]);
}

module fastener_cuts() {
    // clamp screws along Y: counterbore in the bottom block, square nut pocket in the top block
    for (sx = [-1, 1]) translate([x_c + sx*clamp_x_off, 0, clamp_z]) rotate([-90, 0, 0]) {
        translate([0, 0, -1]) cylinder(d = m3_clear, h = L + 2);
        translate([0, 0, -1]) cylinder(d = clamp_head_d, h = clamp_cbore + 1);
        translate([-nut_s/2, -nut_s/2, clamp_tip - nut_h]) cube([nut_s, nut_s, L - clamp_tip + nut_h + 1]);
    }
    // front mounting screws, nuts slid in from the outer Y faces
    for (h = panel_holes) {
        translate([h[0], h[1], mount_z - (panel_screw_len - panel_t) - 1])
            cylinder(d = m3_clear, h = top_z);
        nut_slot_y(h[0], h[1], panel_nut_z, h[1] < L/2 ? 0 : L);
    }
    // friction-plate screws from the rear
    for (o = fc_holes) {
        x = x_c + o[0]; y = spout_y + o[1];
        translate([x, y, -1]) cylinder(d = m3_clear, h = fc_nut_z + nut_h/2 + 3);
        nut_slot_y(x, y, fc_nut_z, y < L/2 ? 0 : L);
    }
    // holes for the bottom-block locating posts: through the plates, blind in the top block
    for (sx = [-1, 1]) translate([x_c + sx*post_x_off, y_a - eps, post_z])
        rotate([-90, 0, 0]) cylinder(d = post_d + 2*post_clear, h = plates_t + post_engage + 0.5);
    // needle bore (printed spout: see spout_channel)
    if (!printed_spout) translate([x_c, spout_y, -1]) cylinder(d = needle_d, h = port_floor_z + 1.5);
}

// printed spout through the fiber plates: a round bore split between the plates
// when they are thick enough, otherwise a full-thickness channel (the spout is
// then located in X by the plate halves and in Y by the two blocks)
module spout_channel() {
    if (spout_round) translate([x_c, spout_y, -1]) cylinder(d = spout_bore_d, h = port_floor_z + 1.5);
    else translate([x_c - spout_bore_d/2, y_a - 1, -1]) cube([spout_bore_d, plates_t + 2, port_floor_z + 1.5]);
}

module lick_port() {
    translate([x_c, port_y0, port_floor_z]) linear_extrude(top_z) stadium_y(port_w, port_len);
    translate([x_c, port_y0, top_z - port_flare]) hull() {
        linear_extrude(eps) stadium_y(port_w, port_len);
        translate([0, 0, port_flare]) linear_extrude(1)
            offset(delta = port_flare) stadium_y(port_w, port_len);
    }
}

module beam_slot(y0, t) {
    translate([x_c - beam_gap/2, y0 - 1, port_floor_z]) cube([beam_gap, t + 2, top_z]);
}

// 2D groove path in the XZ plane for one fiber pair (both halves of the beam)
module fiber_path_2d(beam_z) {
    xf = x_c - fiber_x_off;
    r = fiber_bend_r;
    module half() {
        translate([xf - groove_w/2, -1]) square([groove_w, beam_z - r + 1]);
        translate([xf + r, beam_z - r]) intersection() {
            difference() { circle(r = r + groove_w/2); circle(r = r - groove_w/2); }
            translate([-r - groove_w, 0]) square(r + groove_w);
        }
        translate([xf + r - eps, beam_z - groove_w/2]) square([x_c - beam_gap/2 - xf - r + 2*eps, groove_w]);
    }
    half();
    translate([2*x_c, 0]) mirror([1, 0]) half();
}

// groove cut into the +Y face of a plate whose +Y face is at y_face
module fiber_groove(y_face, beam_depth) {
    translate([0, y_face + 1, 0]) rotate([90, 0, 0])
        linear_extrude(groove_d + 1) fiber_path_2d(top_z - beam_depth);
}

// ---------------------------------------------------------------- parts

module poke_part(p) {
    difference() {
        intersection() { envelope(); layer_region(p); }
        fastener_cuts();
        if (p == "bottom_block" || p == "top_block") lick_port();
        if (p == "fiber_plate_a") { beam_slot(y_a, plate_a_t); fiber_groove(y_b, beam_a_depth); }
        if (p == "fiber_plate_b") { beam_slot(y_b, plate_b_t); fiber_groove(y_f, beam_b_depth); }
        if (p == "fiber_cover")   beam_slot(y_c, cover_t);
        if (printed_spout && (p == "fiber_plate_a" || p == "fiber_plate_b" || p == "fiber_cover")) spout_channel();
    }
    if (p == "bottom_block") locating_posts();
}

// posts on the bottom block's mating face; both fiber plates (each half, when
// split by the spout channel) slide onto them, and they key into the top block
module locating_posts() {
    h = plates_t + post_engage - 0.3;
    for (sx = [-1, 1]) translate([x_c + sx*post_x_off, y_a - eps, post_z]) rotate([-90, 0, 0]) {
        cylinder(d = post_d, h = h - post_chamfer + eps);
        translate([0, 0, h - post_chamfer]) cylinder(d1 = post_d, d2 = post_d - 2*post_chamfer, h = post_chamfer);
    }
}

// friction plate (needle) / spout clamp plate (printed spout) in its own
// frame: z = 0 outer face, z = fc_t faces the poke
module friction_plate() {
    difference() {
        linear_extrude(fc_t) hull() {
            circle(r = fc_lobe_r);
            for (o = fc_holes) translate(o) circle(r = fc_lobe_r);
        }
        if (printed_spout) {
            translate([0, 0, -1]) cylinder(d = fc_tube_hole_d, h = fc_t + 2);
            translate([0, 0, fc_t - flange_t]) cylinder(d = flange_d + 0.3, h = flange_t + 1);
            // conical seat for the spout's self-supporting flange cone (opens upwards: no overhang)
            translate([0, 0, fc_t - flange_t - seat_cone_h])
                cylinder(d1 = fc_tube_hole_d, d2 = flange_d + 0.3, h = seat_cone_h + eps);
        } else {
            translate([0, 0, -1]) cylinder(d = fc_spout_d, h = fc_t + 2);
            translate([0, 0, fc_t - oring_depth]) cylinder(d = oring_d, h = oring_depth + 1);
        }
        for (o = fc_holes) translate(o) {
            translate([0, 0, -1]) cylinder(d = m3_clear, h = fc_t + 2);
            if (fc_countersunk) translate([0, 0, -eps]) cylinder(d1 = csk_d, d2 = 0, h = csk_d/2);
        }
    }
}

// printed spout in its own frame: barb end at z = 0, flange top at z = spout_below
// (flush with the rear face of the poke), tip at port_floor_z + spout_protrude above that
module spout() {
    tube_h = port_floor_z + spout_protrude;
    z_fl = barb_len + flange_cone_h;
    difference() {
        union() {
            // two barb cones, narrow end first so the tubing pushes on and stays on
            for (z = [0, barb_len/2]) translate([0, 0, z]) cylinder(d1 = barb_min, d2 = barb_max, h = barb_len/2);
            // self-supporting cone up to the flange (printed barb end down)
            // (exactly flush with the barb top and flange bottom, so no sliver ledges remain)
            translate([0, 0, barb_len]) cylinder(d1 = barb_max, d2 = flange_d, h = flange_cone_h);
            translate([0, 0, z_fl]) cylinder(d = flange_d, h = flange_t);
            translate([0, 0, z_fl + flange_t - eps]) hull() {
                cylinder(d = spout_od, h = tube_h - spout_tip_r);
                cylinder(d = spout_od - 2*spout_tip_r, h = tube_h);
            }
        }
        translate([0, 0, -1]) cylinder(d = spout_id, h = z_fl + flange_t + tube_h + 2);
    }
}

all_layers = ["bottom_block", "fiber_plate_a", "fiber_plate_b", "fiber_cover", "top_block"];
all_colors = ["SteelBlue", "Orange", "Gold", "Tomato", "MediumSeaGreen"];
layers       = [for (i = [0:4]) if (cover_t > 0 || all_layers[i] != "fiber_cover") all_layers[i]];
layer_colors = [for (i = [0:4]) if (cover_t > 0 || all_layers[i] != "fiber_cover") all_colors[i]];

module assembly(gap = 0) {
    // render() so the preview (F5) shows each part as cut from the shared envelope
    for (i = [0:len(layers) - 1]) color(layer_colors[i]) translate([0, i*gap, 0]) render() poke_part(layers[i]);
    color("DimGray") translate([x_c, spout_y, -gap - fc_t]) friction_plate();
    if (printed_spout)
        color("LightSkyBlue") translate([x_c, spout_y, -2*gap - spout_below]) spout();
}

// print orientation: a flat (mating or outer) face on the bed
module print_part(p) {
    if (p == "bottom_block")    rotate([90, 0, 0]) poke_part(p);
    if (p == "fiber_plate_a") rotate([90, 0, 0]) translate([0, -y_a, 0]) poke_part(p);
    if (p == "fiber_plate_b") rotate([90, 0, 0]) translate([0, -y_b, 0]) poke_part(p);
    if (p == "fiber_cover" && cover_t > 0) rotate([90, 0, 0]) translate([0, -y_c, 0]) poke_part(p);
    if (p == "top_block")   rotate([90, 0, 0]) translate([0, -y_f, 0]) poke_part(p);
    if (p == "friction_plate") friction_plate();
    if (p == "spout") {
        if (printed_spout) spout();
        else echo(str("WARNING: ", animal, " uses a 16G needle, there is no printed spout"));
    }
}

if (part == "assembly") assembly(0);
else if (part == "exploded") assembly(explode);
else print_part(part);
