<p align="right"><b>English</b> · <a href="DESIGN_SYSTEM.ru.md">Русский</a></p>

# Wayback — design system (v0.2)

> A reference of tokens and components for generating UI. Live interactive playground (swatches, states, iOS/Android comparison): https://claude.ai/code/artifact/09d490da-bdcd-4b1c-8d18-952afbe307c0. The component catalog runs in the browser: https://dogayo.github.io/wayback/
>
> Sources: `docs/product.md`, `docs/mvp-scope.md`, `docs/architecture.md`. When this was written the repository had no `BRAND.md` / `SCREENS.md` — the palette, typography and components below are a **new decision** ("Precision and instrumentation"), not a transfer of an existing brand.
>
> When generating any screen or widget: use only the tokens and components from this file. If something is missing, extend this file first (a new component variant, a new pattern), then use it on the screen. No arbitrary hex/px values in screen code.

## Principles

1. **Readable in daylight** — contrast and size come first; the app is used outdoors, often in the sun.
2. **Honest about error** — GPS/compass accuracy is shown, not hidden.
3. **One glance — one decision** — the navigation screen answers two questions: where to, and how far is left.
4. **Quiet until it matters** — color, motion and haptics only for meaningful state changes.
5. **One system, two platforms** — the brand is shared, interaction mechanics adapt to iOS/Android.
6. **Every value has a name** — no token → no right to use the value in code.

## Color

Components use **only** the semantic tokens below, never the hex primitives directly.

### Semantic tokens

| Token | Light | Dark | Purpose |
|---|---|---|---|
| `surfaceDefault` | `#FFFFFF` | `#0B0D10` | screen background |
| `surfaceElevated` | `#FFFFFF` | `#1B2025` | cards, dialogs, sheets, snackbar |
| `surfaceContainer` | `#F5F7F9` | `#14181D` | grouped sections, input fields at rest |
| `contentPrimary` | `#1B2025` | `#F5F7F9` | main text, the distance figure |
| `contentSecondary` | `#545F6B` | `#AEB8C2` | secondary text |
| `contentDisabled` | `#AEB8C2` | `#545F6B` | disabled labels (WCAG does not set contrast for them) |
| `contentOnBrand` | `#FFFFFF` | `#FFFFFF` | text/icon on a brand fill |
| `borderDefault` | `#6B7885` | `#6B7885` | functional borders (field outlines) |
| `borderSubtle` | `#DDE2E7` | `#2B3138` | decorative dividers |
| `borderFocus` | `#C24812` | `#F97A2E` | focus ring |
| `actionPrimaryBg` | `#C24812` | `#C24812` | Primary button fill (white text, 4.97:1) |
| `actionPrimaryPressed` | `#9E390D` | `#9E390D` | Primary when pressed |
| `brand500` | `#E2591A` | `#F97A2E` | accent icons, large text/decoration (not for small text) |
| `brand600` | `#C24812` | `#F97A2E` | tertiary text, links |
| `positive` | `#197A4D` | `#34A873` | a good GPS fix, arrival confirmation |
| `positiveBg` | `#E6F4EC` | `#10261C` | positive badge/alert background |
| `warning` | `#8F5B08` (text) | `#E0A030` | weak signal, uncalibrated compass |
| `warningBg` | `#B8790A` | `#B8790A` | warning badge fill (text is `contentPrimary`, 4.51:1) |
| `negative` | `#D53A2E` | `#FF6E5E` | errors, destructive actions |
| `negativeBg` | `#FBE9E7` | `#331410` | negative alert background |
| `scrim` | `rgba(20,24,29,.48)` | `rgba(0,0,0,.64)` | dimming under modals |

Primitives (for building tokens, not for direct use): the neutral scale is a cool blue-grey, hue 215° (`neutral-0…neutral-1000`, from `#FFFFFF` to `#0B0D10`); the brand is orange, hue 26° (`brand-50…brand-900`); status colors — positive 150°, warning 42°, negative 4°. Every text contrast pair is checked against WCAG 2.1 (4.5:1 for text, 3:1 for large text/functional borders) — the full table is in the interactive playground.

## Typography

