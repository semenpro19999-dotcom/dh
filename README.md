# KS3 // Command Center

KS3 — производственный концепт и интерактивный UI-прототип соревновательного тактического шутера 5×5. Это не просто лендинг: в репозитории собран кликабельный командный центр с основными потоками игрока — стартовой операционной панелью, матчмейкингом, инвентарём, Case Lab, прогрессией, обучением, профилем, патчноутами и настройками.

> **Статус:** playable UI vertical slice / production concept. Визуальная оболочка и UX работают; сетевой игровой клиент, dedicated server, 3D-модели и backend находятся в roadmap как следующие игровые вехи.

## Что реализовано

- тёмный tactical HUD в собственной визуальной системе KS3: графитовая основа, холодный teal-сигнал, янтарный warning;
- responsive-версия от desktop до мобильного узкого viewport;
- главное меню / Operations Overview с hero-сценой `Rift / Fall`, сезонным статусом, ранговым прогрессом, фидом операций и fireteam;
- Matchmaking: режимы Ranked 5v5 / Casual / Wingman / Custom Lobby, выбор региона и карты, таймер поиска, post-match modal;
- Inventory: фильтры, кредиты, loadout banner, rarity cards и inspect feedback;
- Case Lab: seasonal cases, распределение редкостей, pity protocol и анимированный opening flow с reward state;
- Progression: rank ladder, rating chart, season rewards;
- Training: adaptive drills и AI coach концепт;
- Profile, achievements, settings drawer, toast-feedback;
- свои ассеты hero / оружия, сгенерированные для прототипа и лежащие в `public/assets/`.

## Запуск

```bash
npm install
npm run dev
```

Vite слушает `0.0.0.0` и принимает preview-host Arena. Production проверяется так:

```bash
npm run build
npm run preview
```

## Структура

```text
src/main.jsx              # React UI, stateful screen flows и mock data
src/styles.css            # KS3 visual system, responsive layout и motion
public/assets/            # hero/key-art и preview weapon renders
content/                  # целевая структура production-контента Blender/UE

docs/GDD.md               # полный game design document
/docs/UNIQUE-FEATURES.md  # спецификация новых механик и fairness guardrails
/docs/TECH_SPEC.md        # UE5, netcode, backend, anti-cheat, CI/CD
/docs/ART-BIBLE.md        # art direction, UI system, prompts, 2D/3D asset list
/docs/3D_PIPELINE.md      # Blender workflow, maps, rigging, export и QA
/docs/REFERENCES.md       # веб-референсы, документация и лицензии
/docs/ROADMAP.md          # MVP → Alpha → Beta → Release, P0/P1/P2 и риски
```

## Принцип продукта

**KS3: precision over force.** Игра сохраняет читаемую основу классического tactical FPS — точность, звук, экономика, utility и командные решения — и добавляет контролируемое состояние пространства. Новые состояния всегда детерминированы сервером, имеют телеграфирование и counterplay: глубина не должна превращаться в случайность или pay-to-win.

## Важное ограничение прототипа

Репозиторий не притворяется готовым online-shooter production build. Здесь зафиксирована проверяемая концепция и UX-вертикаль, на которую можно навесить Unreal Engine 5 client, C++ rules layer, dedicated server и backend по спецификациям в `docs/`. Установка Unreal/Blender и запуск dedicated server не выполняются в sandbox автоматически — вместо этого создана воспроизводимая структура производства, naming convention и пошаговый pipeline.
