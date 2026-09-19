# KS3 — Art Bible и 2D / UI spec

## 1. Художественное решение

### Style lock

**Реалистичная база + редакционная стилизация.** Геометрия, материалы, оружие и свет физически убедительны; цвет, графические метки и UI намеренно собраны как tactical editorial system. Это не милитари-фотореализм и не cartoon: материал говорит «дорогая индустриальная вещь», цветовой сигнал говорит «соревновательная система».

### Palette

| Token | Hex | Роль |
|---|---|---|
| Void | `#090E14` | фон / negative space |
| Graphite | `#101820` | panel / HUD |
| Slate | `#16232D` | elevated panel / concrete |
| Signal teal | `#73DDD7` | interact / safe / player intent |
| Deep teal | `#2FA6A5` | inactive signal / fog |
| Warning amber | `#F1B66E` | time / rare / alert |
| Archive purple | `#AA8EEA` | mythic / coaching / future |
| Field green | `#72C58D` | success / training |
| Signal red | `#EF7773` | enemy / error / cancel |

Teal — не декоративный neon. Он всегда означает действие, подтверждение или сетевой сигнал. Amber — ограничение времени, риск, редкая награда. Purple — слой анализа / mythic. Red — ошибка / hostile.

### Lighting

- blue hour, overcast and low sun; hard amber practicals против холодного sky fill;
- volumetric fog только слоями вокруг landmarks, не поверх entire play space;
- wet concrete и black metal ловят broad highlights, но не зеркалят gameplay silhouette;
- emissive sources limited: screens, emergency strips, weapon status, signal beacons;
- no chromatic aberration, heavy vignette или distracting motion blur в competitive camera.

### Materials

`concrete / salt / painted steel / oxidized metal / rubber / wet glass / woven nylon / polymer / ceramic`. Edge wear — hand-authored where it tells construction story, not random grunge everywhere. Roughness variation важнее extreme albedo color. Skins add controlled coating / decal / emissive layers while preserving silhouette and faction read.

### References in words

- Арт-дирекцию строим вокруг industrial photography: port infrastructure, metro service corridors, desalination plants, tactical equipment close-ups;
- hero assets читаются как ArtStation hard-surface portfolio: один объект, чистая форма, PBR material story, controlled hero light;
- UI берёт от Behance tactical HUD case studies: modular grid, thin rules, mono labels, information density with breathing room;
- lighting inspiration — moody blue-hour architectural photography, amber service lamps, wet asphalt, top-down cartographic overlays;
- map key art не должен копировать реальные карты / фракции конкурентов, only use general genre vocabulary.

Ссылки и конкретные boards собраны в [`REFERENCES.md`](./REFERENCES.md).

---

## 2. UI / UX visual system

### Typography

- **Display / utility:** monospaced face (in prototype: DM Mono) — systems, numbers, map ids;
- **Body:** neutral humanist sans (in prototype: Manrope) — descriptions, accessible reading;
- all caps only for labels / statuses; title case for actions; numbers use tabular-ish mono;
- base type 13 px, smallest label 7–8 px only when paired with larger context;
- no information encoded by hue alone: label, icon or position repeats state.

### Grid and components

- 8 px base rhythm;
- desktop content max width 1430 px;
- panel border alpha 12–18%; elevated border 22–40%;
- 1 px hairline plus 2 px active underline;
- 38 px primary action; 32 px top action; 42 px nav row;
- rounded corners only for avatars / orbital signals — product surfaces are squared to feel engineered;
- hover: border + slight lift; no scale bigger than 1.02;
- reduced motion flag disables radar rotation, sheen and prize float.

### Icon language

Thin 1.7 px line icons, squared terminals, simple geometry: grid, crosshair, briefcase, cube, chart, target, file, settings, bell, globe, team, wallet. Icons must survive 16 px. Weapon silhouettes and rank emblems are separate illustrative layer.

---

## 3. 2D asset list

| ID | Asset | Size / format | Art note | State |
|---|---|---|---|---|
| UI-001 | KS3 command mark | SVG, 64 | K/S/3 modular signal mark | implemented as CSS/SVG-like mark |
| UI-002 | nav icon family | SVG, 24 | 16 px optical alignment | implemented inline |
| UI-003 | rank emblems | SVG + PNG fallback, 512 | Vector → APEX; angular silhouette | prototype CSS emblem |
| UI-004 | case cards | PNG/WEBP, 1200×700 | ring / metallic foil / item silhouette | prototype cards |
| UI-005 | item thumbnails | PNG/WEBP, 1024×576 | transparent weapon render, rarity edge | 2 generated renders |
| UI-006 | profile frames | SVG/PNG, 256 | seasonal frame, no readability loss | concept |
| UI-007 | team patch set | SVG, 512 | Helix, Relay, Rook factions | concept |
| UI-008 | loading screen | PNG, 2560×1440 | map landmark + route plan | hero image is seed |
| UI-009 | stickers / graffiti | SVG/PNG, 512 | signal glyphs, hand marks, no real brands | concept |
| UI-010 | marketing key art | PNG, 3840×2160 | Rift / Fall wide shot | hero source in prototype |
| UI-011 | case rarity effects | sprite sheet / GPUParticles2D | common noise, immortal amber burst | case modal Godot prototype |
| UI-012 | avatar portraits | PNG, 512 | four faction-neutral operator silhouettes | prototype avatar CSS |

