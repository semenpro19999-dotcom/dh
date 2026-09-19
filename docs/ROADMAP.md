# KS3 — Roadmap, priorities, timeline and risks

## 0. First playable — что сделать в первую очередь

Цель первого прототипа — не кейсы и не три polished maps. Нужно доказать одну честную 5×5 петлю:

1. Godot 4.5+ GDScript project + headless dedicated server build;
2. greybox `de_riftfall` with one A site and one B site;
3. two teams of five bots / local clients;
4. FEN-9 + M-7 + smoke + flash + HE + Key;
5. round state, buy time, plant, defuse, economy, overtime;
6. server hit validation and 128/64 Hz profiling;
7. one breakable panel + one forecasted Weather Lite state;
8. end-of-match result and local profile stub;
9. 20-minute playtest with capture of `time_to_contact`, `utility_used`, `trade_rate`, `round_swing`;
10. only after this: add case animation, seasonal progression and extra maps.

**Reason:** if the round does not feel good with greyboxes and three weapons, additional features only hide the issue and multiply rework.

---

## 1. Milestones

### MVP / Pre-production — Weeks 1–12

**Outcome:** playable local / LAN vertical slice, one map, one full round loop.

- W1–2: project setup, conventions, repository / build, combat spec, data assets;
- W3–4: movement, camera, weapon trace, recoil, damage, basic bots;
- W5–6: round state, Key, plant / defuse, buy UI, economy tests;
- W7–8: dedicated server, replication, lag compensation, telemetry schema;
- W9: `de_riftfall` blockout, spawns, A/B sites, callouts, audio zones;
- W10: Weather Lite + one BreakablePanel behind feature flags;
- W11: first 10-player test, bugs, performance, replay event timeline;
- W12: MVP gate: 3 internal sessions, fun / fairness review.

### Alpha — Months 4–6

**Outcome:** closed test of the core loop with enough content to test retention and fairness.

- finish `de_riftfall` greybox / first art pass;
- add Breacher / Anchor / Relay kits;
- add `cs_vanta_line` greybox and `ar_saltworks` warmup;
- implement Echo opt-in and first AI Coach drills;
- matchmaking queue, party, region routing, rating service;
- inventory / profile / season track with non-monetized mock rewards;
- anti-cheat telemetry, reports, replay review tools;
- Windows client + Linux server build; performance matrix.

### Beta — Months 7–10

**Outcome:** region-limited open test with content, trust and economy in shadow mode.

- all 3 maps playable and performance reviewed;
- Weather Lite, Panels, Rift Zones balance locks;
- ranked seasons, placement, decay / party rules;
- cases with odds / pity in test economy, no real-money launch yet;
- marketplace in sandbox with escrow and fraud simulation;
- final 3D asset pipeline: LOD, collision, materials, animation cleanup;
- accessibility / localization / crash reporting;
- load tests and rollback drills.

### Release — Months 11–14

**Outcome:** stable PC launch, live-ops foundation, console feasibility decision.

- three launch maps with sign-off;
- ranked / casual / deathmatch / wingman / co-op;
- store / cases region compliance, age gate, spending controls;
- server fleet, support, appeals, anti-cheat escalation;
- season 01 live operations, content calendar;
- certification for supported PC storefronts;
- console prototype only after PC SLO and netcode stability.

---

## 2. Priority backlog

### P0 — must prove the game

- [ ] Godot 4.5+ base project, GDScript rules and deterministic headless server build;
- [ ] input, movement, viewmodel, hit registration, recoil;
- [ ] FEN-9 / M-7 / Smoke / Flash / HE;
- [ ] Key plant / defuse / round state / buy phase;
- [ ] economy rules and unit tests;
- [ ] `de_riftfall` blockout and readable callouts;
- [ ] dedicated server + 10-player LAN test;
- [ ] server authoritative BreakablePanel and Weather Lite;
- [ ] performance / replay / telemetry basics;
- [ ] toxic voice / report / disconnect policy prototype;
- [x] command-center UI vertical slice (this repository);
- [x] docs, art bible, 3D pipeline, source ledger (this repository).

### P1 — turns a prototype into a product

- [ ] Party / matchmaking / region routing;
- [ ] rating, placements, seasons, rematch / surrender;
- [ ] remaining launch weapons and maps;
- [ ] Specializations, Echo and AI Coach alpha;
- [ ] profile, achievements, inventory service;
- [ ] case service with idempotent ledger, odds disclosure and pity;
- [ ] original sound pass, radio, music and adaptive layers;
- [ ] anti-cheat provider integration after privacy review;
- [ ] Windows / Linux packaging, crash reporting, accessibility;
- [ ] art lock for three maps and weapon LODs.

### P2 — scale / polish / live ops

