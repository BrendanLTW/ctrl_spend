# ctrlSpend (`ctrl_spend`)

Offline-first personal budgeting app in Flutter (iOS and Android). Portfolio project: code quality, architecture, tests and design fidelity matter more than feature count.

## Read first
- `docs/PRD.md`: requirements, screen IDs (S01–S44), acceptance criteria, data model, derived values, design tokens. **The source of truth for behaviour.**
- `docs/PLAN.md`: the task list. Work through it in order.
- `docs/DESIGN.md`: design tokens, component specs, layout patterns, dark mode and the Flutter theme mapping.
- `docs/design/`: exported screens, light and dark, named after the canvas files (e.g. `Dashboard.png`, `Dashboard · Dark.png`). **The source of truth for layout.** If the PRD and a screen disagree, follow the screen and tell me.

Before building a screen, read its section in the PRD and look at both its light and dark designs.

## Scope
- **v1.0** = P0 + P1 requirements in the PRD.
- **v1.1** = P2 (recurring bills, savings goals, app lock). Do not build P2 code, tables or routes unless the current task says so. In v1.0 their Settings rows are hidden.

## Stack
- Flutter stable, Dart 3, null safety
- State: Riverpod with code generation (`riverpod_annotation`, `riverpod_generator`)
- Database: Drift (SQLite), reactive streams, versioned migrations
- Navigation: go_router with a `StatefulShellRoute` for the bottom bar
- Models: freezed + json_serializable
- Charts: fl_chart · Formatting: intl
- Notifications: flutter_local_notifications (P1)
- CSV: `csv` package, file_picker, share_plus (P1)
- Secure storage and biometrics: flutter_secure_storage, local_auth (v1.1 only)
- Testing: flutter_test, mocktail, integration_test
- Lints: very_good_analysis

Check pub.dev for current versions before adding a package. Don't add packages not listed here without asking.

## Architecture
Feature-first, three layers per feature:

```
lib/
  core/
    theme/         # tokens, ThemeData (light + dark), ThemeExtension for semantic colours
    router/        # go_router config, shell with 4 tabs + centre add button
    db/            # Drift database, tables, migrations
    period/        # periodFor() and period helpers (pure Dart)
    money/         # MoneyFormatter, minor-unit helpers (pure Dart)
    widgets/       # shared widgets: MoneyKeypad, AmountText, CategoryTile, BudgetHero,
                   # ProgressBar, ListGroup, SegmentedControl, FilterChips, Toast, EmptyState
  features/
    onboarding/  dashboard/  transactions/  activity/  budgets/  categories/
    insights/  periods/  notifications/  settings/  data_transfer/
    # v1.1: bills/  goals/  app_lock/
      data/          # DAOs, repository implementations
      domain/        # freezed entities, repository interfaces, pure calculations
      presentation/  # screens, widgets, Riverpod controllers
  l10n/
  main.dart
```

Rules:
- Presentation never imports from `data/`; it uses repository interfaces through providers.
- `domain/`, `core/period/` and `core/money/` are pure Dart: no Flutter, no Drift imports.
- Every derived value in PRD §8 (left to spend, category used %, allocated/flexible, daily pace, left after bills, goal monthly need) is a pure function in a `domain/` file with unit tests.
- One widget per file once it passes ~80 lines. Screens are named after the PRD (e.g. `DashboardScreen` for S09).

## Non-negotiable conventions

**Money**
- Store and calculate in integer minor units (`amountMinor`, `limitMinor`). Never `double`.
- Format only at the edge, with `MoneyFormatter`. Large amounts show the cents smaller (RM 1,240**.00**).
- Switching currency changes the symbol only; never convert amounts.

**Periods**
- A period runs from the start day to the day before it next month (15 Oct – 14 Nov). Start day is 1–28 or `last`.
- Always use `periodFor(date, startDay)`. Never compute period bounds inline or use calendar months.
- Dates are stored in UTC and shown in local time.

**Budget thresholds**
- < 80% neutral, 80–99% warning, ≥ 100% negative, plus a "no overall budget" state. Use one shared function for this everywhere (hero, budgets, categories, notifications).
- Colour is always paired with text ("82%", "Over by RM 10").

**Rules from the PRD that are easy to get wrong**
- "Left to spend" = monthly budget − spent. Goal contributions, goal withdrawals and unpaid bills never change it.
- Categories with transactions are archived, never deleted. Archived categories are hidden from pickers but keep their history.
- Category limits can't add up to more than the monthly budget; enforce it in the domain layer.
- CSV import validates every row first and imports all or nothing.
- The PIN (v1.1) lives in secure storage, never in the database.

**UI**
- Use theme tokens only: no hex colours, font sizes or radii hard-coded in widgets. Tokens and component specs are in `docs/DESIGN.md`.
- Every screen works in light and dark.
- Font: Poppins, bundled as an asset (the app must work offline). No runtime font loading.
- Touch targets ≥ 44 px. Text contrast ≥ 4.5:1 in both themes.
- Icon-only buttons get a `Semantics`/tooltip label. Progress bars and charts get a screen-reader label listing their values.
- All user-facing strings go in ARB files. Use the exact copy from the designs and PRD.

**Privacy**
- No network calls, analytics or crash reporting. Data leaves the device only through CSV export.

## Commands
- Install: `flutter pub get`
- Codegen: `dart run build_runner build --delete-conflicting-outputs`
- Analyze: `flutter analyze`
- Test: `flutter test`
- Integration: `flutter test integration_test`
- Run: `flutter run`

## Testing
- Unit tests for every repository, every derived value and `periodFor`. `periodFor` needs exhaustive cases: start days 1, 15, 28 and `last`, February in leap and non-leap years, and 30- and 31-day months.
- Use an in-memory Drift database in tests and an injected clock for anything date-based; never call `DateTime.now()` directly in domain code.
- Widget tests for every screen, in both light and dark themes, covering its PRD acceptance criteria.
- One end-to-end test: onboarding → add expense → dashboard → delete → undo.

## Definition of done
A task is done only when:
1. `flutter analyze` reports no issues.
2. `flutter test` passes, with new tests for the new behaviour.
3. Codegen is up to date.
4. Each screen touched matches its light and dark design in `docs/design/`.
5. The acceptance criteria for the touched PRD section are met.
6. The task is ticked off in `docs/PLAN.md`.
7. Changes are committed with a Conventional Commit message (`feat:`, `fix:`, `test:`, `refactor:`, `chore:`, `docs:`).

## Working style
- One task from `docs/PLAN.md` at a time. Don't start the next one unprompted.
- For anything touching 3+ files, propose a plan first and wait for approval.
- Keep diffs small and focused; don't refactor unrelated code.
- If the PRD, the designs and this file conflict, stop and ask rather than guess.
- Schema changes bump Drift's `schemaVersion` and add a migration step plus a migration test.
- If a package API is uncertain, check its pub.dev docs rather than guessing.

## Git commits
Never add "Co-Authored-By", "Claude-Session", or "Generated with Claude Code" lines to commit messages or PR descriptions.