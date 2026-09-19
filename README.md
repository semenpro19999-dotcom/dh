# KS3 // Godot Command Center

KS3 — производственный концепт и интерактивный UI-вертикальный срез соревновательного tactical shooter 5×5. Проект переключён на **Godot 4.5+**: основной runtime теперь native Godot project с GDScript, `.tscn` scenes и headless-server планом на ENet.

> **Статус:** playable UI vertical slice / production concept. Native Godot project создан и является новым target runtime; сетевой игровой клиент, dedicated server, 3D-модели и backend находятся в roadmap как следующие игровые вехи.

## Что реализовано в Godot

- `project.godot` с Godot 4.5+ configuration, 128 physics ticks и Compatibility renderer для лёгкого запуска;
- `scenes/main.tscn` — стартовая сцена;
- `scripts/main.gd` — native Control UI, созданный без HTML / browser runtime;
- Главное меню / Operations Overview с hero-сценой `Rift / Fall`, сезонным статусом, ранговым прогрессом, операциями и fireteam;
- Matchmaking: Ranked 5v5 / Casual / Wingman / Custom Lobby, карта, регион, timer и post-match dialog;
- Inventory / loadout с weapon previews;
- Case Lab с odds, pity protocol и reward dialog;
- Progression с rank ladder и season rewards;
- Training / AI Coach concept;
- Field HUD с radar, killfeed, HP, armor, ammo, wallet, Echo и spectator state;
- Profile, achievements и settings dialog;
- responsive-friendly native layout и оригинальные preview assets в `public/assets/`.

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

## Browser preview

Старый React/Vite command center сохранён в `src/` как быстрый браузерный reference / fallback для review UX:

```bash
npm install
npm run dev
```

Это не основной игровой runtime после миграции. В production Godot-проекта именно `project.godot`, `scenes/` и `scripts/` являются source of truth.

## Структура

```text
project.godot             # Godot 4.5+ project settings
scenes/main.tscn          # native entry scene
scripts/main.gd           # Godot command center UI

content/models            # Blender high/low mesh sources
content/textures          # PBR maps, masks, decals
content/rigs              # armature / IK sources
content/animations        # actions / NLA clips
content/maps              # blockouts / greyboxes
content/exports           # reviewed FBX / GLB / QA manifests
public/assets             # prototype hero and weapon renders

src/                      # legacy browser preview

docs/GDD.md               # полный game design document
docs/UNIQUE-FEATURES.md   # уникальные механики и fairness guardrails
docs/TECH_SPEC.md         # Godot, ENet, server, backend, anti-cheat, CI/CD
docs/ART-BIBLE.md         # art direction, UI system, prompts, asset list
docs/3D_PIPELINE.md       # Blender → Godot pipeline
docs/REFERENCES.md        # Godot / Blender / art / audio sources
docs/ROADMAP.md           # MVP → Alpha → Beta → Release
docs/GODOT_MIGRATION.md   # что мигрировано и следующий Godot-план
```

## Техническое решение

- **Engine:** Godot 4.5+;
- **Gameplay / UI:** GDScript + native Control / Node3D scenes;
- **Networking:** `ENetMultiplayerPeer`, `MultiplayerAPI`, `@rpc`, `MultiplayerSpawner`, `MultiplayerSynchronizer`;
- **Server:** authoritative headless Godot export;
- **Backend:** отдельные Auth / Party / Match / Inventory / Case / Market сервисы;
- **3D:** Blender 4.5 LTS+ → glTF/FBX → Godot;
- **Renderer:** Forward+ for high desktop target, Mobile / Compatibility fallback;
- **CI:** headless project check, GDScript tests, map/asset lint, Windows client + Linux server exports.

Godot не предоставляет готовые matchmaking, marketplace, identity или anti-cheat сервисы. Это не скрывается в engine layer: контракты и границы backend описаны в `docs/TECH_SPEC.md`.

## Product principle

**KS3: precision over force.** Игра сохраняет читаемую основу tactical FPS — точность, звук, экономика, utility и командные решения — и добавляет контролируемое состояние пространства. Новые состояния детерминированы сервером, телеграфируются и имеют counterplay: глубина не должна превращаться в случайность или pay-to-win.
