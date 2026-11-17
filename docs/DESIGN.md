# ctrlSpend — Design System

This is the single reference for how ctrlSpend looks. Values come from the "CtrlSpend UI" canvas: the design-system board, the brand board and the 70 screens. If a screen and this file disagree, the screen wins and this file is updated.

- Behaviour and copy: `docs/PRD.md`
- Code conventions: `CLAUDE.md`
- Screen exports: `docs/design/<File>.png` and `<File>Dark.png`

---

## 1. Principles

1. **One number first.** Every screen leads with the figure that answers its question: left to spend, spent this period, or saved. Everything else is smaller and quieter.
2. **Soft and roomy.** A cool off-white ground, white cards with large radii, and generous padding. Cards have no borders; separation comes from space and surface colour.
3. **Navy does the work.** Near-black navy (`ink`) is both the text colour and the accent. It's used for primary buttons, selected states, the hero card and the add button. Colour is reserved for categories and status.
4. **Colour always has words.** Warning, negative and error states always come with text ("82%", "Over by RM 10", "Those PINs don't match").
5. **Same layout, flipped tokens.** Dark mode never changes layout; only tokens change.

---

## 2. Brand

| Item | Rule |
|---|---|
| Name | **ctrlSpend** — lowercase "ctrl", capital "S". Package `ctrl_spend`. |
| Wordmark | "ctrl" in Poppins 400, grey `#5D6169` (on dark `#8A8F99`), then "Spend" in Poppins 700, `#15171C` (on dark `#FFFFFF`). Letter-spacing −2%. |
| Symbol | A green budget ring on a charcoal keycap: `assets/brand/ctrlspend_mark.svg` in the app, `ctrlspend_app_icon.svg` (full-bleed, square corners) for the app icon |
| Brand green | `#22C55E`, only in the logo, the app icon and the splash loader. Never elsewhere in the UI. |
| Parent | ctrlWorks. In sentences: "ctrlSpend, from ctrlWorks". Never "ctrlWorks Spend". |
| Endorsed lockup | "ctrlSpend by ctrlWorks" — App Store page and website |
| Maker credit | "by BrendanLTW" — splash footer and Settings footer |
| Small sizes | The symbol must stay legible at 24 px. Below 48 px, use the symbol without the wordmark. |

The app icon and splash use the keycap. The Android adaptive icon is the ring on `#2C3038`, inside the 66 dp safe zone, with a one-colour ring for themed icons.

---

## 3. Colour

### 3.1 Core tokens

| Token | Light | Dark | Use |
|---|---|---|---|
| `ground` | `#F7F8FA` | `#0B1018` | Screen background |
| `surface` | `#FFFFFF` | `#161D29` | Cards, rows, list groups, chips, fields, sheets, dialogs, nav bar |
| `raised` | `#EEF1F6` | `#232C3A` | Icon buttons, empty-state tiles, progress tracks, pressed rows |
| `ink` | `#101828` | `#F2F4F7` | Primary text **and** primary accent (buttons, selected states, add button, avatar) |
| `onInk` | `#FFFFFF` | `#0B1018` | Text and icons on `ink` fills |
| `inkPressed` | `#1D2939` | `#D0D5DD` | Pressed state of `ink` fills |
| `muted` | `#5B6B86` | `#98A2B3` | Secondary text, captions, labels, unselected segments |
| `positive` | `#067647` | `#47CD89` | Income amounts, "under" results |
| `negative` | `#D92D20` | `#F97066` | Expense amounts, over budget, destructive actions, error outlines |
| `warning` | `#B54708` | `#FDB022` | 80–99% of a budget or limit |
| `hero` | `#101828` | `#1C2536` | Budget hero card, bill and goal summary panels, lock screen |
| `heroTrack` | `#475467` | `#344054` | Progress track on the hero card |

### 3.2 Neutral scale (supporting)

These are for small details. Reference them through tokens, never as raw hex in widgets.

