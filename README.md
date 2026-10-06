# OpenSCAD sources

| File | Contents |
|-|-|
| `lickometer_common.scad` | Shared helpers and fiber-holder base dimensions |
| `led_holder.scad` | Faithful rebuild of `..._LED_Holder.STL` |
| `photo_holder.scad` | Faithful rebuild of `..._Photo_Holder.STL` |
| `poke.scad` | Simplified parametric redesign of the poke (replaces parts 1–6) |
| `stl/` | Pre-rendered poke parts in print orientation |

## Poke (`poke.scad`)

Choose the output with `part` (`assembly`, `exploded`, `back_block`, `fiber_plate_a`,
`fiber_plate_b`, `front_block`, `friction_plate`) and the port size with `sex` (`M`/`F`).
The parameters appear in the OpenSCAD Customizer, or you can set them on the command line:

    openscad -D 'part="front_block"' -D 'sex="F"' -o poke_front_block_F.stl poke.scad

Stack, back to front: back block → fiber plate A (deep beam, 5.75 mm) → fiber plate B
(shallow beam, 2.1 mm) → front block. Each fiber lies in the groove on the front face of
its plate, crosses the 3.3 mm beam gap, and exits straight out of the rear (z = 0) towards
the remote electronics box.

Hardware:
- 2× M3×20 socket head (clamp the stack) + 2 square nuts in the front block's outer face
- 4× M3×12 countersunk (acrylic panel) + 4 square nuts slid in from the outer faces
- 3× M3×12 countersunk (friction plate, optional) + 3 square nuts
- 2× ~6.5 mm pieces of 1.75 mm filament as alignment dowels
- 16G blunt needle as the spout (bore at the plate A / B interface)

Compared with the original, this version drops the PCB mounting features, the side
fiber routing to the LED/photo holders and the part 5 LED holder. The acrylic panel
interface (Ø25 boss, screws at ±14.75 × ±8 mm) is unchanged.