The font is **native to the platform** (San Francisco on iOS, Roboto on Android through Flutter defaults). The only exception is the number of the main distance figure in `WbDistanceValue`: **Barlow SemiBold** (600, OFL 1.1 license, files in `packages/wayback_design_system/assets/fonts/`). The unit stays native: Barlow has no Cyrillic. Numeric figures use tabular digits (`FontFeature.tabularFigures()`).

| Flutter `TextTheme` | Size/line height | Weight | Use |
|---|---|---|---|
| `displayLarge` | 88/96 | 700 | the main distance figure ("640 m"); the unit is `displaySmall` |
| `displaySmall` | 34/40 | 700 | secondary distance/bearing figures |
| `headlineSmall` | 24/30 | 700 | screen title (point name) |
| `titleLarge` | 20/26 | 600 | dialog/sheet titles |
| `titleMedium` | 16/22 | 600 | app bar title, point name in a list |
| `bodyLarge` | 16/24 | 400 | main text |
| `bodyMedium` | 14/20 | 400 | list item subtitle |
| `labelLarge` | 15/20 | 600 | button text |
| `labelMedium` | 13/18 | 600 | chips, tabs, badges |
| `bodySmall` | 12/16 | 500 | GPS accuracy, helper text |

`displayMedium`, `headlineLarge/Medium`, `titleSmall`, `labelSmall` are not used in the MVP; do not set them arbitrarily.

## Spacing (4pt grid)

`spacing2xs`=4 · `spacingXs`=8 · `spacingSm`=12 · `spacingMd`=16 (base, the default screen padding) · `spacingLg`=20 · `spacingXl`=24 · `spacing2xl`=32 · `spacing3xl`=40 · `spacing4xl`=48.

## Shape and elevation

- Radii: `radiusSm`=8 (chips, badges) · `radiusMd`=12 (buttons, fields, list items) · `radiusLg`=20 (cards, dialogs, sheets) · `radiusFull`=999 (avatars, switch, FAB).
- Borders: `borderThin`=1dp (default) · `borderThick`=2dp (focus, selection).
- Elevation: L0 no shadow (background) → L1 fill only (containers) → L2 `shadow1` (cards) → L3 `shadow2` (snackbar, popover) → L4 `shadow3` + `scrim` (dialog, sheet). Shadow is secondary; hierarchy rests mainly on fill/border (shadows are hard to see in the sun).

## Motion

Tokens — `WbMotion`, mockups — Penpot "01 · Foundations → Motion" and "05 · Motion". Durations: `instant`=100 (press, color of small elements) · `fast`=150 (selection color, text ↔ spinner in a button) · `base`=220 (state change inside a block, height change, tab thumb) · `slow`=320 (opening a screen, arrival) · `slowExit`=250 (closing a screen) · `compassSmoothing`=120 · `shimmer`=1400 · `undoWindow`=5000. Curves: appearing — `easeOut`, disappearing — `accelerate`, motion within a screen — `standard`, iOS — `ios`. No bounce and no spring.

- A duration in a component is always `WbMotion.of(context, …)`: with the system "Remove animations" setting it is zero.
- Screen transitions — `WbPage(transition:)`: `drill` (30dp slide + fade; Home → Settings, All places, Details, Vibration), `modal` (bottom to top over the screen, the one below dims by ~8%; Point create), `enterMode` (scale 0.92 → 1 + fade; entering navigation), `fade` (the old one fades out, then the new one fades in; Onboarding → Home). The incoming screen decides what the screen below does; the screen below fades into `surfaceDefault`, not into black. On iOS `drill` and `enterMode` are the system Cupertino transition with swipe back.
- State changes — `WbStateSwitcher(state:)`: a fade when the kind of state changes (loading / data / empty / error), not on new data; `animateSize` — for blocks that change height; `fadeThroughStart` and `scaleFrom` — for arrival.
- Actions sheet: `slow` / `slowExit`. A swipe follows the finger and, after release, snaps in `base`, `standard`. The snackbar ring is `undoWindow`, `linear`.
- Distance digits, accuracy and the arrow get no extra animation — "quiet until it matters".