| Token | Light | Dark | Use |
|---|---|---|---|
| `divider` | `#EEF1F6` | `#232C3A` | Lines between rows in a list group |
| `fillSoft` | `#F2F4F7` | `#232C3A` | Keypad keys inside sheets, segmented track in sheets, chip pressed |
| `control` | `#D0D5DD` | `#344054` | Toggle off, radio border, "today" ring in the calendar |
| `buttonDisabled` | `#D0D5DD` | `#2A3444` | Disabled primary button fill (label `#FFFFFF` / `#667085`) |
| `stepOff` | `#E4E7EC` | `#344054` | Inactive step-indicator segment |
| `disabled` | `#98A2B3` | `#5B6B86` | Past dates, placeholders, disabled text |
| `chipText` | `#344054` | `#D0D5DD` | Unselected filter chip label |
| `navSelected` | `#EEF1F6` | `#2A3444` | Active tab pill in the bottom bar |
| `scrim` | `rgba(16,24,40,.42)` | `rgba(0,0,0,.6)` | Behind sheets and dialogs |

### 3.3 Message boxes

Message boxes are used for inline errors, warnings, confirmations and notes. Each has a 20 px icon (alert, check or info) followed by 13/500 text.

| Box | Light background / text | Dark background / text | Used on |
|---|---|---|---|
| `errorBox` | `#FEE4E2` / `#B42318` | `rgba(240,68,56,.16)` / `#FDA29B` | S54, S61, S65 |
| `warningBox` | `#FEF0C7` / `#93370D` | `rgba(247,144,9,.16)` / `#FEC84B` | S48 (permission denied) |
| `successBox` | `#D1FADF` / `#05603A` | `rgba(23,178,106,.16)` / `#75E0A7` | S52 |
| `infoBox` | `#EEF1F6` / `#344054` | `#1C2536` / `#D0D5DD` | S57, S60, S67 |

Status pills (24 high, pill, 12/600) use the same pairs: `red`, `amber` and `green`.

### 3.4 Category tiles

Each category has a tile background and an icon colour. In dark mode, the tile becomes a translucent wash of the chart colour and the icon gets lighter.

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

User-created categories pick from seven colour keys. Each maps to one of the colours above:

| Colour key | Uses the colours of |
|---|---|
| orange | Food |
| blue | Transport |
| pink | Shopping |
| yellow | Bills |
| purple | Fun |
| green | Income |
| red | Health |

### 3.5 Charts

| Series | Colour |
|---|---|
| Food | `#FB8C00` |
| Shopping | `#F0457A` |
| Transport | `#2196F3` |
| Bills | `#F5B800` |
| Fun | `#7C4DDB` |
| Over budget / over pace | `#F97066` |
| Under budget / under pace | `#98A2B3` |

Chart colours are the same in both themes. Reference lines (daily pace, budget) use `ink`, dashed at 1.5 px.

### 3.6 Status pairings

| State | Threshold | Colour | Required text |
|---|---|---|---|
| Neutral | < 80% | `ink` | "{n}%" or "{amount} left" |
| Warning | 80–99% | `warning` | "{n}%" |
| Negative | ≥ 100% | `negative` | "Over by {amount}" |
| No budget | — | `muted` | "Set a monthly budget" |
| Overdue bill | due date passed | `negative` | "Overdue · was due {date}" |

---

## 4. Typography

**Poppins** only, in weights 400, 500, 600, 700 and 800, bundled in `assets/fonts/`. All numbers use tabular figures (`FontFeature.tabularFigures()`).

