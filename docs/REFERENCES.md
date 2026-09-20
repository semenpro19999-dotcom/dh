# KS3 — References / knowledge base

Дата сверки ссылок: 20 сентября 2026. Ссылки — источники для исследования, а не assets, которые можно автоматически положить в игру. Перед production-интеграцией сверять актуальную лицензию, региональные условия и attribution.

## 1. Godot 4.5+ и networking

- [Godot 4.5 stable download](https://godotengine.org/download/archive/4.5-stable/) — pinned baseline for the first native project pass.
- [Godot 4.5 renderers](https://docs.godotengine.org/en/4.5/tutorials/rendering/renderers.html) — Forward+, Mobile and Compatibility trade-offs; used for the KS3 renderer profile.
- [Godot 4.5 high-level multiplayer](https://docs.godotengine.org/en/4.5/tutorials/networking/high_level_multiplayer.html) — `MultiplayerAPI`, ENet, RPC modes, authority and dedicated-server considerations.
- [Godot 4.5 dedicated server export](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_dedicated_servers.html) — headless export flow for the authoritative Linux server.
- [ENetMultiplayerPeer class reference](https://docs.godotengine.org/en/4.5/classes/class_enetmultiplayerpeer.html) — native UDP transport API for client / server sessions.
- [MultiplayerSpawner class reference](https://docs.godotengine.org/en/4.5/classes/class_multiplayerspawner.html) — controlled replication of player / projectile scenes.
- [MultiplayerSynchronizer class reference](https://docs.godotengine.org/en/4.5/classes/class_multiplayersynchronizer.html) — declared state replication; high-frequency movement remains explicitly profiled.
- [Godot GitHub repository](https://github.com/godotengine/godot) — source, issue tracker and release context.

### 1.1 Godot 3D gameplay references

- [Godot 4.5 — Moving the player with code](https://docs.godotengine.org/en/4.5/getting_started/first_3d_game/03.player_movement_code.html) — `CharacterBody3D`, gravity, velocity and `move_and_slide()` pattern.
- [CharacterBody3D](https://docs.godotengine.org/en/4.5/classes/class_characterbody3d.html) — controlled 3D actor with collision-aware movement.
- [Camera3D](https://docs.godotengine.org/en/4.5/classes/class_camera3d.html) — perspective camera, FOV and first-person view contract.
- [RayCast3D](https://docs.godotengine.org/en/4.5/classes/class_raycast3d.html) — immediate hit detection for weapon aiming and interaction.
- [Environment](https://docs.godotengine.org/en/4.5/classes/class_environment.html) — background color, ambient light and scene readability.
- [Godot 4.5 — Multiple resolutions](https://docs.godotengine.org/en/4.5/tutorials/rendering/multiple_resolutions.html) — `canvas_items`, `expand` aspect and responsive window behavior.

**What KS3 takes from this:** the first playable match uses the native Godot 3D contract: a `CharacterBody3D`-style player controller, `Camera3D` first-person view, `RayCast3D` weapon hit test, static collision geometry and a separate CanvasLayer HUD. The current match is a local vertical slice; authoritative multiplayer remains the next layer.

**What KS3 takes from this:** server owns round state, hit validation, Key, weather and panel state; client owns presentation and bounded prediction. Matchmaking, identity, inventory and fraud protection live in the backend rather than pretending to be engine features.

## 2. Blender / interchange / animation

- [Blender official download](https://www.blender.org/download/) — install the LTS build approved by the team.
- [Blender glTF 2.0 manual](https://docs.blender.org/manual/en/latest/addons/import_export/scene_gltf2.html) — materials, UVs, tangents, armature and animation export.
- [Blender FBX manual](https://docs.blender.org/manual/en/latest/addons/import_export/scene_fbx.html) — skeletal interchange and axis review before Godot import.
- [Khronos glTF-Blender-IO](https://github.com/KhronosGroup/glTF-Blender-IO) — exporter source and versioned docs.
- [Mixamo](https://www.mixamo.com/) — rapid prototype character rig / motion reference; use only under current Adobe terms and do not ship unmodified standalone assets as a marketplace product.
- [Grant Abbitt YouTube](https://www.youtube.com/@grabbitt) — approachable Blender modeling and environment exercises; use for learning, not as a license for copying a tutorial result.
- [CG Cookie](https://cgcookie.com/) — Blender, hard-surface and production workflow education.

**What KS3 takes from this:** Blender 4.5 LTS+ as DCC, GLB for quick review and Godot import, FBX only where the skeletal interchange needs it, Python lint for repeatable exports.

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

## 5. Sandstone map research

Подробная подборка из 30 картографических, архитектурных и material references находится в [`docs/SANDSTONE_REFERENCES.md`](SANDSTONE_REFERENCES.md). Для текущего blockout из неё зафиксированы три маршрута — западный рынок, центральный двор и восточная цитадель — плюс арочные ворота, башни, навесы, ступени и две контрастные objective-зоны.

## 6. Main menu / UX references

- [Game UI Database](https://gameuidatabase.com/) — фильтрация по pre-game menu, loadout, 3D space, list, tabs, camera pan и parallax.
- [Game UI Database — Player Menus](https://www.gameuidatabase.com/index.php?scrn=61) — структура pre-game, loadout, level select, pause и post-game flows.
- [Polycount — Games with standout menus](https://polycount.com/discussion/132289/games-with-standout-menus) — camera-driven menus, Halo/Destiny/Dead Space references и роль background scene.
- [r/gamedev — What makes a good main menu?](https://www.reddit.com/r/gamedev/comments/139uexa/what_makes_a_good_main_menu/) — быстрый вход, tone of the game, readable vertical navigation и clean UI.
- [Video game UI: the design process explained](https://medium.com/@a_kill_/video-game-ui-the-design-process-explained-14c23fa70d37) — hierarchy, strong title, list navigation and restrained color palette.
- [Tactical Intervention UI/UX — Behance](https://www.behance.net/gallery/10528795/Tactical-Intervention-UIUX-Design) — tactical hierarchy and information density; visual study only.

**Что перенесено в KS3:** главное меню теперь ставит Sandstone hero-image в фон, выносит один primary CTA «Найти матч», использует вертикальную навигацию, отдельные pages для карты и арсенала, а состояние операции постоянно видно в sidebar.

## 7. Sound / music references

- Counter-Strike, Valorant and Rainbow Six Siege are genre references for information hierarchy, radio brevity and materialized gun audio. Do not extract or reuse their audio.
- [FMOD learning](https://www.fmod.com/learn) — adaptive music / audio middleware education.
- [Wwise learning portal](https://www.audiokinetic.com/en/education/) — interactive audio and profiling education.
- [Godot audio buses](https://docs.godotengine.org/en/4.5/tutorials/audio/audio_buses.html) — native routing for master / SFX / voice / music / weather buses.
- [Godot AudioStreamPlayer3D](https://docs.godotengine.org/en/4.5/classes/class_audiostreamplayer3d.html) — positional shots, footsteps and zone-aware audio.

## 8. Reference ledger template

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

## 9. Research conclusions

- visual refs confirm that hard-surface asset quality reads through silhouette, material contrast and controlled lighting rather than excessive detail;
- tactical UI references reward modular layout, short labels and persistent state;
- official Godot / Blender docs support the chosen GDScript + native scene + Blender workflow;
- open assets are suitable for prototype and lighting studies only after license verification;
- the design intentionally leaves room for original KS3 identity: teal signal, amber warning, stateful map geometry and readable system labels.
