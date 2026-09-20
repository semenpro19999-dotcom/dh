# KS3 — Game Design Document

**Версия:** 0.1 / concept lock
**Дата:** 19 сентября 2026
**Авторы:** one-agent production pass: game design, tech direction, art direction, UX
**Целевые платформы:** PC (Windows / Linux), после стабилизации client-server — PlayStation / Xbox
**Текущий playable slice:** `Sandstone` — локальная 3D-карта-блок-аут с FPS-камерой, 3 целями и каталогом из 30 видов оружия.
**Жанр:** соревновательный тактический шутер 5×5, round-based, с элементами destruction / stateful maps
**Целевая аудитория:** игроки CS2, Valorant, Rainbow Six Siege; core 16–35, любители high-skill PvP и командных решений

---

## 0. Видение и правила принятия решений

### Elevator pitch

**KS3 — tactical FPS, где точный выстрел открывает пространство, а не просто убирает игрока.** Команды сражаются за устройство «Ключ» на компактных картах: классическая gunplay-основа, экономика раунда и utility соединены с серверными изменениями укрытий, предсказуемой погодой и командными специализациями.

### Продуктовая формула

> **Readable core + stateful space + accountable depth**
>
> Читаемая соревновательная основа + пространство, которое можно осмысленно менять + глубина, за которую игрок отвечает.

### Главный UX-принцип

Игрок должен понимать, **почему** он проиграл дуэль и **какое решение** мог принять иначе. Любая новая система получает:

1. визуальный / аудио-телеграф до изменения;
2. серверный источник истины;
3. понятный counterplay;
4. тренировочный сценарий;
5. telemetry event для баланса.

### USP относительно CS2

| Параметр | KS3 | Классический ориентир |
|---|---|---|
| Gunplay | точность, first-shot discipline, спрей и economy-first TTK | сохраняем понятную основу tactical FPS |
| Пространство | ограниченные breakable panels и 2-state Rift Zones | в основном статичные карты |
| Погода | детерминированная, телеграфированная, влияет на аудио/видимость в безопасных пределах | отсутствует как матчмейкинговая система |
| Команда | round-buy специализация даёт utility-функцию, а не hero-ultimate | роль создаётся оружием и гранатами |
| После смерти | «Echo» даёт контекст последних 3 секунд без wallhack | spectator / killcam-поток |
| Обучение | AI Coach строит drills из telemetry игрока | отдельные режимы тренировки |
| Экономика | Credits для раунда отдельно от косметики; marketplace с escrow | косметика и marketplace не меняют competitive power |
| Визуальный характер | холодный промышленный sci-fi реализм: teal signal / amber warning | более нейтральный military realism |

**Ограничение:** KS3 не копирует названия, модели, бренды, карты, персонажей или визуальные assets существующих игр. Внутренняя семантика — своя: «Key», «Rift», «Signal», «Vector».

---

## 1. Игровой цикл

### Round loop

1. **Buy phase — 25 с:** игрок покупает оружие, броню, utility и активирует одну specialization.
2. **Insertion — 5 с:** spawn-protection, раздача team plan и weather forecast.
3. **Execution — 1:55:** атакующая команда ставит Key на A/B; защитники удерживают площадки и информацию.
4. **Rift window — после 0:55:** на картах с активной zone появляется одно телеграфированное состояние геометрии.
5. **Plant / defend / retake:** установка занимает 4 с; дефьюз 5 с стандартным kit / 2.5 с half-kit.
6. **End-state:** взрыв, elimination, time-out, defuse или timeout решают раунд.
7. **Debrief — 8 с:** RP, XP, stats, Echo context, предметы и следующий buy recommendation.

### Win condition

- стандартный defuse: first to 13 rounds;
- счёт 12–12 → overtime blocks 3 раунда, каждый блок с фиксированным economy reset;
- ranked overtime: максимум 2 блока, затем sudden-decision round с сохранением halftime side swap;
- unrated: first to 9, без рейтинга;
- командная сдача: только после 5-го раунда, 4/5 голосов.