| Style | Size / weight | Letter-spacing | Line height | Example |
|---|---|---|---|---|
| `display` | 56 / 800 | −1.5 | 1.1 | RM 2,000 (onboarding budget) |
| `amountEntry` | 40 / 800 | −1.4 | 1.15 | RM 12.50 (add, edit, sheets) |
| `amount` | 32 / 700 | −0.8 | 1.2 | RM 1,240.00 (hero) |
| `pageTitle` | 26–28 / 700 | −0.3 to −0.4 | 1.2 | Set your monthly budget |
| `stateTitle` | 22–24 / 700 | 0 | 1.3 | No recurring bills yet, Create a 4-digit PIN |
| `header` | 20 / 700 | 0 | 1.3 | Transaction, sheet and dialog titles |
| `rowTitle` | 16 / 600 | 0 | 1.35 | Nasi lemak |
| `rowTitleSm` | 15 / 600 | 0 | 1.35 | Activity rows |
| `body` | 15 / 400–500 | 0 | 1.5 | Supporting copy |
| `button` | 17 / 600 | 0 | 1 | Primary button |
| `caption` | 13 / 400 | 0 | 1.45 | Today · Food |
| `message` | 13 / 500 | 0 | 1.45 | Message boxes |
| `label` | 13 / 600, uppercase | +0.7 | 1.3 | RECENT ACTIVITIES |
| `labelSm` | 11 / 600, uppercase | +0.7 | 1.3 | Stat card labels |
| `statValue` | 21 / 700 | 0 | 1.3 | RM 760 |
| `amountRow` | 15–16 / 700 | 0 | 1.3 | −RM 12.50 |

**Money formatting.**
- Large amounts (hero, display, entry, period totals) show the cents smaller and muted. On the hero, the whole number is 32/700 and ".00" is 18 in `#98A2B3`.
- Row amounts show cents at full size.
- Expenses are prefixed "−" (U+2212) and income "+".
- Currencies without minor units (e.g. JPY) show no cents (PRD §6.5).

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
| `r18` | 18 | Message boxes, text inputs, compact fields, category picker tiles |
| `r20` | 20 | Fields, toast, PIN pad keys, sheet buttons, empty-state icon |
| `r24` | 24 | Rows, chart cards, segmented control track |
| `r28` | 28 | List groups, budget cards, empty-state card |
| `r30` | 30 | Dialogs |
| `r32` | 32 | Hero card, bottom-sheet top corners |
| `pill` | 999 | Chips, search, bottom bar, progress bars, pill buttons, status pills, toggles |

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

All screens are designed at **390 × 844**. S21 Settings (1064) and S22 Categories (904) are drawn taller to show their full scrolled content. Leave the system status bar area alone; the designs show one only as a placeholder.

### Tab screens (Home, Activity, Budgets, Insights)
- **Header row**, 64 px: content on the left (the period and greeting, or a page title) and 48 px icon buttons on the right.
- **Content** scrolls under a floating bottom bar. Keep 120 px of bottom padding so the last item clears it.
- **Bottom bar**: a floating pill, 68 px high and 278 px wide, 16 px from the left and 24 px from the bottom, in `surface` with the bar shadow. Its four items are icon-only (24 px, stroke 1.7), except the active one, which expands into a `navSelected` pill showing icon and label (14/600).
- **Add button**: a separate 64 px `ink` circle, 16 px from the right and 26 px from the bottom, with a white plus and the add-button shadow. Label: "Add transaction".

### Sub-screens
- Top bar, 56 px: a 44 px back button on the left, an optional title centred, and an optional action on the right ("Add", "Skip", "Delete", "Edit", or ••• for more options).
- Page title (`pageTitle`) and supporting copy (`body`, `muted`) inset 24 px.

### Entry screens (S12, S13, S45)
From top to bottom:
1. Header and the Expense/Income segmented control.
2. Amount display.
3. One scrolling row of category tiles.
4. Title field, then the Date and Note chips side by side.
5. Money keypad, pinned 98 px from the bottom.
6. Save, pinned 24 px from the bottom.

When Save is disabled, a 12 px `muted` hint sits between the keypad and Save.

### Onboarding steps
- A top bar with back, a **step indicator** (5 pills of 28 × 6, gap 6, active `ink`, others `stepOff`) and "Skip" where allowed.
- The primary button is pinned 34 px from the bottom, 16 px from each side. With the keyboard open (S03a), it sits just above the keyboard.

### Sheets and dialogs
- **Bottom sheet**: `surface`, top corners 32, full width, with a 40 × 5 handle. It contains a header with ✕ close (or a title only), then content, then a primary button (56 high, radius 20) inside the sheet. Text-entry sheets (S47) float above the keyboard with all four corners rounded.
- **Action sheet** (S62): a list group of actions, with the destructive one last in `negative`, then a Cancel text button.
- **Dialog**: `surface`, radius 30, 20 px from the screen edges, centred. It has a 96 px state icon, a `header` title, `body` `muted` copy, then actions stacked: destructive or primary first, Cancel second.

