// Lickometer_Dual_Detection_Optical_Fiber_Photo_Holder
// Holds two optical fibers under two photosensors.
include <lickometer_common.scad>

fiber_y0     = 10.305;  // first fiber position along the bar
fiber_pitch  = 7.49;    // spacing between fibers
fiber_count  = 2;
pocket_depth = 1.5;     // photosensor pocket depth from the top face
pocket_size  = [4.25, 5.35];

module photo_holder() {
    difference() {
        fiber_holder_body();
        for (i = [0:fiber_count - 1])
            translate([fh_width/2, fiber_y0 + i*fiber_pitch, 0]) {
                fiber_hole(fh_height - pocket_depth);
                translate([0, 0, fh_height - pocket_depth]) pocket(pocket_size, pocket_depth);
            }
    }
}

photo_holder();
