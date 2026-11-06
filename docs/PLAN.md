# ctrlSpend — Build Plan

Work top to bottom. Each task is sized for one Claude Code session and follows the definition of done in `CLAUDE.md`.

- Run `/next` to pick up the first unchecked task, or paste a task as a prompt.
- Run `/clear` between tasks.
- **Refs** point to screen IDs and sections in `docs/PRD.md` (`PRD §5.2`) and `docs/DESIGN.md` (`DESIGN §7`).
- Tasks in Phases 0–4 build **v1.0** (P0 + P1). Phase 5 is **v1.1** (P2). Do not start Phase 5 until v1.0 is released.

---

## Before you start (you, not Claude Code)

- [ ] Create the GitHub repo `ctrl_spend` and add `CLAUDE.md`, `.claude/commands/`, `docs/PRD.md`, `docs/DESIGN.md` and this file.
- [ ] Export every canvas artboard to `docs/design/` as PNG, named after its file (`Dashboard.png`, `Dashboard · Dark.png`, …).
- [ ] Add the name step (`OnbName` + `OnbNameDark`) to the canvas and export it.
- [ ] Update the canvas: Add income shows Salary and Gifts; onboarding steps read "of 5"; the brand board's splash footer reads "by BrendanLTW".

---

## Phase 0 — Foundation

- [x] **0.1 Project setup.** Create the Flutter project `ctrl_spend` (android, ios). Add the v1.0 packages from `CLAUDE.md` (not the v1.1 ones), set up very_good_analysis, and make `flutter analyze` and `flutter test` pass on the template.
  Refs: CLAUDE.md Stack
- [x] **0.2 Folder structure and routing.** Create the `core/` and `features/` folders from `CLAUDE.md`. Set up go_router with a `StatefulShellRoute` for Home, Activity, Budgets and Insights (placeholder screens), plus routes for Add transaction, Settings and Onboarding. Add an onboarding redirect driven by a placeholder provider.
  Refs: PRD §4, DESIGN §6
- [x] **0.3 Colour tokens.** Build `AppColors` as a `ThemeExtension` with every token in DESIGN §3.1–3.2 for light and dark, plus `CategoryColors` (DESIGN §3.3) and the chart palette (DESIGN §3.4). Add a `context.colors` extension. Test that every token has a light and a dark value.
  Refs: DESIGN §3, §11
- [x] **0.4 Type, spacing and theme.** Bundle Poppins 400–800 as assets. Build `AppTypography` (DESIGN §4, tabular figures), `AppSpacing`, `AppRadius`, `AppShadows`, and `buildLightTheme()` / `buildDarkTheme()`. Add a theme-mode provider (default System). Widget-test a sample screen in both themes.
  Refs: DESIGN §4, §5, §11
- [x] **0.5 Localisation and money.** Set up `flutter gen-l10n` with an English ARB file. Build `MoneyFormatter` in `core/money` (pure Dart) and an `AmountText` widget that shows cents smaller for large amounts. Unit-test zero, negative (U+2212), large values and currency-symbol switching.
  Refs: PRD §6.1, DESIGN §4
- [x] **0.6 App shell.** Build `AppShell`: the floating pill bottom bar (four tabs, active tab expands with label) and the separate round add button, with labels and the shadows from DESIGN §5. Widget tests in both themes; compare with `Dashboard.png` and `Dashboard · Dark.png`.
  Refs: PRD §4, DESIGN §6, §7
- [x] **0.7 Money keypad.** Put keypad input logic in a pure function (cents fill, `00`, backspace, 9-digit cap) with unit tests. Build `MoneyKeypad` in both sizes (full screen and sheet) and `AmountDisplay` with its screen-reader label.
  Refs: PRD §6.1, DESIGN §7
- [x] **0.8 CI.** GitHub Actions on every push: set up Flutter, `pub get`, codegen, `flutter analyze`, `flutter test`. Add the status badge to `README.md`.
  Refs: PRD §10
