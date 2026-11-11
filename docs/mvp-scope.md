<p align="right"><b>English</b> · <a href="mvp-scope.ru.md">Русский</a></p>

# MVP Scope

This document describes the state Wayback has to be in to count as ready for the MVP release.

The product requirements come from [product.md](product.md). Here they are turned into criteria that can be checked.

---

## 1. Product goal of the MVP

> The user saves a point, walks away and at any moment gets the direction and distance to it — without the internet.

Anything that does not serve this scenario is not part of the MVP.

---

## 2. Functional scope

### 2.1 Location (`features/location`)

Required:

- request location permission (`whenInUse`), handle denial and "denied forever";
- approximate access (Android 12+, iOS 14+) counts as not enough: the error is in kilometres, so saving and navigation stay unavailable until the user turns on precise access;
- get the current position (latitude, longitude, accuracy, altitude optional);
- subscribe to the stream of position updates during active navigation;
- show the current GPS accuracy (`±N m`);
- an explicit "GPS unavailable / weak signal" state instead of silence or zeros.

Done when: the app handles every permission state correctly and shows accuracy without false confidence.

### 2.2 Saved Points (`features/points`)

Required:

- save the current position in one action from the home screen;
- a point name (optional, with a default);
- a type/icon from a fixed set (car, tent, fishing, bag, house, meeting, parking, generic);
- a list of saved points;
- deleting a point with confirmation;
- choosing the active point;
- a point from coordinates: typing, pasting, parsing map links;
- passing a point on: a QR code on screen and text through the system share sheet; on Android, receiving through "Share → Wayback", and on the first launch the link survives onboarding;
- local persistent storage that survives an app restart.

Point model:

```text
id, name, type, latitude, longitude, altitude?, createdAt
```

Done when: points survive a full app restart and a locale change, and the list does not break at 0 or at 100+ entries.

### 2.3 Navigation (`features/navigation`)

Required:

- distance to the active point (haversine);
- bearing to the point;
- reading the device heading (compass);
- `arrowRotation = bearing - deviceHeading`, the arrow turns smoothly (interpolated, no jerks and no jump across 0/360);
- distance formatting: `< 1000 m` → metres, further on — kilometres with one decimal;
- direction and distance update while moving;
- a warning about unreliable compass data (needs calibration / interference).

Done when: on a real device the arrow keeps pointing at the point while the phone turns, and the values update without freezing.

### 2.4 Arrival

Required:

- an arrival threshold (about 20 m by default, taking the current GPS accuracy into account);
- a visual "you are there" state;
- vibration on entering the radius: opening navigation already inside the radius does not count as arrival, and it vibrates again only after really leaving the radius.

Optional for the MVP: a sound.

### 2.5 Offline

Required:

- the main scenario (saving a point, the list, navigation) works fully in airplane mode;
- no network dependencies on the critical path;
- no backend, no accounts.

Done when: the full Save → Walk away → Navigate back scenario passes in airplane mode.

### 2.6 Onboarding (`features/onboarding`)

Required:

- on the first launch, before the home screen — three steps: why the app exists, how it works, location access;
- the location step explains why access is needed and calls the system dialog only on the "Allow" button;
- access can be postponed ("Not now"): the app is not blocked, and the home screen keeps a banner asking for access;
- onboarding is shown once; the fact that it was completed is stored locally.

Done when: a fresh install opens onboarding, any answer on the location step leads to the home screen, and the next launch goes straight to the home screen.

### 2.7 Diagnostics (`packages/app_logger`)

Required:

- the log is always written, and only on the device: launch, transitions, bloc states, errors and Dart crashes;
- on the navigation screen, once a second — GPS accuracy, heading, bearing, distance, arrival;
- size is bounded by rotation: about 5 MB and 7 days;
- the files live in the app's external directory and can be pulled with `adb`, in the release build too;
- "Send log" in settings opens the system share sheet, only on a user action;
- coordinates are written locally and do not get into the file that is sent. Point names are not written to the log.

It does not catch native Android and iOS crashes; it writes only while the app is open.

Done when: after a walk the log can be read through `adb`, and the sent file contains no coordinates.

### 2.8 Background navigation (Android)

Navigation does not stop when the screen goes off or the app is in the background.

Required:

- starts together with the navigation screen, no separate switch;
- a persistent notification on the lock screen and in the shade: the point name and the distance, on arrival — "Somewhere nearby" under the name; a "Stop navigation" button;
- arrival in the background: vibration by the same setting and the same radius-entry rule (§2.4);
- the "Stop" button on the notification closes navigation; leaving the navigation screen removes the notification;
- after arrival the notification stays until the user stops it;
- only the "while using the app" permission is used: "always" access is not requested;
- a denied notification permission (Android 13+) does not get in the way of on-screen navigation.

Done when: on a real device with the screen locked the distance updates, and entering the radius vibrates.

A Live Activity on iOS is a separate task; on iOS navigation works only while the app is open for now.

---

## 3. Out of MVP scope (Non-Goals)

Not in scope: sign-up, accounts, sync, social features, maps, routing along roads or trails, a server side, a breadcrumb trail, watches and widgets. The diagnostic log (§2.7) is not an export of user data.

See "Future Ideas" in [product.md](product.md) — that is the post-MVP backlog.

---

## 4. Technical done criteria

| Area | Criterion |
| --- | --- |
| Architecture | The `app / core / features/{area}/{data,domain,view}` structure is followed — see [architecture.md](architecture.md) |
| DI | The whole dependency graph is built through `app_di`, no hand-made singletons |
| Navigation | All transitions go through `go_router`, the deep link to a point screen works |
| Localization | Zero hard-coded strings in the UI; ru + en through `l10n`; error codes are localized |
| Errors | The data layer throws `Exception`, domain and view work with a `Failure` that has a code; no unhandled exceptions in the UI |
| Screen states | Every screen has loading / empty / error / content |
| Tests | Unit tests cover distance/bearing/rotation, distance formatting, exception → failure mapping, the points repository |
| Analysis | `flutter analyze` — 0 issues; `dart format` applied |
| CI | The build passes on CI, version and CHANGELOG updated |

---

## 5. Quality and UX criteria

- Saving a point takes no more than one tap from the home screen.
- Direction and distance dominate the navigation screen; everything else is secondary.
- Large elements, high contrast, readable in the sun.
- The app is honest about weak GPS and an uncalibrated compass.
- Cold start to an interactive home screen is under 2 seconds on an average device.
- The navigation screen does not drain the battery abnormally: position and compass subscriptions stop when the screen is left.

---

## 6. Release criteria

- [ ] The Android release build is signed (see [android-signing.md](android-signing.md)).
- [ ] The iOS build builds and runs on a device.
- [ ] Permission strings are filled in (`NSLocationWhenInUseUsageDescription`, Android permissions).
- [ ] The app icon and splash are in place.
- [ ] The app was checked by hand on a real device outdoors, not only in a simulator.
- [ ] The Save → Walk away → Navigate back scenario passed over at least 500 m.

The MVP counts as ready when every item in sections 2, 4 and 6 is done.
