# Quality audit

Dark mode (task 3.12) and accessibility (task 4.1) for every v1.0 screen.

## Dark mode (task 3.12)

Every v1.0 screen was rendered in dark with Poppins at 390 × 844 and compared with its dark design in `docs/design/`. Remaining differences come from sample data or app state (for example S12 opening with its keypad sheet), not from the theme.

### Screens

| Screen | Dark design | Matches | Notes |
|---|---|---|---|
| S01 Splash | Splash · Dark | Yes | Checked in the P0 review |
| S02 Welcome | Onboarding 1 · Welcome · Dark | Yes | |
| S03 How it works | Onboarding 2 · How it works · Dark | Yes | |
| S04 Set up your month | Onboarding 3 · Currency & period · Dark | Yes | |
| S05 Set budget | Onboarding 4 · Set budget · Dark | Yes | |
| S06 Category limits | Onboarding 5 · Category limits · Dark | Yes | |
| S07 Reminders | Onboarding 6 · Reminders · Dark | Yes | |
| S08 All set | Onboarding 7 · All set · Dark | Yes | |
| S09 Dashboard | Dashboard · Dark | Yes | Red unread dot on the bell, as designed |
| S10 First run | Dashboard · First run · Dark | Yes | |
| S11 Hero states | Budget hero · 4 states · Dark | Yes | Widget tests cover all four in both themes |
| S12 / S13 Add, edit | Add Edit transaction · Dark, Add income · Dark | Yes | Amount card uses `surface` (the canvas shows white) |
| S14 Notifications | Notifications · Dark | Yes | See deviations |
| S15 Notifications empty | Notifications · Empty · Dark | Yes | |
| S16 Activity | Activity · Dark | Yes | |
| S17 Budgets | Budgets · Dark | Yes | |
| S18 Insights · Month | Insights · Dark | Yes | |
| S19 Insights · Week | Insights · Week · Dark | Yes | See deviations |
| S20 Insights · 6 months | Insights · 6-month trend · Dark | Yes | See deviations |
| S21 Settings | Settings · Dark | Yes | v1.1 rows hidden |
| S22 / S24 Categories | Category manager · Dark, Add category · Dark | Yes | |
| S23 Category detail | Category detail · Dark | Yes | See deviations |
| S25 Past periods | Past periods · Dark | Yes | See deviations |
| S26 Period detail | Past period detail · Dark | Yes | |
| S32 Month start | Settings · Month start · Dark | Yes | |
| S33 Theme | Settings · Theme · Dark | Yes | |
| S34 Currency | Settings · Currency · Dark | Yes | |
| S35 Export | Settings · Export CSV · Dark | Yes | |
| S36 Import failed | Error · Import failed · Dark | Yes | |
| S39 No search results | Empty · No search results · Dark | Yes | |
| S40 Insights no data | Empty · Insights no data · Dark | Yes | |
| S41 Transaction | Transaction detail · Dark | Yes | |
| S42 Delete dialog | Dialog · Delete transaction · Dark | Yes | See deviations |
| S43 Date picker | Picker · Date · Dark | Yes | Future days disabled for transactions |

### Deviations from the dark designs or DESIGN.md

Where a dark design looked like a mistake, or disagreed with DESIGN.md, the app follows the screen or the shared rules, as agreed during each task.

| Where | Design says | App does | Why |
|---|---|---|---|
| S19, S20 under-pace and under-budget bars | DESIGN §3.4: chart colours are the same in both themes | `disabled` token (lighter grey in light, darker in dark) | Matches both screens |
| S19, S20 reference lines | DESIGN §3.4: `ink` | `muted` | Matches both screens |
| S20 View past periods | Dark design: white bar, near-invisible text | `surface` with `ink` text | Design bug |
| S23 period bar | Category colour on a light peach track, in dark too | Shared status colours on `raised` | One threshold function everywhere (CLAUDE.md); design bug in the dark track |
| S25 results | Dark design: grey "Over by" and "under" | Red and green in both themes | Colour paired with text, as in the light design and S26 |
| S14 unread dot | DESIGN §7: `ink` | The blue category icon colour | Matches both screens |
| S42 and swipe-to-delete red | — | The light theme's red in both themes | White on the dark theme's red falls below 4.5:1 |

### Fixed colours outside the theme

`test/core/theme/no_hardcoded_colours_test.dart` fails on any `Color(0x…)`, `Color.fromRGBO/ARGB` or `Colors.<name>` (other than `transparent`) outside `lib/core/theme/`, except these, each with a reason in the code:

