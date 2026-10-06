# CLAUDE.md

Parametric OpenSCAD model of a dual optical-fiber lickometer poke (mouse, rat, ferret),
derived from Silva et al. (2024) / github.com/fchampalimaud/optical-lickometer.

- **Before changing geometry, read [DESIGN_NOTES.md](DESIGN_NOTES.md)**: original design
  measurements, parameter rationale, decisions and rejected alternatives, open items.
- [README.md](README.md): usage, presets, hardware, attribution, AI-use statement.

## Files

- `poke.scad` — the poke (all parts, presets, assembly/exploded views).
- `led_holder.scad`, `photo_holder.scad`, `lickometer_common.scad` — faithful rebuilds of the
  original PCB fiber holders (not used by the poke).
- `stl/<animal>/poke_*.stl` — exported parts in print orientation (mouse parts are shared
  except `poke_top_block_M/F.stl`).
- `tools/` — `check_all.py` (export + all checks), `meshtool.py` (measure/slice STLs),
  `stl_diff.py` (exact or deviation compare), `overhang.py` (support check).
- `LICENSE` (TAPR OHL v1.0, unaltered), `CONTRIB_ORIGINAL` (original licensors).

## Conventions

- Axes: X across; Y = stacking direction, bottom block (y = 0) → plate A → plate B →
  fiber cover → top block; Z = depth, 0 = rear (fibers and spout exit), `top_z` = front
  face (where the animal licks).
- Say "bottom block" / "top block" (not back/front). `friction_plate` keeps its name.
- Units mm. Clearances are tuned for SLA (Form 4, Tough 2000): 0.15 per side for slides,
  0.2 for nuts/M3 holes.
- Every layer is cut from one shared envelope; add features as global cutters in
  `fastener_cuts()` / part-specific branches in `poke_part()` so neighbours stay consistent.
- New tunables go in a Customizer section with a comment; derived values in `[Hidden]`;
  add an `assert` for any new geometric rule.

## Rules for changes

1. Keep the mouse presets reproducing the original unless a change is intended; when
   refactoring, prove "no geometry change" by comparing STLs (`tools/stl_diff.py` or
   `check_all.py`) before and after.
2. After any model change run `python tools/check_all.py`; when the change is intended,
   `python tools/check_all.py --update` to re-export `stl/`, then run it again until it
   prints `ALL CHECKS PASSED`.
3. Parts may only touch at faces (no overlap); spout and friction plate must print
   without support (no overhang > 45° from vertical).
4. Keep README/DESIGN_NOTES in sync (presets table, sizes, hardware, decisions).
5. Only individual part STLs belong in `stl/` (no assembly/exploded STLs or PNG renders).

## Working with the user

- For larger design changes, explain the approach and wait for agreement before editing.
- Commit only when asked (sometimes "stage, don't commit" as a recovery point). Remote:
  `origin` = github.com/bburan/optical-behavior-assembly; pushing may need the user to
  sign in to GitHub (`! git push`).
- Ask when a request is ambiguous rather than guessing.

## Commands

    "C:/Program Files/OpenSCAD (Nightly)/openscad.com" --backend=manifold --export-format=binstl \
        -D 'part="top_block"' -D 'animal="ferret"' -o out.stl poke.scad
    python tools/check_all.py [--update] [-D name=value ...]
    python tools/meshtool.py part.stl planes | slice z 1,5 | plot y 2,3 out.png
    python tools/stl_diff.py a.stl b.stl
    python tools/overhang.py part.stl [limit_deg]

Python needs numpy and scipy (matplotlib for `plot`). In `include <...>` use an absolute
Windows path with forward slashes (`C:/...`), not `/c/...`.