### Коммуникация

Quick-comms: `CONTACT`, `ROTATE`, `HOLD`, `UTILITY`, `PLANT`, `DEFUSE`, `ECHO`. Голосовая радиолиния короткая, directional и регулируемая. Ping имеет three states: danger / location / plan.

---

## 2. Базовые механики

### 2.1 Движение и стрельба

- скорость, ускорение и остановка — серверные параметры; стрельба во время движения имеет явный accuracy penalty;
- walk снижает footprint и слышимость; crouch меняет профиль, но не даёт случайного dodge;
- jump не предназначен для bunny-hop advantage; landing создаёт короткое recovery окно;
- recoil split на первые 8 пуль, sustained spray, recovery и movement bloom;
- у каждого автомата есть фиксированный pattern seed на weapon family. Pattern не меняется от скина;
- first-shot accuracy — отдельный балансный параметр, отображается в weapon inspect;
- при попадании body / limb / head создаются hit feedback без тяжёлых gore-эффектов, чтобы сохранять читабельность;
- hit registration — server authoritative, client-side prediction только для ощущения выстрела и muzzle feedback.

### 2.2 Гранаты и utility

| Предмет | Базовая цена | Роль | Контр-игра |
|---|---:|---|---|
| **Flash** | 200 | временно отключает vision / HUD contrast | отвернуться, anti-flash positioning, Echo call |
| **Smoke** | 300 | 18 с line-of-sight denial; wind не разрывает дым | thermal silhouette отсутствует, обойти, wait |
| **Molotov** | 500 | 7 с denial; не ставится через solid cover | water / rotation / wait |
| **HE** | 350 | chip damage, ломает слабые панели | spread, counter-nade |
| **Decoy** | 50 | аудио-подмена и краткий fake ping | дисциплина, drone ping, timing |
| **Breach charge** | 400 | одно управляемое разрушение panel | шум, 0.8 с arming, reinforce рядом |
| **Signal dart** | 250 | 1.4 с short ping по зоне, не раскрывает сквозь стены | shoot dart, relocate |

Inventory utility: максимум 4 слота, два одинаковых предмета разрешены только для smoke/flash. Молотовы и charge лимитированы командой, чтобы не превращать раунд в spam.

### 2.3 Key: установка и дефьюз

- две plant zone: A и B;
- установка по hold 4 секунды, любое попадание или движение сбрасывает progress;
- стандартное время до срабатывания — 40 секунд;
- defuse kit 5 с, half-kit 2.5 с, audio cue на 50% и 90%;
- Key физически реплицируется server-side, подбирается и бросается;
- после plant один `Signal ping` показывается защитникам раз в 10 секунд, но не выдаёт позицию игрока;
- если Key падает на разрушаемую панель — panel lock до конца раунда, чтобы избежать физического abuse.

### 2.4 Экономика раунда

- старт: **800 credits**;
- победа: 3,250; победа через explosion / elimination: 3,250; defuse: 3,500;
- проигрышная серия: 1,400 / 1,900 / 2,400 / 2,900 / 3,400 cap;
- kill reward: от 150 до 900 по классу оружия;
- plant: +300 каждому attacker; defuse: +400 defender;
- half-time side swap на 12-м раунде;
- loss bonus виден всей команде перед buy; команда видит прогноз следующего loss bonus;
- специализация покупается из того же round wallet, косметика никогда не использует round credits;
- team save recommendation не автопокупает предметы, а даёт explainable suggestion.

### Экономический UX

В buy screen три слоя: **Essentials** (weapon / armor), **Utility**, **Specialization**. Внизу always-on panel: cash now, team average, likely next-round cash, reserved token. Это предотвращает «потерялся в меню» и помогает новичку без auto-play.

---

## 3. Уникальные механики KS3

