# ctrlSpend — Design System

The single reference for how ctrlSpend looks. Values come from the "CtrlSpend UI" canvas (design-system board, brand board and the 44 screens). If a screen and this file disagree, the screen wins; update this file.

- Behaviour and copy: `docs/PRD.md`
- Code conventions: `CLAUDE.md`
- Screen exports: `docs/design/<File>.png` and `<File>Dark.png`

---

## 1. Principles

1. **One number first.** Every screen leads with the figure that answers its question (left to spend, spent this period, saved). Everything else is smaller and quieter.
2. **Soft and roomy.** Cool off-white ground, white cards with large radii, generous padding. No borders on cards; separation comes from space and surface colour.
3. **Navy does the work.** Near-black navy (`ink`) is both the text colour and the accent: primary buttons, selected states, the hero card and the add button. Colour is reserved for categories and status.
4. **Colour always has words.** Warning and negative states always come with text ("82%", "Over by RM 10").
5. **Same layout, flipped tokens.** Dark mode never changes layout; only tokens change.

---

## 2. Brand

| Item | Rule |
|---|---|
| Name | **ctrlSpend** — lowercase "ctrl", capital "S". Package `ctrl_spend`. |
| Wordmark | "ctrl" in Poppins 800 + "Spend" in Poppins 500, set tight |
| Symbol | An amber coin with a navy **⌃** caret cut into it, on a navy key-shaped tile |
| Parent | ctrlWorks. In sentences: "ctrlSpend, from ctrlWorks". Never "ctrlWorks Spend". |
| Endorsed lockup | "ctrlSpend by ctrlWorks" — App Store page and website |
| Splash footer | "by BrendanLTW" |
| Small sizes | The symbol must stay legible at 24 px; below 48 px use the symbol without the wordmark |

The app icon and splash use the symbol tile. Export the symbol from the brand board as SVG into `assets/brand/`.

---

## 3. Colour

### 3.1 Core tokens

| Token | Light | Dark | Use |
|---|---|---|---|
| `ground` | `#F7F8FA` | `#0B1018` | Screen background |
| `surface` | `#FFFFFF` | `#161D29` | Cards, rows, list groups, chips, fields, sheets, nav bar |
| `raised` | `#EEF1F6` | `#232C3A` | Icon buttons, empty-state tiles, progress tracks, pressed rows |
| `ink` | `#101828` | `#F2F4F7` | Primary text **and** primary accent (buttons, selected states, add button, avatar) |
| `onInk` | `#FFFFFF` | `#0B1018` | Text and icons on `ink` fills |
| `inkPressed` | `#1D2939` | `#D0D5DD` | Pressed state of `ink` fills |
| `muted` | `#5B6B86` | `#98A2B3` | Secondary text, captions, labels, unselected segments |
| `positive` | `#067647` | `#47CD89` | Income amounts, "under" results |
| `negative` | `#D92D20` | `#F97066` | Expense amounts, over budget, destructive actions |
| `warning` | `#B54708` | `#FDB022` | 80–99% of a budget or limit |
| `hero` | `#101828` | `#1C2536` | Budget hero card background |
| `heroTrack` | `#475467` | `#344054` | Progress track on the hero card |

### 3.2 Neutral scale (supporting)

Used for small details; reference them through tokens, never as raw hex in widgets.

| Token | Light | Dark | Use |
|---|---|---|---|
| `divider` | `#EEF1F6` | `#232C3A` | Lines between rows in a list group |
| `fillSoft` | `#F2F4F7` | `#232C3A` | Keypad keys inside sheets, segmented track in sheets, chip pressed |
| `control` | `#D0D5DD` | `#344054` | Toggle off, radio border, "today" ring in the calendar |
| `stepOff` | `#E4E7EC` | `#344054` | Inactive step-indicator segment |
| `disabled` | `#98A2B3` | `#5B6B86` | Past dates, disabled text |
| `chipText` | `#344054` | `#D0D5DD` | Unselected filter chip label |
| `navSelected` | `#EEF1F6` | `#2A3444` | Active tab pill in the bottom bar |

### 3.3 Category tiles

