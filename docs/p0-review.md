# P0 review (task 2.15)

Every P0 acceptance criterion (FR-01 to FR-07) checked against the code and the tests that prove it, and every P0 screen checked against its light and dark design.

## Acceptance criteria

| FR | Criterion (PRD) | Status | Evidence |
|---|---|---|---|
| FR-01 | Onboarding runs once; afterwards the app opens on S09 | Met | `app_router_test`: an onboarded user can't reach onboarding; `onboarding_intro_test`: onboarded user goes from splash to Home |
| FR-01 | Every value chosen in onboarding appears in Settings and can be changed later | Partly | Name, month start (S21, S32), budget and limits (S17) and currency (S34, since 3.7) can be changed. **Reminder toggles** need notification settings (3.8/3.9, P1) |
| FR-01 | Back works on every step without losing entered values | Met | `reminders_and_done_test`: full run, back through every step, values kept |
| FR-02 | Hero thresholds exactly < 80%, 80–99%, ≥ 100%, no budget | Met | `budget_hero_test`: 159,999 / 160,000 / 199,999 / 200,000; `budget_calculations_test` |
| FR-02 | All figures update immediately after adding, editing or deleting | Met | `dashboard_screen_test` (add), `transaction_detail_screen_test` (edit), `activity_screen_test` (delete and Undo) |
| FR-02 | Progress bar label reads "{n}% of monthly budget spent" | Met | `budget_hero_test`: "38% of monthly budget spent" |
| FR-03 | Amount 0 or no category disables Save | Met | `add_transaction_screen_test` |
| FR-03 | Switching Expense/Income swaps categories and clears an incompatible choice | Met | `add_transaction_screen_test` |
| FR-03 | Edit opens prefilled; Delete asks for confirmation (S42) | Met | `add_transaction_screen_test`, `transaction_detail_screen_test` |
| FR-04 | Undo restores the transaction exactly, within 5 seconds | Met | `activity_screen_test`: same id and place; expires after 5 s |
| FR-04 | Search is case-insensitive and respects chips | Deferred | Search and chips are task 3.1 (P1). The repository side is done and tested (`drift_transaction_repository_test`) |
| FR-05 | Category status uses the same thresholds as the hero | Met | `budgets_screen_test`: 79.99%, 80%, 100% |
| FR-05 | Removing a category limit keeps the category and its transactions | Met | `budgets_screen_test` |
| FR-05 | Category limits can't add up to more than the budget (CLAUDE.md) | Met | `budget_calculations_test`; S05, S06, S17 and S24 caps in their screen tests |
| FR-06 | Unused category deleted; used one archived | Met | `drift_category_repository_test`, `category_manager_screen_test` |
| FR-06 | Archived categories hidden from pickers, history kept | Met for P0 | Pickers: `category_manager_screen_test`; Activity: `activity_screen_test`; Home: `dashboard_screen_test`. Insights and past periods are P1 |
| FR-06 | 8 default categories seeded on first launch | Met | `drift_category_repository_test` |
| FR-07 | Changing the month start recalculates every period, budget and chart | Met for P0 | `settings_screen_test`: Home's period after Save; every screen reads the start day through `periodFor`. Charts are P1 |
| FR-07 | `periodFor` handles start days 1–28 and last, short months, leap years | Met | `period_test`, including a 4-year sweep and a DST time zone |

## Screens

Each P0 screen was rendered with Poppins at 390 × 844 in both themes and compared with its design when it was built.

| Screen | Matches | Known differences |
|---|---|---|
| S01 Splash | Yes | Symbol drawn in code until the brand SVG is exported (`shortcut:`) |
| S02 Welcome | Yes | Donut is an illustration |
| S03 How it works | Yes | |
| S03a Your name | n/a | Not on the canvas yet; built in the steps' style |
| S04 Set up your month | Yes | 5 step pills (canvas shows 4, update pending) |
| S05 Set budget | Yes | Low-budget warning shown in the card (new copy) |
| S06 Category limits | Yes | |
| S07 Reminders | Yes | Permission prompt in 3.8 |
| S08 All set | Yes | |
| S09 Dashboard | Yes | |
| S10 First run | Yes | Empty card sits slightly lower; page scrolls clear of the bar |
| S11 Hero states | Yes | |
| S12 / S13 Add, edit | Yes | Keypad in a sheet (no keypad on the canvas); dark amount card uses `surface` (canvas shows white) |
| S16 Activity | Yes | Search and chips in 3.1 |
| S17 Budgets | Yes | By category rows designed from the PRD (hidden by the sheet on the canvas) |
| S21 Settings | Yes | |
| S22 / S24 Categories | Yes | Rows open S23 in 3.6 |
| S32 Month start | Yes | |
| S41 Transaction | Yes | Note row only when a note exists (S12 has one text field) |
| S42 Delete dialog | Yes | Destructive red is the light theme's in both themes, for 4.5:1 contrast |

Icons were placeholders (Material) until the fidelity pass (4.2), which replaced them with bundled Lucide line icons; see `docs/design-notes.md`.

## Gaps found and fixed in this review

- No test proved Home updates after **editing** a transaction. Added to `transaction_detail_screen_test`.
- No test proved archived categories keep their **history in Activity**. Added to `activity_screen_test`.

## Bugs found and fixed while building P0

- Sheets on tab screens opened under the bottom bar, hiding the keypad's last row and Save (2.12).
- Positive day nets in Activity had no "+" (2.11).
- `hideAppToast` could crash after the app was torn down (2.11).
- Hero footers and Welcome chips overflowed on narrow screens (2.3, 2.7).
- The S05 keypad's last row was hidden behind Continue (2.5).
