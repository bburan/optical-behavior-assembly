# Optical behavior assembly: parametric lickometer poke

A parametric [OpenSCAD](https://openscad.org/) model of a dual-beam, optical-fiber
lickometer poke, with presets for mice, rats and ferrets.

> **Status:** not yet print-tested. Fits, clearances and the optical signal across the
> wider rat/ferret beam gaps still need to be checked on a real print.

## Attribution

This work is **derived from the optical-fiber lickometer by Silva et al. (2024)**,
developed at the Champalimaud Foundation:

> Silva A, Carriço P, Fernandes AB, Saraiva T, Oliveira-Maia AJ, Alves da Silva J (2024).
> High-Precision Optical Fiber-Based Lickometer. *eNeuro* 11(7):ENEURO.0189-24.2024.
> https://doi.org/10.1523/ENEURO.0189-24.2024

Original design files: https://github.com/fchampalimaud/optical-lickometer (see
[`CONTRIB_ORIGINAL`](CONTRIB_ORIGINAL)). Their design includes the 3D-printed poke
(`Lickometer_Dual_Detection_Optical_Fiber-1..6`, LED and photosensor holders), laser-cut
acrylic panels, the electronics and Bonsai workflows. The hardware design files are
distributed under the [TAPR Open Hardware License v1.0](LICENSE); the article is published
under CC BY 4.0.

If you use this model, please cite the original article.

The core approach is theirs: a stack of 3D-printed plates that hold plastic optical
fibers in grooves, so that two beams cross the lick slot at two depths, clamped together
with screws and fed from a spout at the rear. This repository re-implements that approach
as a parametric model. It is not an official release of the original authors, and they
have not reviewed or endorsed it.

## Use of AI

The parametric model in this repository was developed with the help of an AI coding
assistant (Claude, by Anthropic), working from the original authors' STL files,
assembly instructions and design approach. The AI:

- measured the original STL meshes (cross-sections, plane and hole detection) and rebuilt
  the LED and photosensor holders as parametric OpenSCAD files;
- wrote the simplified, parametric redesign of the poke (`poke.scad`) and its presets;
- generated the STL exports and checked them (renders, part-overlap checks, clearance
  checks, overhang checks).

All design decisions and requirements were set and reviewed by the repository owner
([@bburan](https://github.com/bburan)). Treat the geometry as untested until it has been
printed and validated.

## Changes from the original design

As required by the TAPR OHL (section 4.2), these are the elements that were changed. The
modifications are licensed under the terms of the TAPR Open Hardware License v1.0.

- **New files:** everything in this repository is new documentation derived from the
  original poke and holder parts. The original files themselves are not modified.
- `led_holder.scad`, `photo_holder.scad`: parametric rebuilds of
  `Lickometer_Dual_Detection_Optical_Fiber_LED_Holder.STL` and `..._Photo_Holder.STL`
  (geometry within ~0.13 mm of the originals).
- `poke.scad`: a simplified, parametric redesign of poke parts 1–6:
  - PCB mounting features, the side fiber routing to the board-mounted LED/photosensor
    holders, the part 5 LED holder and the acrylic-panel boss were removed;
  - animal presets (mouse M/F, rat, ferret) set the beam gap and lick port size, and the
    body, fiber routing and fasteners are derived from them;
  - the fiber diameter and bend radius are parameters; the plates grow to fit them;
  - a fiber cover plate, printed locating posts, a 3D-printed spout with hose barb (rat,
    ferret) and a spout clamp plate were added;
  - the parts were adjusted for printing without support on a resin (SLA) printer.

## Files

| File | Contents |
|-|-|
| `lickometer_common.scad` | Shared helpers and fiber-holder base dimensions |
| `led_holder.scad` | Faithful rebuild of `..._LED_Holder.STL` |
| `photo_holder.scad` | Faithful rebuild of `..._Photo_Holder.STL` |
| `poke.scad` | Simplified parametric redesign of the poke (replaces parts 1–6) |
| `stl/<animal>/` | Pre-rendered poke parts in print orientation |

## Poke (`poke.scad`)

Choose the output with `part` (`assembly`, `exploded`, `bottom_block`, `fiber_plate_a`,
`fiber_plate_b`, `fiber_cover`, `top_block`, `friction_plate`, `spout`) and the animal with `animal`
(`mouse_M`, `mouse_F`, `rat`, `ferret`). The parameters appear in the OpenSCAD Customizer,
or you can set them on the command line:

    openscad -D 'part="top_block"' -D 'animal="ferret"' -o poke_top_block.stl poke.scad

The stack is described with the bottom block (blue in the assembly view) at the bottom and
the top block (green) at the top; the "front face" is the face the animal licks at and the
"rear" is the opposite face, where the fibers and spout leave.

Stack, bottom to top: bottom block → fiber plate A (deep beam, 5.75 mm) → fiber plate B
(shallow beam, 2.1 mm) → fiber cover → top block. Each fiber lies in the groove on the
top face of its plate, crosses the beam gap, and exits straight out of the rear (z = 0)
towards the remote electronics box. The fiber cover (`cover_t`, 1.2 mm; 0 = none) closes
plate B's groove right up to the beam gap, where the top block's wider lick port would
otherwise leave the fiber exposed. Trapezoidal wings on the plates and cover key into
recesses in the bottom block's ears (as in the original part 1), and two printed posts on
the bottom block pass through the plates and cover into the top block, so the fiber
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
end: a 50° cone under the flange (`self_support_angle`) makes it print without support,
and the clamp plate has a matching conical seat. Use a material suitable for drinking
water (e.g. PETG or a biocompatible resin) and check that the bore is open and watertight
before use.

Both the spout and the friction / spout clamp plate print without support in their exported
orientation (no downward-facing surface steeper than 45° from vertical).

### Hardware

- 2× M3 socket head clamp screws (M3×22 mouse, M3×25 rat/ferret; printed in the console)
  + 2 square nuts in pockets in the top block's outer face (the pocket is deepened
  when needed so the screw reaches the nut)
- 4× M3×12 countersunk front mounting screws + 4 square nuts slid in from the outer faces
- 3× M3×12 button or socket head for the friction / spout clamp plate + 3 square nuts
  (plain holes; set `fc_countersunk = true` for countersunk screws, which adds 45°
  overhangs on the plate's bed side)
- mouse: 16G blunt needle as the spout (bore at the plate A / B interface)

Compared with the original, this version drops the PCB mounting features, the side
fiber routing to the LED/photo holders, the part 5 LED holder and the acrylic-panel boss.

The wider rat and ferret beam gaps reduce the light reaching the receiving fiber. Check
the receiver output (TP1/TP3, > 3 V recommended) with the fiber plates before printing
the rest. If it is too low, use thicker fiber (change `fiber_d`) or raise the receiver gain.
