<p align="right"><b>English</b> · <a href="SCREENS.ru.md">Русский</a></p>

# Wayback — screens (v0.3)

> The list of MVP screens: the job, the dominant element, states, transitions.
>
> Sources: [docs/product.md](docs/product.md), [docs/mvp-scope.md](docs/mvp-scope.md), [docs/architecture.md](docs/architecture.md) §6, [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md).
> When this was written, `lib/` had no implemented screens — this document fixes the contract for `feature: points`, `feature: location`, `feature: navigation`, `feature: settings`, rather than describing existing code.
>
> Components and tokens come only from `DESIGN_SYSTEM.md`. Routes are constants in `app/navigation/routes.dart`, with no string literals (see architecture.md §6).
>
> v0.2: added `/points/new`, removed the "one active point" assumption, simplified the arrival state. See §6.
>
> v0.3: added first-launch onboarding `/onboarding` (§1, §2, §3, §4.0).

## 1. Screen list

| # | Route | Screen | Job | Dominant |
| --- | --- | --- | --- | --- |
| 1 | `/` | Home | The list of active points, saving a new point in one action | Save button + list of active points |
| 2 | `/points/new` | Point Create | Name and style a point at the current position | Form: name + icon picker |
| 3 | `/points` | Points List | All saved points, turning activity on and off | List |
| 4a | `/points/:id/share` | Point Share | Pass a point to another person: QR, text, copying coordinates | Name + coordinates + QR |
| 2a | `/import` | Point Import | A point from coordinates or one sent by someone else: always with confirmation | Coordinates + name + icon |
| 4 | `/points/:id` | Point Details | Point details, going to navigation, deleting | Name + point type |
| 5 | `/navigate/:id` | Navigate | Direction and distance to the point in real time | Arrow + distance |
| 6 | `/settings` | Settings | Units, language, vibration | List of settings |
| 0 | `/onboarding` | Onboarding | First launch: why the app exists, how it works, location access | Step illustration + Primary button |

6 routes. The map in architecture.md §6 fixes only 5 — `/points/new` has not been added there yet; sync this file with architecture.md when implementing `feature: points`. Bottom navigation is not used (see DESIGN_SYSTEM.md "Navigation").

**Active point** — a point shown on Home and available for navigation. Several points can be active at once (see §6). "Saved" ≠ "active": every saved point is visible in Points List, but only active ones get onto Home.

---

## 2. Main flow: Save → Walk away → Navigate back

```text
1. Home (/)
   the user is by the car and taps Save current location
   → /points/new, the coordinates are already obtained (current position)

2. Point Create (/points/new)
   enters a name (optional, there is a default) and picks an icon (car)
   taps Save → success feedback, the point is created and becomes active
   → back to Home

3. Home (/)
   the new point appears in the list of active points

4. the user walks away from the point (Walk away — outside the app)

5. Home (/) → Navigate (/navigate/:id)
   tapping the active point in the list opens navigation to exactly that point

6. Navigate (/navigate/:id)
   direction + distance update while moving
   on entering the arrival radius — vibration (once) + the text "{name} is close by" (positive/success green)

7. Navigate → Home (/)
   back after arrival; the point stays active until the user removes it by hand in Points List
```

Before this flow, on the first launch, there is Onboarding (`/onboarding`): three steps, the last one asks for location access; then Home. It is shown once.

An alternative entry into the flow is through the list: `Home → Points List (/points) → Point Details (/points/:id) → Navigate (/navigate/:id)`.

---

## 3. Transition graph

