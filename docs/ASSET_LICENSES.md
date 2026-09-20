# KS3 — лицензии подключённых ассетов

Дата: 20 сентября 2026.

В игру добавлены только ассеты с разрешённой коммерческой переработкой. Модели и звуки не взяты из карты Sandstone и не являются импортом чужой карты. Для runtime используются выбранные файлы из публичных наборов.

## 3D-модели игроков

- **Kenney — Blocky Characters** — [страница набора](https://kenney.nl/assets/blocky-characters), CC0.
- Используемые файлы: `assets/models/kenney/characters/character-a.glb` … `character-d.glb` и соответствующие `Textures/texture-*.png`.
- Модели применяются к видимым ботам; коллизия и hitbox остаются отдельными Godot `CharacterBody3D`/`CapsuleShape3D`, чтобы визуальная сетка не меняла правила попадания.

## 3D-модели оружия

- **Kenney — Weapon Pack** — [страница набора](https://kenney.nl/assets/weapon-pack), CC0.
- Используемые файлы: `machinegun.glb`, `pistol.glb`, `shotgun.glb`, `sniper.glb`, `uzi.glb`, `flamethrower_long.glb`, `knifeRound_sharp.glb`, `knifeRound_smooth.glb`, `knife_sharp.glb`, `knife_smooth.glb`.
- Эти модели назначаются first-person viewmodel и оружию ботов. 30 слотов каталога сохраняются; десять ножей используют четыре читаемых варианта моделей по кругу.

## Звуки

- **Kenney — Starter Kit FPS** — [репозиторий](https://github.com/KenneyNL/Starter-Kit-FPS). Звуковые файлы и модели набора помечены CC0; код репозитория имеет отдельную MIT-лицензию, код из него в KS3 не копируется.
- Используемые runtime-копии: `assets/audio/kenney/enemy_attack.ogg`, `enemy_destroy.ogg`, `jump_a.ogg`, `jump_b.ogg`, `jump_c.ogg`, `land.ogg`, `walking.ogg`, `weapon_change.ogg`.
- **Kenney audio collection** — [репозиторий-зеркало](https://github.com/iwenzhou/kenney), RPG audio; исходные `metalClick.ogg`, `metalLatch.ogg`, `knifeSlice.ogg` сохранены в проекте как `assets/audio/kenney/metal_click.ogg`, `metal_latch.ogg`, `knife_slice.ogg`. Источник указывает CC0 для Kenney audio.
- **CC0 Public Domain Sounds** — [репозиторий](https://github.com/lavenderdotpet/CC0-Public-Domain-Sounds), лицензия репозитория CC0-1.0; `shot_01.ogg`, `hit_01.ogg`, `explosion.ogg`, `ambient_01.ogg` сохранены в проекте как `assets/audio/cc0/shot_01.ogg`, `hit_01.ogg`, `bomb_explosion.ogg`, `ambient_01.ogg`.

## Решение по импорту

- В runtime не подключаются чужие карты, изображения из видео или модели Sandstone.
- Исходные URL и лицензии фиксируются до добавления бинарных файлов; при финальном релизе provenance-файл остаётся в репозитории.
- Процедурные WAV-файлы из предыдущего прототипа оставлены как архивные fallback-ассеты, но текущий `match.gd` для выстрелов, попаданий, движения, бомбы и ambient использует интернет-ассеты из перечисленных CC0-источников.
