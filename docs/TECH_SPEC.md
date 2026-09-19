# KS3 — Technical Specification (Godot 4.5+)

**Decision lock:** Godot Engine 4.5+ stable, GDScript-first, native desktop target.
**Current runtime:** `project.godot` → `scenes/main.tscn` + `scripts/main.gd` (командный центр) → `scenes/match.tscn` + `scripts/match.gd` (локальный 3D playable slice).
**Target:** Windows / Linux first, with console feasibility after the PC multiplayer gate.
**UI review target:** базовый viewport 1440×900 в изменяемом окне; stretch aspect `expand`, минимальный размер 800×500, страницы растягиваются по viewport и прокручиваются только при переполнении.

## 1. Почему Godot 4.5+

Godot 4.5+ выбран вместо Unreal Engine / Unity по четырём причинам:

1. **Быстрый ownership:** сцены, UI и gameplay logic находятся в открытом проекте без тяжёлой engine-specific build layer;
2. **Native cross-platform:** один GDScript codebase для Windows / Linux и понятный export pipeline;
3. **Built-in multiplayer API:** `SceneTree`, `MultiplayerAPI`, `ENetMultiplayerPeer`, `@rpc`, `MultiplayerSpawner` и `MultiplayerSynchronizer` дают базовый server-authoritative слой без обязательного стороннего netcode;
4. **Производственная прозрачность:** простые `.tscn`, `.gd`, `.tres` и import settings легче ревьюить, тестировать и подключать к CI.

Godot не предоставляет готовые matchmaking, account, marketplace, anti-cheat или relay services. Эти сервисы остаются отдельным backend-слоем. Для соревновательного FPS это осознанный trade-off: engine отвечает за client / simulation / replication, backend — за identity, queue, rating, inventory и trust.

### Renderer strategy

- **Forward+** для desktop High / Ultra: основной визуальный режим для hero maps, advanced lighting, volumetric fog и screen-space effects;
- **Mobile** для low / mid hardware и будущей консольной scalability-проверки;
- **Compatibility** для widest low-end fallback, tools, UI review и headless / CI smoke tests.

Godot 4.5 renderer documentation описывает Forward+ как desktop-oriented renderer с Vulkan / Direct3D 12 / Metal и Compatibility как OpenGL fallback. В `project.godot` прототип использует `gl_compatibility`, чтобы команда могла открыть UI на рабочей станции без Vulkan; production map profile переключается на Forward+ после GPU budget pass.

### Languages and modules

- **GDScript:** gameplay rules, UI, data adapters, tools, test harness;
- **C# optional:** backend SDK wrapper / data-heavy tooling only if profiling justifies it;
- **GDExtension C++ optional:** anti-cheat bridge, platform SDK or hot path only after a measured bottleneck;
- **Python:** Blender batch export and asset QA, outside the Godot runtime;
- **Shaders:** Godot Shader Language for controlled materials / UI post-process, no feature-critical information hidden in a shader.

## 2. Project structure

```text
project.godot                 # Godot 4.5+ project, 128 physics ticks, renderer profile
scenes/main.tscn              # root Control scene for command center
scenes/match.tscn             # root Node3D scene for local match
scripts/main.gd               # native UI vertical slice and screen state
scripts/match.gd              # 3D player, camera, arena, RayCast3D and HUD
scripts/network_manager.gd    # next P0: ENet host / client lifecycle
scripts/match_state.gd        # next P0: authoritative round model
scenes/ui/                    # reusable HUD / menu scenes after extraction
scenes/gameplay/              # player, Key, grenade, breakable actors
resources/                    # .tres weapon / economy / map data
content/models                # Blender source placeholder
content/textures              # PBR source placeholder
content/rigs                  # armature / IK placeholder
content/animations            # actions / NLA placeholder
content/maps                  # blockout / greybox placeholder
content/exports               # reviewed FBX / GLB / QA manifests
assets                 # JPG key art used by the native Godot UI slice
```

