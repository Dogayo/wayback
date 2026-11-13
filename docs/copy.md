<p align="right"><b>English</b> · <a href="copy.ru.md">Русский</a></p>

# Wayback — interface copy (v0.1)

The single source of user-facing strings for ru and en. The keys are the future ARB keys: the l10n task (#11) moves the tables below into `lib/app/localization/arb/` without rewording.

Screen states — [SCREENS.md](../SCREENS.md) §4, the error code contract — [architecture.md](architecture.md) §4.2.

---

## 1. Voice and rules

- **Short and calm.** The person is outdoors, maybe in the dark and with one hand. One thought per line, no exclamation marks.
- **Formal «вы» in ru**, lower case. In en — a neutral "you", without "please" where it is not a request.
- **Error = what happened + what to do.** Never show a code, a bare "Error" or the technical `description`.
- **A destructive confirmation names the consequence** instead of asking "Are you sure?" (DESIGN_SYSTEM.md "Patterns").
- **Terms:**

  | Concept | ru | en |
  | --- | --- | --- |
  | a saved place | точка | place |
  | the save action | сохранить место | save location |
  | the point we are heading to | активная | active |
  | arrival | вы на месте | you're here |

  In en "point" sounds technical, so the noun is "place". In ru «точка» is already fixed in the documents and short.
- **Quotes:** ru — «guillemets», en — “curly”. An ellipsis is a single `…` character.
- **Numbers and units** — only through the `core/utils` formatters (§9), never by joining strings.

---

## 2. Common actions

| Key | ru | en | Note |
| --- | --- | --- | --- |
| `appTitle` | Wayback | Wayback | not translated |
| `actionSave` | Сохранить | Save | |
| `actionCancel` | Отмена | Cancel | |
| `actionRetry` | Повторить | Try again | under an error Alert |
| `actionDelete` | Удалить | Delete | |
| `actionUndo` | Вернуть | Undo | snackbar with a countdown |
| `actionAllow` | Разрешить | Allow | permission request |
| `actionOpenSettings` | Открыть настройки | Open settings | the phone's system settings |
| `actionEnablePreciseLocation` | Включить точную геолокацию | Turn on precise location | system dialog, then the app settings |

## 3. Home (`/`)

| Key | ru | en | Note |
| --- | --- | --- | --- |
| `homeTitle` | Wayback | Wayback | |
| `homeSaveLocation` | Сохранить место | Save location | Primary button, always visible |
| `homeAllPoints` | Все точки | All places | |
| `homeSettingsTooltip` | Настройки | Settings | icon in the header |
| `homeEmptyTitle` | Пока нет точек | No places yet | empty (a): no points at all |
| `homeEmptyBody` | Сохраните место, куда хотите вернуться, — например, где оставили машину. | Save a spot you want to return to, like where you parked. | |
| `homeNoActiveTitle` | На главной пока пусто | Nothing on Home yet | empty (b): there are points, none active |
| `homeNoActiveBody` | Выберите, к каким точкам сейчас идёте. | Choose the places you're heading to. | |
| `homeNoActiveAction` | Выбрать точку | Choose a place | → `/points` |
| `homePointSemantics` | {name}, {distance} | {name}, {distance} | card label for the screen reader |

## 4. Point Create (`/points/new`)

| Key | ru | en | Note |
| --- | --- | --- | --- |
| `pointCreateTitle` | Новая точка | New place | |
| `pointCreateLocating` | Определяем местоположение… | Getting your location… | loading, Save unavailable |
| `pointNameLabel` | Название | Name | |
| `pointNameHelper` | Можно оставить как есть | Optional | under the field, the default is already filled in (§7) |
| `pointActionShare` | Поделиться | Share | actions sheet, button in details |
| `pointShareTitle` | Поделиться | Share | screen title |
| `pointShareQrHint` | Наведите камеру другого телефона на код | Point another phone’s camera at the code | |
| `pointShareQrLabel` | QR-код точки | QR code of this place | for the screen reader |
| `pointShareSend` | Отправить | Send | the system share sheet |
| `pointShareCopy` | Скопировать координаты | Copy coordinates | |
| `pointCoordinatesCopied` | Координаты скопированы | Coordinates copied | snackbar |
| `pointImportTitle` | По координатам | By coordinates | screen title |
| `pointImportDistance` | До точки | Distance | |
| `pointCoordinatesHint` | 56.50353, 85.03131 | 56.50353, 85.03131 | hint in an empty field |
| `pointCoordinatesHelper` | Числа, градусы или ссылка на карту | Numbers, degrees or a map link | |
| `pointCoordinatesPaste` | Вставить | Paste | |
| `pointCoordinatesRead` | Широта {latitude}, долгота {longitude} | Latitude {latitude}, longitude {longitude} | how the app understood the input |
| `pointCoordinatesInvalid` | Не удалось распознать координаты | Could not read these coordinates | |
| `pointImpreciseTitle` | Координаты неточные | Rough coordinates | |
| `pointImpreciseBody` | Мало знаков после запятой: точка может быть смещена на сотни метров и больше. | Too few decimals: the place may be off by hundreds of meters or more. | |
| `pointNearbyTitle` | Рядом уже есть «{name}» | “{name}” is right here | |
| `pointNearbyBody` | До неё {distance}. Сохранить всё равно можно. | {distance} away. You can still save this one. | |
| `pointAddTitle` | Новая точка | New place | the "+" sheet |
| `pointAddSubtitle` | Как задать место | How to set it | |
| `pointAddCurrent` | Текущее место | Current location | |
| `pointAddByCoordinates` | По координатам | By coordinates | |
| `pointNameRequired` | Введите название | Enter a name | error in the rename dialog; names are up to 40 characters |
| `pointTypeLabel` | Иконка | Icon | title of the 4×2 picker |
| `pointCoordinatesLabel` | Координаты | Coordinates | coordinates preview; the same label in the details card |
| `pointAccuracy` | Точность {accuracy} | Accuracy {accuracy} | `{accuracy}` = `±8 m`, §9 |
| `pointSavedSnackbar` | Точка «{name}» сохранена | “{name}” saved | snackbar after saving from the form |
| `pointQuickSavedSnackbar` | {name} сохранена | {name} saved | snackbar after a one-tap save, with `actionEdit` |
| `pointEditTitle` | Изменить точку | Edit place | sheet title |
| `actionEdit` | Изменить | Edit | snackbar button |

## 5. Points List (`/points`)

| Key | ru | en | Note |
| --- | --- | --- | --- |
| `pointsListTitle` | Точки | Places | |
| `pointsAddTooltip` | Новая точка | New place | "+" icon in the header |
| `pointsEmptyTitle` | Нет сохранённых точек | No saved places | |
| `pointsEmptyBody` | Сохраните первое место — стрелка приведёт вас обратно. | Save your first place and the arrow will lead you back. | |
| `pointActiveLabel` | На главной | On Home | switch label on the point screen |
| `pointHiddenLabel` | Скрыта | Hidden | badge in the list, only on points not on Home |
| `pointActiveToggleSemantics` | Показывать на главном экране | Show on home screen | Switch label for the screen reader |
| `pointsListSubtitle` | {distance} · сохранено {when} | {distance} · saved {when} | list row subtitle: `640 m · saved 12 min ago` |

**When saved** (`{when}`) — relative time, by the age of the point:

| Key | ru | en | When |
| --- | --- | --- | --- |
| `timeJustNow` | только что | just now | under a minute |
| `timeMinutesAgo` | {n} мин назад | {n} min ago | under an hour |
| `timeHoursAgo` | {n} ч назад | {n} h ago | today |
| `timeYesterday` | вчера | yesterday | yesterday in local time |
| — | `2 нояб.` | `Nov 2` | earlier: a date through `intl` (`d MMM`), no year within the current year |

## 6. Point Details (`/points/:id`)

| Key | ru | en | Note |
| --- | --- | --- | --- |
| `pointDetailsTitle` | Точка | Place | fallback title, usually the point name |
| `pointDistanceFromYou` | {distance} от вас | {distance} away | under the point name |
| `pointSavedAt` | Сохранена {date} | Saved {date} | `{date}` — local date and time format; for a single line |
| `pointSavedLabel` | Сохранена | Saved | row label in the details card, the date goes on a separate line |
| `pointNavigate` | Вести к точке | Navigate | Primary |
| `pointDeleteTitle` | Удалить «{name}»? | Delete “{name}”? | confirmation dialog |
| `pointDeleteBody` | Точка пропадёт из списка и с главного экрана. | It will disappear from your list and home screen. | the named consequence; it can be undone from the snackbar |
| `pointDeletedSnackbar` | Точка «{name}» удалена | “{name}” deleted | |
| `pointDeactivatedSnackbar` | «{name}» убрана с главной | “{name}” removed from Home | snackbar with a countdown and `actionUndo` |
| `pointActionDetails` | Подробнее | Details | actions sheet |
| `pointActionDeactivate` | Убрать с главной | Remove from Home | actions sheet |
| `pointActionActivate` | Показать на главной | Show on Home | actions sheet |
| `pointSwipeDeactivate` | Убрать | Remove | swipe panel button, 88 dp |
| `pointSwipeActivate` | На главную | To Home | swipe panel button, 88 dp |
| `pointBackToList` | К списку точек | Back to places | under the `points_not_found` error |

## 7. Point types and the default name

| Key | ru | en | Type (`WbPointType`) |
| --- | --- | --- | --- |
| `pointTypeCar` | Машина | Car | `car` |
| `pointTypeTent` | Лагерь | Camp | `tent` |
| `pointTypeFishing` | Рыбалка | Fishing | `fishing` |
| `pointTypeBackpack` | Вещи | Gear | `backpack` |
| `pointTypeHouse` | Домик | Cabin | `house` |
| `pointTypeMeeting` | Встреча | Meetup | `meeting` |
| `pointTypeParking` | Парковка | Parking | `parking` |
| `pointTypeGeneric` | Точка | Place | `generic`, selected by default |
| `pointDefaultNameNumbered` | {type} {number} | {type} {number} | `Car 2` if the name is taken |

**The default name** is the label of the chosen type: "Place", and after picking the car icon — "Car". If a point with that name already exists, a number is added: "Car 2", "Car 3". While the user has not edited the field, the name follows the chosen icon; after a manual edit it does not.

The name is saved in the locale the point was created in and is not translated when the language changes: it is user data by then.

## 8. Navigate (`/navigate/:id`)

| Key | ru | en | Note |
| --- | --- | --- | --- |
| `navigateTitle` | Навигация | Navigate | fallback title, usually the point name |
| `navigateLocating` | Ждём GPS и компас… | Waiting for GPS and compass… | loading until the first fix and compass reading |
| `navigateArrived` | {name} где‑то рядом | {name} is close by | arrival title; a non-breaking hyphen U+2011 keeps «где‑то» from breaking |
| `navigateCompassCalibrationTitle` | Компас неточен | Compass is off | `WbAlertRow` warning, the arrow stays |
| `navigateCompassCalibrationBody` | поводите восьмёркой | move in a figure eight | continues the line after the colon |
| `navigateWeakSignalTitle` | Слабый GPS | Weak GPS | `WbAlertRow` warning on the navigation screen |
| `navigateWeakSignalBody` | расстояние неточно | distance may be off | continues the line after the colon |
| `navigateCompassDistanceOnly` | только расстояние | distance only | continues the "No compass" line |
| `navigateDirection` | Направление на точку, {degrees} градусов | Direction to the point, {degrees} degrees | for the screen reader |
| `navigateDirectionApproximate` | Примерное направление на точку, {degrees} градусов | Approximate direction to the point, {degrees} degrees | for the screen reader, compass is off |
| `pointDirectionApproximate` | Направление примерное | Approximate direction | for the screen reader, card on Home, compass is off |
| `navigateWeakSignal` | Слабый сигнал GPS — расстояние может быть неточным. | Weak GPS signal — distance may be off. | warning Alert, with poor accuracy |
| `navigateSemantics` | До «{name}» {distance} | {distance} to “{name}” | live region, announced with throttling |
| `navigateNotificationStop` | Завершить навигацию | End navigation | button on the background navigation notification, closes navigation |
| `navigateArrivedNotice` | Где‑то рядом | Close by | notification text on arrival, under the point name in the title |
| `navigateNotificationChannel` | Навигация | Navigation | notification channel name in Android settings |

The background navigation notification (mvp-scope.md §2.8): the title is the point name, the text is the distance per §9 or `navigateArrivedNotice`, the button is `navigateNotificationStop`. Tapping the notification returns to the app on the navigation screen: the notification lives only while that screen is open.

## 9. Distance and accuracy

| Key | ru | en | Example ru / en |
| --- | --- | --- | --- |
| `distanceMeters` | {value} м | {value} m | `850 м` / `850 m` |
| `distanceKilometers` | {value} км | {value} km | `1,2 км` / `1.2 km` |
| `accuracyValue` | ±{value} м | ±{value} m | `±8 м` / `±8 m` |
| `distanceUnknown` | — | — | distance while there is no position |
| `distanceFeet` | {value} фт | {value} ft | `420 фт` / `420 ft` |
| `distanceMiles` | {value} ми | {value} mi | `1,4 ми` / `1.4 mi` |
| `accuracyValueFeet` | ±{value} фт | ±{value} ft | `±26 фт` / `±26 ft` |

**Metric** (default):

- Up to 1000 m — whole metres, further on — kilometres with one decimal (mvp-scope.md §2.3). Rounding happens before the unit is picked: 999.6 m → `1.0 km`.

**Feet and miles** (the "Feet & miles" setting):

- Up to 0.1 mile (528 ft) — whole feet, further on — miles with one decimal: `420 ft`, `0.1 mi`, `1.4 mi`. The 0.1-mile threshold is the usual one for navigators in imperial units: beyond it feet become three- or four-digit numbers that are hard to read on the move.
- Rounding also happens before the unit is picked: 527.8 ft → `0.1 mi`.
- Implemented in the `core/utils` formatter (`formatDistance`, `formatAccuracy` with `UnitSystem`).

**Common:**

- ru: decimal comma, thousands separated by a non-breaking space (`1 234,5 км`); en: point and comma (`1,234.5 km`).
- A non-breaking space between the number and the unit, so that `850` and `m` do not end up on different lines.
- Accuracy is always whole metres or feet, never switching to kilometres or miles.
- Abbreviations: in ru «фт» and «ми» without a period — like «м» and «км».

## 10. Settings (`/settings`)

| Key | ru | en | Note |
| --- | --- | --- | --- |
| `settingsTitle` | Настройки | Settings | |
| `settingsUnits` | Единицы измерения | Units | |
| `settingsUnitsMetric` | Метры и километры | Meters & kilometers | |
| `settingsUnitsImperial` | Футы и мили | Feet & miles | |
| `settingsLanguage` | Язык | Language | |
| `settingsLanguageSystem` | Как в системе | System default | |
| `settingsLanguageRu` | Русский | Русский | endonym, the same in both locales |
| `settingsLanguageEn` | English | English | endonym |
| `settingsThemeToggle` | Сменить тему | Switch theme | app bar icon: the sun in the light theme, the moon in the dark one |
| `settingsVibration` | Вибрация при прибытии | Vibrate on arrival | Switch |
| `settingsTouchFeedback` | Отклик при нажатиях | Haptic feedback | Switch, on by default |
| `settingsVibrationPattern` | Вид вибрации | Vibration type | ListItem, screen title |
| `settingsVibrationPatternHint` | Выберите вибрацию, которую хорошо чувствуете на своём телефоне | Pick a vibration you can clearly feel on your phone | Hint |
| `settingsVibrationStandard` | Обычная | Standard | ListItem |
| `settingsVibrationLong` | Длинная | Long | ListItem |
| `settingsVibrationTwice` | Двойная | Double | ListItem |
| `settingsVibrationStrong` | Сильная | Strong | ListItem |
| `settingsVibrationTest` | Проверить | Test | Button |
| `settingsSendLog` | Отправить журнал | Send log | opens the share sheet |
| `settingsSendLogHint` | Для разбора ошибок, без координат | To look into problems, no coordinates | item caption |
| `diagnosticsShareSubject` | Журнал Wayback | Wayback log | email subject |

## 11. Permissions and errors

### 11.1 Permission request

| Key | ru | en | Note |
| --- | --- | --- | --- |
| `permissionTitle` | Доступ к геолокации | Location access | explainer screen before the system dialog |
| `permissionBody` | Wayback запоминает, где вы были, и показывает дорогу обратно. Данные остаются на телефоне. | Wayback remembers where you've been and shows the way back. Your data stays on your phone. | the explainer screen before the system dialog; the iOS `NSLocationWhenInUseUsageDescription` is a longer string of its own, see below |
| `iosLocationUsage` | Wayback запоминает, где вы были, и показывает дорогу обратно. Пока открыта навигация, он следит за расстоянием и с погашенным экраном. Данные остаются на телефоне. | Wayback remembers where you've been and shows the way back. While navigation is open it keeps following the distance with the screen off. Your data stays on your phone. | `NSLocationWhenInUseUsageDescription`; lives in `ios/Runner/Info.plist` and the `InfoPlist.strings`, not in the ARB |

### 11.2 Errors by code

An error is shown with the Alert component: a short **title** (what happened) and a **body** (why it matters or what to do). The keys are `error_<code>` for the title and `error_<code>_body` for the body; the action is a separate button.

The title is up to ~30 characters, with no period at the end. The body is one sentence with a period. The body can be left out where space is tight (Snackbar): the title is clear on its own.

**ru**

| Code | Title | Body | Action |
| --- | --- | --- | --- |
| `generic` | Что-то пошло не так | Попробуйте ещё раз. | Повторить |
| `location_permission_denied` | Нет доступа к геолокации | Без него Wayback не знает, где вы. | Разрешить |
| `location_permission_denied_forever` | Доступ к геолокации запрещён | Включите его в настройках телефона. | Открыть настройки |
| `location_service_disabled` | Геолокация выключена | Включите её, чтобы сохранять и находить точки. | Открыть настройки |
| `location_unavailable` | Не получается определить, где вы | Выйдите на открытое место. | Повторить |
| `location_precise_required` | Нужна точная геолокация | С приблизительной дорогу назад не показать. | Включить точную геолокацию |
| `navigation_compass_unavailable` | Компас недоступен | На этом телефоне нет компаса, поэтому направление не показать. | — |
| `points_storage_read_failed` | Не удалось загрузить точки | Попробуйте ещё раз. | Повторить |
| `points_storage_write_failed` | Не удалось сохранить точку | Попробуйте ещё раз. | Повторить |
| `points_not_found` | Точка не найдена | Возможно, её удалили. | К списку точек |
| `settings_storage_failed` | Не удалось сохранить настройки | Попробуйте ещё раз. | Повторить |
| `diagnostics_export_failed` | Не удалось подготовить журнал | Попробуйте ещё раз. | — |
| `point_share_failed` | Не удалось поделиться точкой | Попробуйте ещё раз. | — |

**en**

| Code | Title | Body |
| --- | --- | --- |
| `generic` | Something went wrong | Try again. |
| `location_permission_denied` | No location access | Wayback needs it to know where you are. |
| `location_permission_denied_forever` | Location access is blocked | Turn it on in your phone settings. |
| `location_service_disabled` | Location is off | Turn it on to save and find places. |
| `location_unavailable` | Can't find your location | Try moving into the open. |
| `location_precise_required` | Precise location needed | Approximate location can't show the way back. |
| `navigation_compass_unavailable` | No compass | This phone has no compass, so direction can't be shown. |
| `points_storage_read_failed` | Couldn't load your places | Try again. |
| `points_storage_write_failed` | Couldn't save the place | Try again. |
| `points_not_found` | Place not found | It may have been deleted. |
| `settings_storage_failed` | Couldn't save settings | Try again. |
| `diagnostics_export_failed` | Couldn't prepare the log | Try again. |
| `point_share_failed` | Couldn't share this place | Try again. |

The `error_generic` / `error_generic_body` pair is shown for any code without a translation; the code itself is logged (architecture.md §4.2).

Settings have their own code, `settings_storage_failed`, rather than `points_storage_write_failed`: otherwise the settings error text would talk about places.

---

## 12. String length

Counted from the tables above (characters without placeholders, 75 pairs): in total ru is **14%** longer than en, but short labels differ much more.

The largest ru/en ratio is in one-line labels:

| Key | ru | en | ru/en |
| --- | --- | --- | --- |
| `settingsUnits` | 17 | 5 | 3.4× |
| `pointNameHelper` | 23 | 8 | 2.9× |
| `actionSave` | 9 | 4 | 2.3× |
| `pointSavedSnackbar` | 18 | 8 | 2.3× |
| `pointNavigate` | 13 | 8 | 1.6× |

The longest ru strings are multi-line blocks:

| Key | ru, characters |
| --- | --- |
| `permissionBody` | 90 |
| `homeEmptyBody` | 72 |
| `pointDeleteBody` | 70 |
| `error_location_service_disabled` | 68 |
| `error_location_permission_denied_forever` | 65 |

Takeaways for layout:

- **Size buttons, headers and `ListItem` for ru**, not en: a 2–3× difference on short labels eats up all the room left for en. The longest one-line ru labels are «Открыть настройки» (17), «Единицы измерения» (17), «Вибрация при прибытии» (21).
- **Error, empty-state and warning texts** are multi-line blocks of up to 90 characters; wrapping is expected, so lay them out without a fixed height.
- Text scale up to 200% (DESIGN_SYSTEM.md "Accessibility"): buttons with a long ru label have to wrap the text, not truncate it.

## 13. Decisions and what follows from them

- **The en term is "place"**, not "point".
- **Feet and miles** — both, switching to miles from 0.1 mile (§9). The formatter is extended in settings (#15).
- **The settings error code is `settings_storage_failed`** (§11.2); SCREENS.md §4.6 is updated.
- **Point type labels** come from the `pointType*` keys, not from `WbPointType.label` in the design system, where they are hard-coded in Russian. Switch over in l10n (#11).
- **Onboarding is three steps, with one button on the access step** (§14): the step explains why location is needed, and "Continue" opens the system dialog where the choice is made. The button does not say "Allow" and offers no refusal before the dialog: that is what Apple HIG advises. A refusal does not block the app.
- **Weak signal and calibration** are warnings, not errors: their keys have no `error_` prefix, and the "poor accuracy" threshold is set in navigation (#14).

## 14. Onboarding (`/onboarding`)

Three steps on the first launch (SCREENS.md §4.0). Step 3 comes before the system dialog; the banner on Home (§11.1) stays for those who refused in the system dialog.

| Key | ru | en | Note |
| --- | --- | --- | --- |
| `onboardingNext` | Далее | Next | steps 1–2 |
| `onboardingSkip` | Пропустить | Skip | in the header of steps 1–2, leads to step 3 |
| `onboardingIntroTitle` | Вернитесь туда, где были | Get back to where you were | step 1 |
| `onboardingIntroBody` | Запомните место — парковку, лагерь, точку встречи. Wayback покажет дорогу назад без карты. | Save a spot — where you parked, your camp, a meeting point. Wayback shows the way back, no map needed. | |
| `onboardingHowTitle` | Три простых шага | Three simple steps | step 2 |
| `onboardingHowSave` | Сохраните место одним нажатием. | Save a spot with one tap. | item 1 |
| `onboardingHowLeave` | Уходите по своим делам. | Go about your day. | item 2 |
| `onboardingHowReturn` | Возвращайтесь по стрелке — она покажет направление и расстояние. | Follow the arrow back — it shows direction and distance. | item 3 |
| `onboardingHowOffline` | Работает без интернета. Точки хранятся только на телефоне. | Works offline. Your places stay on your phone. | line under the items |
| `onboardingLocationTitle` | Доступ к геолокации | Location access | step 3; the same text as `permissionTitle` |
| `onboardingLocationBody` | Без него Wayback не сможет запомнить место и показать дорогу назад. Местоположение нужно, только пока приложение открыто или идёт навигация, и остаётся на телефоне. Выберите точное местоположение — с приблизительным дорога назад не сработает. | Without it, Wayback can't save a spot or show the way back. Location is used only while the app is open or navigating and stays on your phone. Choose precise location — the way back won't work with approximate. | |
| `onboardingLocationContinue` | Продолжить | Continue | opens the system dialog |
| `onboardingProgress` | Шаг {step} из {total} | Step {step} of {total} | step indicator label for the screen reader |