```text
Onboarding (/onboarding)                     first launch only, outside the `/` stack
├── step 1 → step 2 → step 3                 "Next" or a swipe; "back" — to the previous step, from step 1 — exit
├── "Skip" (steps 1–2)                       → step 3
└── "Continue" (step 3) [system dialog]      → / (whatever the answer), onboarding done; without access Home shows a banner

Home (/)
├── Save current location [action]          → /points/new
├── tap an active point (in the list)       → /navigate/:id
├── "All places" / list                     → /points
└── settings                                → /settings

Point Create (/points/new)
├── Save [action]                           → the point is created and active, back to /
└── Cancel / back                           → /, the point is not saved

Points List (/points)
├── back                                    → /
├── tap a point                             → /points/:id
├── + [sheet]                               → /points/new (current location) or /import (by coordinates)
├── swipe left [actions panel]              → activity, rename, delete
├── long press [actions sheet]              → details, rename, activity, delete
├── toggle point activity [action]          → stays on /points, the point appears/disappears in the Home list
│                                              (0..N points can be active at once); turning it off shows an "Undo" snackbar
└── delete a point [confirm dialog]         → stays on /points, the list updates, an "Undo" snackbar

Point Details (/points/:id)
├── back                                    → /points (or / — if opened as a deep link)
├── share [action]                          → /points/:id/share
├── "Navigate"                              → /navigate/:id
├── rename / change icon [action]           → stays on /points/:id
├── toggle activity [action]                → stays on /points/:id
└── delete [confirm dialog]                 → /points

Navigate (/navigate/:id)
├── back                                    → the previous screen in the stack (/ or /points/:id)
└── (no further transitions — the terminal screen of the scenario)

Settings (/settings)
└── back                                    → /
```

A deep link to `/points/:id` must open directly (architecture.md §6) — the navigation stack is then `/points/:id` with "back" to `/`.

---

## 4. Screen states

The criterion from mvp-scope.md §4: every screen has loading / empty / error / content. Below is what each state holds for each screen.

### 4.0 Onboarding (`/onboarding`)

| State | Content |
| --- | --- |
| loading | None of its own: the completion flag is read before the router's first frame |
| empty | Not applicable (the steps are static) |
| error | A failure to write the flag does not block: the transition to Home still happens, and onboarding may show again on the next launch |
| content | A step: illustration · title · text (step 2 — three items and a line about offline and privacy) · step indicator · buttons. Step 1 — a dial that finds the direction by itself. Steps 1–2: "Next" (primary), "Skip" in the header. Step 3: "Continue" (primary), followed right away by the system dialog; the choice is made there. Texts — docs/copy.md §14 |

### 4.1 Home (`/`)

| State | Content |
| --- | --- |
| loading | A skeleton list in place of the active point cards (storage not read yet or position not obtained yet) |
| empty | Two cases on one screen: (a) no saved points at all — icon + text + Primary button Save current location; (b) there are saved points but none is active — text + a "Choose a place" button → `/points` |
| error | A negative Alert — location permission denied, approximate access (`location_precise_required`, a button to turn on precise access) or GPS unavailable; the Save button is unavailable until permission is given |
| content | A list of active point cards (type icon, name, a direction/distance preview on each), each leading to `/navigate/:id`; if there is one active point, a large card with the full dial replaces it. A constant Primary button Save current location: with a good signal it saves right away and shows a snackbar with "Edit" (a sheet with name and type), with a weak signal or no access it opens `/points/new`. The card circle holds an arrow to the point; with an inaccurate compass it is amber; while there is no direction or no compass, the circle holds the type icon. The compass is listened to only while Home is on top and the app is on screen |

### 4.2 Point Create (`/points/new`)

| State | Content |
| --- | --- |
| loading | ProgressIndicator + label until a GPS fix for the new point arrives (coordinates not ready yet, Save unavailable) |
| empty | Not applicable (this is a creation form, not a list) |
| error | A negative Alert — GPS unavailable / permission revoked between Home and this screen / approximate access (a button to turn on precise access); Save unavailable, Cancel available |
| content | Form: name (`AppTextField`, has a default, optional), icon picker (a 4×2 grid from DESIGN_SYSTEM.md), coordinates and accuracy preview, Save (primary) / Cancel (tertiary) buttons |

### 4.3 Points List (`/points`)

| State | Content |
| --- | --- |
| loading | A skeleton list (3–5 `AppListItem` placeholders) |
| empty | Icon + "No saved places" + text + Primary button Save current location (→ `/points/new`) |
| error | A negative Alert by `failure.code` (for example `points_storage_read_failed`) + retry |
| content | An `AppListItem` per point (type icon · name · distance hint · activity switch/indicator), handling 0…100+ entries without degrading; 0..N can be active at once |

