# KS3 — Godot 4.5+ project cleanup

Дата: 19 сентября 2026.

## Итоговое решение

KS3 теперь является чистым native Godot 4.5+ проектом:

- engine target: Godot 4.5+;
- runtime: `project.godot` → `scenes/main.tscn` → `scripts/main.gd`;
- язык: GDScript;
- networking target: `ENetMultiplayerPeer` + Godot high-level multiplayer API;
- future dedicated server: headless Godot export;
- renderer baseline: Compatibility для лёгкого UI smoke-test, Forward+ для desktop visual target;
- Blender pipeline: glTF/FBX import в Godot;
- все preview assets перенесены в `assets/`.

## Что удалено

Удалены все browser-specific файлы и зависимости:

- `src/`;
- `index.html`;
- `package.json` и `package-lock.json`;
- `vite.config.js`;
- `public/`;
- локальные `node_modules/` и `dist/`.

В репозитории больше нет web runtime, npm build chain или browser fallback.

## Native Godot vertical slice

- Overview;
- Matchmaking и queue state;
- post-match dialog;
- Inventory / loadout;
- Case Lab и reward flow;
- Progression;
- Training;
- Field HUD;
- Profile;
- Settings dialog.

Сцена строится через стандартные `Control`, `PanelContainer`, `MarginContainer`, `VBoxContainer`, `HBoxContainer`, `GridContainer`, `TextureRect`, `ProgressBar` и `AcceptDialog`. Это простая production-ready база: после UX lock экраны можно разнести в reusable `.tscn`, не меняя продуктовый contract.

## Следующий технический коммит

1. вынести `main.gd` экраны в `scenes/ui/*.tscn`;
2. добавить `resources/*.tres` для оружия, редкостей и экономики;
3. подключить `scripts/network_manager.gd` к local ENet host / client test;
4. подключить `scripts/match_state.gd` к dedicated server scene;
5. добавить один player scene и server-validated FEN-9 trace;
6. запустить headless export на Linux и Windows client smoke;
7. только после этого подключать backend queue / identity.

## Честная граница проверки

В текущем sandbox бинарник Godot отсутствует, поэтому финальный engine parse / F6 smoke-test должен быть выполнен на машине с Godot 4.5+ и export templates. README содержит точные команды проверки.
