# KS3 — Technical Specification

## 1. Decision summary

### Engine

**Unreal Engine 5.6+** как основной client / server runtime. На старте проекта фиксируется exact engine version в `Config/DefaultEngine.ini`; minor upgrade только отдельной migration веткой.

**Почему не Unity:** Unity быстро даёт FPS prototype, но для KS3 нужна одна производственная вертикаль для PC + consoles, streaming maps, server build, Niagara / MetaSounds / Control Rig и artist pipeline. Unreal даёт более прямой путь к нужной AAA-like визуальной подаче и dedicated server.

**Почему не Godot:** Godot 4 подходит для небольшого open-source проекта и 2D / stylized vertical slice. Для KS3 с console потенциалом, competitive FPS netcode, high fidelity hard-surface art и внешним anti-cheat ecosystem интеграция потребовала бы больше собственного foundation.

### Languages

- **C++:** server-authoritative gameplay, weapon / ballistics, replication, economy, telemetry contracts, automated tests;
- **Blueprints:** UI flow, prototyping, VFX hooks, map scripting, content authoring;
- **Python:** Blender batch export / asset QA / naming checks;
- **TypeScript or Go (backend):** service layer; frontend command center prototype currently uses React/JS only.

### Target budgets

| Target | Budget |
|---|---:|
| Ranked server simulation | 128 Hz target, 64 Hz fallback for staging |
| Client input | 128 samples/s, packet coalescing when idle |
| Match size | 10 players + 2 spectators / observer slots |
| Player network payload | aim / movement / action delta compressed; no cosmetic spam |
| Competitive client | 144 FPS target on mid-high PC, 60 FPS minimum supported |
| Frame time | 6.9 ms at 144 FPS target; gameplay thread budget separately tracked |
| Match server | authoritative; no listen server in ranked |

128 Hz is a target, not a promise that every tick is shipped to clients. Replication uses relevancy, prioritization and delta compression. A 64 Hz dedicated server is the supported low-cost fallback for internal playtest only.

---

## 2. Runtime architecture

```text
[Windows/Linux client]
  ├─ Input + local prediction
  ├─ Viewmodel / audio / UI
  ├─ read-only replicated GameState
  └─ encrypted session → [Match gateway]
                               └─ allocates → [Dedicated UE server]
                                              ├─ authoritative movement
                                              ├─ weapon trace / hit result
                                              ├─ round / economy / Key
                                              ├─ breakables / weather / Rift state
                                              └─ signed result → [Game backend]

[Backend]
  API gateway → auth / party / matchmaking / inventory / case / market
       ├─ Postgres (accounts, inventory ledger, matches)
       ├─ Redis (queues, session, rate limits)
       ├─ object storage (replays, thumbnails, build artifacts)
       └─ event stream (Kafka/Redpanda-compatible) → analytics
```

### Server authority

- Client sends intent: input frame, fire request, interact request;
- server validates timestamp / sequence / weapon state / ammo / cooldown / line of sight;
- server produces `HitConfirmed`, `RoundState`, `InventoryDelta`, `WeatherState`;
- client predicts local camera, muzzle flash, recoil feel and movement presentation, then reconciles;
- cosmetic presentation is never trusted for hit or economy decisions;
- case result is generated in backend, signed, then client receives animation payload.

Unreal `GameState` holds replicated match state; `PlayerState` holds team, score and public operator data; server-only subsystems hold inventory / anti-fraud data. See Epic's networking and replication documentation in [`REFERENCES.md`](./REFERENCES.md).

### Tick / lag compensation

- player input includes monotonically increasing `input_sequence` and client timestamp;
- server stores 200 ms rewind buffer for player capsules and relevant breakables;
- hitscan validation rewinds target to shot timestamp within bounded window;
- projectile / grenade uses server simulation, local prediction may show trajectory preview only;
- server rejects impossible commands: fire without ammo, movement delta above acceleration envelope, plant through panel, duplicate interaction.

---

## 3. Core data contracts

### Weapon data

```cpp
struct FKS3WeaponSpec {
    FName WeaponId;
    EWeaponClass Class;
    int32 Price;
    int32 MagazineSize;
    float FireRate;
    FCurveTableRowHandle DamageByDistance;
    FName RecoilPatternId;
    float MovementPenalty;
    int32 KillReward;
    FName AudioSetId;
    FName ViewmodelAnimSetId;
};
```

### Match result

```json
{
  "match_id": "m_2026_09_19_8F04",
  "ruleset": "ranked_5v5",
  "map_id": "de_riftfall",
  "weather_seed": 18402,
  "score": { "attackers": 13, "defenders": 9 },
  "players": [{ "account_id": "opaque", "kills": 27, "deaths": 14, "assists": 8, "rating_delta": 124 }],
  "server_build": "0.1.0+sha",
  "signature": "backend-issued-signature"
}
```

No email, real name or raw voice is in gameplay telemetry. Account IDs are opaque internal identifiers.

---

## 4. Backend services

### API surface v0.1

| Service | Endpoint | Purpose |
|---|---|---|
| Auth | `POST /v1/session` | login, device attestation, short-lived session |
| Party | `POST /v1/party`, `POST /v1/party/invite` | party lifecycle |
| Match | `POST /v1/match/search`, `DELETE /v1/match/search` | queue / cancel |
| Match | `GET /v1/match/{id}/result` | signed result |
| Inventory | `GET /v1/inventory`, `POST /v1/inventory/equip` | cosmetic state |
| Case | `POST /v1/cases/{case_id}/open` | idempotent server RNG |
| Market | `POST /v1/listings`, `POST /v1/listings/{id}/buy` | escrow transaction |
| Profile | `GET /v1/profile/{account_id}` | public stats / achievements |
| Coach | `GET /v1/coach/drills`, `POST /v1/coach/drills/{id}/complete` | opt-in training |