Подробная спецификация, acceptance criteria и telemetry находятся в [`UNIQUE-FEATURES.md`](./UNIQUE-FEATURES.md). В ранний competitive MVP попадают только Weather Lite, Breakable Panels и Specializations; Echo и AI Coach входят в Alpha/Beta после плейтестов.

1. **Rift Weather / предсказуемая погода** — не меняет damage или hitbox; даёт понятное аудио-/визуальное состояние.
2. **Breachable Cover / разрушаемые укрытия** — фиксированный budget panel, разрушение server-authoritative, debris не блокирует путь.
3. **Specializations / командные роли без ультимейтов** — один слот, 1–2 утилитарных инструмента, контрится информацией и бюджетом.
4. **Rift Zones / изменяемая геометрия** — только заранее маркированные зоны с двумя авторскими состояниями; переход происходит по раундному таймеру.
5. **Echo / последние 3 секунды** — персональный ghost replay после смерти; показывает только собственное восприятие и подтверждённые события.
6. **AI Coach / адаптивное обучение** — модель рекомендаций на telemetry, не AI-aim assist; строит drills по ошибкам.
7. **Signal Economy** — прогноз buy и team reserve делает экономику командным решением, а не калькулятором в голове.

---

## 4. Специализации

Специализация — это не герой, не постоянная способность и не отдельный магазин. В начале buy phase игрок выбирает один kit; kit требует денег и занимает tactical slot.

| Kit | Инструмент | Польза | Ограничение |
|---|---|---|---|
| **BREACHER** | 1 Breach charge + panel scan | создаёт новый angle / видит integrity | loud arming; 1 на игрока |
| **ANCHOR** | 1 hardlight brace | усиливает panel на 12 с; не создаёт wall | ломается двумя HE / charge |
| **RELAY** | 2 signal pings | ставит командный ping beacon | beacon можно уничтожить |
| **MEDIC** | fast revive token в co-op; в ranked — быстрее stabilize после non-lethal hit | польза в co-op, в ranked только tempo | не лечит full HP, no combat revive |
| **ANALYST** | forecast card | показывает следующую weather phase и last known Key state | не показывает врагов |

Ranked launch: Breacher, Anchor, Relay, Analyst. Medic сначала тестируется в co-op, чтобы не ломать 5×5 TTK.

---

## 5. Режимы

| Режим | Игроки | Цель | Рейтинг |
|---|---:|---|---|
| **Ranked 5×5** | 10 | first to 13 Key / defuse | да |
| **Casual 5×5** | 10 | first to 9, relaxed economy | нет |
| **Deathmatch** | 12 | 10 минут, weapon loop | hidden MMR |
| **Arms Race** | 10 | kill ladder, map `ar_saltworks` | нет |
| **Wingman** | 2×2 | one plant zone, short rounds | отдельный MMR |
| **Co-op / AI Coach** | 1–5 | scenarios against adaptive AI | XP, без ranked RP |
| **Custom Lobby** | 1–10 | server rules, map state toggle | нет |

Custom host settings: round count, weather seed, breakables on/off, buy time, cheats only in private server. Для tournament mode все dynamic features можно фиксировать или отключать через server config.

---

## 6. Карты

В launch target — три полноценные карты с blockout и art pass. Каждая создаётся с одной primary objective loop и одним teachable unique system.

### `de_riftfall` — Port Helix

- **Формат:** 5×5 bomb / Key, first to 13;
- **Фантазия:** заброшенный средиземноморский порт, satellite dish, wet concrete, service tunnels;
- **Схема:** T spawn на Dry Dock; CT spawn у Control; A — Crane Yard; B — Pump Station; Mid — Customs Hall;
- **Choke points:** A Main wide 2-lane, Mid window, B Tunnel one-way pressure;
- **Сильный skill test:** smoke discipline и панель вокруг A Main;
- **Rift Zone:** Helix Gate после 0:55 открывает один из двух заранее прочных проходов; forecast виден на buy card;
- **Performance budget:** 8k visible static instances, 4k dynamic, MultiMesh / visibility ranges для repeated props, Forward+ lighting only on high preset.

