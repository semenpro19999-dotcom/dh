# KS3 — References / knowledge base

Дата сверки ссылок: 19 сентября 2026. Ссылки — источники для исследования, а не assets, которые можно автоматически положить в игру. Перед production-интеграцией сверять актуальную лицензию, региональные условия и attribution.

## 1. Движок и networking

- [Unreal Engine — Networking and Multiplayer](https://dev.epicgames.com/documentation/en-us/unreal-engine/networking-and-multiplayer) — replication, authority, dedicated server concepts.
- [Unreal Engine — Networked Physics Overview](https://dev.epicgames.com/documentation/en-us/unreal-engine/networked-physics-overview) — server-authoritative physics and replication modes; useful for deciding that decorative debris should not be simulated as gameplay state.
- [Lyra Sample Game](https://dev.epicgames.com/documentation/en-us/unreal-engine/lyra-sample-game-in-unreal-engine) — Epic's sample for modular multiplayer architecture, gameplay experiences and UI patterns.
- [Unreal Engine dedicated server documentation](https://dev.epicgames.com/documentation/en-us/unreal-engine/setting-up-dedicated-servers-in-unreal-engine) — build / deploy reference; verify exact steps for the pinned engine version.
- [Epic Online Services](https://dev.epicgames.com/docs/epic-online-services) — identity / sessions / services to evaluate; not a replacement for authoritative gameplay or anti-fraud.

**What KS3 takes from this:** server owns round state, hit validation, Key, weather, panel state and case result; client owns presentation and prediction only.

## 2. Blender / interchange / animation

- [Blender official download](https://www.blender.org/download/) — install the LTS build approved by the team.
- [Blender glTF 2.0 manual](https://docs.blender.org/manual/en/latest/addons/import_export/scene_gltf2.html) — materials, UVs, tangents, armature and animation export.
- [Blender FBX manual](https://docs.blender.org/manual/en/latest/addons/import_export/scene_fbx.html) — Unreal interchange settings and axis review.
- [Khronos glTF-Blender-IO](https://github.com/KhronosGroup/glTF-Blender-IO) — exporter source and versioned docs.
- [Mixamo](https://www.mixamo.com/) — rapid prototype character rig / motion reference; use only under current Adobe terms and do not ship unmodified standalone assets as a marketplace product.
- [Grant Abbitt YouTube](https://www.youtube.com/@grabbitt) — approachable Blender modeling and environment exercises; use for learning, not as a license for copying a tutorial result.
- [CG Cookie](https://cgcookie.com/) — Blender, hard-surface and production workflow education.

**What KS3 takes from this:** Blender 4.5 LTS+ as DCC, FBX for UE skeletal pipeline, GLB for quick review, Python lint for repeatable exports.

## 3. Materials / HDRI / open assets

- [Poly Haven](https://polyhaven.com/) — HDRIs, materials and models for reference / prototype; [Poly Haven license](https://polyhaven.com/license) states their assets are CC0. Keep a local asset ledger anyway.
- [ambientCG](https://ambientcg.com/) — PBR material reference and alternative source; check asset-specific license / attribution.
- [OpenGameArt FAQ](https://opengameart.org/content/faq) — community asset license guidance; every downloaded asset needs a source record.
- [Freesound licensing FAQ](https://freesound.org/help/faq/#licenses) — sound assets are not all the same license; filter for compatible CC0 / attribution terms and store author + URL.
- [BBC Sound Effects](https://sound-effects.bbcrewind.co.uk/) — useful reference / archive; verify terms before commercial shipping.

**What KS3 takes from this:** use CC0 PBR / HDRI only as temporary blockout or with source metadata; final weapon / map sounds should be original recordings or commissioned packs.

## 4. Visual direction / portfolio references

These pages are mood / craft references, not direct copying targets.

- [ArtStation — SPX-80 Tactical Sniper Rifle](https://www.artstation.com/artwork/eR8AgP) — hard-surface hero asset, PBR wear, controlled industrial lighting; use to study presentation grammar.
- [Behance — Tactical Intervention UI/UX](https://www.behance.net/gallery/10528795/Tactical-Intervention-UIUX-Design) — tactical shooter HUD / menu case study; useful for screen hierarchy, match lobby and HUD reasoning.
- [Behance — FPS game UI search](https://www.behance.net/search/projects/fps%20game%20ui) — broad UI exploration for layout / interaction reference; filter for original work and do not reuse assets.
- [ArtStation — environment search](https://www.artstation.com/search?q=tactical%20environment&sort_by=relevance) — industrial environment composition, lighting and material studies.
- [Pinterest — tactical game UI search](https://www.pinterest.com/search/pins/?q=tactical%20game%20ui) — moodboard for hierarchy / color, not a license source.
- [Pinterest — hard surface weapon design](https://www.pinterest.com/search/pins/?q=hard%20surface%20weapon%20design) — silhouette / mechanical reference; validate real-world IP separately.

## 5. Sound / music references

- Counter-Strike, Valorant and Rainbow Six Siege are genre references for information hierarchy, radio brevity and materialized gun audio. Do not extract or reuse their audio.
- [FMOD learning](https://www.fmod.com/learn) — adaptive music / audio middleware education.
- [Wwise learning portal](https://www.audiokinetic.com/en/education/) — interactive audio and profiling education.
- [Unreal MetaSounds documentation](https://dev.epicgames.com/documentation/en-us/unreal-engine/metasounds-in-unreal-engine) — candidate native audio graph system.

## 6. Reference ledger template

Every external asset / tutorial / image used in production is entered like this:

```text
asset_id: KS3_REF_0001
source_url: https://...
source_type: HDRI | texture | sound | tutorial | mood
creator: ...
license: CC0 | CC-BY | commercial | internal | reference-only
attribution_text: ...
local_file: content/... or external storage path
approved_by: art lead / legal
notes: what was learned / changed / not copied
```

## 7. Research conclusions

- visual refs confirm that hard-surface asset quality reads through silhouette, material contrast and controlled lighting rather than excessive detail;
- tactical UI references reward modular layout, short labels and persistent state;
- official UE / Blender docs support the chosen C++ + Blueprint + Blender workflow;
- open assets are suitable for prototype and lighting studies only after license verification;
- the design intentionally leaves room for original KS3 identity: teal signal, amber warning, stateful map geometry and readable system labels.
