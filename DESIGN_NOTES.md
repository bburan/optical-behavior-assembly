# Design notes

Knowledge behind `poke.scad`: what was measured on the original lickometer, why the
parametric model is shaped the way it is, what was decided and rejected, and what is
still open. Read this before changing the model. See [README.md](README.md) for usage and
[CLAUDE.md](CLAUDE.md) for the working rules and checks.

Original design: Silva et al. (2024), *eNeuro* 11(7):ENEURO.0189-24.2024,
https://github.com/fchampalimaud/optical-lickometer (TAPR OHL v1.0). Its files were
measured from the paper's supplementary material (`Hardware/CAD/*.STL`, assembly
instructions PDF, acrylic panel PDF, `Lickometer_model_v1.easm`).

## 1. How the original was reverse-engineered

- The STLs are binary meshes (no feature history). They were measured with
  `tools/meshtool.py`: axis-aligned planar faces (`planes`), cross-sections with circle
  fitting (`slice`), and section plots (`plot`). Rebuilds were validated with
  `tools/stl_diff.py` (volume and surface deviation).
- `Lickometer_model_v1.easm` (eDrawings) wraps a ZIP whose `eModel` is compressed HOOPS
  stream data (HSF). It was not decoded; the stacking order was derived from mating faces
  instead (section 2.2).
- The acrylic panel PDF has vector geometry; circle fits of its paths gave the panel holes.

## 2. Original design measurements

All dimensions in mm. "A frame" = the coordinate frame of the original part 1 STL:
X across (0..37.2), Y stacking direction (part 1 at y 0..15.7), Z depth (0 = rear,
24 = front face where the animal licks).

### 2.1 Original parts

| Part | Size (X × Y × Z) | Role |
|-|-|-|
| `-1` | 37.2 × 15.7 × 24 | rear block of the stack (our **bottom block**); body y 0–6.1, side "ears" x 0–5.44 and 31.76–37.2 extend to y 15.7 |
| `-2` | 31 × 3.9 × 24 | fiber plate with the deeper beam (our **plate A**); body 2.5 thick + a rib (x 14–17, z 0–9, 1.4 thick) |
| `-3` | 31 × 3.1 × 24 | fiber plate with the shallow beam (our **plate B**); base y 0.4–2.4, rim to 3.5; slot receives plate 2's rib |
| `-4_M` / `-4_F` | 37.2 × 12.8 × 24 | front block (our **top block**); M and F differ only in lick port length |
| `-5` | 13.2 × 7.9 × 24 | wedge in a V-notch of part 4 holding an LED (Ø4.5 bore, 0.5 mm pinhole at the front): cue light. Not reproduced. |
| `-6` | 20 × 21 × 4.5 | spout friction controller (our **friction_plate**) |
| LED holder | 6.5 × 28.1 × 6.25 | PCB-mounted fiber holder (rebuilt faithfully: `led_holder.scad`) |
| Photo holder | 6.5 × 28.1 × 6.25 | PCB-mounted fiber holder (`photo_holder.scad`); its STL sits at x = 17.8 (assembly position) |

### 2.2 Stack (A frame)

part 1 body y 0–6.1 → plate 2 y 6.1–8.6 → plate 3 y 8.6–11.7 → part 4 y 11.7–24.5.
(STL offsets: plate 2 +6.1; plate 3 and part 4 +8.2.) Part 1's ears cover the plates'
edges and reach 4 mm into a relief in part 4.

### 2.3 Key features (A frame)

- **Plate locating wings** (on plates 2 and 3, mirrored both sides): trapezoids sticking
  out 2.5 mm from the plate edge (plate edge at x 5.6 / 31.6), base z 5–14, flat tip
  z 7.75–11.25 (45° flanks), centred on z 9.5. Part 1's ears have the matching recess
  with ~0.15 clearance and filleted (~0.5) corners.