### 4.4 Point Details (`/points/:id`)

| State | Content |
| --- | --- |
| loading | A skeleton in place of the title and coordinates |
| empty | Not applicable to this screen (the point either exists or it is an error) |
| error | Point not found (`points_not_found`, for example after a deep link to a deleted point) — a negative Alert + a "Back to places" button |
| content | Type icon · name · coordinates · save date · activity flag · Navigate / Edit (a sheet with name and type) / Delete buttons |

### 4.5 Navigate (`/navigate/:id`)

| State | Content |
| --- | --- |
| loading | `WbDirectionSearching` + label until the first GPS fix and the first compass reading arrive |
| empty | Not applicable (the screen is always tied to a specific point) |
| error | A dial with an icon, a title and text by `failure.code`, a button at the bottom: `location_permission_denied` / `location_precise_required` (a button to turn on precise access) / GPS unavailable — direction and distance are not shown as valid, an honest error instead of zeros. No compass is not a screen error: the distance stays together with a negative `WbAlertRow`, and an icon replaces the arrow |
| content | `WbDirectionDial`: the arrow (interpolated `arrowRotation`) and an error beam as wide as the compass accuracy + distance (`WbDistanceValue`) + GPS accuracy (`±N m`). Warnings are a `WbAlertRow` in an area reserved for two lines, so the arrow does not shift. On entering the arrival radius — a separate full-screen state: `WbArrivalDial` with the point type icon and a pointer on the ring, "{name} is close by", a large distance and accuracy (the point may not be visible yet, so the text does not promise an exact hit), plus one vibration at the moment of entering from outside; opening the screen inside the radius does not count as arrival. The point is not deactivated automatically. On Android the background navigation notification works together with the screen (mvp-scope.md §2.8). |
| screen | While Navigate is open, the display does not go off: the arrow has to be visible without touching |

### 4.6 Settings (`/settings`)

| State | Content |
| --- | --- |
| loading | A skeleton list of sections (values are read from local storage) |
| empty | Not applicable (the list of settings is static and does not depend on user data) |
| error | A negative Alert on a settings read/write failure (`settings_storage_failed`, texts — docs/copy.md §11.2) |
| content | Groups labelled "Units", "Language", "Vibration", "Diagnostics"; `WbListItem` rows and switches of the same height, all with a 16dp inset, the chosen language marked with a check. Inside: units, language, vibrate on arrival, "Vibration type" (only with vibration on; leads to `/settings/vibration` with a list of options and a "Test" button), "Send log" (the system share sheet, a file without coordinates) |

---

## 5. Point model

`SavedPoint` (mvp-scope.md §2.2) gets an extra activity field:

```text
id, name, type, latitude, longitude, altitude?, createdAt, isActive
```

`isActive` is an independent flag per point, not an index/reference to "the only active one". It is toggled from Points List and Point Details; `true` by default right after creation in Point Create.

---

## 6. Decisions on the open questions of v0.1

Answers received; they update §1–§4 of this document:

1. **Creating a point is a separate screen.** `/points/new` is added: Save current location on Home opens a form (name + icon) over the already obtained coordinates instead of creating the point instantly.
2. **Several points can be active.** Home shows a list of active points, not a single card; activity is an independent flag on each point, toggled in Points List / Point Details.
3. **The arrival state is a separate screen mode** (revised in the navigation redesign; it used to be "text only"): a full-screen field, the point icon with a pointer on the ring, "{name} is close by", a large distance (wave 2 replaced the check mark and "You're here": the check mark promised a precision that a ~20 m radius does not have). The text had to be readable at arm's length, and within a ~20 m radius the point may not be visible yet. The vibration (`mediumImpact`, once) stays as it is per mvp-scope.md §2.4.

### Remaining open questions

- whether there should be an upper limit on the number of simultaneously active points (the list on Home may grow) — not set;
- `architecture.md` §6 is not yet updated with `/points/new` — do it when implementing `feature: points`.