Each category has a tile background and an icon colour. In dark mode the tile is a translucent wash of the chart colour and the icon gets lighter.

| Category | Light tile / icon | Dark tile / icon |
|---|---|---|
| Food | `#FFE2B8` / `#C25E00` | `rgba(251,140,0,.20)` / `#FFB547` |
| Transport | `#CDE6FB` / `#1769C2` | `rgba(33,150,243,.22)` / `#6CB8FF` |
| Shopping | `#FBD3E1` / `#C8174F` | `rgba(240,69,122,.22)` / `#FF7AA2` |
| Bills | `#FFF0B8` / `#8A6100` | `rgba(245,184,0,.20)` / `#FFD34D` |
| Fun | `#E4DBF7` / `#6D3FD1` | `rgba(124,77,219,.26)` / `#B69BFF` |
| Income | `#C9F3D5` / `#1E8A43` | `rgba(23,178,106,.22)` / `#5BD996` |
| Health | `#FEE4E2` / `#D92D20` | `rgba(240,68,56,.22)` / `#FF8A80` |
| Neutral (Gifts, other) | `#EEF1F6` / `#5B6B86` | `#232C3A` / `#98A2B3` |

User-created categories pick from seven colour keys — **orange, blue, pink, yellow, purple, green, red** — which map to Food, Transport, Shopping, Bills, Fun, Income and Health above.

### 3.4 Charts

| Series | Colour |
|---|---|
| Food | `#FB8C00` |
| Shopping | `#F0457A` |
| Transport | `#2196F3` |
| Bills | `#F5B800` |
| Fun | `#7C4DDB` |
| Over budget / over pace | `#F97066` |
| Under budget / under pace | `#98A2B3` |

Chart colours are the same in both themes. Reference lines (daily pace, budget) use `ink` dashed at 1.5 px.

### 3.5 Status pairings

| State | Threshold | Colour | Required text |
|---|---|---|---|
| Neutral | < 80% | `ink` | "{n}%" or "{amount} left" |
| Warning | 80–99% | `warning` | "{n}%" |
| Negative | ≥ 100% | `negative` | "Over by {amount}" |
| No budget | — | `muted` | "Set a monthly budget" |

---

## 4. Typography

**Poppins** only, weights 400, 500, 600, 700 and 800, bundled in `assets/fonts/`. All numbers use tabular figures (`FontFeature.tabularFigures()`).

| Style | Size / weight | Letter-spacing | Line height | Example |
|---|---|---|---|---|
| `display` | 56 / 800 | −1.5 | 1.1 | RM 2,000 (onboarding budget) |
| `amount` | 32 / 700 | −0.8 | 1.2 | RM 1,240.00 (hero) |
| `pageTitle` | 26–28 / 700 | −0.3 to −0.4 | 1.2 | Set your monthly budget |
| `header` | 20 / 700 | 0 | 1.3 | Transaction, dialog titles |
| `rowTitle` | 16 / 600 | 0 | 1.35 | Nasi lemak |
| `rowTitleSm` | 15 / 600 | 0 | 1.35 | Activity rows |
| `body` | 15 / 400–500 | 0 | 1.5 | Supporting copy |
| `button` | 17 / 600 | 0 | 1 | Primary button |
| `caption` | 13 / 400 | 0 | 1.45 | Today · Food |
| `label` | 13 / 600, uppercase | +0.7 | 1.3 | RECENT ACTIVITIES |
| `labelSm` | 11 / 600, uppercase | +0.7 | 1.3 | Stat card labels |
| `statValue` | 21 / 700 | 0 | 1.3 | RM 760 |
| `amountRow` | 15–16 / 700 | 0 | 1.3 | −RM 12.50 |

**Money formatting.** Large amounts (hero, display, period totals) show the cents in a smaller, muted style: on the hero, whole number 32/700 and ".00" 18 in `#98A2B3`. Row amounts show cents at full size. Expenses are prefixed "−" (U+2212) and income "+".

---

## 5. Spacing, radius and elevation