- [x] **0.9 Spike (no production code).** Schedule a local notification on Android and iOS with flutter_local_notifications, including the permission prompt. Record findings and any setup steps in `docs/spikes.md`.
  Refs: PRD §12

## Phase 1 — Data

- [x] **1.1 Periods.** Implement `periodFor(date, startDay)` in `core/period` (start day 1–28 or `last`) and an injectable `Clock` provider. Exhaustive unit tests: start days 1, 15, 28 and `last`; February in leap and non-leap years; 30- and 31-day months; dates on the boundary.
  Refs: PRD §6.2, CLAUDE.md Testing
- [x] **1.2 Database schema v1.** Drift database in `core/db` with Category, Transaction, Notification and a key-value Preferences table (schemaVersion 1). Provide it through Riverpod; use an in-memory database in tests. No Bill or Goal tables.
  Refs: PRD §8
- [x] **1.3 Domain entities.** freezed entities for Category, Transaction, Notification and Preferences, enums for type, icon key and colour key, and mappers to and from Drift rows.
  Refs: PRD §8, DESIGN §3.3, §8
- [x] **1.4 Category repository.** Interface and Drift implementation: watch by type, add, update, archive, restore, delete. Seed the 8 default categories on first launch. Enforce unique names per type and delete-only-if-unused (otherwise archive). Unit tests.
  Refs: PRD §5.9, §8
- [x] **1.5 Transaction repository.** Watch by period; filter by type, category and search text (case-insensitive over title, note and category name); add, update, delete and exact restore for undo. Unit tests.
  Refs: PRD §5.3, §5.5
- [x] **1.6 Preferences repository.** Read and watch `userName`, `currencyCode`, `monthStartDay`, `monthlyBudgetMinor`, `theme`, reminder settings and `onboardingComplete`, with defaults. Wire the theme-mode provider from 0.4 to it. Unit tests.
  Refs: PRD §8
- [x] **1.7 Budget calculations.** Pure domain functions with tests: spent and income for a period, left to spend, the shared threshold function (neutral, warning, negative, no budget), category used %, allocated and flexible, and validation that category limits don't exceed the monthly budget.
  Refs: PRD §6.3, §8 Derived values
- [x] **1.8 Insight calculations.** Pure domain functions with tests: category shares for a period, daily totals and daily pace, under/over pace per day, monthly totals, averages and under-budget counts over full periods only, and past-period summaries with per-category results.
  Refs: PRD §5.7, §5.10, §8

## Phase 2 — Core (P0)

- [x] **2.1 Shared widgets, part 1.** `CategoryTile`, `TransactionRow`, `ListGroup` / `ListGroupRow` / `KeyValueRow`, `AppProgressBar` (with label), `StatCard`. Widget tests in both themes.
  Refs: DESIGN §7, §11
- [x] **2.2 Shared widgets, part 2.** `SegmentedControl` (both variants), `AppToggle`, `AppRadio`, `DaySelector`, `StepIndicator`, `EmptyState`, `AppToast`, `AppSheet`, `AppDialog`, `MonthCalendar`. Widget tests in both themes.
  Refs: DESIGN §7, §11
- [x] **2.3 Onboarding intro.** S01 Splash (with "by BrendanLTW"), S02 Welcome (with the hero preview), S03 How it works, and `OnboardingScaffold`. The onboarding redirect now uses `onboardingComplete`.
  Refs: S01–S03, PRD §5.1, FR-01
- [ ] **2.4 Name and month setup.** S03a Your name (validation, 30-character limit) and S04 Set up your month (currency row showing RM, month-start segments, live period preview). "Other" opens S32 (task 2.13).
  Refs: S03a, S04, PRD §5.1, FR-01, FR-07
