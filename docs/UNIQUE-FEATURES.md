# KS3 — Уникальные механики и fairness spec

Этот документ превращает идеи в проверяемые правила. Любая механика ниже проходит три фильтра: **readability**, **counterplay**, **server authority**. Если фича не выдерживает один из фильтров, она отключается из ranked до следующего теста.

## F1. Rift Weather

**Проблема:** статичная карта быстро становится выученным скриптом; нужен лёгкий слой состояния, не превращающий матч в лотерею.

**Решение:** в buy phase команда видит иконку следующей фазы: `CLEAR`, `OVERCAST`, `RAIN`, `STORM`. Фаза длится один раунд и выбирается из seed матча. Для ranked seed не зависит от игроков.

### Влияние

- Overcast: визуальная дистанция остаётся competitive-safe, чуть мягче contrast на far background;
- Rain: global ambience +8 dB low layer, distant steps имеют чуть меньшую confidence; close footsteps и radio не меняются;
- Storm: каждые 24 секунды lightning flash в skybox, краткая silhouette только на открытой площадке; не пробивает geometry;
- wind only affects loose VFX, **не меняет траекторию гранат** и не разрывает smoke.

### Guardrails

- forecast показывается минимум за buy phase;
- colorblind safe: буквенный label и pattern;
- server фиксирует `weather_phase` и реплицирует его; client не вычисляет результат;
- accessibility toggle: ambience lower / flash reduce, но gameplay information остаётся в subtitles / icon.

### Acceptance criteria

- игрок с закрытыми глазами по audio cue не может точно узнать enemy position;
- tick-to-tick gameplay state идентичен на server и replay;
- тестовая группа не фиксирует статистически значимый win-rate swing >2% между phases;
- performance delta <3% GPU budget на target mid PC.

### Telemetry

`weather_phase_started`, `weather_audio_occlusion`, `lightning_visibility_event`, `player_weather_death`.

---

## F2. Breachable Panels

**Проблема:** карта должна давать пространство для решения, но не стать хаотичной physics sandbox.

**Решение:** только авторские `BreakablePanel` actors с конечным integrity budget. Никаких произвольных стен, потолков или props.

### Правила

- каждый panel имеет `integrity`, `material_profile`, `break_state` (`intact`, `cracked`, `open`);
- integrity уменьшается от bullets, HE и Breach charge по таблице; melee не ломает ranked panel;
- после open debris визуален и не создаёт collision; Key не может быть permanent stuck;
- panel state server authoritative и попадает в round replay;
- max 6 active panels на карте, max 2 changes per round per zone;
- sound cue за 0.35 с до break, чтобы игрок мог отступить.

### Counterplay

- anchor kit может временно укрепить panel;
- HE ломает/скалывает, но не сразу открывает каждый panel;
- panel scan сообщает integrity, не выдаёт врага;
- через open angle можно играть обеим сторонам.

### Acceptance criteria

- break не меняет navmesh в реальном времени: для каждого panel заранее author двух nav corridors;
- destroy event не вызывает client hitch > 4 ms;
- kill attribution сохраняет weapon / damage source;
- любой новый angle проходит blind playtest с вопросом «откуда мог прийти контакт?».

### Telemetry

`panel_damage`, `panel_break`, `panel_reinforce`, `panel_angle_first_contact`, `panel_stuck_attempt`.

---

## F3. Specializations

**Проблема:** команда должна распределять utility и планировать роли, но KS3 не должен становиться hero shooter.

**Решение:** specialization выбирается в buy phase, стоит credits, имеет один ограниченный utility item, не имеет ult, постоянного buff или уникального hitbox.

### Design constraints

- kit visible in team roster и silhouette не меняет;
- только одна active specialization per player;
- use time / sound / counterplay обязательны;
- kit can be swapped before round lock, no mid-round class switch;
- same kit duplication: max 2 per team в ranked.

### Базовые kits

| Kit | Кнопка | Cooldown / charge | Counter |
|---|---|---:|---|
| Breacher | place charge | 1 charge | destroy, hear arming |
| Anchor | reinforce | 1 charge / 12 s | HE / Breach |
| Relay | beacon ping | 2 charges | shoot beacon |
| Analyst | forecast view | passive at buy | no extra info in action |