### Spacing
| Token | Value | Use |
|---|---|---|
| `screenX` | 16 | Left/right margin for cards and rows |
| `textX` | 24 | Left/right inset for page titles, section labels and body copy |
| `cardGap` | 10–14 | Between stacked cards or rows |
| `cardPad` | 20–24 | Inside large cards |
| `rowPad` | 12–18 | Inside list rows |
| `sectionTop` | 22 | Space above a section label |

### Radius
| Token | Value | Use |
|---|---|---|
| `r12` | 12 | Small inner elements |
| `r16` | 16 | Icon tiles (48 px), keypad keys in sheets |
| `r20` | 20 | Fields, toast, category tile buttons, empty-state icon |
| `r24` | 24 | Rows, chart cards, segmented control track |
| `r28` | 28 | List groups, budget cards, dialogs, empty-state card |
| `r32` | 32 | Hero card, bottom-sheet top corners |
| `pill` | 999 | Chips, search, bottom bar, progress bars, pill buttons, toggles |

### Elevation
Cards are flat. Shadows appear only on floating elements:

| Element | Light | Dark |
|---|---|---|
| Bottom bar | `0 8 28 rgba(16,24,40,.08)` | `0 8 28 rgba(0,0,0,.5)` |
| Add button | `0 10 24 rgba(16,24,40,.28)` | `0 10 24 rgba(0,0,0,.5)` |
| Toast | `0 10 24 rgba(16,24,40,.25)` | same |
| Dialog | `0 24 48 rgba(16,24,40,.24)` | same, plus a scrim |

---

## 6. Layout patterns

All screens are designed at **390 × 844**. Leave the system status bar area alone (the designs show one only as a placeholder).

### Tab screens (Home, Activity, Budgets, Insights)
- Header row, 64 px: content on the left (period and greeting, or page title), 48 px icon buttons on the right.
- Content scrolls under a floating bottom bar; keep 120 px of bottom padding so the last item clears it.
- **Bottom bar**: a floating pill, 68 px high, 278 px wide, 16 px from the left and 24 px from the bottom, `surface` with the bar shadow. Four items, icon-only (24 px, stroke 1.7) except the active one, which expands into a `navSelected` pill showing icon + label (14/600).
- **Add button**: a separate 64 px `ink` circle, 16 px from the right and 26 px from the bottom, with a white plus and the add-button shadow. Label: "Add transaction".

### Sub-screens
- Top bar, 56 px: 44 px back button on the left, optional title centred, optional action ("Add", "Skip", "Delete") on the right.
- Page title (`pageTitle`) and supporting copy (`body`, `muted`) inset 24 px.

### Onboarding steps
- Top bar with back, a **step indicator** (pills 28 × 6, gap 6; active `ink`, others `stepOff`) and "Skip" where allowed.
- Primary button pinned 34 px from the bottom, 16 px from each side.

### Sheets and dialogs
- **Bottom sheet**: `surface`, top corners 32, full width; contains a header with ✕ close, then content, then a primary button.
- **Dialog**: `surface`, radius 28, 24 px from the screen edges, centred; title `header`, body `body` `muted`, then actions stacked: destructive or primary first, Cancel second.

---

## 7. Components

