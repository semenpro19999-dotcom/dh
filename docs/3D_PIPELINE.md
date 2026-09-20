# KS3 — 3D pipeline: Blender → Godot 4.5+

## 0. Editor choice

**Blender 4.5 LTS+** — современный бесплатный 3D-редактор для hard-surface, sculpt, UV, rigging, animation, geometry nodes и Python automation. Рендер-превью — Eevee/Cycles, asset review — glTF viewer / Godot 4.5+.

Официальная установка: [blender.org/download](https://www.blender.org/download/). Официальный manual для glTF 2.0 и текущих exporter options: [Blender glTF manual](https://docs.blender.org/manual/en/latest/addons/import_export/scene_gltf2.html). FBX используем только там, где нужен стабильный skeletal interchange; glTF/GLB — основной формат для быстрых review и импорта в Godot.

> В sandbox не выполняется тихая установка бинарного 3D-редактора: лицензия, OS package и GPU должны быть выбраны на workstation команды. Ниже — воспроизводимая настройка, структура и quality gates.

## 1. Структура проекта

В репозитории создана production-заготовка `content/`:

```text
content/
├── models/       # high / low mesh, weapon, character, prop sources
├── textures/     # ALB, NRM, RMA, ORM, masks, decals
├── rigs/         # armature, IK, AnimationTree / IK sources
├── animations/   # actions, NLA, exported clips, mocap cleanup
├── maps/         # blockout, greybox, gameplay art, audio zones
└── exports/      # FBX, GLB, preview renders, QA manifests
```

Оригиналы `.blend` хранятся в DCC storage / LFS, exports с checksum — в build artifact storage. Не коммитить 4K/8K source textures и cooked maps без согласованного LFS policy.

### Naming

```text
KS3_[DOMAIN]_[ASSET]_[TYPE]_[VARIANT]

KS3_WPN_FEN9_MESH_HI.blend
KS3_WPN_FEN9_MESH_LO.fbx
KS3_WPN_FEN9_T_ALB_2K.png
KS3_WPN_FEN9_T_NRM_2K.png
KS3_WPN_FEN9_T_ORM_2K.png     # occlusion roughness metallic
KS3_WPN_FEN9_SKIN_COBALT_MI
KS3_CHR_HELIX_RIG.blend
KS3_CHR_HELIX_ANIM_RELOAD.fbx
KS3_MAP_RIFTFALL_BLOCKOUT.blend
KS3_MAP_RIFTFALL_GAMEPLAY.umap
```

## 2. Blender install / startup checklist

1. Install Blender LTS from the official site;
2. set Units → Metric, Unit Scale `1.0`: в Godot одна world unit = один метр; weapon / prop dimensions фиксируются в asset sheet;
3. set scene frame rate 60 fps; animation source can be 30 fps mocap, then resample;
4. enable built-in **Import-Export: glTF 2.0**, **FBX** and **Node: Node Wrangler**;
5. add optional internal add-ons only after license review: Rigify for rapid rig test, Blender Game Animation Tools only if maintained;
6. create startup file with collections: `REF`, `HI`, `LOW`, `COLLISION`, `RIG`, `EXPORT`, `LIGHTS`;
7. add custom properties: `ks3_asset_id`, `ks3_lod_group`, `ks3_collision`, `ks3_material_budget`;
8. configure export presets: UE FBX (`-Z Forward`, `Y Up`, Apply Transform, Selected Objects), GLB (Y Up, Apply Modifiers, tangents, materials, active actions);
9. run `asset_lint.py` before export: scale, unapplied transforms, non-manifold, material slots, UV channel, missing image.

Do not install random scripts from forums into production Blender. Keep add-on `.zip`, version, author and license in the asset ledger.

## 3. Weapon production — step by step

### 3.1 Reference and blockout

1. create reference board from original / licensed photographs and measured dimensions;
2. block primary silhouette using simple primitives;
3. validate first-person read at 90 FOV and 16:9;
4. mark moving parts: trigger, magazine, bolt, charging handle, safety, scope;
5. freeze silhouette before detail.

### 3.2 High poly

1. build clean hard-surface base with bevel discipline;
2. separate materials by physically meaningful surface, not every polygon;
3. use weighted normals / bevel where baking requires;
4. model mechanical seams, screw heads and stamps only when camera can resolve;
5. verify no accidental real brand or copied design mark.

### 3.3 Low poly and UV

1. duplicate high → retopologize / decimate with silhouette priority;
2. create separate first-person and world meshes if necessary;
3. set LOD0 / LOD1 / LOD2 budgets from `ART-BIBLE.md`;
4. unwrap with 2 px padding at target texture resolution;
5. create UV1 for lightmap only if world mesh needs it; weapon viewmodel typically uses packed UV.

### 3.4 Baking / PBR

- bake high → low: normal, AO, curvature, thickness where useful;
- textures: Albedo / Normal / ORM, optional emissive and mask;
- tangent space должен совпадать с Godot StandardMaterial3D; используем MikkTSpace и тестируем известную sphere;
- roughness breaks up large flat surfaces; metallic only true metal;
- validate no baked light or shadow in albedo.

### 3.5 Viewmodel / animation

- origin and grip at documented socket;
- sockets: `Muzzle`, `Eject`, `Mag`, `Optic`, `Shell`, `FX_Inspect`;
- first-person animation clips: idle, walk, run, crouch, jump, fire, dry fire, reload tactical, reload empty, inspect, equip, melee;
- use additive recoil / sway layers so weapon tuning does not require reanimating all clips;
- export skeleton once, animations in separate FBX batches; preserve bone names.

## 4. Character production

1. block body proportions and faction read;
2. model neutral base, clothing panels as separate production modules;
3. retopologize to deformation-friendly edge loops around shoulder / elbow / knee;
4. create `KS3_Skeleton` with stable bone names and socket contract;
5. skin with max 4 influences per vertex for export safety;
6. test weight paint: crouch, sprint, reload, death, aim, grenade throw;
7. use AnimationTree / IK / IK for foot placement, weapon hand alignment and additive recoil;
8. export base skeleton + animations, затем настраиваем Skeleton3D / AnimationTree и retargeting-профили для training bots / faction skins.

### Animation list

`idle, walk, run, sprint, crouch, crouch-walk, jump-start, jump-loop, land, fire, recoil, reload-tactical, reload-empty, inspect, plant, defuse, throw, hit-react, death-front, death-back, melee, radio, revive-coop`.

Facial / emotion is not required for competitive MVP. Radio can use body gestures and subtitle, reducing scope.

## 5. Map production

### Phase A — blockout

- 1 m grid, simple cubes, placeholder cover;
- label callouts on physical signs and in minimap;
- measure spawn-to-contact, rotate time, plant visibility, utility lanes;
- bots / 10 human test; no art pass before two playable review sessions.

### Phase B — greybox

- replace primary surfaces with modular kit;
- add collision, navmesh, climb / vault decisions;
- test sightline color values in grayscale;
- lock breakable panels and Rift Zone states;
- place audio zones and occlusion volumes.

### Phase C — detail / lighting

- hero landmark first, then mid-distance blockers, then micro props;
- use modular trims, decals and vertex paint; no unique mesh for every wall;
- set skybox / overcast / storm variants as separate Godot scenes or Environment resources;
- bake or fallback lighting for competitive scalability;
- decals never obscure enemy read or callout signs.

### Phase D — optimization

- visibility ranges / occlusion review, MultiMesh для повторяющихся props;
- LOD screen sizes и shadow budgets для MeshInstance3D;
- texture streaming pool; no unexpected 8K on minor props;
- occlusion / scene-streaming cells;
- GPU/CPU capture on target low, mid, high machines;
- test network physics only on gameplay actors, not decorative debris.

## 6. Preview / turntable

For every weapon / skin:

1. set 3-point studio lights: teal key, amber rim, soft neutral fill;
2. camera 50 mm equivalent, neutral gray/graphite backdrop;
3. 8–12 second turntable, 24/30 fps, 1024 or 1920 preview;
4. export transparent PNG thumbnails for UI and MP4/WebM turntable for store;
5. display rarity label in UI, never bake label into asset image;
6. store source `.blend`, final `.fbx` / `.glb`, preview and manifest.

## 7. Godot import / QA

- import FBX / glTF with correct meter scale and Skeleton3D; never create duplicate skeleton for one animation family;
- verify normals, tangents, socket transforms and material slot order;
- create `StandardMaterial3D` / controlled `ShaderMaterial` from the KS3 master: base, normal, ORM, emissive, decal mask, wear amount;
- create MeshInstance3D LOD / visibility ranges and CollisionShape3D;
- compare Blender and Godot render under neutral HDRI;
- Godot scene validation and asset lint must pass before an asset moves from `WIP` to `APPROVED`.

## 8. Asset status

```text
WIP → REVIEW_ART → REVIEW_TECH → APPROVED → INTEGRATED → LOCKED
```

A change to a LOCKED weapon silhouette, collision or map callout requires design review and recorded version bump.

## 9. Content backlog

### MVP P0

- FEN-9, M-7, Kestrel, Sable, Vanta Edge;
- one Helix character base + training bot;
- `Sandstone` blockout + final collision / nav; production naming for the next networked pass remains `de_riftfall` until the map ID is locked;
- Key and all five launch grenade meshes;
- one neutral studio turntable scene.

### Alpha P1

- `cs_vanta_line` greybox;
- `ar_saltworks` blockout;
- faction modular gear, gloves, stickers;
- weather VFX and breakable panel variants;
- first pass on animation library.

### Beta P2

- final map art for all three;
- LOD / optimization pass and console scalability;
- case presentation library, seasonal UI frames;
- final hero renders and marketing exports.