### Case card art direction

- Common: matte field label, one thin line, no fake rarity glow;
- Uncommon: controlled edge tint + micro wear;
- Rare: stronger contrast and hard line;
- Mythic: purple bloom, geometric reflection;
- Legendary: amber foil / radial highlight;
- Immortal: amber-white signal burst, one iconic silhouette, reduced frequency in UI.

---

## 4. Generative art prompts

Prompts are starting points, not final production assets. Remove logos, text, real weapon trademarks, identifiable people and competitor references. Any generated image must be reviewed for IP, anatomy, material continuity and gameplay readability before inclusion.

### Rift / Fall hero

> Wide 16:9 cinematic key art for an original competitive tactical shooter, rain-soaked Mediterranean port district at blue hour, high oblique tactical overview, concrete rooftops, shipping containers, narrow alleys, monumental satellite dish, amber window lights, subtle cyan emergency lights, wet reflective surfaces, restrained slate blue graphite muted teal amber palette, moody volumetric light, negative space on left for UI, realistic hard-surface AAA environment, no people, no logos, no text, no watermark.

### FEN-9 Cobalt Circuit

> Premium studio render of an original bullpup assault rifle for a competitive tactical shooter, matte graphite body, deep cobalt anodized panels, tiny amber status light, believable engineering, subtle edge wear, hero angle, near-black slate background, cyan rim light, clean PBR product presentation, no brand, no text, no hands, no blood.

### Vanta Edge / Null

> Premium studio render of an original compact ceramic tactical knife, dark blade, subtle cyan signal line, graphite grip, believable hard-surface engineering, near-black studio background, amber rim light, no logo, no text, no hands, no blood.

### Negative prompt / review list

`no game logo, no existing IP, no military insignia, no random text, no watermark, no extra fingers, no floating parts, no impossible barrel, no glossy plastic everywhere, no oversaturated neon, no uncontrolled fog, no weapon skin changing silhouette`.

---

## 5. 3D asset list

### Weapons

1. FEN-9 bullpup rifle — hero + first-person viewmodel + world drop;
2. M-7 sidearm — fast slide animation, modular suppressor;
3. Kestrel SMG — compact silhouette, high cyclic rate;
4. Morrow AR — long barrel, high recoil pattern;
5. Sable bolt sniper — bolt cycle + scope overlay;
6. Hush pump shotgun — shell-by-shell reload;
7. Vanta Edge — first-person inspect and takedown;
8. Flash / smoke / HE / molotov / decoy / breach charge / signal dart;
9. Key device — plant / carry / drop / defuse states.

### Characters

- `Helix Response` defender: navy shell, modular ceramic plates, cyan signal tag;
- `Rift Cell` attacker: graphite utility jacket, amber tape, asymmetric gear;
- `Relay Unit` specialist: low-profile comms pack;
- `Anchor Unit`: heavier harness but same body proportions;
- neutral training bot with color-safe material blocks.

### Environment kits

- concrete port walls, painted steel, salt tanks, corroded pipes, service doors;
- cargo containers, pump controls, crates, safety rails, cables, signs;
- breakable panels in 3 states and debris cards;
- metro benches, turnstiles, platform edges, emergency signs;
- hero landmarks: satellite dish, pump station, Helix gate, desalination tower.

### LOD / collision

| Asset | LOD0 | LOD1 | LOD2 | Collision |
|---|---:|---:|---:|---|
| hero weapon | 60–90k tris | 25–40k | 8–15k | simplified UCX, magazine separate |
| world weapon | 18–30k | 8–15k | 2–5k | 2–4 convex |
| character | 80–100k | 40–55k | 18–25k | capsule + ragdoll proxy |
| prop medium | 10–25k | 4–10k | 1–3k | box / convex |
| panel | 4–8k | 2–4k | 1k | fixed gameplay collision state |

---

## 6. 2D art review checklist

- clear at 25% size and grayscale;
- no text baked into item thumbnail except intentional brand-free item name overlay;
- rarity readable by label + color + shape;
- safe margins for 16:9 / 21:9 / 16:10;
- localized strings can expand 35%;
- image license / generation source recorded in asset ledger;
- no real-world insignia or unlicensed typography.

## 7. Current prototype assets

- `public/assets/ks3-riftfall-hero.jpg` — generated wide hero background;
- `public/assets/fen-9-cobalt.jpg` — generated rifle preview;
- `public/assets/vanta-edge.jpg` — generated melee preview.

They are presentation seeds, not final game-ready PBR maps. They must be replaced by modeled / UV’d / textured source assets in the Blender/UE pipeline.