| Component | Spec |
|---|---|
| **Primary button** | 58 high, radius 22, `ink` fill, `onInk` 17/600 label; pressed `inkPressed`; full width minus 32 |
| **Pill button** | 48 high, pill, padding 0 24, `ink` fill, 15/600 |
| **Text link** | 52 high touch area, 16/600 `ink`, no underline |
| **Destructive button** | Same shape as the dialog button it sits in, `negative` fill, white label; pressed `#B42318` |
| **Icon button** | 48 circle, `raised` fill, 22 px icon stroke 1.8 |
| **Avatar** | 48 circle, `ink` fill, initial in 18/700 `onInk` |
| **Hero card** | `hero` fill, radius 32, padding 22; 56 px white circle icon; `label` in `#D0D5DD`; `amount`; 10 px bar on `heroTrack` with white fill; footer 14/500 `#EAECF0` |
| **Stat card** | `surface`, radius 26, padding 16 × 14; 46 px tinted circle icon (spent: `#FEE4E2`/`negative`, income: `#D1FADF`/`positive`); `labelSm` + `statValue` |
| **Transaction row** | `surface`, radius 22–24, min height 66–72, padding 12 18 12 12; 44–48 px category tile; title + caption; amount right-aligned, coloured by sign |
| **List group** | `surface`, radius 28, rows ≥ 64 high, padding 14 × 18, 16 gap, `divider` between rows, chevron 20 px |
| **Key–value row** | 58 high, padding 0 20, label left, value right in 600 |
| **Category tile (icon)** | 48 × 48, radius 16 (44 × 44, radius 15 in Activity); icon 21–22 px, stroke 1.9, colours from §3.3 |
| **Category picker tile** | 60 × 60, radius 20, `surface`; label below in 12/600 uppercase; selected: `ink` fill with `onInk` icon |
| **Field** | 56 high, radius 20, `surface`, padding 0 20, 22 px leading icon, 15/500 text |
| **Search** | 52 high, pill, `surface`, 20 px search icon in `muted`, placeholder in `muted` |
| **Filter chip** | 44 high, pill, padding 0 18, `surface`, 14/600 `chipText`; selected `ink` fill, `onInk` text |
| **Segmented control** | Track `surface` (on ground) or `fillSoft` (in sheets), radius 24 / 22, padding 8 / 6; segments 46 / 42 high, radius 18 / 16, 15/600 `muted`; selected `ink` fill, `onInk` text |
| **Day selector** | 56 high, radius 18, `surface`, 16/600; selected `ink` fill |
| **Toggle** | 52 × 32 pill; off `control`, on `ink`; 26 px white thumb with a small shadow |
| **Radio** | 24 circle, 2 px `control` border; on: 7 px `ink` border |
| **Progress bar** | 10 high, pill, track `raised`, fill `ink` (or status colour); on the hero, track `heroTrack`, fill white |
| **Money keypad** | 3 × 4 grid. Full screen: keys 56 high, radius 18, `surface`, 22/600. In sheets: keys 48 high, radius 16, `fillSoft`, 21/600. Backspace key uses an icon labelled "Backspace". |
| **Amount display** | `display` style with a smaller "RM" prefix and cents; caption ("per month") in `muted` below |
| **Toast** | 54 high, radius 20, `ink` fill, `onInk` 15/500; action button 15/700 in `#FDB022`; in dark mode the toast is light, so the action uses `#B54708`; sits 106 px from the bottom, above the bar |
| **Empty state** | `surface` card, radius 28, padding 26 24 24, centred; 64 px `raised` tile radius 20 with a 28 px icon; `header`-size title; `body` `muted`; one primary action |
| **Calendar** | 7 columns, weekday initials 12/600 `muted`; days 44 high, radius 14; today: 2 px `control` ring; selected `ink` fill, 700; past days `disabled` |
| **Notification row** | Category or type icon tile, title 15/600, time on the right in `caption`, body `caption`; unread: a small `ink` dot labelled "Unread" |
| **Step indicator** | Pills 28 × 6, gap 6, active `ink`, others `stepOff`; label "Step {n} of {total}" |

### Pressed states
Mobile has no hover. Use the canvas's hover colours as **pressed** colours: rows and chips go to `raised`, `ink` fills go to `inkPressed`, keypad keys go one step darker (`#EAECF0` in sheets).

---

## 8. Iconography

- Line icons on a 24 grid, round caps and joins, stroke 1.7–1.9 (1.7 in the bottom bar, 1.9 in category tiles, 1.8 in buttons and fields, 2–2.4 for small chevrons).
- Nav icons: Home, Activity (list), Budgets (pie), Insights (bars).
- Category icon keys: **food, coffee, car, bag, bolt, film, heart, gift, book, travel, home, phone** (categories) and **travel, car, home, laptop, heart, gift** (goals, v1.1).
- Store icons as an `AppIcon` enum mapped to SVG assets or a custom icon font, so the database stores a key, never a code point from a third-party set.
- Decorative icons are excluded from semantics; icon-only buttons always have a label (Back, Close, Settings, Notifications, Add transaction, Backspace, Clear search, Notification settings).

---

## 9. Dark mode

