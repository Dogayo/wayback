# Wayback — design system

> Save a place. Find your way back.

Wayback is a Flutter mobile app (iOS + Android) for saving your current GPS position and
walking back to it later. It shows **direction and distance**, not a route: you leave the
car at the edge of a forest, save the spot, walk away, and later open the app to see
`← 640 м до машины`. There is no map, no account, no backend, and the core scenario works
in airplane mode.

The whole product is one app. There is no marketing site, docs site or web app in the
sources — so this system has exactly one UI kit.

## Sources this system was built from

| Source | What was taken from it |
| --- | --- |
| Local codebase `wayback/` (Flutter) | Product scenario, MVP scope, architecture, route map. `lib/app/theme/` is empty and `lib/features/*/view/` has no screens yet — there was no existing visual language in code to preserve. |
| `wayback/README.md`, `docs/mvp-scope.md`, `docs/architecture.md` | Product copy, the eight point types, distance formatting, arrival threshold, accuracy honesty rules. |
| `uploads/DESIGN_SYSTEM.md` (= `wayback/DESIGN_SYSTEM.md`) | The token reference: semantic colours, type scale, spacing, radii, elevation, component inventory, iOS/Android adaptation, Flutter mapping. |
| `uploads/design-system.html` (= `wayback/design/design-system.html`) | The interactive playground. Every exact value in this system (paddings, 14.5px labels, 64dp rows, shadow triplets) was copied from it. |
| GitHub — https://github.com/Dogayo/wayback | Same project, `main` branch. Explore it further before building anything production-facing; `lib/` is still mostly scaffolding, so the playground remains the ground truth. |

**Important framing, inherited from the sources:** the palette, type scale and component
set are a *proposal* made in `DESIGN_SYSTEM.md` ("Точность и инструментальность"), not a
transfer of an existing brand. There is no `BRAND.md`, no shipped app icon and no splash.

## Contents

| Path | What it is |
| --- | --- |
| `styles.css` | The single entry point consumers link. `@import` lines only. |
| `tokens/` | `fonts.css`, `colors.css`, `typography.css`, `spacing.css`, `shape.css`, `elevation.css`, `motion.css`. |
| `components/` | React primitives, grouped: `foundations/`, `actions/`, `forms/`, `content/`, `navigation/`, `wayfinding/`, `feedback/`. |
| `ui_kits/wayback-app/` | Click-through recreation of the app: permission, navigation, points, save sheet, settings. See its own README. |
| `guidelines/` | Foundation specimen cards (colour, type, spacing, shape, motion, brand). |
| `assets/` | `logo.svg` (four-point star mark), `logo-lockup.svg` (mark + wordmark). |
| `SKILL.md` | Agent-skill entry point. |
| `github.md` | Upstream repository association and sync record. |

## Components

Foundations — `Icon`.
Actions — `Button`, `IconButton`.
Forms — `TextField`, `TextArea`, `Checkbox`, `Radio`, `Switch`, `TypePicker` (+ the `POINT_TYPES` set).
Content — `ListItem`, `Card`, `Avatar`, `Badge`, `Chip`, `Divider`.
Navigation — `AppBar`, `BackButton`, `BottomNav`, `SegmentedTabs`.
Wayfinding — `CompassArrow`.
Feedback — `Dialog`, `BottomSheet`, `Snackbar`, `Alert`, `ProgressIndicator`, `Skeleton`.

Each has a sibling `.d.ts` (props contract) and `.prompt.md` (what & when + usage).

**Intentional additions** beyond the source inventory:

- `Icon` — a one-line Material Symbols wrapper. The sources specify the icon set but name
  no component for it; without a wrapper, every consumer hand-rolls SVG, which the system
  forbids.
- `BackButton` — split out of `AppBar` because the source names `AppBackButton` explicitly.
- `CompassArrow` — the sources' own "create, don't extend" example: nothing among the
  primitives models a continuously rotating direction indicator.

`BottomNav` exists because the sources specify it, and is marked unused in MVP (four routes).

## Content fundamentals

**Language.** The product UI is **Russian**. Documentation headings and the tagline are
English ("Save a place. Find your way back."), body prose is Russian. Keep both: an
English label inside the app UI would be off-brand.

