// Lickometer_Dual_Detection_Optical_Fiber_LED_Holder
// Holds four optical fibers under four LEDs (two pocket sizes, alternating).
include <lickometer_common.scad>

fiber_y0       = 8.25;  // first fiber position along the bar
fiber_pitch    = 4.0;   // spacing between fibers
fiber_count    = 4;
pocket_depth   = 1.25;  // LED pocket depth from the top face
pocket_a       = [3.75, 3.05];  // pockets at even positions (1st, 3rd)
pocket_b       = [3.0, 2.26];   // pockets at odd positions (2nd, 4th)

module led_holder() {
    floor_z = fh_height - pocket_depth;
    difference() {
        fiber_holder_body();
        for (i = [0:fiber_count - 1]) {
            translate([fh_width/2, fiber_y0 + i*fiber_pitch, 0]) {
                fiber_hole(floor_z);
                translate([0, 0, floor_z])
                    pocket(i % 2 == 0 ? pocket_a : pocket_b, pocket_depth);
            }
        }
    }
}

led_holder();