## Haptics

Vibration only for a state change and a result: buttons, "back", transitions and scrolling stay silent. So do GPS and compass updates: the phone may be in a pocket. Arrival is a separate setting with its own pattern and is not part of these levels.

| Level | Pulse, ms | What for |
|---|---|---|
| `tick` | 30 | selection: something toggled |
| `press` | 40 | a special gesture worked, something opened |
| `success` | 40 · 60 · 40 | an important action finished |
| `warning` | 70 · 60 · 70 | a refusal or an error |

| Event | Level |
|---|---|
| A long press opened the sheet | `press` |
| A swipe snapped the actions panel | `tick` |
| Tabs, type icon, radio, switch | `tick` |
| A sheet item, the "+" sheet | — (the result gives the feedback) |
| Point saved | `success` |
| Point renamed, made active or inactive | `tick` |
| Deletion confirmed | `press` |
| "Undo" in the snackbar | `tick` |
| The snackbar countdown ran out | — |
| Empty name, coordinates not recognised | `warning` |
| Failed to save, delete, send | `warning` |
| "Copy coordinates" | `tick` |
| Regular buttons, "back", transitions, scrolling | — |
| GPS and compass updates, signal loss | — |

- Android: the pulse goes straight to the vibration motor, because system feedback is silent when "touch vibration" is off (as on Samsung M32 and Redmi). iOS: `HapticFeedback`.
- An action result is listened to only through `ActionResultListener`: it vibrates on success and error itself and shows the error text. A plain `BlocListener` on `ActionState` is forbidden by an architecture test.
- The "Haptic feedback" setting is on by default and does not depend on "Vibrate on arrival".
- No more than one pulse per 50 ms. Durations are tuned on real phones: vibration motors differ a lot.

## Iconography

Material Icons (`Icons.*`), outlined variants — one set on both platforms. Sizes: `iconSm`=16dp (inline in text) · `iconMd`=20dp/44dp target · `iconLg`=24dp/44dp target · `iconXl`=32dp/48dp target (point type glyphs) · `icon2xl`=48dp (empty states). The visual icon size ≠ the tap area — the target is always ≥44×44dp.

**The app icon** is an eight-facet compass rose; sources are in Penpot "04 · App icon" and `assets/launcher/`, and `flutter_launcher_icons` generates the platform files. The Android 13+ themed icon is a monochrome layer: light facets are opaque, shadows are 50% transparent, so the rose stays three-dimensional in a single color. iOS 18: a dark variant on a transparent background (light `brand500` of the dark theme, shadow `actionPrimaryBg`) and a tinted one in greys on black.

## Accessibility

Contrast 4.5:1 (text) / 3:1 (large text, functional borders) · tap area ≥44×44dp always · state is never conveyed by color alone (an icon/text is required) · text scaling up to 200% without clipping (`MediaQuery.textScaler`, flexible container sizes) · a visible focus state (2dp ring) · `Semantics` labels on icon-only elements, a live region for continuously updating values (distance/bearing) — announcement throttling is not designed yet (an open risk).

## Components

**Buttons** (`WbButton(variant, size, icon?, loading, enabled, onPressed)`): `primary` (`actionPrimaryBg` fill) · `secondary` (`borderDefault` outline) · `tertiary` (`brand600` text, no background/border) · `destructive` (`negative` outline, filled only in a confirmation dialog). Sizes: `medium` (44dp), `small` (36dp, dense contexts). States: default / pressed (tonal shift) / focused (ring) / disabled (60% opacity) / loading (a spinner fades in over the label, the button width does not change).

**Inputs**: `WbAnimatedPointIcon(type, active:, playOnAppear:)` — a point type icon with its own short motion (320 ms, once; with "Remove animations" it is in place right away), used by `WbTypePicker` · `WbTextField(maxLength:)` and `WbDialogs.prompt(validator:, maxLength:)` — input stops at the limit, the counter appears at 75% of the limit; a `validator` error shows on confirm, keeps the dialog open and clears on typing · `WbTextField`, `Checkbox`, `Radio`, `Switch` (platform-adaptive), the point type picker (`WbTypePicker`) — a 4×2 icon grid, not a dropdown; the selected tile is filled with `actionPrimaryBg` with `actionPrimaryFg` text, not `brand600`: in the dark theme `brand600` is too light for a white label (2.6:1). Text field states: empty / focused / filled / error (red border + message) / disabled / with a leading icon / with a trailing action / with helper text.