### `cs_vanta_line` — Metro District

- **Формат:** 5×5 rescue / extraction, round target 9;
- **Фантазия:** ночной metro interchange в дождь, emergency teal lighting и amber service lamps;
- **Схема:** civilian hub, two train platforms, maintenance side lane;
- **Objective:** attackers escort the Key to extraction terminal, defenders hold three doors;
- **Unique teaching:** Sound Zones; train arrivals mask footsteps на короткое окно;
- **Competitive guardrail:** поезд schedule fixed by round phase, not random.

### `ar_saltworks` — Desalination Plant

- **Формат:** Arms Race / Deathmatch / warmup;
- **Фантазия:** белая salt refinery, long catwalks, teal tanks, bright sun bounce;
- **Схема:** three lanes, vertical central tower, no bomb sites;
- **Unique teaching:** spray, vertical aim, breakable short cover;
- **Target:** stable 144 FPS on mid PC with high scalability.

### Map process

`blockout → greybox playtest → readability pass → lighting pass → material pass → audio zones → network stress test → optimization → performance sign-off`.

Каждый choke получает: а) минимум два entry angles; б) defensive reset; в) utility answer; г) spawn-to-contact timing; д) telemetry event.

---

## 7. Оружие

### Launch families

- **Pistols:** M-7 sidearm, Rook burst, K-12 heavy;
- **SMG:** Kestrel, Veil-9 suppressed;
- **Rifles:** FEN-9 stable bullpup, Morrow AR high recoil, T-41 marksman;
- **Sniper:** Sable bolt, Vex semi-auto;
- **Shotguns:** Hush pump, Breach-12;
- **Melee:** Vanta Edge, utility knife;
- **Utility:** Flash, Smoke, Molotov, HE, Decoy, Breach Charge, Signal Dart.

### Weapon spec minimum

Каждый item хранит в data asset: `damage profile`, `falloff`, `armor multiplier`, `fire rate`, `mag size`, `reload`, `spread`, `recoil pattern`, `movement penalty`, `price`, `kill reward`, `audio set`, `viewmodel animation set`. Визуальный skin изменяет только material parameters и inspect/audio accents, не gameplay values.

---

## 8. Скины и монетизация

### Art categories

- weapon skins: hard-surface PBR, decals, reactive emissive;
- gloves, knives, stickers, charms, graffiti;
- banner / card / finisher-free inspect animations;
- rank badges, team emblems, profile frames;
- store bundles are cosmetic-only and have clear price + odds disclosure.

### Safety and economy principles

- cosmetics are never readable as hitbox or sound advantage;
- no loot box purchase with real money without odds, region age gate and spending controls;
- case duplicate conversion uses fixed credit value, not hidden exchange;
- marketplace escrow locks item and funds before trade, 2FA for sell / withdraw, cooldown for newly received items;
- no peer-to-peer direct links inside chat; trade links are one-time signed server URLs;
- no resale promise: item value is not investment language in UI.

---

## 9. UI / UX спецификация

### Information hierarchy

1. **Now:** queue / match state / threat;
2. **Next:** best action, buy suggestion, current objective;
3. **Why:** telemetry, reward, patch context;
4. **Deep:** full inventory, history, market and settings.

### Main menu / Command Center

Реализован в `scripts/main.gd` как native Godot screen `Overview`. Структура:

