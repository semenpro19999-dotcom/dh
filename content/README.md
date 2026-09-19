# KS3 content workspace

This is the production-shaped placeholder for the Blender → Godot 4.5+ content pipeline described in `docs/3D_PIPELINE.md`.

- `models/` — high/low mesh sources and hard-surface assets
- `textures/` — PBR maps, masks and decals
- `rigs/` — armatures, IK and control rig sources
- `animations/` — actions, NLA clips and cleaned mocap
- `maps/` — blockouts, greyboxes and map source scenes
- `exports/` — reviewed FBX / GLB / preview renders / QA manifests

Use the `KS3_[DOMAIN]_[ASSET]_[TYPE]_[VARIANT]` naming contract. `.gitkeep` files preserve the structure until real source assets arrive. Large binaries belong in approved Git LFS or artifact storage, not in the regular source diff.
