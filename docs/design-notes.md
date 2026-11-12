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
| S01, S02 brand symbol | Brand-board artwork | Drawn in code | The symbol SVG isn't exported yet (`brand_symbol.dart`, `shortcut:`) |
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
| S36 title | — | Kept to one line, scaling down on narrow screens | — |
| S41 Note row | Always shown | Only when there's a note | S12 has one text field |
| S42 and swipe-to-delete red | — | The light theme's red in both themes | Contrast |
| Delete all data | Not on the canvas | S42-style dialog | Added in 3.13 |

Copy that follows the screens over the PRD, and other per-task decisions, are recorded in the commit messages and `docs/PLAN.md`.