```text
┌ KS3 / COMMAND CENTER ┐ ┌ COMMAND CENTER / OVERVIEW ─ EU NORTH ─ profile ┐
│ OPERATIONS            │ │ ┌──── RIFT/FALL hero / FIND A MATCH ───────────┐ │
│  Overview             │ │ │ SEASON 03                    rank / streak    │ │
│  Matchmaking          │ │ │ Precision over force.                         │ │
│  Inventory            │ │ │ [FIND A MATCH]  [VIEW OPERATIONS]             │ │
│  Case Lab             │ │ └──────────────────────────────────────────────┘ │
│ INTEL                 │ │ ┌ READY WHEN YOU ARE ┐ ┌ YOUR SIGNAL ┐          │
│  Progression          │ │ │ Ranked 5v5          │ │ VECTOR IV   │          │
│  Training             │ │ └────────────────────┘ └─────────────┘          │
│  Patch notes          │ │ OPERATIONS FEED: Active ops / fireteam            │
│ season card / profile │ └─────────────────────────────────────────────────┘
└───────────────────────┘
```

### Matchmaking

- режимы: Ranked 5v5 / Casual / Wingman / Custom Lobby;
- server region и ping всегда видны;
- `START SEARCH` → timer; `CANCEL SEARCH` сохраняет party;
- map preview показывает weather / breakables / rotation;
- post-match preview в прототипе открывается кнопкой `PREVIEW POST-MATCH SCREEN`.

### HUD in match

```text
┌ ROUND 07  01:42  [A] [B]      TEAM SCORE  4 — 2 ┐
│ $ 2,850                         [mini radar]     │
│                                                  │
│                    crosshair                    │
│                     +                            │
│  [HP 100] [ARMOR 85]       killfeed             │
│  [utility slots]         K0MET + FEN-9          │
│                                                  │
│  FEN-9  24 / 90     key: NOT CARRIED   weather  │
└──────────────────────────────────────────────────┘
```

Гайдлайн: radar не должен скрывать playfield; HP/armor и ammo — bottom corners; round state и Key — top center; killfeed — right; Echo preview после смерти — lower center.

### После матча

```text
RANKED // MATCH COMPLETE
VICTORY                         13 — 09
MVP #01                         +124 RP
────────────────────────────────────────────
operator       K / D / A     impact      rating
niko//zero     27 / 14 / 8   1,642       +124
...
BATTLEPASS XP +3,840   ITEM DROP RIFT CASE   [RETURN]
```

### Inventory / Profile / Settings

- Inventory: filters, rarity, wear, sort, 3D inspect, equip;
- Profile: rating, map / weapon stats, achievements, recent items;
- Settings: Video, Audio, Controls, Crosshair, sensitivity, accessibility, reduce motion;
- все интерактивные действия имеют hover/focus и toast feedback; color не единственный carrier статуса — добавлены подписи и формы.

---

## 10. Case System

### Виды кейсов

1. **Standard** — обычный, постоянный пул;
2. **Seasonal** — сезонный, закрывается вместе с сезоном;
3. **Themed** — визуальная коллекция;
4. **Event** — ограниченный event window;
5. **Weekly Free** — один бесплатный кейс после weekly challenge.

### Редкости

`Common → Uncommon → Rare → Mythic → Legendary → Immortal`.

### Odds v0.1

| Редкость | Вероятность |
|---|---:|
| Common | 78.00% |
| Uncommon | 16.00% |
| Rare | 5.00% |
| Mythic | 0.90% |
| Legendary | 0.09% |
| Immortal | 0.01% |

Вероятности показываются перед открытием, фиксируются в server response и логируются по `case_open_id`. Уникальность предмета выбирается внутри rarity bucket через weight, duplicate protection не меняет displayed tier odds.

### Pity protocol

После 10 открытий без Mythic+ следующее открытие гарантирует Mythic или выше. Pity meter виден игроку, счётчик не скрывается при переходе между standard case variants. При гарантии rarity bucket меняется server-side до roll; клиент не решает результат.

### Opening UX

`token check → signed open request → server result → roulette animation → item reveal → inventory write`. Рулетка — presentation, не источник RNG. Immortal получает amber flash, unique chime и reduced motion-safe fallback.