- [ ] **2.5 Budget and category limits.** S05 Set your monthly budget (keypad, Skip leaves no budget) and S06 Split by category (allocated summary, add limit per category, can't exceed the budget).
  Refs: S05, S06, PRD §5.1, FR-01, FR-05
- [ ] **2.6 Reminders and finish.** S07 Stay on track (save toggle preferences only; the permission prompt comes in 3.8) and S08 You're all set (summary, Add your first expense, Go to dashboard). Back keeps values on every step.
  Refs: S07, S08, PRD §5.1
- [ ] **2.7 Dashboard.** S09 with header (period, greeting, bell, avatar → Settings), `BudgetHero` in all four states (S11), Spent and Income cards, and Recent activities with View all. Figures update live.
  Refs: S09, S11, PRD §5.2, FR-02
- [ ] **2.8 Dashboard first run.** S10 empty state with Add your first expense.
  Refs: S10, PRD §5.2, FR-02
- [ ] **2.9 Add and edit transaction.** S12 and S13: Expense/Income toggle swapping category sets, keypad amount, category row with More, date row opening the S43 date picker, note, Save disabled for amount 0 or no category, edit mode prefilled with Delete.
  Refs: S12, S13, S43, PRD §5.3, FR-03
- [ ] **2.10 Transaction detail and delete.** S41 with details and budget impact; S42 confirmation dialog; deleting returns to the previous screen.
  Refs: S41, S42, PRD §5.13, FR-03
- [ ] **2.11 Activity list.** S16 day groups with net totals, rows opening S41, swipe left to delete, and the Transaction deleted toast with 5-second Undo. (Search and chips come in 3.1.)
  Refs: S16, PRD §5.5, FR-04
- [ ] **2.12 Budgets.** S17 monthly budget card, By category list with thresholds, and the edit sheet (keypad, Remove, Save) for both the monthly budget and category limits.
  Refs: S17, PRD §5.6, FR-05
- [ ] **2.13 Settings and month start.** S21 with the profile row (edit name), Month starts on, Categories, and placeholders for P1 rows; v1.1 rows hidden. S32 Month start with day grid, Last day of the month and period previews; saving recalculates everything.
  Refs: S21, S32, PRD §5.8, FR-07
- [ ] **2.14 Categories.** S22 Category manager (Expense, Income, Archived with Restore) and S24 Add category sheet (type, name, icon, colour, optional limit). Deleting or archiving follows the repository rule.
  Refs: S22, S24, PRD §5.9, FR-06
- [ ] **2.15 P0 review.** Walk through every acceptance criterion for FR-01 to FR-07 and every P0 screen against its light and dark design. List gaps, fix them, and confirm all P0 tests pass.
  Refs: PRD §7

## Phase 3 — Complete (P1)

- [ ] **3.1 Search and filters.** Search field and chips (All, Expense, Income, categories) on S16, and the S39 No results state with Search all.
  Refs: S16, S39, PRD §5.5, FR-08
- [ ] **3.2 Insights · Month.** S18 with the Week/Month/6 months control, period total, ranked spending categories with a screen-reader summary, and the S40 empty state.
  Refs: S18, S40, PRD §5.7, FR-09
- [ ] **3.3 Insights · Week.** S19 daily bars against the pace line, under/over marking, today highlighted, Under pace and Biggest day stats, and the chart's text alternative.
  Refs: S19, PRD §5.7, FR-09
- [ ] **3.4 Insights · 6 months.** S20 monthly bars against the budget line, "so far" for the current period, Under budget and Highest month stats, and View past periods.
  Refs: S20, PRD §5.7, FR-09
- [ ] **3.5 Past periods.** S25 current and previous periods, and S26 period detail with per-category results against limits.
  Refs: S25, S26, PRD §5.10, FR-13
- [ ] **3.6 Category detail.** S23 with this-period stats, Name, Icon & colour and Monthly limit rows, recent transactions and Archive category.
  Refs: S23, PRD §5.9, FR-15
- [ ] **3.7 Theme and currency.** S33 Theme (Light, Dark, System) and S34 Currency (search, Suggested, All currencies, symbol-only note). Wire the S04 currency row and the S21 rows.
  Refs: S33, S34, PRD §5.8, FR-10
- [ ] **3.8 Local notifications.** A notification service using the spike findings: permission request from S07, daily reminder, budget alerts at 80% and 100%, weekly summary, new period started and income recorded. Each writes a Notification row. Tests with a fake scheduler and injected clock.
  Refs: S07, PRD §5.4, FR-12
- [ ] **3.9 Notifications inbox.** S14 grouped Today/Earlier with unread markers, S15 empty state, the bell badge on S09, and mark-as-read on open.
  Refs: S14, S15, PRD §5.4, FR-12
- [ ] **3.10 CSV export.** S35 range and include options, `ctrlspend-YYYY-MM-DD.csv` via the share sheet, and the "Saved {n} transactions to Files" toast. Define the CSV format in `docs/csv-format.md`.
  Refs: S35, PRD §5.8, FR-14
- [ ] **3.11 CSV import.** Import from Settings: validate every row first, import all or nothing, S36 error screen listing problems by row, Choose another file and Download a sample CSV. Round-trip test with export.
  Refs: S36, PRD §5.8, FR-14
- [ ] **3.12 Dark mode audit.** Check every v1.0 screen against its dark design; make sure every screen's widget tests run in both themes; fix any hard-coded colours.
  Refs: FR-11, DESIGN §9

## Phase 4 — Ship v1.0

- [ ] **4.1 Accessibility pass.** Screen-reader labels, chart and progress text alternatives, 44 px targets, contrast in both themes, and 200% text scale on every screen.
  Refs: DESIGN §10, PRD §9
- [ ] **4.2 Design fidelity pass.** Run the DESIGN §12 checklist for every v1.0 screen in light and dark; fix differences or log intentional ones in `docs/design-notes.md`.
  Refs: DESIGN §12
- [ ] **4.3 Performance.** A debug-only generator for 5,000 transactions; measure cold start and list scrolling on a mid-range Android device; fix anything below target.
  Refs: PRD §10
- [ ] **4.4 End-to-end test.** Integration test: onboarding → add expense → dashboard → delete → undo.
  Refs: PRD §10
- [ ] **4.5 README and release.** README with screenshots in both themes, architecture diagram and key decisions. Build the release APK, attach it to a GitHub Release and tag `v1.0.0`.
  Refs: PRD §2

## Phase 5 — v1.1 (start only after v1.0 is released)

- [ ] **5.1 Schema v2.** Add Bill, Goal and GoalContribution tables (schemaVersion 2), the migration step and a migration test from v1.0 data.
  Refs: PRD §8
- [ ] **5.2 Bills domain.** Repeat rules and next-due calculation, mark paid (creates a transaction and advances next due), left after bills. Unit tests.
  Refs: PRD §5.11, §8
- [ ] **5.3 Bills screens.** S27 Recurring bills, S28 Add bill, S44 Repeats picker (S43 date picker reused), and the Settings row.
  Refs: S27, S28, S43, S44, FR-16
- [ ] **5.4 Bill reminders.** Reminders the set number of days before the due date, using the notification service.
  Refs: PRD §5.11, FR-16
- [ ] **5.5 Goals domain.** Goal and contribution repositories, monthly need (rounded up), completion. Contributions never touch left to spend. Unit tests.
  Refs: PRD §5.12, §8
- [ ] **5.6 Goals screens.** S29 Savings goals, S30 Goal detail (Add money, Withdraw), S31 Add goal, and the Settings row.
  Refs: S29–S31, FR-17
- [ ] **5.7 App lock settings.** Add flutter_secure_storage and local_auth. S37 with PIN setup and change (stored hashed in secure storage), Face ID, Lock after and Hide amounts in app switcher.
  Refs: S37, PRD §5.8, FR-18
- [ ] **5.8 Lock screen.** S38 with PIN pad, biometric unlock and Forgot PIN, shown on launch and after the lock-after delay; obscure the app-switcher snapshot when enabled.
  Refs: S38, FR-18
- [ ] **5.9 v1.1 release.** Unhide the Settings rows, run the accessibility and fidelity checklists for the new screens, update the README, and tag `v1.1.0`.
  Refs: PRD §11
