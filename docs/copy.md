# Wayback — тексты интерфейса (v0.1)

Единый источник пользовательских строк для ru и en. Ключи — будущие ключи ARB: задача l10n (#11) переносит таблицы ниже в `lib/app/localization/arb/` без переформулирования.

Состояния экранов — [SCREENS.md](../SCREENS.md) §4, контракт кодов ошибок — [architecture.md](architecture.md) §4.2.

---

## 1. Голос и правила

- **Коротко и спокойно.** Человек на улице, возможно в темноте и с одной рукой. Одна мысль в строке, без восклицательных знаков.
- **Обращение на «вы»**, со строчной буквы. В en — нейтральное «you», без «please» там, где это не просьба.
- **Ошибка = что случилось + что сделать.** Никогда не показываем код, «Ошибка» без объяснения или технический `description`.
- **Деструктивное подтверждение называет последствие**, а не спрашивает «Вы уверены?» (DESIGN_SYSTEM.md «Паттерны»).
- **Термины:**

  | Понятие | ru | en |
  | --- | --- | --- |
  | сохранённое место | точка | place |
  | действие сохранения | сохранить место | save location |
  | точка, к которой идём | активная | active |
  | прибытие | вы на месте | you're here |

  В en «point» звучит технически, поэтому существительное — «place». В ru «точка» уже закреплена в документах и коротка.
- **Кавычки:** ru — «ёлочки», en — “curly”. Многоточие — один символ `…`.
- **Числа и единицы** — только через форматтеры `core/utils` (§9), не конкатенацией.

---

## 2. Общие действия

| Ключ | ru | en | Примечание |
| --- | --- | --- | --- |
| `appTitle` | Wayback | Wayback | не переводится |
| `actionSave` | Сохранить | Save | |
| `actionCancel` | Отмена | Cancel | |
| `actionRetry` | Повторить | Try again | под Alert ошибки |
| `actionDelete` | Удалить | Delete | |
| `actionRename` | Переименовать | Rename | |
| `actionAllow` | Разрешить | Allow | запрос разрешения |
| `actionOpenSettings` | Открыть настройки | Open settings | системные настройки телефона |

## 3. Home (`/`)

| Ключ | ru | en | Примечание |
| --- | --- | --- | --- |
| `homeTitle` | Wayback | Wayback | |
| `homeSaveLocation` | Сохранить место | Save location | Primary-кнопка, всегда видна |
| `homeAllPoints` | Все точки | All places | |
| `homeSettingsTooltip` | Настройки | Settings | иконка в шапке |
| `homeEmptyTitle` | Пока нет точек | No places yet | пустое (а): точек нет вовсе |
| `homeEmptyBody` | Сохраните место, куда хотите вернуться, — например, где оставили машину. | Save a spot you want to return to, like where you parked. | |
| `homeNoActiveTitle` | Нет активных точек | No active places | пустое (б): точки есть, активных нет |
| `homeNoActiveBody` | Выберите, к каким точкам сейчас идёте. | Choose the places you're heading to. | |
| `homeNoActiveAction` | Выбрать точку | Choose a place | → `/points` |
| `homePointSemantics` | {name}, {distance} | {name}, {distance} | метка карточки для скринридера |

## 4. Point Create (`/points/new`)

| Ключ | ru | en | Примечание |
| --- | --- | --- | --- |
| `pointCreateTitle` | Новая точка | New place | |
| `pointCreateLocating` | Определяем местоположение… | Getting your location… | loading, Save недоступен |
| `pointNameLabel` | Название | Name | |
| `pointNameHelper` | Можно оставить как есть | Optional | под полем, дефолт уже подставлен (§7) |
| `pointTypeLabel` | Иконка | Icon | заголовок пикера 4×2 |
| `pointCoordinatesLabel` | Координаты | Coordinates | превью координат; та же подпись в карточке деталей |
| `pointAccuracy` | Точность {accuracy} | Accuracy {accuracy} | `{accuracy}` = `±8 м`, §9 |
| `pointSavedSnackbar` | Точка «{name}» сохранена | “{name}” saved | Snackbar после сохранения |

## 5. Points List (`/points`)

| Ключ | ru | en | Примечание |
| --- | --- | --- | --- |
| `pointsListTitle` | Точки | Places | |
| `pointsAddTooltip` | Новая точка | New place | иконка «+» в шапке |
| `pointsEmptyTitle` | Нет сохранённых точек | No saved places | |
| `pointsEmptyBody` | Сохраните первое место — стрелка приведёт вас обратно. | Save your first place and the arrow will lead you back. | |
| `pointActiveLabel` | Активна | Active | бейдж / подпись переключателя |
| `pointActiveToggleSemantics` | Показывать на главном экране | Show on home screen | метка Switch для скринридера |
| `pointsListSubtitle` | {distance} · сохранено {when} | {distance} · saved {when} | подзаголовок строки списка: `640 м · сохранено 12 мин назад` |

**Когда сохранено** (`{when}`) — относительное время, по возрасту точки:

| Ключ | ru | en | Когда |
| --- | --- | --- | --- |
| `timeJustNow` | только что | just now | меньше минуты |
| `timeMinutesAgo` | {n} мин назад | {n} min ago | меньше часа |
| `timeHoursAgo` | {n} ч назад | {n} h ago | сегодня |
| `timeYesterday` | вчера | yesterday | вчера по местному времени |
| — | `2 нояб.` | `Nov 2` | раньше: дата через `intl` (`d MMM`), без года в текущем году |

## 6. Point Details (`/points/:id`)

| Ключ | ru | en | Примечание |
| --- | --- | --- | --- |
| `pointDetailsTitle` | Точка | Place | запасной заголовок, обычно — имя точки |
| `pointDistanceFromYou` | {distance} от вас | {distance} away | под именем точки |
| `pointSavedAt` | Сохранена {date} | Saved {date} | `{date}` — локальный формат даты и времени; для одной строки |
| `pointSavedLabel` | Сохранена | Saved | подпись строки в карточке деталей, значение — дата отдельной строкой |
| `pointNavigate` | Вести к точке | Navigate | Primary |
| `pointRenameTitle` | Название точки | Place name | диалог переименования |
| `pointDeleteTitle` | Удалить «{name}»? | Delete “{name}”? | диалог подтверждения |
| `pointDeleteBody` | Точка пропадёт из списка и с главного экрана. Вернуть её не получится. | It will disappear from your list and home screen. This can't be undone. | названное последствие |
| `pointDeletedSnackbar` | Точка «{name}» удалена | “{name}” deleted | |
| `pointBackToList` | К списку точек | Back to places | под ошибкой `points_not_found` |

## 7. Типы точек и имя по умолчанию

| Ключ | ru | en | Тип (`WbPointType`) |
| --- | --- | --- | --- |
| `pointTypeCar` | Машина | Car | `car` |
| `pointTypeTent` | Лагерь | Camp | `tent` |
| `pointTypeFishing` | Рыбалка | Fishing | `fishing` |
| `pointTypeBackpack` | Вещи | Gear | `backpack` |
| `pointTypeHouse` | Домик | Cabin | `house` |
| `pointTypeMeeting` | Встреча | Meetup | `meeting` |
| `pointTypeParking` | Парковка | Parking | `parking` |
| `pointTypeGeneric` | Точка | Place | `generic`, выбран по умолчанию |
| `pointDefaultNameNumbered` | {type} {number} | {type} {number} | `Машина 2`, если имя уже занято |

**Имя по умолчанию** — подпись выбранного типа: «Точка», а после выбора иконки машины — «Машина». Если точка с таким именем уже есть, добавляется номер: «Машина 2», «Машина 3». Пока пользователь не правил поле, имя следует за выбранной иконкой; после ручной правки — нет.

Имя сохраняется в той локали, в которой точку создали, и при смене языка не переводится: это уже пользовательские данные.

## 8. Navigate (`/navigate/:id`)

| Ключ | ru | en | Примечание |
| --- | --- | --- | --- |
| `navigateTitle` | Навигация | Navigate | запасной заголовок, обычно — имя точки |
| `navigateLocating` | Ждём GPS и компас… | Waiting for GPS and compass… | loading до первого фикса и показания компаса |
| `navigateArrived` | Вы на месте | You're here | цвет `positive`, поверх контента |
| `navigateCompassCalibrationTitle` | Компас неточен | Compass is off | Alert warning, стрелка остаётся |
| `navigateCompassCalibrationBody` | Поводите телефоном восьмёркой. | Move your phone in a figure eight. | пояснение к нему |
| `navigateWeakSignalTitle` | Слабый сигнал GPS | Weak GPS signal | Alert warning на экране навигации |
| `navigateWeakSignalBody` | Расстояние может быть неточным. | Distance may be off. | пояснение к нему |
| `navigateWeakSignal` | Слабый сигнал GPS — расстояние может быть неточным. | Weak GPS signal — distance may be off. | Alert warning, при плохой точности |
| `navigateSemantics` | До «{name}» {distance} | {distance} to “{name}” | live region, озвучивается с троттлингом |

## 9. Расстояние и точность

| Ключ | ru | en | Пример ru / en |
| --- | --- | --- | --- |
| `distanceMeters` | {value} м | {value} m | `850 м` / `850 m` |
| `distanceKilometers` | {value} км | {value} km | `1,2 км` / `1.2 km` |
| `accuracyValue` | ±{value} м | ±{value} m | `±8 м` / `±8 m` |
| `distanceUnknown` | — | — | расстояние, пока нет позиции |
| `distanceFeet` | {value} фт | {value} ft | `420 фт` / `420 ft` |
| `distanceMiles` | {value} ми | {value} mi | `1,4 ми` / `1.4 mi` |
| `accuracyValueFeet` | ±{value} фт | ±{value} ft | `±26 фт` / `±26 ft` |

**Метрическая система** (по умолчанию):

- До 1000 м — целые метры, дальше — километры с одним знаком (mvp-scope.md §2.3). Округление до выбора единицы: 999,6 м → `1,0 км`.

**Футы и мили** (настройка «Футы и мили»):

- До 0,1 мили (528 фт) — целые футы, дальше — мили с одним знаком: `420 фт`, `0,1 ми`, `1,4 ми`. Порог 0,1 мили — привычный для навигаторов в имперских единицах: дальше футы становятся трёх-четырёхзначными и плохо читаются на ходу.
- Округление тоже до выбора единицы: 527,8 фт → `0,1 ми`.
- Реализация — в форматтере `core/utils` (`formatDistance`, `formatAccuracy` с `UnitSystem`).

**Общее:**

- ru: десятичная запятая, разряды через неразрывный пробел (`1 234,5 км`); en: точка и запятая (`1,234.5 km`).
- Между числом и единицей — неразрывный пробел, чтобы `850` и `м` не разъезжались по строкам.
- Точность — всегда целые метры или футы, без перехода в километры и мили.
- Сокращения: в ru «фт» и «ми», без точки — так же, как «м» и «км».

## 10. Settings (`/settings`)

| Ключ | ru | en | Примечание |
| --- | --- | --- | --- |
| `settingsTitle` | Настройки | Settings | |
| `settingsUnits` | Единицы измерения | Units | |
| `settingsUnitsMetric` | Метры и километры | Meters & kilometers | |
| `settingsUnitsImperial` | Футы и мили | Feet & miles | |
| `settingsLanguage` | Язык | Language | |
| `settingsLanguageSystem` | Как в системе | System default | |
| `settingsLanguageRu` | Русский | Русский | самоназвание, одинаково в обеих локалях |
| `settingsLanguageEn` | English | English | самоназвание |
| `settingsVibration` | Вибрация при прибытии | Vibrate on arrival | Switch |
| `settingsSendLog` | Отправить журнал | Send log | открывает меню «Поделиться» |
| `settingsSendLogHint` | Для разбора ошибок, без координат | To look into problems, no coordinates | подпись пункта |
| `diagnosticsShareSubject` | Журнал Wayback | Wayback log | тема письма |

## 11. Разрешения и ошибки

### 11.1 Запрос разрешения

| Ключ | ru | en | Примечание |
| --- | --- | --- | --- |
| `permissionTitle` | Доступ к геолокации | Location access | экран-пояснение перед системным диалогом |
| `permissionBody` | Wayback запоминает, где вы были, и показывает дорогу обратно. Данные остаются на телефоне. | Wayback remembers where you've been and shows the way back. Your data stays on your phone. | тот же текст — в `NSLocationWhenInUseUsageDescription` (#18) |

### 11.2 Ошибки по кодам

Ошибка показывается компонентом Alert: короткий **заголовок** (что случилось) и **пояснение** (почему это важно или что делать). Ключи — `error_<code>` для заголовка и `error_<code>_body` для пояснения; действие — отдельной кнопкой.

Заголовок — до ~30 символов, без точки в конце. Пояснение — одна фраза с точкой. Пояснение можно не показывать там, где места мало (Snackbar): заголовок понятен сам по себе.

**ru**

| Код | Заголовок | Пояснение | Действие |
| --- | --- | --- | --- |
| `generic` | Что-то пошло не так | Попробуйте ещё раз. | Повторить |
| `location_permission_denied` | Нет доступа к геолокации | Без него Wayback не знает, где вы. | Разрешить |
| `location_permission_denied_forever` | Доступ к геолокации запрещён | Включите его в настройках телефона. | Открыть настройки |
| `location_service_disabled` | Геолокация выключена | Включите её, чтобы сохранять и находить точки. | Открыть настройки |
| `location_unavailable` | Не получается определить, где вы | Выйдите на открытое место. | Повторить |
| `navigation_compass_unavailable` | Компас недоступен | На этом телефоне нет компаса, поэтому направление не показать. | — |
| `points_storage_read_failed` | Не удалось загрузить точки | Попробуйте ещё раз. | Повторить |
| `points_storage_write_failed` | Не удалось сохранить точку | Попробуйте ещё раз. | Повторить |
| `points_not_found` | Точка не найдена | Возможно, её удалили. | К списку точек |
| `settings_storage_failed` | Не удалось сохранить настройки | Попробуйте ещё раз. | Повторить |
| `diagnostics_export_failed` | Не удалось подготовить журнал | Попробуйте ещё раз. | — |

**en**

| Код | Title | Body |
| --- | --- | --- |
| `generic` | Something went wrong | Try again. |
| `location_permission_denied` | No location access | Wayback needs it to know where you are. |
| `location_permission_denied_forever` | Location access is blocked | Turn it on in your phone settings. |
| `location_service_disabled` | Location is off | Turn it on to save and find places. |
| `location_unavailable` | Can't find your location | Try moving into the open. |
| `navigation_compass_unavailable` | No compass | This phone has no compass, so direction can't be shown. |
| `points_storage_read_failed` | Couldn't load your places | Try again. |
| `points_storage_write_failed` | Couldn't save the place | Try again. |
| `points_not_found` | Place not found | It may have been deleted. |
| `settings_storage_failed` | Couldn't save settings | Try again. |
| `diagnostics_export_failed` | Couldn't prepare the log | Try again. |

Пара `error_generic` / `error_generic_body` показывается для любого кода без перевода; сам код при этом логируется (architecture.md §4.2).

У настроек свой код `settings_storage_failed`, а не `points_storage_write_failed`: иначе текст ошибки настроек говорил бы о точках.

---

## 12. Длина строк

Посчитано по таблицам выше (символы без плейсхолдеров, 75 пар): в сумме ru длиннее en на **14%**, но короткие подписи расходятся гораздо сильнее.

Наибольшее отношение ru/en — однострочные подписи:

| Ключ | ru | en | ru/en |
| --- | --- | --- | --- |
| `settingsUnits` | 17 | 5 | 3,4× |
| `pointNameHelper` | 23 | 8 | 2,9× |
| `actionSave` | 9 | 4 | 2,3× |
| `pointSavedSnackbar` | 18 | 8 | 2,3× |
| `actionRename` | 13 | 6 | 2,2× |
| `pointNavigate` | 13 | 8 | 1,6× |

Самые длинные строки ru — многострочные блоки:

| Ключ | ru, символов |
| --- | --- |
| `permissionBody` | 90 |
| `homeEmptyBody` | 72 |
| `pointDeleteBody` | 70 |
| `error_location_service_disabled` | 68 |
| `error_location_permission_denied_forever` | 65 |

Выводы для вёрстки:

- **Кнопки, шапки и `ListItem` рассчитывать по ru**, а не по en: разница в 2–3 раза на коротких подписях съедает весь запас, заложенный под en. Самые длинные однострочные ru-подписи — «Открыть настройки» (17), «Единицы измерения» (17), «Вибрация при прибытии» (21).
- **Тексты ошибок, пустых состояний и warning** — многострочные блоки до 90 символов; переносы ожидаемы, верстать без фиксированной высоты.
- Масштаб текста до 200% (DESIGN_SYSTEM.md «Доступность»): кнопки с длинной ru-подписью должны переносить текст, а не обрезать.

## 13. Решения и что из них следует

- **Термин в en — «place»**, не «point».
- **Футы и мили** — оба, с переходом на мили от 0,1 мили (§9). Форматтер расширяется в settings (#15).
- **Код ошибки настроек — `settings_storage_failed`** (§11.2); SCREENS.md §4.6 обновлён.
- **Подписи типов точек** берутся из ключей `pointType*`, а не из `WbPointType.label` в дизайн-системе, где они захардкожены на русском. Переключить — в l10n (#11).
- **Онбординг — три шага, доступ можно отложить** (§14): шаг геолокации объясняет, зачем доступ, а «Не сейчас» не блокирует приложение — так требуют правила Google Play и App Store.
- **Слабый сигнал и калибровка** — предупреждения, а не ошибки: ключи без префикса `error_`, порог «плохой точности» задаётся в navigation (#14).

## 14. Onboarding (`/onboarding`)

Три шага при первом запуске (SCREENS.md §4.0). Шаг 3 предваряет системный диалог; плашка на Home (§11.1) остаётся для тех, кто нажал «Не сейчас».

| Ключ | ru | en | Примечание |
| --- | --- | --- | --- |
| `onboardingNext` | Далее | Next | шаги 1–2 |
| `onboardingSkip` | Пропустить | Skip | в шапке шагов 1–2, ведёт на шаг 3 |
| `onboardingIntroTitle` | Вернитесь туда, где были | Get back to where you were | шаг 1 |
| `onboardingIntroBody` | Запомните место — парковку, лагерь, точку встречи. Wayback покажет дорогу назад без карты. | Save a spot — where you parked, your camp, a meeting point. Wayback shows the way back, no map needed. | |
| `onboardingHowTitle` | Три простых шага | Three simple steps | шаг 2 |
| `onboardingHowSave` | Сохраните место одним нажатием. | Save a spot with one tap. | пункт 1 |
| `onboardingHowLeave` | Уходите по своим делам. | Go about your day. | пункт 2 |
| `onboardingHowReturn` | Возвращайтесь по стрелке — она покажет направление и расстояние. | Follow the arrow back — it shows direction and distance. | пункт 3 |
| `onboardingHowOffline` | Работает без интернета. Точки хранятся только на телефоне. | Works offline. Your places stay on your phone. | строка под пунктами |
| `onboardingLocationTitle` | Доступ к геолокации | Location access | шаг 3; тот же текст, что `permissionTitle` |
| `onboardingLocationBody` | Без него Wayback не сможет запомнить место и показать дорогу назад. Местоположение нужно, только пока приложение открыто, и остаётся на телефоне. | Without it, Wayback can't save a spot or show the way back. Location is used only while the app is open and stays on your phone. | |
| `onboardingLocationAllow` | Разрешить | Allow | вызывает системный диалог; = `actionAllow` |
| `onboardingLocationLater` | Не сейчас | Not now | без запроса на Home |
| `onboardingProgress` | Шаг {step} из {total} | Step {step} of {total} | подпись индикатора шагов для скринридера |