### State screens (empty, loading, success, reset)
These are centred, about 170 px from the top on screens with no other content: a 96 px circle icon (`raised`, or the error and success tints), a `stateTitle`, `body` `muted` copy, and one action. Loading uses a 64 px spinner (6 px ring) and a progress bar.

---

## 7. Components

| Component | Spec |
|---|---|
| **Primary button** | 58 high, radius 22, `ink` fill, `onInk` 17/600 label, full width minus 32. Pressed: `inkPressed`. **Disabled**: `buttonDisabled` fill, no press, `aria-disabled`. |
| **Sheet button** | 56 high, radius 20, otherwise as the primary button |
| **Pill button** | 48 high, pill, padding 0 24, `ink` fill, 15/600 |
| **Pay pill** | 34 high, pill, padding 0 12, `ink` fill, 13/600; sits at the end of a bill row |
| **Text link** | 52 high touch area, 16/600 `ink`, no underline |
| **Destructive button** | 56 high, radius 20, `negative` fill, white label. Pressed: `#B42318`. |
| **Icon button** | 48 circle, `raised` fill, 22 px icon with stroke 1.8 |
| **Avatar** | 48–56 circle, `ink` fill, initial in 18–22/700 `onInk` |
| **Hero card** | `hero` fill, radius 32, padding 22. Contents: a 56 px white circle icon, a `label` in `#D0D5DD`, the `amount`, a 10 px bar on `heroTrack` with white fill, and a footer in 14/500 `#EAECF0`. |
| **Stat card** | `surface`, radius 26, padding 16 × 14. Contents: a 46 px tinted circle icon (spent: `#FEE4E2`/`negative`; income: `#D1FADF`/`positive`), then `labelSm` and `statValue`. |
| **Transaction row** | `surface`, radius 22–24, min height 66–72, padding 12 18 12 12. Contents: a 44–48 px category tile, title and caption, and the amount right-aligned, coloured by sign. |
| **List group** | `surface`, radius 28, rows ≥ 56–64 high, padding 14 × 18, 16 gap, `divider` between rows, 20 px chevron |
| **Key–value row** | 58 high, padding 0 20, label left, value right in 600; may end with "›" when tappable |
| **Category tile (icon)** | 48 × 48, radius 16 (40 × 40, radius 13 in compact rows); icon 21–22 px, stroke 1.9, colours from §3.4 |
| **Category picker tile** | 56–60 square, radius 18–20, `surface`, label below in 12/600 uppercase. Selected: `ink` fill with an `onInk` icon. Shown in a single horizontally scrolling row on entry screens. |
| **Field** | 48–56 high, radius 18–20, `surface`, padding 0 18, 20–22 px leading icon, 15/500 text; placeholder in `disabled` |
| **Text input** | 56 high, radius 18, `surface`, 17/500. Focus: 2 px `ink` outline with a 2 px caret. Error: 2 px `negative` outline. A character counter ("4/30") in `caption` sits under it on the right. |
| **Search** | 52 high, pill, `surface` (`fillSoft` in sheets), 20 px search icon and placeholder in `muted` |
| **Filter chip** | 44 high, pill, padding 0 18, `surface`, 14/600 `chipText`. Selected: `ink` fill, `onInk` text. |
| **Segmented control** | Track: `surface` on the ground or `fillSoft` in sheets; radius 24 / 22; padding 8 / 6. Segments: 46 / 42 high, radius 18 / 16, 15/600 `muted`. Selected: `ink` fill, `onInk` text. |
| **Day selector** | 56 high, radius 18, `surface`, 16/600; selected `ink` fill |
| **Toggle** | 52 × 32 pill; off `control`, on `ink`; 26 px white thumb with a small shadow |
| **Radio** | 24 circle with a 2 px `control` border; on: a 7 px `ink` border |
| **Progress bar** | 10 high, pill, track `raised`, fill `ink` (or a status colour). On the hero: track `heroTrack`, fill white. |
| **Money keypad** | 3 × 4 grid with gap 6–8. Keys: 44–48 high, radius 16, `fillSoft`, 21/600. Backspace is an icon key labelled "Backspace". |
| **PIN pad** | 3 × 4 grid with gap 8. Keys: 64 high, radius 20, `surface`, 26/600. Bottom row: blank, 0, Backspace. Above it are 4 dots (16 px, 2 px `disabled` border, filled `ink`; `negative` border on error). |
| **Amount display** | `display` or `amountEntry` style, with a smaller "RM" prefix and cents. Empty: muted "0.00" with a caret. Error: 2 px `negative` outline on its box. |
| **Message box** | Radius 18, padding 12 × 14, 20 px icon and `message` text, colours from §3.3, `role="alert"` for errors |
| **Status pill** | 24 high, pill, padding 0 10, 12/600, `red` / `amber` / `green` from §3.3 |
| **Toast** | 54 high, radius 20, `ink` fill, `onInk` 15/500. The action button is 15/700 in `#FDB022`; in dark mode the toast is light, so the action uses `#B54708`. Sits 106 px from the bottom, above the bar. |
| **Empty state** | Centred: a 96 px `raised` circle with a 40 px icon, then `stateTitle`, `body` `muted` and one pill action. Inline variant: a `surface` card, radius 28, padding 26 24 24. |
| **Spinner** | 64 px ring, 6 px stroke: track `raised`, arc `ink` |
| **Calendar** | 7 columns; weekday initials 12/600 `muted`. Days: 44 high, radius 14. Today: 2 px `control` ring. Selected: `ink` fill, 700. Past days: `disabled`. |
| **Notification row** | Category or type icon tile, title 15/600, time on the right in `caption`, body in `caption`. Unread: a small `ink` dot labelled "Unread". |
| **Step indicator** | Pills 28 × 6, gap 6, active `ink`, others `stepOff`, labelled "Step {n} of 5" |
| **System keyboard** | Shown as a placeholder (291 px) on S03a and S47 only, so layouts account for it. Not built by the app. |

