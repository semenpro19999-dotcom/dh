# SALTWORKS — текущий playable blockout

## Концепция

`SALTWORKS` заменяет прежний market/courtyard/citadel layout на собственный промышленный соляной завод. Карта всё ещё создаётся процедурно из `MeshInstance3D`/`StaticBody3D`, без импорта чужой карты или layout.

## Пространственная схема

- **Loading Yard / A** — западная короткая линия с погрузочным залом, контейнерами и двумя silos;
- **Brine Core** — центральный tank, control block, cross-lanes и overhead pipes;
- **Refinery Control / B** — восточная длинная линия с refinery hall, двумя tanks, catwalk и control room;
- южный **warehouse/dock** даёт альтернативную ротацию между A и B;
- северные/южные service gates и западный/восточный проходы сохраняют три читаемых направления атаки;
- два objective sites находятся на открытых подходах: `ObjectiveA (-14, -7)` и `ObjectiveB (14, 7)`.

## Gameplay contract

- игрок стартует в юго-западном loading approach;
- три бота патрулируют западный process lane, центральный pipe lane и восточный refinery control;
- укрытия, tanks и warehouse walls создают короткие/средние/длинные sightlines;
- collision остаётся отдельным от visual meshes, поэтому новая геометрия не ломает capsule hitboxes;
- карта сохраняет размер blockout **44 × 32 м** и две bomb sites, но не использует старые market/courtyard/citadel runtime calls.

## Production next step

Для production-версии блоки должны быть заменены на Blender-модули с отдельным navmesh, cover graph и QA collision pass. Runtime prototype намеренно оставляет геометрию процедурной, чтобы gameplay layout можно было быстро пересобирать без чужих карт.