### Telemetry

`specialization_picked`, `specialization_used`, `specialization_value`, `specialization_countered`, `specialization_duplicate_denied`.

---

## F4. Rift Zones

**Проблема:** нужно ощущение живого места и macro rotation, но любое случайное изменение geometry может быть unfair.

**Решение:** author-locked zone имеет две заранее проверенные состояния A/B. На 0:55 сервер запускает одну из них по объявленному forecast. Перемещаются только двери, shutters, мостовые секции — не spawn, не plant sites, не full lane.

### Правила

- zone boundary видна в map / world через thin cyan seam;
- transition 6 секунд, с warm-up audio и signage;
- path A/B всегда оставляет минимум два маршрута на site;
- rotate chosen at round start and cannot be rerolled;
- spectator / replay показывает state timeline;
- tournament mode может lock zone to state A.

### Acceptance criteria

- spawn-to-contact difference между states <8%;
- plant time и retake path не становятся нулевыми;
- server replay reproduces state with same seed;
- map callouts не меняются между states.

---

## F5. Echo

**Проблема:** после смерти игрок чувствует только фрустрацию; полезно дать контекст без wallhack и killcam abuse.

**Решение:** после смерти локальный client получает replay buffer последних 3 секунд **с точки зрения умершего**. Echo — стилизованный low-opacity ghost; можно перемотать 1.5 с, но нельзя смотреть от лица врага.

### Что видно

- own crosshair, own audio, confirmed damage events, own pings;
- attacker silhouette только если attacker был в прямой line-of-sight в момент смерти;
- no enemy name, no spectator camera, no minimap reveal;
- команда может услышать только normal death radio, Echo private.

### Trust

- replay buffer хранится client-side short ring, но authoritative kill event приходит server;
- competitive review сохраняет compressed server event timeline, не raw personal voice;
- toggle `Echo reduced` для motion sensitivity.

### Acceptance criteria

- Echo никогда не показывает entity outside player visibility set;
- latency between death and view <250 ms on target network;
- нельзя извлечь team information из post-death spectator beyond normal rules.

---

## F6. AI Coach

**Проблема:** aim trainer не объясняет, почему игрок принимает плохие решения.

**Решение:** offline / co-op scenario builder анализирует агрегированные показатели и подбирает drill. Это recommendation system, а не neural aiming, opponent prediction или matchmaking black box.

### Signal axes

1. **Mechanics:** first-shot accuracy, recoil recovery, movement stop;
2. **Information:** utility timing, clear order, sound reaction;
3. **Team:** trade distance, ping quality, rotate delay.

### Loop

`match telemetry → explainable metric → 5 minute scenario → one coaching cue → result → next drill`.

Пример: если player умирает с smoke в инвентаре 4 раза подряд, Coach не говорит «ты плохой», а запускает `Quiet Entry`: 3 exits, ограниченный buy, hint после второй ошибки.

### Guardrails

- no aim assist in PvP;
- no raw chat / voice sent to model in MVP;
- player can delete training history;
- every advice has metric label and dismiss button;
- AI response is templated and localization-safe in ranked contexts.

---

## F7. Signal Economy

**Проблема:** beginner не понимает loss bonus, а stack не может быстро согласовать save.

**Решение:** buy HUD визуализирует team cash + next-round forecast + safe spend. System suggests, player confirms.

### Example

```text
TEAM SIGNAL
avg cash 2,340        next loss 2,900
BUY STATUS: 3 / 5 can full buy
RECOMMENDATION: half-buy utility + save rifle
WHY: 4 rifles survive into next round
```

Не используется для автоматической покупки или hidden player rating. Forecast deterministic based on rules и виден всей команде.

---

## Политика экспериментальных фич

- Weather Lite / Panels проходят в MVP prototype;
- Specializations — Alpha with two kits;
- Rift Zones — Alpha map-only experiment;
- Echo — Alpha opt-in, затем ranked only if no info leak;
- AI Coach — Beta; no dependency for matchmaking;
- Signal Economy — MVP UI, backend rules in Alpha.

Every feature получает remote config flag, kill switch and `feature_version` telemetry field.