- Every screen has a dark design (`<File>Dark`). Layout, sizes and copy are identical; only tokens change.
- `ink` flips to near-white, so primary buttons, selected chips and segments, the add button, the avatar and the toast become light with dark text.
- Cards move from white to `surface` `#161D29`; icon buttons, tracks and pressed rows use `raised` `#232C3A`.
- The hero card stays dark but lifts to `#1C2536` so it separates from the ground.
- Category tiles become translucent washes (§3.3); chart colours do not change.
- Status colours switch to their lighter dark values for contrast.

---

## 10. Accessibility

- Text contrast ≥ 4.5:1 against its background in both themes (3:1 only for text ≥ 24 px). `muted` on `ground` and on `surface` passes in both themes; do not use `disabled` for text that must be read.
- Touch targets ≥ 44 × 44, including icon buttons, chips, calendar days and keypad keys.
- Progress bars and charts expose a text label with their values, e.g. "38% of monthly budget spent", "Daily spending: Thursday RM 22.40, …".
- The amount display reads the full amount: "Budget RM 2,000.00 per month".
- Text scales to 200% without clipping; rows grow taller rather than truncating amounts.
- Colour is never the only signal (§3.5).

---

## 11. Flutter implementation

```
lib/core/theme/
  app_colors.dart        # AppColors ThemeExtension: every token in §3.1–3.2, light() and dark()
  category_palette.dart  # CategoryColors: tile + icon per colour key, light and dark
  chart_palette.dart     # Chart series colours
  app_typography.dart    # TextStyles in §4, with tabular figures
  app_spacing.dart       # Spacing tokens in §5
  app_radius.dart        # Radius tokens in §5
  app_shadows.dart       # The four shadows in §5
  app_theme.dart         # buildLightTheme() / buildDarkTheme(): ThemeData + extensions
```

- Map the core tokens onto `ColorScheme` (`surface`, `onSurface` = `ink`, `primary` = `ink`, `onPrimary` = `onInk`, `error` = `negative`) and keep the rest in `AppColors`.
- Widgets read colours with `context.colors.muted`, text with `context.text.rowTitle`, never `Color(0xFF…)` or a raw font size.
- `ThemeMode` comes from the Theme preference (Light, Dark, System).
- Widget tests render each screen under both `buildLightTheme()` and `buildDarkTheme()`.

### Shared widgets (`lib/core/widgets/`)

| Widget | Used on |
|---|---|
| `AppShell` (bottom bar + add button) | S09, S16, S17, S18–S20, S39, S40 |
| `BudgetHero` (four states) | S02, S09, S10, S11 |
| `MoneyKeypad` + `AmountDisplay` | S05, S12, S13, S17, S28, S31 |
| `CategoryTile`, `CategoryPicker` | S12, S13, S16, S22–S24, S41 |
| `TransactionRow` | S09, S16, S23, S41 |
| `ListGroup`, `ListGroupRow`, `KeyValueRow` | S03, S07, S08, S21, S22, S26, S27, S35, S37 |
| `StatCard` | S09, S19, S20 |
| `AppProgressBar` | S06, S09, S17, S23, S25, S29 |
| `SegmentedControl` | S04, S12, S18–S20, S24, S33, S35 |
| `FilterChips`, `SearchField` | S16, S39 |
| `AppToggle`, `AppRadio`, `DaySelector` | S04, S07, S32, S33, S35, S37 |
| `StepIndicator`, `OnboardingScaffold` | S03a–S07 |
| `AppSheet`, `AppDialog` | S17, S24, S42, S43, S44 |
| `AppToast` | S16, S35 |
| `EmptyState` | S10, S15, S39, S40 |
| `MonthCalendar` | S43 |

---

## 12. Fidelity checklist

Before a screen task is marked done, compare it with both exports and check:

- [ ] Colours, type styles, radii and spacing come from tokens only.
- [ ] Layout matches at 390 × 844 in light and dark.
- [ ] Copy matches the design exactly (strings in ARB).
- [ ] Every status colour has text beside it.
- [ ] Touch targets ≥ 44 px; icon-only buttons labelled.
- [ ] Charts and progress bars have screen-reader labels with values.
- [ ] Layout holds at 200% text scale.