### Pressed states
Mobile has no hover. Use the canvas's hover colours as **pressed** colours:
- Rows and chips go to `raised`.
- `ink` fills go to `inkPressed`.
- Keypad keys go one step darker (`#EAECF0` in sheets).

---

## 8. Iconography

- Line icons on a 24 grid, with round caps and joins. Stroke width depends on where the icon sits:

| Where | Stroke |
|---|---|
| Bottom bar | 1.7 |
| Category tiles | 1.9 |
| Buttons and fields | 1.8 |
| Small chevrons | 2–2.4 |

- Nav icons: Home, Activity (list), Budgets (pie), Insights (bars).
- Category icon keys: **food, coffee, car, bag, bolt, film, heart, gift, book, travel, home, phone**.
- Goal icon keys (v1.1): **travel, car, home, laptop, heart, gift**.
- Utility icons: calendar, note, tag (title), bell, lock, biometric face, trash, file, check, alert, info, repeat, target, clock, edit, flag, search, plus.
- Store icons as an `AppIcon` enum mapped to SVG assets or a custom icon font, so the database stores a key, never a code point from a third-party set.
- Decorative icons are excluded from semantics. Icon-only buttons always have a label: Back, Close, Settings, Notifications, Add transaction, Backspace, Clear search, Notification settings, More options.

---

## 9. Dark mode

- Every screen has a dark design (`<File>Dark`). Layout, sizes and copy are identical; only tokens change.
- `ink` flips to near-white. Primary buttons, selected chips and segments, the add button, the avatar, the Pay pill and the toast become light with dark text.
- Cards, sheets and dialogs move from white to `surface` `#161D29`. Icon buttons, tracks and pressed rows use `raised` `#232C3A`.
- The hero card stays dark but lifts to `#1C2536` so it separates from the ground.
- Category tiles and message boxes become translucent washes (§3.3, §3.4). Chart colours don't change.
- Status colours switch to their lighter dark values for contrast.

---

## 10. Accessibility

