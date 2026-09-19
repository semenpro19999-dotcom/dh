# KS3 — Migration from browser/UE concept to Godot 4.5+

## Что изменилось

Дата: 19 сентября 2026.

- основной engine target: **Godot 4.5+**;
- UI source of truth: `project.godot` → `scenes/main.tscn` → `scripts/main.gd`;
- язык: GDScript;
- networking target: `ENetMultiplayerPeer` + Godot high-level multiplayer API;
- future dedicated server: headless Godot export;
- renderer baseline: Compatibility для быстрого UI smoke-test, Forward+ для desktop visual target;
- Blender pipeline: glTF/FBX import в Godot вместо engine-specific Unreal import;
- web React/Vite сохранён только как temporary browser reference, чтобы не потерять уже собранный UX-preview.

## Почему не удалён `src/`

Web preview был готовым UX reference и удобен для review без установленного Godot. Он больше не считается игровым runtime, но помогает сравнивать состояния UI во время миграции. После того как native Godot scenes будут выделены в отдельные reusable `.tscn`, `src/` можно удалить отдельным cleanup commit.

## Godot vertical slice

В native проекте уже есть:

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

Сцена строится через стандартные `Control`, `PanelContainer`, `MarginContainer`, `VBoxContainer`, `HBoxContainer`, `GridContainer`, `TextureRect`, `ProgressBar` и `AcceptDialog`. Это намеренно простая база: она может быть разнесена в `.tscn` scenes после UX lock, не меняя продуктовый contract.

## Следующий технический коммит

1. вынести `main.gd` экраны в `scenes/ui/*.tscn`;
2. добавить `resources/*.tres` для оружия, редкостей и экономики;
3. подключить `scripts/network_manager.gd` к local ENet host / client test;
4. подключить `scripts/match_state.gd` к dedicated server scene;
5. добавить один player scene и server-validated FEN-9 trace;
6. запустить headless export на Linux и Windows client smoke;
7. только после этого подключать backend queue / identity.

## Риск и честная граница

Godot project files созданы под 4.5+ и не зависят от Unreal. В текущем sandbox бинарник Godot отсутствует, поэтому финальный engine parse / F6 smoke-test должен быть выполнен на машине с Godot 4.5+ и export templates. Это не скрывается: README содержит точные команды проверки.