- **Beams:** plate 2 groove crosses the slot at z 18.25 (5.75 below the front), plate 3
  at z ~21.9 (2.1 below). Grooves ~1.1 wide × 1.1 deep on the plate faces; they run up
  the plate sides (x ~6.6–7.7) from z = 0 and bend inward with a ~3.5–4 mm radius.
- **Beam gap (lick slot in the plates):** 3.3 wide (x 16.95–20.25), from z 9 to the front.
- **Lick port in the blocks:** 6.0 wide at depth (7.5 at the front with a ~0.75 lead-in),
  stadium-shaped, y ~3.4 to ~15.5 (M) / ~14.0 (F): length ~12.1 (M) / ~10.6 (F).
  Port floor z = 9.
- **Spout:** 16G blunt needle (OD 1.65) in a Ø1.75 bore at (x 18.6, y 8.2), z 0–9.
- **Clamp screws:** 2 × M3×20 along Y at x 10.1 / 27.1, z 9.5; counterbore Ø~7 in part 1
  (~3.3 deep); nuts in part 4.
- **Front boss:** Ø~25 (R ~12.5, small top fillet), z 19–24, centre (18.6, 12.2), passes
  through the 5 mm acrylic panel. Panel hole Ø26.2.
- **Panel screws:** 4 × M3 countersunk at boss centre ± 14.75 (X) × ± 8 (Y) → (3.85 / 33.35,
  4.2 / 20.2), from the front face into square nuts.
- **Friction controller (part 6):** needle hole Ø1.9 at (10, 9.175) in its own frame;
  3 × M3 countersunk at (10, 4.275), (5, 16.775), (15, 16.775) = offsets (0, −4.9),
  (±5, +7.6) from the needle; O-ring pocket Ø5 × 1.2; two kidney-shaped flex slots.
  In the assembly the screws land in part 1 (x 18.6, y ~3.3) and part 4 (x 13.6/23.6).
- **Square nuts:** 11 × M3 square nuts (5 in part 1, 6 in part 4), in slots.
- **Male/female:** the only difference between parts 4_M and 4_F is the lick port length
  (and small related cavities near x 12–15 / 22–25, z ~12).

### 2.4 LED / photosensor holders (faithful rebuilds, within ~0.13 mm)

- Common body: stadium 6.5 × 28.1 × 6.25, 0.5 bottom chamfer, 2 × M3 holes Ø3.2 at
  y 3.25 / 24.85 with 0.5 chamfers both ends; fiber holes Ø1.25 with 0.2 bottom chamfer
  and a 45° countersink to Ø2.5 into the pocket.
- LED holder: 4 fibers at y 8.25 + 4n; pockets alternate 3.75 × 3.05 and 3.0 × 2.26,
  1.25 deep, with ~10° lead-in and 0.4 top fillet.
- Photo holder: 2 fibers at y 10.305 / 17.795 (pitch 7.49); pockets 4.25 × 5.35, 1.5 deep.

### 2.5 Original assembly facts (assembly instructions PDF)

- Fiber: 500 µm POF (Edmund 57-097), 4 pieces of ~77 mm, cut with a cutting block.
- Plates 1–4 clamped with 2 × M3×20 socket head; part 5 on 2 × M3×10 nylon spacers;
  poke to PCB with 4 × M3×12 nylon screws; holders to PCB with 4 × M3×12 nylon + nuts.
- Acrylic panels attached with 4 × M3×12 countersunk; part 6 with 3 × M3×12 countersunk
  plus a 1.6 mm ID silicone tube section / O-ring around the spout.
- Spout: 16G blunt needle (SAI 847.356.0321).
- Alignment check: > 3 V at the transimpedance amplifier outputs (TP3, TP1) with the beam
  unbroken.

## 3. The parametric model (`poke.scad`)

### 3.1 Structure

