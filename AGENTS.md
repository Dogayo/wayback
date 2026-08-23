# Wayback

Wayback is a Flutter application for saving a location and returning to it with GPS and a compass. Product behavior and MVP boundaries live in `README.md`; visual decisions, tokens, and component conventions live in `DESIGN_SYSTEM.md`.

## Repository layout

- `lib/` — application code.
- `test/` — application tests.
- `packages/wayback_design_system/` — reusable Wayback tokens, themes, components, tests, and catalog app.
- `android/` and `ios/` — platform projects; keep generated Flutter files out of commits.
- `.github/workflows/ci.yml` — tag-driven builds and releases.
- `.claude/skills/` — canonical project skills shared with Codex and Cursor through repository symlinks.

## Working conventions

- Keep changes focused on the request and preserve unrelated work in the tree.
- Follow `analysis_options.yaml` and format changed Dart files with `dart format`.
- Reuse `wayback_design_system` tokens and components instead of introducing app-local visual constants or parallel components.
- When changing the design system, keep its public exports in `packages/wayback_design_system/lib/wayback_design_system.dart` current and add or update focused tests.
- Preserve offline-first behavior and the product boundaries documented in `README.md`.
- Do not edit generated Flutter, Gradle, CocoaPods, or Xcode output.

## Validation

Run the narrowest relevant checks first, then the full affected suite:

```bash
flutter analyze
flutter test

cd packages/wayback_design_system
flutter analyze
flutter test
```

If dependencies changed, run `flutter pub get` in each affected package before validation. Report checks that could not be run and why.

## Releases and pull requests

- Releases are tag-driven. The version in `pubspec.yaml`, the `CHANGELOG.md` release heading, and tag `v<version>` must match exactly; see `.github/workflows/ci.yml`.
- Use the repository skills when a request matches them:
  - `wayback-changelog` for changelog entries, versions, or release notes.
  - `wayback-pr-description` for a pull-request description or branch summary.
- Edit skill content only under `.claude/skills/`; `.agents/skills/` and `.cursor/skills/` are linked views of the same files.