- White on the hero card, which is dark in both themes: `budget_hero.dart`, `app_progress_bar.dart` and `welcome_preview.dart`.
- White text and a darker pressed state on the light theme's red: `pill_button.dart` and `swipe_to_delete.dart`.
- The toggle knob, white when off in both themes: `app_toggle.dart`.

Fixed in this task: the toggle knob's shadow was a literal; it is now the `toggleKnob` token in `AppShadows`.

Every screen has widget tests that run in both themes.

## Accessibility (task 4.1)

Checked on every screen listed in `test/helpers/screens.dart` (31, with sample data), against DESIGN §10.

### What the tests enforce

- `test/accessibility/guidelines_test.dart`: every screen, in light and dark, meets Flutter's guidelines: tap targets of at least 48 px (Android) and 44 px (iOS), every tap target labelled, and text contrast.
- `test/accessibility/large_text_test.dart`: every screen at 200% text, with Poppins loaded, lays out without errors, and no amount on screen is cut short with an ellipsis.
- Charts and progress bars have screen-reader labels with their values; their widget tests check the exact text.

### Found and fixed

| Problem | Fix |
|---|---|
| Segmented control segments were 46 px (42 in sheets), under Android's 48 and, in sheets, iOS's 44 | The track's padding is part of each segment's tap area: 62 px (54 in sheets), same look |
| Segment labels cut short at large text ("This p…") | Up to two lines; the control grows |
| Primary button cut off a wrapped label | 58 px is now the minimum height |
| S05's pinned keypad left no room for the content at large text | `OnboardingScaffold` scrolls its footer with the content at 150% text and up |
| Label-and-value rows squeezed the label to a character per line (S19/S20 headers, S25, S26, S14, S24, S32, S06, S16 day headers, settings rows) | `SpreadOrStack`: side by side normally, the value below the label from 150% text; the value never takes more than 60% of the row |
| Pairs of cards too narrow at large text (S09 Spent/Income, Insights stats, S18 grid) | `PairOrStack`: one per row from 150% text |
| Amounts truncated or broken across lines (S18 cards, S23, S19/S20 totals, S34 symbols) | Kept on one line, scaled down only if they still don't fit |
| S12 category labels ran together at large text | Small padding between the scaled-down labels |
| S32's Last day of the month button clipped its label | Minimum height instead of a fixed one |

### Accepted

- Transaction titles in Activity and Recent activities can truncate at large text; DESIGN §10 asks only that amounts never do.
- At 200%, long single words can break mid-word on a 390 px screen ("notifica-tions" on S15). Nothing is clipped.
- The bottom bar shows the active tab's label truncated at 200%; every tab still has its full label for screen readers.

## Performance (task 4.3)

PRD §10: with 5,000 transactions, an interactive dashboard within 2 s of a cold start on a mid-range Android phone, and lists at 60 fps.

### Sample data

Debug builds have **Settings → Developer → Add 5,000 sample transactions** (`lib/features/dev/`): 12 months of realistic expenses and income in the default categories, saved in one database transaction. The section only shows when `kDebugMode` is true, so release builds never show it.

### Calculations

`test/benchmarks/hot_paths_test.dart` times what screens compute over every transaction when data changes, with the 5,000-transaction sample. Medians on the Dart VM in debug (JIT), so slower than a release build on a phone:

| Work | Before | After |
|---|---|---|
| Activity: group by day | 5.5 ms | 5.5 ms |
| S18: category shares | 2.8 ms | 2.6 ms |
| S19: last seven days | 2.8 ms | 2.6 ms |
| S20: six periods | 15.7 ms | 13.1 ms |
| S25: twelve previous periods | 62.4 ms | 16.7 ms |
| Notifications: compare after a save | 10.6 ms | 10.4 ms |
| Notifications: catch-up | 5.2 ms | 5.1 ms |

Fixed: S20 and S25 rescanned every transaction for each period. `transactionsByPeriod` now groups them in one pass. The test fails if any of these passes 100 ms, which would mean quadratic work crept back in. Activity builds its rows lazily, so scrolling doesn't rebuild the list.

### On a device (pending)

Not yet measured: no Android phone was available. To measure, on a mid-range Android phone in profile mode:

1. Frame timings and dashboard readiness with 5,000 transactions:
   `flutter drive --profile --driver=test_driver/integration_test.dart --target=integration_test/performance_test.dart`
   The test fails if the dashboard takes 2 s or more, or if the 90th-percentile build or raster time passes 16.7 ms while scrolling Activity, switching Insights views or opening Categories. Summaries are written to `build/integration_response_data.json`.
2. Cold start from launch: `flutter run --profile --trace-startup`, then read `timeToFirstFrameMicros` in `build/start_up_info.json`.