- One file; `part` selects what is rendered, `animal` selects a preset row.
- Every layer is `intersection(envelope, layer_region) − cutters`, so features cut across
  layers stay consistent automatically (e.g. a nut slot that crosses an interface leaves
  a matching relief in the neighbouring part).
- Stack along Y: bottom block → plate A → plate B → fiber cover → top block. Z = depth
  (0 = rear, `top_z` = front face). X across, centred on `x_c`.
- Derived quantities live in the `[Hidden]` section; tunables are in the Customizer
  sections above it. The console prints a one-line summary per render (body size, beam
  gap, bend radius, clamp screw length, spout/barb sizes).
- Asserts stop the render when a rule is violated (groove too close to a hole, no clamp
  screw length fits, port too close to an outer face, spout bore vs barb, seat too thin).

### 3.2 Presets and why

| Preset | Beam gap | Port W × L | Port bottom end* | Spout | Tubing |
|-|-|-|-|-|-|
| mouse_M | 3.3 | 6.0 × 12.1 | 5.5 | 16G needle | – |
| mouse_F | 3.3 | 6.0 × 10.6 | 5.5 | 16G needle | – |
| rat | 9.0 | 11 × 16 | 8.0 | printed, bore 1.6 | 3.2 ID, OD unknown |
| ferret | 13.5 | 16 × 20 | 10.0 | printed, bore 2.0 | 3 (1/8") ID × 5 OD |

\* from the plate-stack centre towards the bottom block.

- Beam gap = tongue **width** + clearance: mouse ~2–3 mm (original 3.3), rat ~7.5 mm → 9,
  ferret 8–12 mm → 13.5. Port width = gap + 2–2.5 mm so the fiber tips are recessed.
- Mouse values reproduce the original. The model has a regression guarantee for the
  mouse geometry at the original settings (see 3.6).

### 3.3 Parameter rationale (current defaults)

- **Fiber:** `fiber_d = 2.0` (2 mm OD incl. jacket, the fiber the user plans to use).
  Grooves `+0.3` wide (0.15/side) and `+0.15` deep for SLA (Form 4) tolerances, so the
  mating plate closes without pinching. The IF-C-E1000 (1 mm, 2.2 mm jacket) was
  considered and dropped (jacket too thick, discontinued).
- **Plate thickness = groove depth + floor** (`plate_a_floor` 1.35, `plate_b_floor` 1.95,
  the original's material behind the grooves). With 2 mm fiber: 3.5 and 4.1.
- **Bend radius** `fiber_bend_r = 10`. The fiber spec says ≥ 25 mm, but the original
  assemblers report the ~4 mm original radius works. Body width/depth grow with it
  (`fiber_x_off = max(clamp-derived, R + gap/2 + fiber_tip_straight)`,
  `depth = max(24, R + beam_a_depth + 1)`). Approximate W × D with 2 mm fiber:
  R4 39.6–46 × 24; R10 45.8–56 × 24; R15 55.8–66 × 24; R25 75.8–86 × 31.75.
- **Fiber exits at the rear** (z = 0). Side exits were proposed (no bend at all) and
  rejected: the fibers cannot exit the sides in the housing.
- **Beam depths** 5.75 / 2.1 below the front face (original). `port_depth = 15` is
  measured from the front face so the spout stays reachable when the body gets deeper.
- **Fiber cover** `cover_t = 1.2`: the top block's lick port is wider than the beam gap,
  which left plate B's groove (fiber tips) exposed. The cover has the plates' beam slot.
- **Locating:** ears + trapezoid wings (original approach, X and Z location of the plates
  while stacking) and two printed posts Ø2.5 on the bottom block (0.15 radial clearance,
  2 mm into the top block). Posts replaced 1.75 mm filament dowels because the plate halves
  (when split by a spout channel) were not connected to anything during assembly.
  `post_x_off` keeps ≥ 1 mm wall to the lick port.
- **Clamp screws:** chosen from `clamp_lengths` (incl. M3×18/22): the longest screw whose
  head seats 3.2 … (bottom_t − 1.5) deep; the nut pocket in the top block's outer face is
  deepened as needed but keeps ≥ 3 mm of top block in front of the plates. Currently
  mouse M3×22, rat/ferret M3×25.
- **Front mounting:** 4 × M3 at the corners (3.85 from the X sides, 4.2 / 4.3 from the
  Y faces; same pattern as the acrylic panel), nuts slid in from the outer Y faces. The
  acrylic boss (`panel_mount`) is off for all presets: no acrylic panel will be used.
- **Printed spout (rat, ferret):** OD 5.3 (`spout_od_nom`), in a round bore through the
  plates (≥ 0.8 mm plate wall each side) — or a full-thickness channel if the stack is
  too thin. Tip 1 mm above the port floor. Barb `tubing_id + 0.2 … + 0.8` (two cones),
  8 mm long. Flange Ø(OD + 3) × 1.5 with a 50° (`self_support_angle`) cone underneath so
  it prints without support; the clamp plate has a matching conical seat. When the tubing
  OD is known, the clamp-plate hole lets the tubing slide over the whole barb.
- **Friction / spout clamp plate:** screw offsets (0, −fc_bottom) and (±4.5, +7.6) from the
  spout; plain M3 holes for M3×12 button/socket heads (`fc_countersunk = false`, because
  countersinks are 45° overhangs on the bed side).
- **Clearances (SLA):** 0.15 per side for slides (ears, posts, spout), 0.2 for nuts and
  M3 holes (Ø3.4).
- **Colors** (assembly view): bottom block steel blue, plate A orange, plate B gold, cover
  tomato, top block green, clamp plate grey, spout light blue. Layers are `render()`ed in
  the assembly so the F5 preview does not let the last part cover the shared envelope.

### 3.4 Coordinates and naming

- "Bottom block" / "top block" (not back/front) — the user's preferred terms. "Front face"
  = where the animal licks (max Z); "rear" = where fibers and spout leave (Z = 0).
- `friction_plate` keeps its name (it is the spout clamp for rat/ferret).

### 3.5 Printing

- Printer: Formlabs Form 4, Tough 2000 V2 (user). Supports are placed manually in PreForm.
- Spout and friction plate print support-free in their exported orientation (checked);
  the spout still benefits from 3–4 touchpoints around the barb tip for stability.
  Tough 2000 is not rated for drinking water; consider a biocompatible resin for the spout.
  Flush the spout bore with IPA before curing.
- Keep support touchpoints off mating faces, grooves, posts and wings.

### 3.6 Verification approach

- `python tools/check_all.py` (see CLAUDE.md). Mouse regression: at `fiber_d = 1.0`,
  `fiber_bend_r = 4`, `cover_t = 0` the model reproduced the earlier committed mouse STLs
  vertex-for-vertex; refactors were checked this way at each step.
- Overlap checks render `intersection()` of two parts; "empty" or zero volume = OK. Use an
  absolute Windows path in the `include` (a POSIX `/c/...` path silently fails and makes
  every check look empty); `check_all.py` guards against this and includes a sanity case.

## 4. Open items

- First print: measure fits (ears/wings, posts, nut slots, grooves) and adjust
  `ear_clear`, `post_clear`, `fiber_clear_w/_d`, `nut_clear`.
- Optical signal across the 9 / 13.5 mm rat/ferret gaps (> 3 V at TP1/TP3); options if
  low: thicker fiber, lenses, more receiver gain.
- Rat water tubing size (preset still 3.2 ID, OD unknown).
- Cue LED (original part 5) not reproduced; could be added as a pocket in the top block.
- Spout material (biocompatible resin) and the effect of support nubs on the barb seal.
- TAPR OHL: email the modified documentation (repo link) to the addresses in
  `CONTRIB_ORIGINAL`.
