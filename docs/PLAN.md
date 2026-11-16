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
- [x] **2.4 Name and month setup.** S03a Your name (validation, 30-character limit) and S04 Set up your month (currency row showing RM, month-start segments, live period preview). "Other" opens S32 (task 2.13).
  Refs: S03a, S04, PRD §5.1, FR-01, FR-07
- [x] **2.5 Budget and category limits.** S05 Set your monthly budget (keypad, Skip leaves no budget) and S06 Split by category (allocated summary, add limit per category, can't exceed the budget).
  Refs: S05, S06, PRD §5.1, FR-01, FR-05
- [x] **2.6 Reminders and finish.** S07 Stay on track (save toggle preferences only; the permission prompt comes in 3.8) and S08 You're all set (summary, Add your first expense, Go to dashboard). Back keeps values on every step.
  Refs: S07, S08, PRD §5.1
- [x] **2.7 Dashboard.** S09 with header (period, greeting, bell, avatar → Settings), `BudgetHero` in all four states (S11), Spent and Income cards, and Recent activities with View all. Figures update live.
  Refs: S09, S11, PRD §5.2, FR-02
- [x] **2.8 Dashboard first run.** S10 empty state with Add your first expense.
  Refs: S10, PRD §5.2, FR-02
- [x] **2.9 Add and edit transaction.** S12 and S13: Expense/Income toggle swapping category sets, keypad amount, category row with More, date row opening the S43 date picker, note, Save disabled for amount 0 or no category, edit mode prefilled with Delete.
  Refs: S12, S13, S43, PRD §5.3, FR-03
- [x] **2.10 Transaction detail and delete.** S41 with details and budget impact; S42 confirmation dialog; deleting returns to the previous screen.
  Refs: S41, S42, PRD §5.13, FR-03
- [x] **2.11 Activity list.** S16 day groups with net totals, rows opening S41, swipe left to delete, and the Transaction deleted toast with 5-second Undo. (Search and chips come in 3.1.)
  Refs: S16, PRD §5.5, FR-04
- [x] **2.12 Budgets.** S17 monthly budget card, By category list with thresholds, and the edit sheet (keypad, Remove, Save) for both the monthly budget and category limits.
  Refs: S17, PRD §5.6, FR-05
- [x] **2.13 Settings and month start.** S21 with the profile row (edit name), Month starts on, Categories, and placeholders for P1 rows; v1.1 rows hidden. S32 Month start with day grid, Last day of the month and period previews; saving recalculates everything.
  Refs: S21, S32, PRD §5.8, FR-07
- [x] **2.14 Categories.** S22 Category manager (Expense, Income, Archived with Restore) and S24 Add category sheet (type, name, icon, colour, optional limit). Deleting or archiving follows the repository rule.
  Refs: S22, S24, PRD §5.9, FR-06
- [x] **2.15 P0 review.** Walk through every acceptance criterion for FR-01 to FR-07 and every P0 screen against its light and dark design. List gaps, fix them, and confirm all P0 tests pass.
  Refs: PRD §7

## Phase 3 — Complete (P1)

- [x] **3.1 Search and filters.** Search field and chips (All, Expense, Income, categories) on S16, and the S39 No results state with Search all.
  Refs: S16, S39, PRD §5.5, FR-08
- [x] **3.2 Insights · Month.** S18 with the Week/Month/6 months control, period total, ranked spending categories with a screen-reader summary, and the S40 empty state.
  Refs: S18, S40, PRD §5.7, FR-09
- [x] **3.3 Insights · Week.** S19 daily bars against the pace line, under/over marking, today highlighted, Under pace and Biggest day stats, and the chart's text alternative.
  Refs: S19, PRD §5.7, FR-09
- [x] **3.4 Insights · 6 months.** S20 monthly bars against the budget line, "so far" for the current period, Under budget and Highest month stats, and View past periods (moved to 3.5, with S25).
  Refs: S20, PRD §5.7, FR-09
- [x] **3.5 Past periods.** S25 current and previous periods, and S26 period detail with per-category results against limits. Add S20's View past periods row (`surface`, `ink` text in both themes).
  Refs: S25, S26, PRD §5.10, FR-13
- [x] **3.6 Category detail.** S23 with this-period stats, Name, Icon & colour and Monthly limit rows, recent transactions and Archive category.
  Refs: S23, PRD §5.9, FR-15
- [x] **3.7 Theme and currency.** S33 Theme (Light, Dark, System) and S34 Currency (search, Suggested, All currencies, symbol-only note). Wire the S04 currency row and the S21 rows.
  Refs: S33, S34, PRD §5.8, FR-10
- [x] **3.8 Local notifications.** A notification service using the spike findings: permission request from S07, daily reminder, budget alerts at 80% and 100%, weekly summary, new period started and income recorded. Each writes a Notification row. Tests with a fake scheduler and injected clock.
  Refs: S07, PRD §5.4, FR-12
- [x] **3.9 Notifications inbox.** S14 grouped Today/Earlier with unread markers, S15 empty state, the bell badge on S09, and mark-as-read on open.
  Refs: S14, S15, PRD §5.4, FR-12
- [x] **3.10 CSV export.** S35 range and include options, `ctrlspend-YYYY-MM-DD.csv` via the share sheet, and the "Saved {n} transactions to Files" toast. Define the CSV format in `docs/csv-format.md`.
  Refs: S35, PRD §5.8, FR-14
- [x] **3.11 CSV import.** Import from Settings: validate every row first, import all or nothing, S36 error screen listing problems by row, Choose another file and Download a sample CSV. Round-trip test with export.
  Refs: S36, PRD §5.8, FR-14
- [x] **3.12 Dark mode audit.** Check every v1.0 screen against its dark design; make sure every screen's widget tests run in both themes; fix any hard-coded colours.
  Refs: FR-11, DESIGN §9
- [x] **3.13 Delete all data.** *(Added on request.)* A red S21 row and S42-style dialog with Export first; erase every table in one transaction, re-seed the default categories, cancel scheduled notifications and return to onboarding.
  Refs: PRD §5.8 (addition)

## Phase 4 — Ship v1.0

- [x] **4.1 Accessibility pass.** Screen-reader labels, chart and progress text alternatives, 44 px targets, contrast in both themes, and 200% text scale on every screen.
  Refs: DESIGN §10, PRD §9
- [x] **4.2 Design fidelity pass.** Run the DESIGN §12 checklist for every v1.0 screen in light and dark; fix differences or log intentional ones in `docs/design-notes.md`.
  Refs: DESIGN §12
- [x] **4.3 Performance.** A debug-only generator for 5,000 transactions; measure cold start and list scrolling on a mid-range Android device; fix anything below target. *(Generator, benchmarks and the device test are done. The device run was skipped for v1.0, see `docs/quality-audit.md`.)*
  Refs: PRD §10
- [x] **4.4 End-to-end test.** Integration test: onboarding → add expense → dashboard → delete → undo.
  Refs: PRD §10
- [x] **4.5 README and release.** README with screenshots in both themes, architecture diagram and key decisions. Build the release APK, attach it to a GitHub Release and tag `v1.0.0`. *(README and screenshots done; the brand SVGs are in `assets/brand/`. The release was skipped: no tag, APK or GitHub Release. If one is made later, the APK keeps the debug signing.)*
  Refs: PRD §2

## Phase 5 — v1.1 (v1.0 is complete; its release was skipped)

- [x] **5.1 Schema v3.** Add Bill, Goal and GoalContribution tables (schemaVersion 3; v2 added the notification category in 3.9), the migration step and a migration test from v1.0 data. *(Also `transactions.billId`. A repeat is a unit and a count, which covers Custom; dates are UTC midnight.)*
  Refs: PRD §8
- [x] **5.2 Bills domain.** Repeat rules and next-due calculation, mark paid (creates a transaction and advances next due), left after bills. Unit tests. *(Every payment due by the period end counts, so a weekly bill can count twice. A category with bills is archived, not deleted.)*
  Refs: PRD §5.11, §8
- [x] **5.3 Bills screens.** S27 Recurring bills, S28 Add bill, S44 Repeats picker (S43 date picker reused), and the Settings row. *(Bills have their own icon and colour, schema v4. Tapping a bill opens Mark paid, Edit bill and Delete bill. The Settings row shows in debug builds until 5.9.)*
  Refs: S27, S28, S43, S44, FR-16
- [x] **5.4 Bill reminders.** Reminders the set number of days before the due date, using the notification service. *(At 9:00 local; one already past isn't scheduled. Rescheduled when a bill is paid, edited or deleted; caught up into the inbox like the other scheduled kinds.)*
  Refs: PRD §5.11, FR-16
- [x] **5.5 Goals domain.** Goal and contribution repositories, monthly need (rounded up), completion. Contributions never touch left to spend. Unit tests. *(Months left count from next month to the target month, as S31's RM 616 does; S30's RM 360 example would read RM 450. Completion follows saved and the target.)*
  Refs: PRD §5.12, §8
- [x] **5.6 Goals screens.** S29 Savings goals, S30 Goal detail (Add money, Withdraw), S31 Add goal, and the Settings row. *(A goal's type and colour come from its icon. Edit and Delete live on S31, opened from S30. The Settings row shows in debug builds until 5.9.)*
  Refs: S29–S31, FR-17
- [ ] ~~**5.7 App lock settings.**~~ *Superseded by 6.22–6.23 (15 Nov spec).* Add flutter_secure_storage and local_auth. S37 with PIN setup and change (stored hashed in secure storage), Face ID, Lock after and Hide amounts in app switcher.
  Refs: S37, PRD §5.8, FR-18
- [ ] ~~**5.8 Lock screen.**~~ *Superseded by 6.22–6.23.* S38 with PIN pad, biometric unlock and Forgot PIN, shown on launch and after the lock-after delay; obscure the app-switcher snapshot when enabled.
  Refs: S38, FR-18
- [ ] **5.9 v1.1 release.** *(After Phase 6.)* Unhide the Settings rows, run the accessibility and fidelity checklists for the new screens, update the README, and tag `v1.1.0`.
  Refs: PRD §11

## Phase 6 — Spec update (PRD and DESIGN of 15 Nov 2026, AUDIT.md §8)

Group A (data and rules) has no UI changes. Stop for review after 6.10, and again after 6.23. Each screen task is compared with its light and dark PNGs before it's ticked.

### A. Data and rules

- [x] **6.1 Schema v5.** Add the PeriodSnapshot table, with its limits in a child table (categoryId → limitMinor). Add `bills.paused` and `goals.createdAt` (existing goals get their first contribution's date, else the migration date). Rename the stored notification kind `billReminder` to `billDue`. New preference keys: `billRemindersOn`, `lockAfterMinutes`, `failedPinCount`, `lockoutUntil` (reminder time already exists). Migration tests from v1–v4 data. *(Also the other app-lock preferences in PRD §8: enabled, biometrics, hide in switcher.)*
  Refs: PRD §8
- [x] **6.2 Period snapshots.** Write a snapshot for each period that has ended, on launch and on resume, without double-writing. Backfill past periods from the current budget and limits; this is an approximation, and the docs and the commit say so. Changing the month start recalculates the current period and leaves snapshots alone. Past-period data (S25, S26, S20) reads budgets and limits from snapshots. *(Spent and income are read live, so later edits show; the stored totals are a record. A month-start change follows `periodFor`, so a new period can overlap the last snapshot; only periods ending after the latest snapshot are written.)*
  Refs: PRD §6.2, §5.8, §5.10, §8
- [x] **6.3 Transaction and category rules.** Title optional and at most 40 characters, defaulting to the category name. Note at most 200 characters. No future dates. Category name at most 20 characters. Enforced in the repositories, with tests. *("No future dates" compares calendar days, so later today is allowed. CSV import reports these per row on S36.)*
  Refs: PRD §5.3, §5.9, §8
- [x] **6.4 Over-allocation in the domain.** Over-allocation is already blocked in the UI. Move the rules into the repositories: a limit can't make the allocated total exceed the budget, and the budget can't drop below the allocated total. Removing the budget keeps the limits. *(Also: income categories take no limit. A restored category keeps its limit only if it still fits. Renames aren't blocked by limits that were already over.)*
  Refs: PRD §5.6, §8
- [x] **6.5 Alert deduplication.** A budget alert fires once per category (or the monthly budget), per threshold, per period, checked against the inbox. A month-start change re-evaluates alerts for the new period.
  Refs: PRD §5.4, §5.8
- [x] **6.6 Currency: MYR only for now.** *(Decided 15 Nov: S34 offers Malaysian Ringgit only; the other currencies stay in code for later, and a saved one reads as MYR. Per-currency minor units (PRD §6.5, JPY 0) wait until a currency that needs them is offered; MYR has 2.)* Originally: each currency carries its ISO 4217 minor units (JPY 0), for MoneyFormatter, the keypad, CSV amounts and "rounded up to the whole unit".
  Refs: PRD §6.5
- [x] **6.7 Shared CSV format.** Columns `date,time,type,amount,category,title,note` for export and import. Import maps columns by header name. Duplicates (same date, type, amount and category) are found and skipped by default. Unknown categories are created. At most 20,000 rows. Round-trip test, and a 20,000-row timing test. *(The note column is always there, empty when Notes is off. 20,000 rows are checked in about 0.25 s locally.)*
  Refs: PRD §6.4, §10
- [x] **6.8 Bill rules.** Paused bills are left out of Upcoming totals, "Left after bills" and reminders. Custom repeat is every N days, weeks or months, N from 1 to 12. Mark paid takes an amount, a date and a category. Reminders use the `billDue` kind and respect `billRemindersOn`. *(Mark paid also follows the no-future-dates rule. The current Custom sheet is capped at 12 and drops Years, so it can't save a repeat the repository refuses; the full S44 rework is 6.20.)*
  Refs: PRD §5.11, §5.4, §8
- [x] **6.9 Goal rules.** Statuses: on track, behind, past target date, each with the monthly amount now needed. Mark as completed by hand. Contributions take a label and a date. *(On track: saved ≥ target × months since the creation month ÷ months from creation to the target month, so always on track in the month it's made. Completion is sticky: once reached or marked, a withdrawal or a higher target doesn't reopen it.)*
  Refs: PRD §5.12
- [x] **6.10 PIN lockout timing.** A pure function: 5 wrong PINs → 30 s, doubling every further 5, capped at 15 min. Unit tests. *(Entry locks only on every fifth wrong PIN; the ones in between don't.)*
  Refs: PRD §5.8, §10

### B. Screens

- [x] **6.11 Tokens and shared components.** `buttonDisabled`, `scrim`, the four message boxes, `r18`/`r30`, the `amountEntry`/`stateTitle`/`message` styles. MessageBox, StatusPill, StateScreen, AppSpinner, text input with counter and error outline, sheet button, Pay pill, action sheet, and the dialog at r30 with a 96 px icon. *(Also `destructive`/`onDestructive` and `pillLabel` tokens. AppDialog has both layouts: S42 still shows the compact one, S49 the new one.)*
  Refs: DESIGN §3, §4, §7
- [x] **6.12 S12, S13, S45 entry screens and S46 category picker.** Pinned keypad, one row of category tiles, Title field, Date and Note chips, Save disabled with its hint. S12 reads "New expense". Edit goes to S45. Update the end-to-end test. *("Added by you" means the name and type don't match a default category. The tile row scrolls a newly picked category into view. Entry keys are drawn 44 high but take taps over 48, for the tap-target guideline.)*
  Refs: PRD §5.3, DESIGN §6
- [x] **6.13 S17, S06 and S54 over-allocation.** Red outline and the S54 copy on the limit and budget sheets.
  Refs: PRD §5.6
- [x] **6.14 Categories.** Every S22 row and every S18 category row opens S23. S24 name at most 20 characters. *(Archived rows open S23 too, following the PRD, and show their transaction count. The 20-character limit landed in 6.3.)*
  Refs: PRD §5.7, §5.9
- [x] **6.15 S21, S21a Settings and S47, S49.** Profile row opens the S47 sheet. Notifications row opens S48. Erase all data uses the S49 dialog. Import opens S51. Footer "ctrlSpend {version} · by BrendanLTW".
  Refs: PRD §5.8
- [x] **6.16 S48 Notification settings.** Remind me at (time picker), Bill reminders, and the permission-denied banner with Open phone settings. The settings icon on S14 opens it.
  Refs: PRD §5.4
- [x] **6.17 S35 and S50 export range.** Custom opens S50: From and To, a live count, and "Export {n} transactions".
  Refs: PRD §5.8
- [x] **6.18 Import flow S51–S53 and S36.** Checking with progress and Cancel, Review with the duplicate choice and new categories, Success.
  Refs: PRD §5.8, §6.4
- [x] **6.19 Past periods S25, S26, S55, S20 and S40.** Read from snapshots. Add S55 empty. S40 shows until there's spending on 3 different days.
  Refs: PRD §5.7, §5.10
- [ ] **6.20 Bills S27, S56–S59, S44.** Pay pill opens S57. A row opens S56 (pause, history, Mark as paid, Edit, Delete). Overdue copy (S58), empty state (S59), Custom 1–12 days, weeks or months.
  Refs: PRD §5.11
- [ ] **6.21 Goals S29, S30, S60–S63.** ••• opens S62 (Edit, Mark as completed, Delete with its count, Cancel). S60/S61 sheets with the toggle, label, date and limit message. Status card with the three statuses. "Completed {date}" rows. S63 empty state.
  Refs: PRD §5.12
- [ ] **6.22 App lock settings S37, S68, S64, S65.** Add flutter_secure_storage and local_auth, with iOS and Android setup. PIN stored hashed in secure storage. Biometrics wording. Lock after options. Create, confirm and change PIN. Hide amounts in app switcher.
  Refs: PRD §5.8, FR-18
- [ ] **6.23 Lock screen S38, S66, S67.** Shown on launch and after the lock-after delay. PIN pad, biometric key, lockout countdown, Forgot PIN through biometrics or the phone passcode. Erase all data also removes the PIN.
  Refs: PRD §5.8, FR-18

