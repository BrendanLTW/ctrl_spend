# Design notes

Where the app intentionally differs from the canvas exports in `docs/design/`, checked in the fidelity pass (task 4.2) against the DESIGN §12 checklist. Dark-mode and accessibility decisions are in [`quality-audit.md`](quality-audit.md).

## How it was checked

Every v1.0 screen was rendered at 390 × 844 with Poppins and the bundled icons, in light and dark, and compared side by side with its export. Most checklist items are enforced by tests:

| DESIGN §12 | Enforced by |
|---|---|
| Colours from tokens only | `test/core/theme/no_hardcoded_colours_test.dart` |
| Layout in light and dark | Each screen's widget tests in both themes; side-by-side review (this task and 3.12) |
| Copy matches the design | Strings in ARB; widget tests assert the copy |
| Status colour has text | Widget tests for each status (hero, budgets, S23, S25, S26) |
| Touch targets, labelled buttons | `test/accessibility/guidelines_test.dart` |
| Chart and progress labels | Insights, hero and budget widget tests |
| 200% text | `test/accessibility/large_text_test.dart` |

## Icons

DESIGN §8 asks for line icons on a 24 grid, round caps and joins, stored as SVGs or an icon font behind an `AppIcon` enum. The canvas icons weren't exported, so the app bundles **Lucide** (lucide-static 1.72.0, ISC licence, listed on the app's licence page) in `assets/icons/`, drawn with flutter_svg. Lucide is the same style; individual glyphs can differ slightly from the canvas (for example the Activity receipt). Strokes follow §8: 1.7 in the bottom bar, 1.8 for buttons and fields, 1.9 in category tiles, 2.2 for chevrons.

## Intentional differences

| Screen | Canvas | App | Why |
|---|---|---|---|
| S03a Your name | Not on the canvas | Built in the onboarding steps' style | Added for the greeting |
| S04 step indicator | 4 pills | 5 pills | S03a is a step |
| S08 All set | — | Shows "0 of 6" etc. from real data | Sample data only |
| S12 Add | Keypad not shown | Keypad opens in a sheet | Keeps the category grid visible |
| S12 / S13 dark amount card | White | `surface` | Readable in dark |
| S17 By category | Hidden behind the sheet | Designed from the PRD | — |
| S20 View past periods (dark) | White bar, near-invisible text | `surface` with `ink` text | Design bug |
| S21 Settings | App lock, Recurring bills, Savings goals | Hidden; Delete all data added | v1.1 rows; Delete all data added in 3.13 |
| S23 bar | Category colour on a peach track | Shared status colours on `raised` | One threshold rule everywhere |
| S25 results (dark) | Grey | Red and green | Colour paired with text |
| S26 By category | Unsorted | Largest spend first | Agreed in 3.5 |
| S27 Upcoming | Only bills due this period | Every bill, soonest first | A bill due later would otherwise appear nowhere |
| S27 due line | Amber for the next bill | Red when overdue, amber within 7 days, muted after | One rule, with the date and "in 4 days" beside the colour |
| S27 bill actions | Not on the canvas | Tap a bill: a sheet with Mark paid, Edit bill, Delete bill | The canvas has no way to pay, edit or delete a bill |
| S28 icon | No icon field, yet S27 shows one per bill | An Icon section (12 bill icons and the 7 colours) | Bills get their own tile; schema v4 |
| S44 Custom… | Not designed | A sheet: Every 1–99, Days · Weeks · Months · Years | — |
| S44 (dark) | White card, near-invisible text | `fillSoft` card with `ink` text | Design bug |
| S34 Currency | Suggested (MYR, SGD, USD) and All currencies | Malaysian Ringgit only | MYR only for now (15 Nov); the other currencies stay in code for later |
| Dialogs | DESIGN §6: radius 30, 96 px icon | S42 keeps radius 28 and a 60 px icon; S49 uses the new layout | Each follows its own artboard on the 15 Nov canvas |
| S29 goal type and colour | "Travel" purple, "Gadget" pink; S31 picks only an icon | The icon sets both: Travel purple, Car blue, Home green, Gadget pink, Personal red, Gift orange | Only Travel and Gadget are on the canvas |
| S29 Total saved | Amount wraps onto two lines | One line, with this period's net beside it | — |
| S29 completed goals | A collapsed row | Tapping it lists them; each opens S30 | The canvas doesn't show it open |
| S29, S30, S31 Travel icon | Paper-plane arrow | Lucide plane | The Travel icon key is shared with categories |
| S30 monthly amount | "Save RM 360 a month" | RM 450 for that example | Months left count from next month to the target month, which gives S31's RM 616 (agreed in 5.5) |
| S30 Edit, Delete | Not on the canvas | "Edit" in the header opens S31, which has Delete | — |
| S30 Add money, Withdraw | Not designed | The keypad sheet with an optional note | A blank note saves as "Added" or "Withdrawn" |
| S31 Target amount | "8,000" | "8,000.00" | Amounts show cents everywhere |
| S31 Target date | Not designed | A month picker sheet | S43 picks days |
| S36 title | — | Kept to one line, scaling down on narrow screens | — |
| S41 Note row | Always shown | Only when there's a note | S12 has one text field |
| S42 and swipe-to-delete red | — | The light theme's red in both themes | Contrast |
| Delete all data | Not on the canvas | S42-style dialog | Added in 3.13 |

Copy that follows the screens over the PRD, and other per-task decisions, are recorded in the commit messages and `docs/PLAN.md`.

## 15 Nov 2026 spec: decisions where the designs are silent

- **S26 By category order.** The PeriodDetail artboard lists Food (RM 512) above Bills (RM 612). The app sorts by amount spent, largest first, as S18 does, so the biggest categories are easiest to find.
- **S62 Delete goal.** The sheet row already says what goes ("Removes the goal and its 4 contributions…"), so it deletes without a second dialog. Delete left S31, which the AddGoal artboard shows without it.
- **S62 Mark as completed** is left out once a goal is completed.
- **S61 Withdraw label.** "From salary" is only the Add money default; a withdrawal starts blank and saves as "Withdrawn" if left blank.
- **S30 status tiles:** On track green wallet (as designed), Behind amber warning, Past target date red alert, Goal reached green check.
- **S29 completed goals** expand into the same cards as active goals, with "Completed {date}" in place of the type chip.
- **Current PIN check** (Change PIN, turning app lock off) reuses the S64 layout as "Enter your current PIN"; wrong tries say "That's not your PIN. Try again." and count toward the S66 lockout.
- **Hide amounts in app switcher** covers the app with the ground colour on iOS while it isn't active, and sets FLAG_SECURE on Android, which also blocks screenshots while the option is on.
- **S38 lock screen** sits above the whole app, so the screen underneath is kept; it uses the splash logo at 76 px. Biometrics, when on, prompt over it as it opens. Only going to the background (hidden or paused) starts the Lock after clock; a prompt or banner (inactive) doesn't.
- **S37 Preview lock screen** checks the real PIN but doesn't count wrong ones, has a ✕, and no Forgot PIN?.
- **S67 on a phone with no lock** goes to Erase all data without the "Export a CSV first" link, which would get past the lock.
- **S12/S13 entry screens** follow the earlier design (`docs/design/Add Edit transaction.png`, `Add income.png`), not the 15 Nov canvas (`AddTransaction`, `EditTransaction`): by request after v1.1. More opens the newer S46 Choose category. The one text row becomes the title (at most 40 characters); a transaction's note isn't typed here, but is kept when editing and still shows on S41 and in CSV.

