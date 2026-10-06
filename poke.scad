// Lickometer poke (dual optical-fiber beam break), parametric redesign.
//
// Simplified from Lickometer_Dual_Detection_Optical_Fiber-1..6.STL, keeping
// only the functional elements:
//   - a stack of four layers: back block, two fiber plates, front block
//   - fiber grooves that carry two plastic optical fibers across the lick
//     slot at two depths, exiting straight out of the back of the poke
//   - 2x M3 clamp screws through the stack (counterbored head, captive nut)
//   - front boss + 4x M3 screws matching Acrylic_Plates_Lickometer_5mm_v1
//   - spout bore for a 16G blunt needle + optional friction plate (part 6)
// PCB mounting features of the original are intentionally omitted.
//
// Coordinate frame (assembly):
//   X  across the poke             (0 .. body_w)
//   Y  stacking direction          (0 = back of back block)
//   Z  depth; z = 0 is the rear,   z = body_h + panel_t is the front face
//      (the animal licks in the -Z direction)
//
// Render a single part in print orientation with e.g.
//   openscad -D 'part="front_block"' -D 'sex="F"' -o front_F.stl poke.scad
include <lickometer_common.scad>

/* [Output] */
part = "exploded"; // [assembly, exploded, back_block, fiber_plate_a, fiber_plate_b, front_block, friction_plate]
sex  = "M";        // [M, F]
explode = 8;       // gap between layers in the exploded view

/* [Body] */
body_w    = 37.2;  // width (X)
body_h    = 19;    // depth of the body behind the acrylic panel (Z)
back_t    = 6.1;   // back block thickness (Y)
plate_a_t = 2.5;   // fiber plate A thickness (deeper beam)
plate_b_t = 3.1;   // fiber plate B thickness (shallower beam)
front_t   = 12.8;  // front block thickness
ear_w     = 5.5;   // back-block side ears that locate the fiber plates in X
ear_clear = 0.15;  // gap between ears and plates
corner_r  = 1.0;   // rounding of the vertical body edges
wing_depth  = 2.5; // plate locating wings: how far they reach into the ears
wing_base   = 9;   // wing length along Z at the plate edge
wing_top    = 3.5; // wing length along Z at the tip (45-degree flanks for 2.5 depth)
wing_z      = 9.5; // wing centre along Z
wing_fillet = 0.5; // rounding of the wing tip corners

/* [Front boss / acrylic panel] */
panel_t       = 5;     // acrylic thickness = boss height
boss_d        = 25;    // panel hole is 26.2
boss_y        = 12.2;  // boss centre along Y
boss_chamfer  = 0.5;
panel_hole_dx = 14.75; // panel screw offsets from the boss centre
panel_hole_dy = 8;
panel_screw_len = 12;  // M3 countersunk, includes the panel thickness

/* [Lick port] */
port_w        = 6.0;   // width (X)
port_len_M    = 12.1;  // length along Y for male mice
port_len_F    = 10.6;  // length along Y for female mice
port_y0       = 3.4;   // rear end of the port along Y
port_floor_z  = 9;     // port bottom (where the spout tip sits)
port_flare    = 0.75;  // 45-degree lead-in chamfer at the front face

/* [Optical fibers] */
fiber_d       = 1.0;   // fiber outer diameter (incl. jacket)
fiber_clear   = 0.1;
beam_gap      = 3.3;   // distance between facing fiber tips (X)
beam_a_depth  = 5.75;  // beam A (plate A) distance below the front face
beam_b_depth  = 2.1;   // beam B (plate B) distance below the front face
fiber_x_off   = 10.95; // fiber exit position from the centre line (X)
fiber_bend_r  = 4;     // bend radius of the groove

/* [Spout] */
spout_d = 1.75;        // 16G needle OD is 1.65

/* [Fasteners] */
m3_clear   = 3.4;
m3_tap     = 2.9;      // hole for screws ending in a nut
nut_w      = 5.5;      // M3 square nut (DIN 562)
nut_t      = 1.8;
nut_clear  = 0.2;
csk_d      = 6.3;      // M3 countersunk head
clamp_screw_len = 20;  // M3 socket head
clamp_head_d    = 6.2;
clamp_x_off     = 8.0; // from centre line
clamp_z         = 9.5;
dowel_d     = 1.95;    // hole for 1.75 mm filament used as alignment dowels
dowel_depth = 2.5;     // into each block
dowel_x_off = 5;
dowel_z     = 14;

/* [Friction plate (part 6)] */
fc_t        = 4.5;
fc_back     = 5.4;     // screw offsets from the spout
fc_front    = 7.6;
fc_side     = 4.5;
fc_lobe_r   = 4.5;
fc_screw_len = 12;     // M3 countersunk
oring_d     = 5;       // pocket for the silicone tube / O-ring
oring_depth = 1.2;
fc_spout_d  = 1.9;

/* [Hidden] */
x_c     = body_w / 2;
top_z   = body_h + panel_t;
y_a     = back_t;
y_b     = y_a + plate_a_t;
y_f     = y_b + plate_b_t;
L       = y_f + front_t;
spout_y = y_b;  // spout runs in the plate A / plate B interface
port_len = sex == "M" ? port_len_M : port_len_F;
groove_w = fiber_d + fiber_clear;
groove_d = fiber_d + fiber_clear;
nut_s    = nut_w + 2*nut_clear;
nut_h    = nut_t + 2*nut_clear;
panel_holes = [for (sx = [-1, 1], sy = [-1, 1]) [x_c + sx*panel_hole_dx, boss_y + sy*panel_hole_dy]];
fc_holes    = [[0, -fc_back], [-fc_side, fc_front], [fc_side, fc_front]];
// screw tip positions -> nut heights
panel_nut_z = body_h - (panel_screw_len - panel_t) + 0.6 + nut_h/2;
fc_nut_z    = 5.0;
clamp_cbore = L - clamp_screw_len - 0.2;   // head seat depth in the back block

