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
`fiber_plate_b`, `front_block`, `friction_plate`, `spout`) and the animal with `animal`
(`mouse_M`, `mouse_F`, `rat`, `ferret`). The parameters appear in the OpenSCAD Customizer,
or you can set them on the command line:

    openscad -D 'part="front_block"' -D 'animal="ferret"' -o poke_front_block.stl poke.scad

Stack, back to front: back block → fiber plate A (deep beam, 5.75 mm) → fiber plate B
(shallow beam, 2.1 mm) → front block. Each fiber lies in the groove on the front face of
its plate, crosses the beam gap, and exits straight out of the rear (z = 0) towards the
remote electronics box. Trapezoidal wings on the plate edges key into recesses in the
back block's ears (as in the original part 1), and two printed posts on the back block
pass through both plates (each half, when the spout channel splits them) into the front
block, so the fiber guides are located during assembly.

### Animal presets

| Preset | Beam gap | Lick port (W × L) | Front | Spout | Body (W × L × D) |
|-|-|-|-|-|-|
| `mouse_M` | 3.3 mm | 6.0 × 12.1 mm | acrylic boss | 16G needle | 37.2 × 24.5 × 24 mm |
| `mouse_F` | 3.3 mm | 6.0 × 10.6 mm | acrylic boss | 16G needle | 37.2 × 24.5 × 24 mm |
| `rat` | 9.0 mm | 11 × 16 mm | flat | printed, Ø5.3 / bore 1.6 | 38.6 × 28.4 × 24 mm |
| `ferret` | 13.5 mm | 16 × 20 mm | flat | printed, Ø5.3 / bore 2.0 | 43.6 × 32.4 × 24 mm |

The beam gap is the tongue width plus clearance (rat ~7.5 mm, ferret 8–12 mm). Presets
live in the `presets` table at the top of `poke.scad`. The body size, fiber routing,
clamp screw positions and screw length are derived from the beam gap and port size.

### Printed spout (rat, ferret)

The spout is a tube with a hose barb (for 3.2 mm ID tubing, `tubing_id`) and a flange.
It slides into the channel through the fiber plates from the rear, and the clamp plate
(`friction_plate`) holds the flange against the rear face. Print it standing on the barb
end. Use a material suitable for drinking water (e.g. PETG or a biocompatible resin) and
check that the bore is open and watertight before use.

### Hardware

- 2× M3 socket head clamp screws (M3×20 mouse, M3×25 rat/ferret; printed in the console)
  + 2 square nuts in the front block's outer face
- 4× M3×12 countersunk front mounting screws + 4 square nuts slid in from the outer faces
- 3× M3×12 countersunk for the friction / spout clamp plate + 3 square nuts
- mouse: 16G blunt needle as the spout (bore at the plate A / B interface)

Compared with the original, this version drops the PCB mounting features, the side
fiber routing to the LED/photo holders and the part 5 LED holder. For the mouse presets
the acrylic panel interface (Ø25 boss, screws at ±14.75 × ±8 mm) is unchanged.

The wider rat and ferret beam gaps reduce the light reaching the receiving fiber. Check
the receiver output (TP1/TP3, > 3 V recommended) with the fiber plates before printing
the rest. If it is too low, use thicker fiber (change `fiber_d`) or raise the receiver gain.
