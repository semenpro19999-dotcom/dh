# KS3 // Командный центр Godot

KS3 — производственный концепт и интерактивный UI-вертикальный срез соревновательного tactical shooter 5×5. Основной runtime проекта — **Godot 4.5+**: GDScript, native `.tscn` scenes, ENet и headless-server план.

> **Статус:** native Godot vertical slice с полностью переработанным меню, запускаемой 3D-картой SALTWORKS, рабочими camera look/firing, 3D-моделями игроков и оружия, бегом, прыжком, вооружёнными убиваемыми ботами, базовым bomb plant/defuse loop и локальным case prototype. Сетевая синхронизация, dedicated server и backend находятся в roadmap как следующие игровые вехи.

## Что реализовано

- `project.godot` с Godot 4.5+ configuration, базовым viewport **1440×900**, изменяемым окном от 800×500, 128 physics ticks и Compatibility renderer для лёгкого запуска;
- `scenes/main.tscn` — стартовая сцена командного центра;
- `scenes/match.tscn` — запускаемая локальная игровая сцена;
- `scripts/main.gd` — нативный интерфейс Control без web-слоя;
- `scripts/match.gd` — 3D SALTWORKS arena, mouse look, raycast-стрельба, бег, прыжок, bomb plant/defuse, убиваемые вооружённые боты с FSM combat AI и HUD;
- `scripts/arsenal.gd` — общий data-driven каталог из 30 видов оружия: 20 firearm slots + 10 ножей; AWM SANDWRAITH сохранён как sniper slot;
- `scripts/case_system.gd` — локальные Standard cases с odds, pity после 10 низких открытий, duplicate flags и persistent inventory history;
- `assets/models/kenney/` — импортированные CC0 GLB-модели игроков, огнестрельного оружия и ножей;
- `assets/audio/` — интернет-ассеты с CC0-лицензией для выстрелов, попаданий, движения, бомбы и ambient; provenance в `docs/ASSET_LICENSES.md`;
- полностью переработанное главное меню: SALTWORKS briefing-screen, вертикальная навигация, briefing карты, запуск матча, арсенал и кейсы;
- полностью переработанная процедурная карта SALTWORKS: Loading Yard, Brine Core, Refinery Control, silos, tanks, catwalk, warehouse и две objective-зоны; схема зафиксирована в `docs/MAP_SALTWORKS.md`;
- Q/E переключают весь каталог оружия; 1 — скорострелка RIFT-9, 2 — AWM SANDWRAITH, 3 — нож, 4–0 — быстрые слоты;
- мышь управляет камерой и стрельбой; ПКМ включает ADS/прицел (для AWM — scope), Shift — бег, Space — прыжок, удержание F на objective site — плант бомбы, удержание F возле бомбы — обезвреживание;
- русскоязычный adaptive HUD с таймером, HP, живыми ботами, оружием, слотом, патронами, бомбой и целями;
- оригинальные демонстрационные материалы в `assets/`, включая Sandstone menu key art.

## Запуск Godot 4.5+

1. Установить стабильную версию [Godot 4.5](https://godotengine.org/download/archive/4.5-stable/) или более новую совместимую stable-версию.
2. Открыть **корень репозитория** как Godot project — файл `project.godot` уже создан.
3. Запустить `scenes/main.tscn` или нажать **F6 / F5**.

Из командной строки:

```bash
godot --editor --path .
godot --path . --editor --quit --check-only
```

В sandbox Godot binary не установлен, поэтому runtime smoke-test нужно выполнить на workstation с Godot 4.5+. GDScript, сцена и project configuration подготовлены под эту версию.

## Структура

```text
project.godot             # Godot 4.5+ project settings
scenes/main.tscn          # стартовая сцена командного центра
scenes/match.tscn         # локальная игровая сцена
scripts/main.gd           # интерфейс командного центра
scripts/match.gd          # SALTWORKS arena, camera, weapons and HUD
scripts/arsenal.gd         # shared catalogue: 30 weapons / 10 knives
scripts/case_system.gd     # local case odds, pity and inventory history
scripts/network_manager.gd# ENet host / client lifecycle
scripts/match_state.gd    # server-authoritative round model

assets/                   # hero и weapon preview assets для Godot
content/models            # Blender high/low mesh sources
content/textures          # PBR maps, masks, decals
content/rigs              # armature / IK sources
content/animations        # actions / NLA clips
content/maps              # blockouts / greyboxes
content/exports           # reviewed FBX / GLB / QA manifests

docs/GDD.md               # полный game design document
docs/UNIQUE-FEATURES.md   # уникальные механики и fairness guardrails
docs/TECH_SPEC.md         # Godot, ENet, server, backend, anti-cheat, CI/CD
docs/ART-BIBLE.md         # art direction, UI system, prompts, asset list
docs/3D_PIPELINE.md       # Blender → Godot pipeline
docs/REFERENCES.md        # Godot / Blender / UI / art / audio sources
docs/SANDSTONE_REFERENCES.md # 30 map and architecture references
docs/ROADMAP.md           # MVP → Alpha → Beta → Release
docs/GODOT_MIGRATION.md   # решения Godot-перехода и следующий план
docs/UI_LAYOUT.md          # русская схема интерфейса и правила viewport
docs/ASSET_LICENSES.md     # provenance и лицензии импортированных моделей/звуков
docs/MAP_SALTWORKS.md      # новая схема playable карты SALTWORKS
```

## Техническое решение

- **Engine:** Godot 4.5+;
- **Gameplay / UI:** GDScript + native Control / Node3D scenes;
- **Networking:** `ENetMultiplayerPeer`, `MultiplayerAPI`, `@rpc`, `MultiplayerSpawner`, `MultiplayerSynchronizer`;
- **Server:** authoritative headless Godot export;
- **Backend:** отдельные Auth / Party / Match / Inventory / Case / Market сервисы;
- **3D:** Blender 4.5 LTS+ → glTF/FBX → Godot;
- **Renderer:** GL Compatibility baseline for the current lightweight slice; Forward+ remains the production desktop target after asset integration;
- **CI:** headless project check, GDScript tests, map/asset lint, Windows client + Linux server exports.

Godot не предоставляет готовые matchmaking, marketplace, identity или anti-cheat сервисы. Это не скрывается в engine layer: контракты и границы backend описаны в `docs/TECH_SPEC.md`.

## Product principle

**KS3: precision over force.** Игра сохраняет читаемую основу tactical FPS — точность, звук, экономика, utility и командные решения — и добавляет контролируемое состояние пространства. Новые состояния детерминированы сервером, телеграфируются и имеют counterplay: глубина не должна превращаться в случайность или pay-to-win.