`main.gd` строит командный центр на native `Control` nodes. Кнопки запускают `match.tscn`, где `match.gd` создаёт локальную 3D-арену на `Node3D`, `CharacterBody3D`, `Camera3D`, `RayCast3D` и `StaticBody3D`. UI и игровой экран остаются редактируемыми в Godot.

## 3. Runtime architecture

```text
[Godot client]
  ├─ input / camera / viewmodel / UI
  ├─ local presentation prediction
  ├─ read-only replicated match state
  └─ ENet session → [Godot dedicated server]
                       ├─ authoritative movement request validation
                       ├─ hit / damage / ammo / Key / economy
                       ├─ breakable panels / weather / Rift state
                       └─ signed result → [KS3 backend]

[Backend]
  API gateway → auth / party / matchmaking / rating / inventory / cases / market
       ├─ PostgreSQL: account, match, immutable item ledger
       ├─ Redis: queue, party, session, rate limits
       ├─ object storage: replays, thumbnails, build artifacts
       └─ event stream: balancing / trust / operations analytics
```

### Godot multiplayer mapping

| KS3 responsibility | Godot 4.5+ implementation |
|---|---|
| transport | `ENetMultiplayerPeer` for native client / server |
| server instance | headless Godot export, `--headless`, no rendering / audio |
| RPC events | `@rpc("any_peer", "reliable")` for requests that must arrive |
| high-frequency state | `@rpc("authority", "unreliable_ordered")` or `MultiplayerSynchronizer` |
| dynamic players / projectiles | `MultiplayerSpawner` with approved spawnable scenes |
| player authority | `set_multiplayer_authority(peer_id)` only for local input request |
| match state | server-owned `MatchState` node; clients receive replicated snapshot |
| offline UI | `Main.tscn` and `main.gd` run without a network peer |

Godot's high-level API is not itself a competitive trust boundary. Client RPCs are requests; the dedicated server must validate every gameplay-critical argument and apply the result only on authority.

## 4. Network / tick design

- project physics tick: **128 Hz** in `project.godot`; staging can run a profiled 64 Hz server;
- client sends input frames with sequence number, client timestamp and action bitset;
- server validates acceleration, fire interval, ammo, weapon state, interaction range and line of sight;
- client predicts camera, muzzle flash, local recoil feel and input movement; server remains source of truth;
- position / aim updates use unreliable ordered channel; plant, defuse, hit confirm, damage and round events use reliable channel;
- snapshot interpolation buffer: 50–100 ms depending on measured RTT;
- bounded lag compensation window: 200 ms, server-side history of player capsules and relevant breakable states;
- no gameplay state is derived from cosmetic skin or local animation;
- Godot `Time.get_ticks_usec()` / server tick index is used for monotonic simulation time, never wall-clock time from the client.

### Dedicated server flow

```gdscript
var peer := ENetMultiplayerPeer.new()
var error := peer.create_server(7777, 10)
if error == OK:
    multiplayer.multiplayer_peer = peer
```

A production `NetworkManager` must:

1. bind a fixed internal UDP port;
2. expose `--server`, `--port`, `--match-id`, `--region` command-line options;
3. not spawn a local player in dedicated mode;
4. log build hash, map id, seed and tick loss;
5. close the peer and flush signed result on match end.

## 5. Core GDScript data model

```gdscript
class_name KS3WeaponSpec
extends Resource

@export var weapon_id: StringName
@export var price: int = 800
@export var magazine_size: int = 30
@export var fire_rate: float = 10.0
@export var recoil_pattern_id: StringName
@export var damage_by_distance: Curve
@export var kill_reward: int = 300
@export var audio_set_id: StringName
```

Gameplay data is stored in `.tres` resources, not hard-coded in UI. The prototype uses mock arrays in `main.gd` only to keep the command center immediately runnable; those arrays move to Resources during the first gameplay pass.

### Match result contract