assert(clamp_cbore > 0 && clamp_cbore < back_t - 1, "clamp screw length does not suit the stack");
assert(x_c - fiber_x_off - groove_w/2 - (ear_w + ear_clear) >= 0.5, "fiber groove too close to the plate edge");
assert(x_c - clamp_x_off - m3_clear/2 - (x_c - fiber_x_off + groove_w/2) >= 0.5, "fiber groove too close to the clamp screw");

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
    // front boss, clipped to the body footprint
    intersection() {
        translate([x_c, boss_y, body_h - eps]) hull() {
            cylinder(d = boss_d, h = panel_t - boss_chamfer + eps);
            cylinder(d = boss_d - 2*boss_chamfer, h = panel_t + eps);
        }
        translate([0, 0, body_h - 1]) cube([body_w, L, panel_t + 1]);
    }
}

// 2D (XZ) outline of the locating wings on both plate edges: trapezoids with
// 45-degree flanks that key into matching recesses in the back-block ears.
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
    if (p == "back_block") difference() {
        union() {
            translate([-1, -1, -1]) cube([body_w + 2, back_t + 1, big]);
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
    if (p == "front_block")   translate([-1, y_f, -1]) cube([body_w + 2, front_t + 1, big]);
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
    // clamp screws along Y: counterbore at the back, square nut pocket at the front
    for (sx = [-1, 1]) translate([x_c + sx*clamp_x_off, 0, clamp_z]) rotate([-90, 0, 0]) {
        translate([0, 0, -1]) cylinder(d = m3_clear, h = L + 2);
        translate([0, 0, -1]) cylinder(d = clamp_head_d, h = clamp_cbore + 1);
        translate([-nut_s/2, -nut_s/2, L - nut_h - 0.2]) cube([nut_s, nut_s, nut_h + 1.2]);
    }
    // acrylic panel screws from the front, nuts slid in from the outer Y faces
    for (h = panel_holes) {
        translate([h[0], h[1], body_h - (panel_screw_len - panel_t) - 1])
            cylinder(d = m3_clear, h = top_z);
        nut_slot_y(h[0], h[1], panel_nut_z, h[1] < L/2 ? 0 : L);
    }
    // friction-plate screws from the rear
    for (o = fc_holes) {
        x = x_c + o[0]; y = spout_y + o[1];
        translate([x, y, -1]) cylinder(d = m3_clear, h = fc_nut_z + nut_h/2 + 3);
        nut_slot_y(x, y, fc_nut_z, y < L/2 ? 0 : L);
    }
    // alignment dowels (1.75 mm filament) through the plates, blind in the blocks
    for (sx = [-1, 1]) translate([x_c + sx*dowel_x_off, y_a - dowel_depth, dowel_z])
        rotate([-90, 0, 0]) cylinder(d = dowel_d, h = y_f - y_a + 2*dowel_depth);
    // spout bore
    translate([x_c, spout_y, -1]) cylinder(d = spout_d, h = port_floor_z + 1.5);
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
        if (p == "back_block" || p == "front_block") lick_port();
        if (p == "fiber_plate_a") { beam_slot(y_a, plate_a_t); fiber_groove(y_b, beam_a_depth); }
        if (p == "fiber_plate_b") { beam_slot(y_b, plate_b_t); fiber_groove(y_f, beam_b_depth); }
    }
}

// friction plate in its own frame: z = 0 outer face, z = fc_t faces the poke
module friction_plate() {
    difference() {
        linear_extrude(fc_t) hull() {
            circle(r = fc_lobe_r);
            for (o = fc_holes) translate(o) circle(r = fc_lobe_r);
        }
        translate([0, 0, -1]) cylinder(d = fc_spout_d, h = fc_t + 2);
        translate([0, 0, fc_t - oring_depth]) cylinder(d = oring_d, h = oring_depth + 1);
        for (o = fc_holes) translate(o) {
            translate([0, 0, -1]) cylinder(d = m3_clear, h = fc_t + 2);
            translate([0, 0, -eps]) cylinder(d1 = csk_d, d2 = 0, h = csk_d/2);
        }
    }
}

layers = ["back_block", "fiber_plate_a", "fiber_plate_b", "front_block"];
layer_colors = ["SteelBlue", "Orange", "Gold", "SteelBlue"];

module assembly(gap = 0) {
    for (i = [0:3]) color(layer_colors[i], 0.9) translate([0, i*gap, 0]) poke_part(layers[i]);
    color("DimGray") translate([x_c, spout_y, -gap - fc_t]) friction_plate();
}

// print orientation: mating/back face on the bed
module print_part(p) {
    if (p == "back_block")    rotate([90, 0, 0]) poke_part(p);
    if (p == "fiber_plate_a") rotate([90, 0, 0]) translate([0, -y_a, 0]) poke_part(p);
    if (p == "fiber_plate_b") rotate([90, 0, 0]) translate([0, -y_b, 0]) poke_part(p);
    if (p == "front_block")   rotate([90, 0, 0]) translate([0, -y_f, 0]) poke_part(p);
    if (p == "friction_plate") friction_plate();
}

if (part == "assembly") assembly(0);
else if (part == "exploded") assembly(explode);
else print_part(part);