### Case RNG and idempotency

1. client requests `open` with `idempotency_key`;
2. API validates token ownership, region, age gate and rate limit;
3. case service locks token ledger row;
4. cryptographically secure RNG selects rarity / item server-side;
5. service writes immutable `case_open` ledger and `inventory_event` in one transaction;
6. response returns item, odds snapshot, pity counter, signed presentation payload;
7. retry with same key returns same result, never a second item.

### Marketplace anti-fraud

- PostgreSQL transaction + escrow wallet;
- item moves into `locked` state before listing;
- 2FA for first sale, high-value sale and withdrawal;
- new account / new device cooldown;
- signed listing ids, no client-provided price currency conversion;
- velocity limits, risk scoring, manual review queue;
- full audit log with immutable event IDs;
- user-friendly error codes and no silent rollback;
- no off-platform link in trade chat.

KS3 Credits are not advertised as an investment, cannot be used for round economy and have region-specific purchase / refund policy review before launch.

---

## 5. Anti-cheat and trust

### Layered model

1. **Server authority:** main protection; client cannot decide hit, ammo, money, drop;
2. **Client integrity:** signed build, tamper detection, module allowlist, secure boot signal where available;
3. **Heuristics:** impossible input / aim deltas, packet pattern, repeated visibility anomalies;
4. **Review:** report bundles, server replay timeline, human / automated triage;
5. **Enforcement:** shadow queue only after validation, temporary lock, appeal and audit.

Third-party anti-cheat choice (EOS / Easy Anti-Cheat or equivalent) must go through legal, platform and privacy review; it is not treated as a replacement for authoritative server rules. Never collect more data than needed for fair play.

### Replay integrity

- compact server event timeline for hit / death / plant / defuse / panel / weather;
- server build hash and match seed in result;
- signed match result required for rating / items;
- observer client gets policy-filtered feed, not player memory dump.

---

## 6. Rendering and content

- Nanite for high detail static hero environment where target platform allows;
- Lumen optional on High / Cinematic, baked or distance-field fallback for Low / competitive;
- Niagara for weather / break debris; hard cap per zone;
- virtual shadow maps only where measurable benefit;
- material instances for skins, no per-skin shader explosion;
- FOV 75–110, viewmodel separate from world camera;
- scalability tiers: Low / Medium / High / Ultra / Competitive.

### Asset naming

```text
KS3_WPN_FEN9_MESH_HI.fbx
KS3_WPN_FEN9_MESH_LO.fbx
KS3_WPN_FEN9_MAT_COBALT_MI.uasset
KS3_WPN_FEN9_T_COBALT_ALB_2K.png
KS3_WPN_FEN9_T_COBALT_NRM_2K.png
KS3_WPN_FEN9_T_COBALT_RMA_2K.png
KS3_MAP_RIFTFALL_BLOCKOUT.umap
KS3_MAP_RIFTFALL_GAMEPLAY.umap
```

---

## 7. CI/CD

### Pull request checks

- `npm ci && npm run build` for command-center prototype;
- Unreal C++ compile for Win64 and Linux server;
- unit tests: economy, recoil data, damage, case odds, pity, market ledger;
- functional test: plant / defuse / overtime / panel break / weather replication;
- map validation: navmesh, spawn distance, collision, audio zones, lightmap / Lumen budget;
- asset lint: naming, scale, material slots, triangle budget, texture size, missing references;
- static analysis: clang-tidy, Unreal Header Tool, secret scan, dependency audit.

### Build lanes

- **PR:** fast compile + unit tests + UI build;
- **Nightly:** dedicated server integration, 10 bots, packet loss / latency matrix, replay determinism;
- **Weekly:** Windows client, Linux server, map cooking, content validation;
- **Release candidate:** staged canary region, signed artifacts, rollback manifest.

GitHub Actions / self-hosted runners are acceptable. Artifacts go to object storage with SHA-256 manifest; never commit cooked builds or large source textures to Git.

---

## 8. Observability / SLO

- Match allocation p95 < 8 s after queue match;
- ranked server startup p95 < 25 s;
- result write success >99.95%;
- case open idempotency error rate <0.01%;
- crash-free client session >99.5% in beta;
- telemetry drop rate <1%;
- alert on rating / inventory ledger mismatch, suspicious drop distribution, server tick loss >2%.

Dashboard panels: queue time by region, abandon / remake, tick rate, p95 RTT, hit registration disputes, weather phase win delta, panel first-contact outcomes, case odds actual-vs-expected with confidence interval.

---

## 9. Local development order

1. Install UE5 and a supported IDE; create C++ blank project;
2. Add `KS3Core` module, data assets and test map;
3. Implement `RoundStateMachine` and local 5×5 bot match;
4. Add weapon trace / recoil and automated tests;
5. Add dedicated server build and one listen-to-dedicated migration;
6. Add Key plant / defuse and round economy;
7. Add one `BreakablePanel`, weather phase, replication tests;
8. Integrate backend stub with signed local match results;
9. Hook Command Center UI to mock API first, then real profile / inventory endpoints.