В текущем локальном Godot prototype страница `КЕЙСЫ` реализует Standard case без сетевого authority: `scripts/case_system.gd` делает roll до UI update, показывает odds, pity, rarity, duplicate flag и последние item history entries, а состояние сохраняет в `user://ks3_cases.cfg`. Этот ledger не является production inventory; server Cases service должен заменить его до multiplayer launch.

### Получение и marketplace

- **KS3 Credits:** match XP, challenges, seasonal track, drops;
- case tokens: gameplay / event / store; не используются в раундовом buy;
- market: listing → escrow → buyer confirmation → item cooldown → audit trail;
- anti-scam: typed item preview, exact rarity, trade lock, 2FA, no external URL input;
- craft: 10 items same tier → one random item next tier из коллекционного набора; UI до подтверждения показывает весь outcome range;
- upgrade: только косметическая rarity conversion, без gameplay;
- event: limited drops, trade-up contracts и gold variants с отдельной odds-table.

---

## 11. Звук и музыка

### Sound pillars

- **Material truth:** concrete, steel, glass, wet ground имеют distinct transient;
- **Direction truth:** footsteps и reload position должны легко различаться на stereo headset;
- **Silence as information:** weather снижает confidence, но не стирает all cues;
- **Signal identity:** teal UI — short glassy ping; amber warning — warm double pulse.

Audio sets: shot close / mid / distant, tail per zone, magazine / bolt / safety, step surface, jump / landing, hit confirm, plant / defuse, weather layers, radio callouts, menu ambience, reward reveal. Music: low-BPM modular synth, 90–110 BPM lobby, 130 BPM round-end tension, ducking under comms.

---

## 12. Техническое решение

Выбран **Godot 4.5+** (stable version pin на старте pre-production): GDScript для authoritative rules / weapon data / UI / tools, native `Control` scenes для интерфейса, `ENetMultiplayerPeer` и `MultiplayerAPI` для client-server транспорта. Подробно — [`TECH_SPEC.md`](./TECH_SPEC.md).

Почему Godot 4.5+:

- быстрый open-source workflow с понятными `.tscn`, `.gd` и `.tres`;
- native Windows/Linux export и ясный путь к headless server;
- встроенные `@rpc`, `MultiplayerSpawner`, `MultiplayerSynchronizer` и ENet для базовой сетевой вертикали;
- Forward+ для desktop visual target, Mobile / Compatibility для scalability;
- Blender → glTF/FBX → Godot pipeline без обязательной proprietary toolchain;
- gameplay-critical backend остаётся отдельным сервисом, а не скрывается внутри engine project.

Godot не даёт готовый matchmaking, marketplace или anti-cheat — это сознательно вынесено в backend и описано в технической спецификации. Для KS3 сначала доказываем честный 5×5 loop, затем добавляем GDExtension / platform integrations только при подтверждённой необходимости.

---

## 13. Accessibility / Trust / Moderation

- colorblind presets, shape + label redundancy;
- subtitles for radio and important system cues;
- separate master / music / voice / SFX / UI sliders;
- reduced motion, flash intensity, hit effect intensity;
- left-handed viewmodel, FOV, sensitivity, raw input;
- voice report, text report, mute, block, automated grief telemetry;
- transparent disconnect / remake policy and appeal workflow.

---

## 14. Definition of Done for playable prototype

Прототип считается играбельным, когда 10 локальных clients can:

1. подключиться к dedicated server;
2. выбрать side, buy weapon / utility / specialization;
3. сыграть полный round с Key plant / defuse;
4. увидеть deterministic panel break и weather state;
5. получить server-side hit registration и round result;
6. вернуться в lobby и увидеть rating / XP / inventory mock;
7. пройти один AI Coach drill offline;
8. записать telemetry without PII.

Текущая репа покрывает UX / data contract / визуальный vertical slice пунктов 6–7, а gameplay implementation оставлена в roadmap с честной маркировкой.