**Voice.** Instrumental, second-person plural (`вы`, lowercase), present tense. The app
states facts and consequences; it does not cheer, apologise or explain itself.

- Distance: `640 м`, `1.4 км` — space before the unit, one decimal past a kilometre.
- Accuracy: `Точность GPS ±8 м` — always signed, always with the unit.
- Arrival: `Вы почти у цели — осталось 18 м. Держите это направление.`
- Empty state: `Пока нет сохранённых точек` + `Сохраните место, где вы сейчас стоите — машину, лагерь, любое место, которое захотите найти снова.`
- Destructive confirm: `Удалить «Машина»?` + `Вы потеряете сохранённое местоположение.` — **never** a bare `Вы уверены?`. Name the consequence.
- Buttons are imperative verbs: `Сохранить текущее местоположение`, `Переименовать`, `Готово`, `Удалить`.

**Casing.** Sentence case everywhere in the app — no Title Case, no ALL CAPS except the
uppercase micro-labels above form fields and section headers (11.5px, 600, `0.05em`).
Documentation headings are uppercase in the display face; app headings never are.

**Numbers.** Every readout uses tabular figures so values do not jitter as they update.
Numbers carry the meaning: the subtitle of a list row is allowed to be long, but never
truncated, because the number lives there.

**Errors.** Named cause + what to do: `Нет доступа к геолокации` / `Разрешите доступ в
настройках, чтобы видеть направление.` Never a code, never "что-то пошло не так".

**Emoji.** Not used in the product. (The repo README uses 🚗⛺🎣 in its use-case list, and
the playground uses 📍 as a stand-in glyph — both are documentation artefacts. In UI, a
point type is a Material Symbol, never an emoji.)

**Vibe.** A precision instrument: a hiking altimeter or a machinist's gauge, not a
consumer map app. Quiet until something matters.

## Visual foundations

**Colour.** One warm accent on a cool graphite neutral scale. Neutrals are deliberately
blue-grey at hue 215° (reads as anodised aluminium); brand is orange at 26°, held ~15–20°
away from warning (42°, amber) and negative (4°, red) so status colours never read as
brand. Light and dark are two independent mappings of the same semantic names — a
component reads `surfaceDefault`, it never asks "is this dark mode?". Contrast targets:
4.5:1 body text, 3:1 large text and functional borders. Components use semantic tokens
only; the primitive ramps exist to build them.

**Type.** The app ships **no font**: San Francisco on iOS, Roboto on Android, via Flutter
defaults. This keeps the app genuinely offline and respects each OS's dynamic type. The
one typographic accent is tabular figures on every number. Ten steps of the Flutter
`TextTheme` are in use (56/34/24/20/16 display→title, 16/14 body, 15/13 label, 12 caption);
`displayMedium`, `headlineLarge/Medium`, `titleSmall` and `labelSmall` are deliberately
unassigned. Documentation and marketing surfaces use Big Shoulders Display (uppercase,
condensed) with IBM Plex Sans for prose and IBM Plex Mono for token names.

**Spacing.** 4pt grid, nine steps, `spacingMd` (16) as screen padding and the default gap
between unrelated elements; 12 inside a group, 24 between groups. No value off the scale —
if a layout wants 13px, it wants a different step.

**Shape.** Radii 8 (chips, badges) / 12 (buttons, fields, rows) / 20 (cards, dialogs,
sheets) / 999 (avatars, switch, FAB); Android dialogs are 28. Borders are 1px by default,
2px for focus and selection. Cards: `surfaceElevated` fill, 1px `borderSubtle`, 20px
radius, shadow-1 — border and fill first, shadow second.

**Elevation.** L0 flat → L1 fill only → L2 shadow-1 (cards) → L3 shadow-2 (snackbar,
popover) → L4 shadow-3 + scrim (dialog, sheet). Shadows are secondary on purpose: they
are nearly invisible on a phone screen in direct sun, so hierarchy is carried by fill and
border. Three shadow triplets exist, and dark mode has its own (heavier, black-based).

**Backgrounds.** Flat token fills only. No photography, no illustration, no gradient
washes, no pattern or texture, no full-bleed imagery — the product has no imagery at all
in MVP, and inventing some would be a rebrand. The compass area sits on
`surfaceContainer`; screens are `surfaceDefault`.

