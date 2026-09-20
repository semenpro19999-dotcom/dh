# KS3 — SALTWORKS: схема нового меню и HUD

## Новый главный экран

Главное меню больше не использует прежний sidebar command-center layout. Это полноэкранный tactical briefing на фоне отдельного Sandstone key art:

- верхняя строка: бренд SALTWORKS, навигация «Операция / Карта / Арсенал / Кейсы / Тренировка», сеть и профиль;
- основной экран: крупный primary CTA «Войти в раунд», короткий брифинг и hero-карточка карты;
- информационные карточки: 30 слотов оружия, 3 цели, кейсы/токены, 360° camera mouse look;
- нижняя status bar: состояние поля, размер карты, количество оружия и build;
- страницы карты, арсенала, кейсов, тренировки, профиля и настроек открываются в том же fullscreen canvas как briefing overlays;
- длинные страницы арсенала и кейсов используют вертикальный `ScrollContainer`, остальные страницы остаются короткими;
- страница `Кейсы`: Standard case card с token balance и pity progress, drop-table с odds до открытия, результат с rarity/duplicate flag и последние item history entries;
- case roll выполняется до presentation update, а `scripts/case_system.gd` сохраняет локальный prototype ledger в `user://ks3_cases.cfg`.

В меню использован отдельный сгенерированный Sandstone key art `assets/sandstone-menu.jpg`. Он не содержит логотипов, текста или чужих игровых assets.

## Переход в матч

Главные CTA вызывают `launch_match()` → `call_deferred("_open_match_scene")` → `res://scenes/match.tscn`. Это сохраняет deferred-переход и не оставляет старые page nodes в дереве: `_clear_page()` освобождает текущий overlay перед рендером следующей страницы.

## Адаптивность

- базовый viewport: **1440×900**;
- минимальное окно: **800×500**;
- `window/stretch/mode = canvas_items`, `window/stretch/aspect = expand`;
- main content находится в `ScrollContainer`, а footer закреплён к нижней границе окна;
- карточки используют `SIZE_EXPAND_FILL`, изображения имеют ограниченную минимальную ширину и могут сжиматься;
- footer не является частью прокручиваемого контента, поэтому нижняя информация не пропадает на маленьком окне.

## Игровой HUD и input contract

`scenes/match.tscn` использует `CanvasLayer` для верхнего таймера, crosshair и компактного нижнего оружейного/бомбового HUD. Центральный action popup намеренно не используется: он перекрывал прицел после любого действия.

- `WASD` — движение;
- `Shift` — бег;
- `Space` — прыжок;
- `MouseMotion` через `_input()` — yaw игрока и pitch головы;
- ЛКМ через `_input()` и удержание в `_physics_process()` — стрельба;
- ПКМ — удерживаемый ADS/прицел; обычное оружие получает zoom, AWM открывает scope overlay;
- `RayCast3D` выполняет hit test, а `PhysicsRayQueryParameters3D` служит прямым physics fallback;
- `Q/E` — переключение всех 30 оружий;
- `1` — скорострелка RIFT-9;
- `2` — AWM SANDWRAITH;
- `3` — нож;
- `4–0` — быстрые слоты каталога;
- `R` — перезарядка;
- `F` — удерживать на objective site для планта или возле бомбы для обезвреживания;
- `Esc` — deferred-возврат в меню.

Mouse input обрабатывается на `_input()`, а не на `_unhandled_input()`, чтобы CanvasLayer HUD и Control-элементы меню не могли съесть поворот камеры или выстрел.

## Проверка

`gdlint` и `gdparse` проходят для `scripts/main.gd`, `scripts/match.gd` и `scripts/arsenal.gd`. Полный F5 smoke-test в текущем sandbox невозможен: Godot binary отсутствует, а загрузка официального архива была заблокирована сетевым SSL-ошибкой.