**Content**: `WbQrCode(data)` — the QR is always black on white, with a margin around it, in the dark theme too; up to 285dp · `WbSwipeActions` — a swipe towards the row start reveals 88dp buttons, one row is open at a time, the action itself is not done by the swipe; the screen reader gets the same actions another way · `WbAnimatedItems` — a short list from a stream: it finds rows that left and arrived and collapses and expands them (`base`) · `WbListItem` (a full-width row: leading icon · title · subtitle · trailing element, text 16dp from the edge, height 56dp and 72dp with a subtitle; without a leading icon the title is `bodyLarge`, like a regular setting, with one it is `titleMedium`; `selected` puts a brand check mark instead of the trailing element, with no colored fill; the divider starts under the text; a list holding these rows adds no 16dp of its own on the sides; in the points list the leading element is `WbIconTile(compact: true)`, a 40dp circle, and the "Hidden" badge sits before the chevron only on points not on Home: there are fewer of them, so they get the label), `WbPointCard` (an active point on Home: a circle with a direction arrow · the name with the type icon · distance in `headlineSmall` · chevron; the circle is filled by `direction`, usually `WbPointDirection`: a `brand600` arrow, also with an inaccurate compass, and the type icon without a direction) and `WbPointCardSkeleton` of the same height for loading, `WbPointHeroCard` (the only point on Home: a full dial `dialSize` 240dp, the name, distance as `WbDistanceValue(compact: true)`), `Card`, `Avatar` (the placeholder is the first letter, no photos in the MVP), `Badge`, `Chip` (with a `selected` state), `Divider`.

**Navigation**: a top `WbAppBar` with an adaptive back button (`WbBackButton`), the title right after its 56dp slot; bottom navigation is specified but not used in the MVP (only 4 routes); tabs/segmented control `WbSegmentedTabs`: equal segments in a `segmentTrack` pill 44 high with `md` rounding, the selected one is a `segmentSelected` pill 36 high with `sm` rounding that slides to the new selection (`base`, `standard`), text `labelMedium` 500 `contentPrimary`; the whole segment height takes the tap, and with a large font the labels wrap. In the dark theme the track is lighter than the selection, so the control has tokens of its own. `WbPageDots` — the position in a short sequence of screens (onboarding): the current step is a 24×8 `brand600` pill, the rest are 8×8 `borderSubtle` dots, and the screen reader gets "Step N of M". `WbThemeToggle(dark:, label:, onPressed:)` — an app bar action that switches the theme: the icon shows the theme that is on now (the sun in the light one, the moon in the dark one), a 44×44 tap target, `contentPrimary`. On a change the icons swap through half a turn, a scale from 0.8 and a cross-fade (`base`, `standard`); the tap answers with `tick`, and with "Remove animations" the icons simply swap.

**Direction** (`wayfinding/wb_direction_dial.dart`): `WbDirectionDial(rotation, spread, semanticLabel)` — a `surfaceContainer` dial with a `borderDefault` ring, a fixed `contentPrimary` mark at 12 o'clock (where the phone is pointing), a faceted arrow (`brand500` + `actionPrimaryBg`, like the facets of the app icon; the nose is longer than the tail) and an error beam: `spread` is the beam half-width in degrees, 10–45, and the width itself is the honest display of compass accuracy. With an inaccurate compass the arrow stays brand-colored: the wide beam and the amber banner above the dial speak of the inaccuracy, and only the banner gets a color. `WbDirectionSearching` — the same dial with an arc running along the edge while there is no direction. `WbDirectionIcon(icon)` — a dial with an icon when there will be no direction. `WbDirectionFinding` — the dial finds the direction by itself in 1.6 s, an illustration without sensors. `WbDirectionArrow` — a small single-color arrow. `WbDistanceValue` — the distance: the number in `displayLarge`, the unit in `displaySmall`, `color` for a colored field. `WbArrivalDial(type, rotation)` — arrival: the point type icon in the dial and a pointer on the ring while the direction is known; it appears once in 480 ms (the dial opens with a spring, the icon plays its motion, the pointer moves onto the ring), and with "Remove animations" it is in place right away. `context.wbArrivalColors` — full-screen arrival: a saturated `positive` in the light theme, a muted `positiveBg` in the dark one, so as not to blind at night. `WbAppBar(onField:)` — a bar on top of such a field.

