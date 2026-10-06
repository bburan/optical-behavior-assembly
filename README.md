# OpenSCAD sources

| File | Contents |
|-|-|
| `lickometer_common.scad` | Shared helpers and fiber-holder base dimensions |
| `led_holder.scad` | Faithful rebuild of `..._LED_Holder.STL` |
| `photo_holder.scad` | Faithful rebuild of `..._Photo_Holder.STL` |
| `poke.scad` | Simplified parametric redesign of the poke (replaces parts 1–6) |
| `stl/<animal>/` | Pre-rendered poke parts in print orientation |

## Poke (`poke.scad`)

Choose the output with `part` (`assembly`, `exploded`, `back_block`, `fiber_plate_a`,
`fiber_plate_b`, `fiber_cover`, `front_block`, `friction_plate`, `spout`) and the animal with `animal`
(`mouse_M`, `mouse_F`, `rat`, `ferret`). The parameters appear in the OpenSCAD Customizer,
or you can set them on the command line:

    openscad -D 'part="front_block"' -D 'animal="ferret"' -o poke_front_block.stl poke.scad

Stack, back to front: back block → fiber plate A (deep beam, 5.75 mm) → fiber plate B
(shallow beam, 2.1 mm) → fiber cover → front block. Each fiber lies in the groove on the
front face of its plate, crosses the beam gap, and exits straight out of the rear (z = 0)
towards the remote electronics box. The fiber cover (`cover_t`, 1.2 mm; 0 = none) closes
plate B's groove right up to the beam gap, where the front block's wider lick port would
otherwise leave the fiber exposed. Trapezoidal wings on the plates and cover key into
recesses in the back block's ears (as in the original part 1), and two printed posts on
the back block pass through the plates and cover into the front block, so the fiber
guides are located during assembly.

### Animal presets

| Preset | Beam gap | Lick port (W × L) | Front | Spout | Body (W × L × D) |
|-|-|-|-|-|-|
| `mouse_M` | 3.3 mm | 6.0 × 12.1 mm | flat | 16G needle | 45.8 × 27.7 × 24 mm |
| `mouse_F` | 3.3 mm | 6.0 × 10.6 mm | flat | 16G needle | 45.8 × 27.7 × 24 mm |
| `rat` | 9.0 mm | 11 × 16 mm | flat | printed, Ø5.3 / bore 1.6 | 51.5 × 28.6 × 24 mm |
| `ferret` | 13.5 mm | 16 × 20 mm | flat | printed, Ø5.3 / bore 2.0 | 56.0 × 32.4 × 24 mm |

Body sizes are for the defaults (2 mm fiber, 10 mm bend radius).

The beam gap is the tongue width plus clearance (rat ~7.5 mm, ferret 8–12 mm). Presets
live in the `presets` table at the top of `poke.scad`. The body size, fiber routing,
clamp screw positions and screw length are derived from the beam gap and port size.
The acrylic-panel boss of the original can still be switched on per preset (second
column of the table) but is off for all presets.

### Fiber

The grooves are sized for a 2.0 mm fiber including jacket (`fiber_d`), with SLA
clearances: 2.3 mm wide (`fiber_clear_w`) and 2.15 mm deep (`fiber_clear_d`), so the
mating plate closes over the fiber without pinching it. The fiber plates are the groove
depth plus a fixed floor (`plate_a_floor` 1.35 mm, `plate_b_floor` 1.95 mm), i.e.
3.5 and 4.1 mm for a 2 mm fiber; the blocks, posts, clamp screws and spout follow.
The default bend radius (`fiber_bend_r`) is 10 mm; the original design used 4 mm.

`fiber_bend_r` is parametric: the fiber exit positions, body width and (above ~16 mm)
body depth grow to fit the bend, keeping a 3 mm straight run before each fiber tip
(`fiber_tip_straight`). The lick port depth is measured from the front face
(`port_depth`), so the spout stays within reach when the body gets deeper. The model
refuses to render if a groove comes closer than `groove_min_wall` to a clamp screw or
locating post. Approximate body size (W × D, mm):

| `fiber_bend_r` | mouse | rat | ferret |
|-|-|-|-|
| 4 | 39.6 × 24 | 41.0 × 24 | 46.0 × 24 |
| 10 (default) | 45.8 × 24 | 51.5 × 24 | 56.0 × 24 |
| 15 | 55.8 × 24 | 61.5 × 24 | 66.0 × 24 |
| 20 | 65.8 × 26.75 | 71.5 × 26.75 | 76.0 × 26.75 |
| 25 | 75.8 × 31.75 | 81.5 × 31.75 | 86.0 × 31.75 |

### Printed spout (rat, ferret)

The spout is a tube with a hose barb and a flange. The water tubing is set per preset
(last two columns of the `presets` table): ferret uses 3 mm (1/8") ID × 5 mm OD tubing
(barb 3.2–3.8 mm), and the clamp-plate hole lets the tubing slide over the whole barb up
to the flange. Rat is still set to 3.2 mm ID tubing with unknown OD.
It slides into a bore through the fiber plates from the rear, and the clamp plate
(`friction_plate`) holds the flange against the rear face. Print it standing on the barb
end. Use a material suitable for drinking water (e.g. PETG or a biocompatible resin) and
check that the bore is open and watertight before use.

### Hardware

- 2× M3 socket head clamp screws (M3×22 mouse, M3×25 rat/ferret; printed in the console)
  + 2 square nuts in pockets in the front block's outer face (the pocket is deepened
  when needed so the screw reaches the nut)
- 4× M3×12 countersunk front mounting screws + 4 square nuts slid in from the outer faces
- 3× M3×12 countersunk for the friction / spout clamp plate + 3 square nuts
- mouse: 16G blunt needle as the spout (bore at the plate A / B interface)

Compared with the original, this version drops the PCB mounting features, the side
fiber routing to the LED/photo holders, the part 5 LED holder and the acrylic-panel boss.

The wider rat and ferret beam gaps reduce the light reaching the receiving fiber. Check
the receiver output (TP1/TP3, > 3 V recommended) with the fiber plates before printing
the rest. If it is too low, use thicker fiber (change `fiber_d`) or raise the receiver gain.
