# Dark mode audit (task 3.12)

Every v1.0 screen was rendered in dark with Poppins at 390 × 844 and compared with its dark design in `docs/design/`. Remaining differences come from sample data or app state (for example S12 opening with its keypad sheet), not from the theme.

## Screens

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

## Deviations from the dark designs or DESIGN.md

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

## Fixed colours outside the theme

`test/core/theme/no_hardcoded_colours_test.dart` fails on any `Color(0x…)`, `Color.fromRGBO/ARGB` or `Colors.<name>` (other than `transparent`) outside `lib/core/theme/`, except these, each with a reason in the code:

- White on the hero card, which is dark in both themes: `budget_hero.dart`, `app_progress_bar.dart` and `welcome_preview.dart`.
- White text and a darker pressed state on the light theme's red: `pill_button.dart` and `swipe_to_delete.dart`.
- The toggle knob, white when off in both themes: `app_toggle.dart`.

Fixed in this task: the toggle knob's shadow was a literal; it is now the `toggleKnob` token in `AppShadows`.

Every screen has widget tests that run in both themes.