**Illustrations**: `WbIllustration(kind)` — a decorative picture in a `surfaceContainer` circle for explainer screens: `compassRose` (the app mark), `trail` (a point, a dotted path and an arrow back), `location` (the current location with rings). Colors — `brand500`/`brand600`/`contentDisabled`, hidden from the screen reader: the text next to it carries the meaning. Mockups — Penpot "03 · Screens", Onboarding / Step 1–3.

**Feedback**: `WbBottomSheet.show` — a sheet with a form, rises with the keyboard · `WbSnackbar.show(actionLabel:)` — at most one button, disappears by itself · `WbActionSheet.show` — actions on a single object as a bottom sheet on both platforms (icon and title, 56dp rows, the destructive one in red) · `WbUndoSnackbar.show` — a snackbar with a ring and seconds (`undoWindow`=5s) and an undo button; in the background the countdown pauses, and with a screen reader there is no countdown · `WbDialogs.confirm(...)` (platform-adaptive: `CupertinoAlertDialog` / Material `AlertDialog`; with `destructive` the action is red and "Cancel" neutral), `BottomSheet` (grabber + rounded top corners, the same shape on both platforms), `Snackbar`, an inline `Alert` (warning/negative/positive, always icon + text), a one-line `WbAlertRow` ("title: text") for screens read on the move: `WbAlertRow.slotHeight` reserves room for two lines so the content below does not jump, `ProgressIndicator` (determinate/indeterminate), `Skeleton`.

The full state matrix (component × default/pressed/focused/disabled/loading/error/selected) is in the interactive playground, section "State matrix".

## Patterns

Permission request (a platform-specific dialog) · the save-a-point flow (Primary button → Snackbar/confirmation card → optional rename, ≤1 tap) · destructive confirmation (always with the consequence named, never a bare "Are you sure?") · empty state (icon + title + text + Primary button) · error state (negative Alert + text by `failure.code`) · loading state (Skeleton for lists, ProgressIndicator + label for single values) · settings section (title + grouped `ListItem`s).

## iOS / Android adaptation

The brand does not change between platforms; the mechanics do. Key differences: dialogs (centered/no icon, buttons in a row ↔ title on the left, text buttons bottom right), sheets (the same shape, a different animation curve), Switch (`CupertinoSwitch`/`Switch`, recolored to the brand), going back (edge swipe ↔ system gesture/button), system bars (the screen goes under them, the bars are transparent; `WbSystemBars(background:)` picks the icon color, scrolling ends with `context.wbScrollPadding`), haptics (see "Haptics"). The full table with reasons is in the "iOS / Android adaptation" section of the playground.

## Mapping to Flutter

- `ThemeExtension<WaybackColors>` → `app/theme/wayback_colors.dart` (semantic colors, `light`/`dark`).
- `TextTheme` → `app/theme/wayback_text_theme.dart` (the scale above, `fontFamily` not set — the platform default).
- `ThemeExtension<WaybackTokens>` or `static const` → `app/theme/wayback_tokens.dart` (spacing/radius/elevation — independent of the theme).
- `ColorScheme` in `app/theme/app_theme.dart` is filled explicitly from the semantic tokens (no `ColorScheme.fromSeed`), so that third-party Material widgets inherit the brand.
- Components are widgets in `packages/wayback_design_system`; they read tokens through `context.wbColors` / `Theme.of(context).textTheme`, and platform branching (`Theme.of(context).platform`) is hidden inside the component, not in the calling screen.
- Consistent with `docs/architecture.md`: `core` does not import `features`, so every component is available to any screen without breaking the dependency rule.