- [ ] console feasibility and controller aim settings;
- [ ] expanded marketplace, trade-up contracts, event cases;
- [ ] observer / tournament mode;
- [ ] advanced replay search and coaching dashboard;
- [ ] seasonal narrative / banners / team emblems;
- [ ] community map tools with validation sandbox;
- [ ] more weather variants and co-op scenarios;
- [ ] source-built marketing cinematics and physical merchandise.

---

## 3. Ranking and matchmaking algorithm

### Rating

- hidden MMR for queue quality: Bayesian estimate (`mu`, `sigma`) with party adjustment;
- public RP 0–3,000+ for player-facing rank; result delta depends on opponent strength, round differential, uncertainty and abandonment;
- individual impact is capped: kills / damage can affect confidence, but cannot outweigh team result;
- placement: 10 matches, high uncertainty, no public badge until completion;
- ranks: `VECTOR I–V`, `APEX I–III`, `NEXUS` leaderboard tier;
- decay only above APEX after 14 days; casual has hidden MMR separate from ranked;
- seasons 8–10 weeks, soft reset keeps MMR confidence but compresses public RP;
- party MMR uses highest player cap and expected win probability, no boosting loophole;
- abandon: immediate loss / queue lock escalating; server crash and confirmed disconnect use remake rules.

### Queue

1. filter by region / data-center latency;
2. expand MMR window every 12 s within max bound;
3. party composition and role diversity are soft preferences, not hard class requirements;
4. prevent repeat pairing three matches in a row where population allows;
5. accept match → allocate dedicated server → warm map → connect;
6. if one player fails connect in launch window, remake without rating loss;
7. after match, signed result only; reconcile backend ledger asynchronously with visible pending state.

### Matchmaking SLO

- median queue <45 s at healthy population;
- p95 queue <180 s for supported region / rank;
- no hidden server selection based on case / spend history;
- dashboard alerts on win-rate / queue imbalance by region and rank.

---

## 4. Team and production cadence

Even with one agent drafting the concept, production requires accountable roles:

- game director / lead designer: design lock and test readout;
- tech director: replication, server, performance, CI;
- gameplay engineer: weapon, movement, round, economy;
- network / backend engineer: services, ledger, anti-fraud;
- environment / weapon artist: Blender pipeline, materials, LOD;
- UI/UX designer: Command Center, HUD, accessibility;
- audio designer: weapons, zones, radio, music;
- QA / player researcher: test cases, telemetry, fairness;
- producer: scope, dependencies, release gates.

Cadence: weekly design review, twice-weekly playable build, fortnightly 10-player playtest, monthly scope gate.

---

## 5. Risks and mitigations

| Risk | Signal | Mitigation / exit |
|---|---|---|
| Scope explosion | new feature added before gunplay gate | P0 lock; feature flags; one map first |
| Netcode feels unfair | hit dispute / high rewind | server replay, bounded rewind, 128→64 fallback profiling |
| Weather is random-feeling | phase win delta >2% | forecast, fixed seed, reduce gameplay influence |
| Destruction creates impossible angles | panel deaths cluster | author-only panels, two-state review, tournament lock |
| Hero abilities dominate | utility pick rate >70% one kit | kits cost credits, cap duplicates, remove passive buffs |
| Low-end performance | frame time > target | scalability tiers, visibility ranges / occlusion, renderer profiles and GPU capture |
| Marketplace fraud | chargebacks / account takeover | escrow, 2FA, cooldown, immutable ledger, risk queue |
| Loot regulation | region blocks / age issues | odds disclosure, no pay-to-win, legal review before beta |
| Anti-cheat privacy | false positives / consent issues | server authority first, minimal telemetry, appeal workflow |
| Art pipeline drift | assets fail scale / naming | Blender presets, asset lint, review gates |
| AI Coach gives bad advice | dismiss rate / repeated errors | template-only MVP, metric citations, opt-out, human review |
| Toxicity / griefing | reports / AFK rate | report tools, remake, reputation signals, moderation queue |
| Server costs | tick loss / cost per match | 64 Hz staging, autoscale, instance packing, budget dashboard |
| Platform certification | input / privacy failure | PC first, console feasibility gate after beta |

---

## 6. Release gates

### MVP gate

Fun in greybox, full round from buy to result, no known exploit for Key / economy, 60 FPS mid spec, server result deterministic.

### Alpha gate

Three internal maps / modes, ranked shadow MMR, two weeks without critical inventory mismatch, known feature flags and telemetry dashboards.

### Beta gate

Queue / party / reconnect, report and support flows, odds legal review, marketplace sandbox fraud tests, crash-free and SLO targets trending green.

### Release gate

No P0 open bugs, dedicated fleet rehearsed, rollback tested, localization / accessibility pass, content / source license ledger complete, support team trained.