```json
{
  "match_id": "m_2026_09_19_8F04",
  "ruleset": "ranked_5v5",
  "map_id": "de_riftfall",
  "weather_seed": 18402,
  "score": { "attackers": 13, "defenders": 9 },
  "players": [{ "account_id": "opaque", "kills": 27, "deaths": 14, "assists": 8, "rating_delta": 124 }],
  "server_build": "godot-4.5+ks3-sha",
  "signature": "backend-issued-signature"
}
```

## 6. Backend services

| Service | Endpoint | Purpose |
|---|---|---|
| Auth | `POST /v1/session` | login, device session, short token |
| Party | `POST /v1/party` | party lifecycle and invites |
| Match | `POST /v1/match/search` | queue / cancel / region |
| Match | `GET /v1/match/{id}/result` | signed result |
| Inventory | `GET /v1/inventory` | cosmetic state |
| Cases | `POST /v1/cases/{id}/open` | idempotent server RNG |
| Market | `POST /v1/listings/{id}/buy` | escrow transaction |
| Coach | `GET /v1/coach/drills` | opt-in training recommendation |

Case opening uses an idempotency key, an atomic token ledger row, cryptographically secure server-side RNG, an immutable `case_open` event and a signed presentation payload. The roulette animation is never the RNG source.

## 7. Anti-cheat / trust

1. authoritative Godot server is the first protection layer;
2. client build is signed and platform-integrity signals are collected only after privacy review;
3. heuristics watch impossible input, fire cadence, visibility anomalies and packet patterns;
4. server event replay supports report review;
5. enforcement has temporary lock, human review and appeal states.

A third-party anti-cheat / platform SDK is an optional integration behind a GDExtension boundary. It does not replace server validation and is not a P0 dependency for the local prototype.

## 8. Rendering / content in Godot

- `WorldEnvironment` and `Environment` resource for fog, tone mapping and exposure;
- `GPUParticles3D` for rain / debris; gameplay information is not hidden in particles;
- `Decal` and `StandardMaterial3D` for readable materials and controlled wear;
- `MultiMeshInstance3D` for repeated port props;
- `OccluderInstance3D`, visibility ranges and scene streaming after blockout;
- `AnimationPlayer` / `AnimationTree` for viewmodel and characters;
- `AudioStreamPlayer3D` plus audio buses for directional steps, gunshots and weather layers;
- `.glb` for review / lightweight interchange, `.fbx` where skeletal animation workflow requires it; import scale and skeleton names are locked in `docs/3D_PIPELINE.md`.

## 9. CI/CD

### Pull request

- `godot --headless --path . --editor --quit --check-only`;
- headless project boot smoke test;
- GDScript lint / parse check;
- unit tests for economy, recoil, damage, odds and pity;
- scene validation: missing resources, node paths, collision layers;
- Blender export / asset lint;
- headless Godot project check remains mandatory for every pull request.

### Nightly

- Windows client and Linux headless export using the exact 4.5+ export templates;
- 10-bot / 10-client integration session;
- latency and packet-loss matrix;
- replay determinism test;
- map performance capture across Forward+, Mobile and Compatibility profiles.

### Release

- pin Godot version and export templates;
- store build artifact SHA-256 manifest;
- staged region canary;
- server rollback image and result-ledger reconciliation drill;
- never commit exported binaries or cooked artifacts to the regular Git diff.

## 10. Local development order

1. Install Godot 4.5 stable or a newer compatible stable release;
2. open the repository root — `project.godot` is the project file;
3. run `scenes/main.tscn` to verify native command center screens;
4. extract reusable UI scenes from `main.gd` after the UX lock;
5. add `scripts/network_manager.gd` and local ENet host / client test;
6. implement `match_state.gd`, round state and 128 Hz server tick;
7. add one player scene, FEN-9 and server-side hit validation;
8. add Key plant / defuse, economy and result contract;
9. add one `BreakablePanel`, Weather Lite and deterministic replay events;
10. connect the command center to mock API, then to real profile / inventory services.