- Text contrast is ≥ 4.5:1 against its background in both themes; 3:1 is allowed only for text ≥ 24 px. `muted` on `ground` and on `surface` passes in both themes. Don't use `disabled` for text that must be read.
- Touch targets are ≥ 44 × 44, including icon buttons, chips, calendar days, keypad and PIN keys, and the Pay pill row.
- Progress bars and charts expose a text label with their values, e.g. "38% of monthly budget spent" or "Daily spending: Thursday RM 22.40, …".
- The amount display reads the full amount: "Budget RM 2,000.00 per month".
- PIN dots read "{n} of 4 digits entered". Errors and lockouts are announced (`role="alert"`).
- Disabled buttons expose `aria-disabled` and keep a visible hint explaining why.
- Text scales to 200% without clipping. Rows grow taller rather than truncating amounts.
- Colour is never the only signal (§3.6).

---

## 11. Flutter implementation

```
lib/core/theme/
  app_colors.dart        # AppColors ThemeExtension: every token in §3.1–3.3, light() and dark()
  category_palette.dart  # CategoryColors: tile + icon per colour key, light and dark
  chart_palette.dart     # Chart series colours
  app_typography.dart    # TextStyles in §4, with tabular figures
  app_spacing.dart       # Spacing tokens in §5
  app_radius.dart        # Radius tokens in §5
  app_shadows.dart       # The four shadows in §5
  app_theme.dart         # buildLightTheme() / buildDarkTheme(): ThemeData + extensions
```

- Map the core tokens onto `ColorScheme`: `surface`, `onSurface` = `ink`, `primary` = `ink`, `onPrimary` = `onInk`, `error` = `negative`. Keep the rest in `AppColors`.
- Widgets read colours with `context.colors.muted` and text with `context.text.rowTitle`, never `Color(0xFF…)` or a raw font size.
- `ThemeMode` comes from the Theme preference (Light, Dark, System).
- Widget tests render each screen under both `buildLightTheme()` and `buildDarkTheme()`.

### Shared widgets (`lib/core/widgets/`)

| Widget | Used on |
|---|---|
| `AppShell` (bottom bar + add button) | S09, S16, S17, S18–S20, S39, S40 |
| `BudgetHero` (four states) | S02, S09, S10, S11 |
| `MoneyKeypad` + `AmountDisplay` | S05, S12, S13, S17, S28, S31, S45, S54, S57, S60, S61 |
| `PinPad` + `PinDots` | S38, S64, S65, S66 |
| `CategoryTile`, `CategoryTileRow`, `CategoryPickerSheet` | S12, S13, S16, S22–S24, S41, S45, S46 |
| `TransactionRow` | S09, S16, S23, S41 |
| `ListGroup`, `ListGroupRow`, `KeyValueRow` | S03, S07, S08, S21, S21a, S22, S26, S27, S35, S37, S48, S50, S52, S53, S56, S57, S62, S68 |
| `StatCard` | S09, S19, S20 |
| `AppProgressBar` | S06, S09, S17, S23, S25, S29, S51, S55 |
| `SegmentedControl` | S04, S12, S18–S20, S24, S33, S35, S60, S61 |
| `FilterChips`, `SearchField` | S16, S39, S46 |
| `AppToggle`, `AppRadio`, `DaySelector` | S04, S07, S32, S33, S35, S37, S48, S52, S56, S68 |
| `AppTextInput` (with counter) | S03a, S47 |
| `StepIndicator`, `OnboardingScaffold` | S03a–S07 |
| `AppSheet`, `ActionSheet`, `AppDialog` | S17, S24, S42, S43, S44, S46, S47, S49, S54, S57, S60–S62, S68 |
| `MessageBox`, `StatusPill` | S48, S52, S54, S57, S58, S60, S61, S65, S67 |
| `AppToast` | S16, S35 |
| `EmptyState`, `StateScreen`, `AppSpinner` | S10, S15, S39, S40, S51, S53, S55, S59, S63, S67 |
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
- [ ] Disabled and error states match their designs (S12, S54, S61, S65, S66).
- [ ] Layout holds at 200% text scale.