**Transparency and blur.** Two uses only: the modal `scrim` (48% ink light / 64% black
dark) and the iOS floating context menu, which sits on an 85% surface with a 6px backdrop
blur. Nothing else is translucent.

**Animation.** Short and functional: 150ms for press and switch, 220ms for sheets and
fades, 320ms for screen transitions. iOS uses `cubic-bezier(.25,.1,.25,1)`, Android
`cubic-bezier(.2,0,0,1)`. No bounce, no spring, no decorative looping motion. The one
continuous animation in the product is the compass arrow, interpolated in small steps and
never allowed to jump through 0/360. Skeletons shimmer at 1.4s. `prefers-reduced-motion`
collapses all durations.

**Hover.** Not a mobile concern; on web recreations, hover is a small tonal shift toward
the pressed colour, never a scale or shadow change.

**Press.** Tonal shift, not scale: primary goes `#C24812 → #9E390D`; text and secondary
actions darken their fill. Nothing shrinks or lifts. Haptics accompany two events only —
`lightImpact` on save, one `mediumImpact` on entering the arrival radius.

**Focus.** A visible 2px ring in `borderFocus` (brand), never suppressed.

**Disabled.** 60% opacity, and always paired with a reason nearby.

**States are never colour alone.** Every status carries a glyph and text as well — a rule
that comes from the product ("honest about accuracy"), not just from accessibility.

**Layout.** One constraint-driven layout, not an artboard. Content caps at ~480dp and
centres on large phones; the compass never goes below 200dp on small ones; vertical rhythm
compresses in `spacingLg` steps before anything clips. Tap targets are ≥44×44dp always,
independent of glyph size. Text scales to 200% without clipping. Fixed elements: the 56dp
app bar at the top and the primary action pinned above the bottom inset.

## Iconography

**Material Symbols Outlined, weight 400, 2dp stroke** — one set on both platforms. It is
loaded as a webfont from Google Fonts in `tokens/fonts.css` and wrapped by `Icon`.

- Sizes: 16 in text · 20 in controls · 24 default · 32 for point-type glyphs · 48 for
  empty states. Visual size ≠ tap target; the target stays ≥44dp.
- Point types use fixed glyphs: `directions_car`, `camping`, `phishing`, `backpack`,
  `cottage`, `group`, `local_parking`, `location_on` — the eight types from MVP scope.
- Never filled, never two-tone, never a custom SVG drawn to look like an icon. The one
  exception is the brand mark itself (`assets/logo.svg`).
- Unicode characters are used for exactly two things, matching the source: the iOS back
  chevron `‹` and the Android back arrow `←`.
- Emoji are never icons in the product.

**Substitutions to be aware of** (see Caveats below): the source repo contains no icon
font, sprite or SVG set, so the glyph names above are Material Symbols names resolved
against Google's CDN. The playground approximated them with hand-drawn 2px-stroke SVGs;
this system uses the real font instead.

## Accessibility

4.5:1 text / 3:1 large text and functional borders · tap targets ≥44×44dp · state never
carried by colour alone · text scaling to 200% without clipping · visible 2dp focus ring ·
`Semantics` labels on every icon-only control · live regions for the continuously updating
distance and bearing (announcement throttling is still an open question upstream).

## Platform adaptation

Brand never diverges; mechanics do. Dialogs (centred, buttons in a row on iOS vs
left-aligned with text buttons bottom-right on Android), sheets (same shape, different
curve), `Switch` geometry, back navigation (edge swipe vs system gesture/button), context
menus (floating menu vs bottom sheet), and status-bar styling. In code, the platform
branch lives *inside* the component, never in the calling screen.

## Caveats and open questions

Carried over from the sources: no map in MVP; how "save location" is triggered (there is
no `/points/new` route); default units by locale or first run; one active point or several;
what happens after arrival; the app icon, splash and permission onboarding are
deliberately unspecified. Font files for San Francisco cannot be shipped, so `--wb-font`
names the system keywords (`-apple-system`, `system-ui`) that resolve to it on Apple
devices and to Roboto on Android.
