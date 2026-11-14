# ctrlSpend: UI and specification audit

| | |
|---|---|
| Date | 14 Nov 2026 |
| Scope | The "CtrlSpend UI" design canvas (live version 1794662188-6194: 46 light boards, each with a Dark variant), plus PRD.md, DESIGN.md, PLAN.md and CLAUDE.md |
| Method | I read every board file (`project/<Name>.dc.html`), extracted its visible text and links, and checked each against the PRD section that covers it. No files or designs were changed. |

**How to read the statuses.** Three things are kept separate in this audit:

- **Designed** means a canvas board shows it.
- **Specified** means the PRD or CLAUDE.md defines it.
- **Implemented** means working code exists. No codebase was provided for this review, so **nothing can be confirmed as implemented**. Every "Full" below means *designed and specified*, not built.

Each feature gets one overall status:

| Status | Meaning |
|---|---|
| **Full** | Designed and specified, and the two agree. |
| **Partial** | Both exist, but one is incomplete or they disagree. |
| **UI only** | Designed, but not specified. |
| **Spec only** | Specified, but not designed. |
| **Missing** | Neither designed nor specified. |
| **N/A** | Explicitly out of scope for v1 (PRD §2 non-goals). |

Release tags: **v1.0** = P0 + P1 and **v1.1** = P2, both from PRD §7. **Future** = outside both releases.

---

## 1. Coverage summary

Counts cover the MVP features in sections 1, 2, 3, 4, 5, 6, 7 and 9 of the table. Future-scope items (section 8 and the N/A rows) are counted separately.

| | Count | Share |
|---|---|---|
| MVP features assessed | **102** | 100% |
| Full (designed and specified) | **49** | 48% |
| Partial | **26** | 25% |
| Spec only | **9** | 9% |
| UI only | **0** | 0% |
| Missing (neither) | **18** | 18% |
| Implemented in code | **0 confirmed** | No codebase reviewed |
| Future / N/A, listed separately | **16** | — |

**Headline findings**

1. **The core loop is well covered.** Logging a transaction, seeing what's left, budgets, categories, insights and past periods are all designed and specified in detail.
2. **Most gaps are flows, not screens.** Examples:
   - There is no designed way to mark a bill paid.
   - Money can't be added to or withdrawn from a goal.
   - The user can't edit their name or reminder settings after onboarding.
   - A PIN can't be created or recovered.
   - A CSV import can't succeed.
3. **Five points of disagreement between the canvas and the PRD block v1.0 build work.** The PRD says the canvas wins, but in these cases the canvas is the side that is behind:
   - The onboarding step count is out of date.
   - OnbName is missing from the canvas.
   - The income categories differ.
   - The v1.1 rows are visible in Settings.
   - The S12 amount field and the transaction title don't match the spec.
4. **One data-model gap affects correctness.** Past periods show each period's budget and category limits, but the data model doesn't store budget history. After the user changes their budget, old periods would be recalculated against the new amount.

---

## 2. Feature-by-feature table

Evidence names the board file (`<Name>.dc.html` on the canvas) and the PRD section. Every board has a matching `<Name>Dark` variant, which isn't repeated in the table.

### 2.1 Transaction management (FR-03, FR-04, FR-08 · v1.0)

| # | Feature | Overall | UI status | Spec status | Evidence / file | Recommendation |
|---|---|---|---|---|---|---|
| 1.1 | Add expense | **Partial** | Only shown in edit mode. The board is titled "Edit transaction" with Delete; no "New expense" state is drawn. | Specified: titles New expense / New income / Edit transaction | `AddTransaction` · PRD §5.3 | Add a "New expense" state (empty, Save disabled). |
| 1.2 | Add income | **Partial** | Designed ("New income") | Specified | `AddTransactionIncome` · §5.3 | Fix the category mismatch; see inconsistency I-3. |
| 1.3 | Edit transaction | **Full** | Designed: prefilled, with Delete. Opened from TxnDetail → Edit. | Specified, including prefill acceptance | `AddTransaction`, `TxnDetail` · §5.3, §5.13 | Fix the PRD's S12 "Opened from: Edit on S24", which should be S41. |
| 1.4 | Delete with confirmation | **Full** | Designed: dialog | Specified | `TxnDelete` · §5.13 | — |
| 1.5 | Swipe to delete, with Undo | **Full** | Designed: swipe action plus the "Transaction deleted · Undo" toast | Specified (5-second undo) | `Activity` · §5.5 | — |
| 1.6 | Transaction detail | **Full** | Designed | Specified | `TxnDetail` · §5.13 | — |
| 1.7 | Amount entry with the money keypad | **Partial** | S12 shows the amount "12.50" as a text input, with no keypad. The keypad appears only on `Main` and the `Budgets` sheet. | Specified: keypad on S05, S12, S13, S17, S28, S31 | `AddTransaction`, `AddTransactionIncome` · §6.1 | Decide: keypad (as in the spec) or system keyboard. Then align the board or §6.1. |
| 1.8 | Transaction title / payee | **Missing** | No title field on S12, yet rows show titles ("Nasi lemak") | §8 has a `title` field, but §5.3 has no input for it and no rule for filling it in | `AddTransaction`, `Activity` · §5.3, §8 | Specify where the title comes from: its own field, the first line of the note, or the category name. |
| 1.9 | Category selection, with More | **Partial** | 6 tiles plus More. More links to `Categories` (the manager), not to a picker. | Specified: More opens the full list for picking | `AddTransaction` · §5.3 | Specify or design a category picker sheet. Don't send More to the manager. |
| 1.10 | Date selection | **Partial** | The "Today, 4 Nov" row exists but isn't linked to `DatePicker` | Specified: S12 → S43 | `AddTransaction`, `DatePicker` · §5.3 | Link it. Specify whether future dates are allowed and whether the time of day is editable (S41 shows a time). |
| 1.11 | Note | **Full** | Designed | Specified | `AddTransaction` · §5.3 | — |
| 1.12 | Save validation (amount 0 or no category disables Save) | **Spec only** | No disabled state drawn | Specified | §5.3 acceptance | Draw the disabled Save state. |
| 1.13 | Search | **Full** | Designed, with an empty state | Specified (case-insensitive; title, note and category) | `Activity`, `SearchEmpty` · §5.5 | — |
| 1.14 | Filter by type and category | **Full** | Designed: chips | Specified | `Activity` · §5.5 | Specify how the category chips are chosen and ordered (there are only 2 visible). |
| 1.15 | Filter by date range | **Missing** | — | — | `Activity` | v1.0 can rely on past periods (S25 and S26). Keep this as P3. |
| 1.16 | Sort (amount, date) | **Missing** | — | — | `Activity` | P3. The date-grouped list is enough for the MVP. |
| 1.17 | Day groups with net totals | **Full** | Designed | Specified | `Activity` · §5.5 | — |
| 1.18 | Recurring income | **Missing** | — | Recurring bills cover only expenses | §5.11 | Don't add a separate "recurring transactions" feature, because it would duplicate Bills. Decide whether bills can be income-type in a later version. |
| 1.19 | Transactions by category | **Full** | Designed (recent list) | Specified | `CategoryDetail` · §5.9 | — |

### 2.2 Budget management (FR-05, FR-07, FR-13 · v1.0)

| # | Feature | Overall | UI status | Spec status | Evidence / file | Recommendation |
|---|---|---|---|---|---|---|
| 2.1 | Overall monthly budget | **Full** | Designed: onboarding keypad, plus the Budgets card and sheet | Specified | `Main`, `Budgets` · §5.1 S05, §5.6 | — |
| 2.2 | Skip the budget ("no overall budget") | **Full** | Designed: hero state | Specified | `HeroStates` · §5.2 | — |
| 2.3 | Category limits | **Full** | Designed | Specified | `OnbCategories`, `Budgets`, `AddCategory`, `CategoryDetail` · §5.1 S06, §5.6 | — |
| 2.4 | Payday period / month start | **Full** | Designed | Specified (`periodFor`, 1–28 or last day) | `OnbSetup`, `SetMonthStart` · §6.2 | — |
| 2.5 | Progress and thresholds (under 80%, 80–99%, 100% and over) | **Full** | Designed: 4 hero states and category percentages | Specified | `HeroStates`, `Budgets` · §6.3 | — |
| 2.6 | Edit or remove a budget | **Partial** | Designed: "Food budget" sheet with Remove and Save | Removing a category limit is specified. Removing the **overall** budget is not stated. | `Budgets` · §5.6 | State that removing the overall budget shows the "no overall budget" state, and whether category limits remain. |
| 2.7 | Over-allocation validation (limits greater than the budget) | **Spec only** | No error state on OnbCategories or the Budgets sheet | Rule stated, but no message or behaviour | §5.1 S06, §12 risks | Specify the message and whether Save is blocked or capped, then design the state. |
| 2.8 | Lowering the budget below allocated limits | **Missing** | — | — | — | Specify: block the change, warn, or scale the limits down. |
| 2.9 | Budget alerts at 80% and 100% | **Full** | Designed | Specified | `OnbReminders`, `Notifications` · §5.4 | — |
| 2.10 | Past periods and period detail | **Full** | Designed | Specified | `PeriodList`, `PeriodDetail` · §5.10 | — |
| 2.11 | Budget history (each period's own budget and limits) | **Partial** | Past periods show each period's budget and limit | §8 stores only the *current* `monthlyBudgetMinor` and `limitMinor`. There is no history. | `PeriodDetail` · §8 | Add a period snapshot or a budget-history entity, or specify that past periods use the current budget. This is P0 for data model correctness. |
| 2.12 | Changing the month start mid-period | **Partial** | Preview of the current and next period | Spec says "recalculates every period" | `SetMonthStart` · §5.8 acceptance | Specify what happens to the in-progress period and its alerts. |
| 2.13 | Rollover of unspent budget | **Missing** | — | — | — | Decide on it explicitly. Recommendation: list it as a v1 non-goal. |

### 2.3 Account and profile management (FR-01, FR-10 · v1.0)

| # | Feature | Overall | UI status | Spec status | Evidence / file | Recommendation |
|---|---|---|---|---|---|---|
| 3.1 | Name capture in onboarding | **Spec only** | No `OnbName` board on the canvas | Fully specified (S03a) | §5.1 S03a · PLAN pre-task | Add OnbName and OnbNameDark (a known PLAN pre-task). |
| 3.2 | Edit name later | **Spec only** | The Settings profile row ("Alex · Data stored on this phone") has no link and no edit state | Specified: "opens a field to change the name" | `Settings` · §5.8 | Design the edit-name sheet. |
| 3.3 | Currency | **Full** | Designed | Specified (symbol only, no conversion) | `OnbSetup`, `SetCurrency` · §5.8 S34 | See 3.4. |
| 3.4 | Currency formatting (decimals, symbol position) | **Missing** | — | Only RM is shown. Formatting for currencies without minor units (e.g. JPY) or with the symbol after the amount isn't defined. | §8, CLAUDE.md minor units | Specify the minor-unit count and the locale format per currency. |
| 3.5 | Theme (light / dark / system) | **Full** | Designed | Specified | `SetTheme` · §5.8 S33 | — |
| 3.6 | Reset or delete all data | **Missing** | — | — | `Settings` | Add "Erase all data", with confirmation. This matters for a privacy-first app and for demos. P1. |
| 3.7 | Re-entering setup values later | **Partial** | Month start, currency, theme and budget are reachable. Name and reminders are not (3.2, 9.10). | Acceptance: "Every value chosen in onboarding appears in Settings" | `Settings` · §5.1 acceptance | Fixed by 3.2 and 9.10. |

### 2.4 Insights and analytics (FR-09, FR-13, FR-15 · v1.0)

| # | Feature | Overall | UI status | Spec status | Evidence / file | Recommendation |
|---|---|---|---|---|---|---|
| 4.1 | Month: category breakdown | **Full** | Designed, with a screen-reader sentence | Specified | `Insights` · §5.7 S18 | — |
| 4.2 | Week: daily bars against pace | **Full** | Designed | Specified (pace formula) | `InsightsWeek` · §5.7 S19 | — |
| 4.3 | 6-month trend against budget | **Full** | Designed | Specified | `InsightsTrend` · §5.7 S20 | — |
| 4.4 | Empty / not enough data | **Full** | Designed | Specified | `InsightsEmpty` · §5.7 S40 | Define "a few days" as a number. |
| 4.5 | Text alternatives for charts | **Partial** | Seen on the Month view. Not verifiable for the Week and 6-month bar charts from the board text. | Specified for every chart | `Insights`, `InsightsWeek`, `InsightsTrend` · §5.7, §9 | Add the label text to the Week and Trend boards so the handoff is explicit. |
| 4.6 | Drill-down from an insight category | **Missing** | No links from the category rows | — | `Insights` | Specify tap → `CategoryDetail` (existing screen). Don't add a new screen. |
| 4.7 | Viewing an earlier month or week in Insights | **Partial** | No previous/next control | Not specified. Past periods (S25 and S26) cover month history. | `Insights`, `PeriodList` | Keep using S25 and S26 for history. Don't add a duplicate pager. State this in the PRD. |
| 4.8 | Category detail stats | **Full** | Designed, but only the Food row links to it | Specified | `CategoryDetail`, `Categories` · §5.9 | Make every category row link to the detail screen. |
| 4.9 | Income or net-savings insights | **Missing** | — | — | — | P3. The Dashboard's Income card is enough for v1. |
| 4.10 | Weekly summary notification | **Full** | Designed | Specified | `Notifications`, `OnbReminders` · §5.4 | — |

### 2.5 Savings and goals (FR-17 · v1.1)

| # | Feature | Overall | UI status | Spec status | Evidence / file | Recommendation |
|---|---|---|---|---|---|---|
| 5.1 | Goals list with total saved | **Full** | Designed | Specified | `Savings` · §5.12 S29 | — |
| 5.2 | Create a goal | **Full** | Designed, with a live monthly hint | Specified (rounding rule) | `AddGoal` · §5.12 S31 | — |
| 5.3 | Goal detail and progress | **Full** | Designed | Specified | `GoalDetail` · §5.12 S30 | — |
| 5.4 | Add money / Withdraw | **Partial** | Buttons exist but link back to `GoalDetail`. No sheet is designed. | Rules are specified (not spending), but there is no field list (amount, label, date) | `GoalDetail` · §5.12, §8 GoalContribution | Specify the sheet fields and validation (e.g. a withdrawal can't exceed the amount saved). Design it with the keypad. |
| 5.5 | Completed goals | **Full** | Designed: collapsed "1 completed goal" | Specified | `Savings` · §5.12 | Specify what the expanded state shows. |
| 5.6 | "On track" status | **Partial** | "On track" shown | Only the monthly need is defined. There's no rule for "behind" or "overdue". | `GoalDetail` · §5.12 | Define the status states and their thresholds. |
| 5.7 | Edit / delete a goal | **Missing** | — | — | `GoalDetail` | Specify edit and delete, including what happens to contributions on delete. |
| 5.8 | Empty state (no goals) | **Missing** | — | — | `Savings` | Add an empty state. |

### 2.6 Bills and subscriptions (FR-16 · v1.1)

| # | Feature | Overall | UI status | Spec status | Evidence / file | Recommendation |
|---|---|---|---|---|---|---|
| 6.1 | Bills list (upcoming and paid) | **Full** | Designed | Specified | `Bills` · §5.11 S27 | — |
| 6.2 | Add a bill | **Full** | Designed | Specified | `AddBill` · §5.11 S28 | — |
| 6.3 | Repeat options | **Partial** | Designed, including "Custom…" | "Custom…" isn't defined | `RepeatPicker` · §5.11, §8 | Define Custom, or remove it for v1.1. |
| 6.4 | Next due date | **Full** | Designed (linked to DatePicker) | Specified | `AddBill`, `DatePicker` | — |
| 6.5 | **Mark as paid** | **Spec only** | No action on the Bills board | Specified: it creates a transaction and advances `nextDue` | `Bills` · §5.11 acceptance | Design the mark-paid action, its confirmation (amount and date can be edited) and Undo. This blocks v1.1. |
| 6.6 | Left after bills | **Full** | Designed | Specified (derived) | `Bills` · §5.11, §8 | — |
| 6.7 | Bill reminders | **Partial** | Toggle on AddBill | The reminder is specified, but §5.4's list of notification types has no bill-due type | `AddBill`, `Notifications` · §5.4, §5.11 | Add a "bill due" type to §5.4 and to the Notifications board. |
| 6.8 | Edit / delete / pause a bill | **Missing** | — | — | `Bills` | Specify them. Deleting a bill should keep the transactions it already created (`billId`). |
| 6.9 | Overdue bill state | **Missing** | — | — | `Bills` | Define what happens when `nextDue` passes while the bill is unpaid. |
| 6.10 | Empty state (no bills) | **Missing** | — | — | `Bills` | Add an empty state. |

### 2.7 Data management and security (FR-14 · v1.0; FR-18 · v1.1)

| # | Feature | Overall | UI status | Spec status | Evidence / file | Recommendation |
|---|---|---|---|---|---|---|
| 7.1 | CSV export | **Partial** | Designed: range, include toggles, toast | Specified. The "Custom" range has no picker flow, and the column layout isn't defined. | `ExportCSV` · §5.8 S35 | Specify the custom range (two dates using `DatePicker`) and the CSV columns. |
| 7.2 | CSV import: file selection and success | **Partial** | Only the failure screen exists. The Settings "Import" row goes straight to `ImportError`. | All-or-nothing is specified. There's no success result, duplicate handling or confirmation. | `Settings`, `ImportError` · §5.8 S36 | Design import → validating → success ("Imported n transactions"). Specify duplicate handling and whether unknown categories are created or rejected. |
| 7.3 | CSV format definition | **Missing** | A sample CSV link exists | No column, date format or encoding spec | `ImportError` · §5.8 | Write one CSV schema that is shared by export and import, so a round trip works. P1. |
| 7.4 | Import failed (row errors) | **Full** | Designed | Specified | `ImportError` · §5.8 S36 | — |
| 7.5 | App lock toggle and options | **Full** | Designed | Specified | `SetAppLock` · §5.8 S37 | — |
| 7.6 | Create / change PIN | **Spec only** | The "Change PIN" row links to `#`. There's no PIN-entry screen for first setup or confirmation. | Mentioned only | `SetAppLock` · §5.8 S37, §8 | Design the enter → confirm PIN flow and the mismatch error. |
| 7.7 | Lock screen | **Full** | Designed | Specified | `LockScreen` · §5.8 S38 | — |
| 7.8 | Forgot PIN | **Spec only** | "Forgot PIN?" links to `#` | One sentence: reset with Face ID or the phone passcode | `LockScreen` · §5.8 S37 | Specify the reset flow and the case where biometrics are off. |
| 7.9 | Wrong-PIN attempts / lockout | **Missing** | No error state | — | `LockScreen` | Specify the attempt limit, delay and error message. |
| 7.10 | Biometric unlock | **Full** | Designed | Specified | `SetAppLock`, `LockScreen` · §5.8, §10 | Use platform-neutral wording ("Face ID" is iOS-only; Android uses fingerprint). |
| 7.11 | Hide amounts in the app switcher | **Full** | Designed | Specified | `SetAppLock` · §5.8 acceptance | — |
| 7.12 | Lock after (timeout) | **Partial** | Row shows "Immediately" | Options aren't listed | `SetAppLock` · §5.8 | List the options. |
| 7.13 | Offline and privacy messaging | **Full** | Designed: OnbHow privacy block, profile row text | Specified | `OnbHow`, `Settings` · §10 | — |
| 7.14 | v1.0 → v1.1 data migration | **Full** | No UI needed | Specified | PRD §11 Phase 5 | — |

### 2.8 General UI/UX

| # | Feature | Overall | UI status | Spec status | Evidence / file | Recommendation |
|---|---|---|---|---|---|---|
| 9.1 | Splash | **Full** | Designed ("by BrendanLTW") | Specified | `Splash` · §5.1 S01 | — |
| 9.2 | Onboarding flow | **Partial** | 7 screens; steps read "Step 1–4 of 4" | 8 screens; steps "1–5 of 5" | `OnbSetup`, `Main`, `OnbCategories`, `OnbReminders` · §5.1 | See I-1 and I-2. |
| 9.3 | Welcome: skip the tour | **Full** | Designed | Specified | `OnbWelcome` · §5.1 S02 | — |
| 9.4 | Onboarding month start "Other" | **Partial** | Options 1st / 15th / 25th / Other | Other → S32 | `OnbSetup` · §5.1 S04 | Link Other → `SetMonthStart`. |
| 9.5 | Bottom navigation with add button | **Full** | Designed | Specified | `Dashboard` · §4 | — |
| 9.6 | Dashboard and first run | **Full** | Designed | Specified | `Dashboard`, `DashboardEmpty`, `HeroStates` · §5.2 | — |
| 9.7 | Notifications inbox and empty | **Full** | Designed | Specified | `Notifications`, `NotificationsEmpty` · §5.4 | — |
| 9.8 | OS notification permission (granted / denied) | **Partial** | A button only. The denied state isn't drawn. | A request is specified, but not what happens if it's denied | `OnbReminders` · §5.1 S07 | Specify the denied state and how to re-enable from Settings. |
| 9.9 | Notification preferences after onboarding | **Spec only** | Settings has no Notifications row. The inbox's settings icon links to `Settings`. | "A settings icon opens notification preferences" | `Settings`, `Notifications` · §5.4 | Add a Notifications preferences screen (daily time, alerts, weekly). This is needed to meet the §5.1 acceptance. |
| 9.10 | Reminder time | **Partial** | Fixed "9:00 PM" | Stored in Preferences, but there's no picker | `OnbReminders` · §8 | Put a time picker on the screen from 9.9. |
| 9.11 | Dark mode | **Full** | Every board has a Dark variant | Specified | `<Name>Dark` boards · DESIGN.md, §9 | — |
| 9.12 | Empty states | **Partial** | Dashboard, Notifications, Search and Insights | Same four | `DashboardEmpty`, `NotificationsEmpty`, `SearchEmpty`, `InsightsEmpty` | Add empty states for Bills, Savings, Past periods (first period) and the Activity filter with no results. |
| 9.13 | Error and validation states | **Partial** | Only `ImportError` | Rules exist (§5.1 S03a, §5.3, §5.1 S06), but they have no designed states | — | Design the inline errors listed in §4. |
| 9.14 | Loading states | **Partial** | Only the splash loader | Not specified | `Splash` | Specify loading for import and export. Elsewhere the app works locally, so skeletons aren't needed. |
| 9.15 | Toasts / feedback | **Full** | Designed: undo and export | Specified | `Activity`, `ExportCSV` · §9 | — |
| 9.16 | Category manager, archive and restore | **Full** | Designed | Specified | `Categories`, `AddCategory` · §5.9 | See I-3 (Gifts). |
| 9.17 | Accessibility | **Partial** | aria-labels on icon buttons; a screen-reader sentence on Insights | Specified (§9, §10) | `Insights`, `Dashboard` · §9 | Run a contrast check on both themes before handoff. |
| 9.18 | Design system board | **Full** | Designed | Specified | `StyleGuide` · DESIGN.md, §9 | — |
| 9.19 | Brand board | **Full** | Designed | Specified | `BrandFamily2` · §9 | — |
| 9.20 | Motion, haptics and transitions | **Missing** | — | — | — | P3. Specify sheet and page transitions and the haptic on Save. |
| 9.21 | Web demo variant (lock and notifications hidden) | **Spec only** | No UI needed beyond hiding rows | Specified | §10 | — |

### 2.9 Advanced and future scope (kept separate from the MVP)

These are deliberately **not** counted as MVP gaps.

| # | Feature | Status | Evidence | Recommendation |
|---|---|---|---|---|
| 8.1 | Bank linking / open banking | **N/A** (non-goal) | PRD §2 | Keep out. |
| 8.2 | Accounts / sign-in | **N/A** | §2 | Keep out. |
| 8.3 | Cloud backup, sync, multi-device | **N/A** | §2 | CSV export is the backup. Say so in the README. |
| 8.4 | Shared or household budgets | **N/A** | §2 | — |
| 8.5 | Investments, net worth, debt | **N/A** | §2 | — |
| 8.6 | Currency conversion | **N/A** | §2, §5.8 S34 | — |
| 8.7 | Multiple wallets (cash, e-wallet, card) | **N/A** | §2 ("accounts") | The "Mei" persona mentions cash and e-wallet. Clarify that this is solved with categories or notes, not accounts. |
| 8.8 | Transfers between accounts | **N/A** | Follows from 8.7 | — |
| 8.9 | Other ctrl apps (ctrlBill, ctrlHome, ctrlPlay) | **N/A** | §2 | — |
| 8.10 | Receipt photos / OCR | **Future** | — | Candidate for v1.2+. |
| 8.11 | Split transactions | **Future** | — | — |
| 8.12 | AI insights / predictions | **Future** | — | Conflicts with the "no network" rule unless it runs on the device. |
| 8.13 | Subscription detection | **Future** | — | Would build on Bills. Don't create a separate "Subscriptions" feature. |
| 8.14 | Home-screen widgets | **Future** | — | A good fit for the "one number" promise. |
| 8.15 | Rollover of unspent budget | **Future** | Row 2.13 | Decide whether it's a non-goal. |
| 8.16 | Date-range filter and sort in Activity | **Future** | Rows 1.15 and 1.16 | — |

---

## 3. Missing UI screens and states

Everything below already has a home in an existing screen family, so none of it is a new feature.

| # | Missing screen or state | Needed for | Release |
|---|---|---|---|
| U-1 | **OnbName (S03a)**, light and dark | FR-01 | v1.0 · P0 |
| U-2 | **Add transaction · New expense** (empty, Save disabled) | FR-03 | v1.0 · P0 |
| U-3 | **Category picker sheet** (from More on S12) | FR-03 | v1.0 · P0 |
| U-4 | **Edit name** sheet (from the Settings profile row) | FR-01 | v1.0 · P1 |
| U-5 | **Notification preferences** (daily reminder and time, budget alerts, weekly summary, permission denied) | FR-12 | v1.0 · P1 |
| U-6 | **Import flow**: file chosen → validating → success | FR-14 | v1.0 · P1 |
| U-7 | **Export · Custom range** (two-date picker) | FR-14 | v1.0 · P1 |
| U-8 | **Over-allocation error** on OnbCategories and the Budgets sheet | FR-05 | v1.0 · P1 |
| U-9 | **Erase all data** confirmation | Privacy | v1.0 · P1 |
| U-10 | **Mark bill paid** action and confirmation | FR-16 | v1.1 · P2 |
| U-11 | **Edit / delete bill**; overdue state; Bills empty state | FR-16 | v1.1 · P2 |
| U-12 | **Add money / Withdraw** sheet | FR-17 | v1.1 · P2 |
| U-13 | **Edit / delete goal**; Savings empty state | FR-17 | v1.1 · P2 |
| U-14 | **Create PIN / confirm PIN / change PIN** | FR-18 | v1.1 · P2 |
| U-15 | **Forgot PIN** and **wrong PIN / lockout** states | FR-18 | v1.1 · P2 |
| U-16 | Past periods empty (first period) | FR-13 | v1.0 · P3 |

## 4. Missing specifications and user flows

### 4.1 Missing user flows (end to end)

| # | Flow | What's missing |
|---|---|---|
| F-1 | **First launch → working budget** | The name step is missing from the design. "Other" month start isn't linked to S32. There's no denied-permission branch. Back-navigation state retention is in the acceptance criteria but not drawn. |
| F-2 | **Log a new expense** | The new state, the keypad, the category picker and the date picker link are all undrawn, and the transaction title has no source. This is the app's core 10-second goal (PRD §2). |
| F-3 | **Change reminders after onboarding** | There's no route at all. |
| F-4 | **Change my name** | Specified, but has no screen. |
| F-5 | **Import a CSV successfully** | Only failure is designed. The file format is unspecified. |
| F-6 | **Pay a bill** | Mark paid → transaction created → next due date advanced → "Left to spend" updated. None of this is drawn. |
| F-7 | **Contribute to or withdraw from a goal** | The buttons go nowhere. |
| F-8 | **Turn on app lock for the first time** | Toggle → create PIN → confirm → optional biometrics. Not drawn. |
| F-9 | **Locked out / forgot PIN** | Not drawn. Only one sentence in the spec. |
| F-10 | **Start a new period** | The "New period started" notification exists, but the dashboard at reset (day 1) and the move of the old period into the past list aren't described. |
| F-11 | **Delete a category with no transactions** | Specified (delete, not archive), but no confirmation is designed. |

### 4.2 Missing business rules and validation

| # | Area | Rule needed |
|---|---|---|
| R-1 | Transaction | Source and maximum length of `title`; whether future dates are allowed; whether the time is editable; maximum note length. |
| R-2 | Budget history | How past periods keep their own budget and limits (snapshot or history table). |
| R-3 | Budget | What happens when the budget is lowered below the allocated limits, and when the overall budget is removed. |
| R-4 | Month start | What happens to the in-progress period and pending alerts when the start day changes. |
| R-5 | Currency | Minor-unit count and format per currency (decimals, symbol position, grouping). |
| R-6 | CSV | Column schema, date format, encoding, category matching, duplicates, maximum rows. |
| R-7 | Alerts | Whether an 80% or 100% alert fires again after an edit makes it drop and then cross again. Whether it's once per period per category. |
| R-8 | Bills | Overdue behaviour; meaning of "Custom…" repeat; edit and delete effects on created transactions; a bill-due notification type. |
| R-9 | Goals | Status thresholds (on track / behind / overdue); the maximum withdrawal; what happens on goal deletion; what an edited target date does. |
| R-10 | PIN | PIN length (the board shows 4 digits), attempt limit and lockout, behaviour when biometrics are turned off. |
| R-11 | Name | Already specified (1–30 characters, trimmed). It just needs a design. |
| R-12 | Category | Maximum name length. Behaviour when a limit is set on an income category (AddCategory allows limits for both types). |

---

## 5. Inconsistencies between the UI and the specification

The PRD header says "Where this file and a screen disagree, the screen wins and this file is updated." For several items below, though, the **spec is the newer decision** (recorded in PLAN.md as canvas pre-tasks), so the canvas should change instead.

| # | Inconsistency | Canvas | Spec | Which should change |
|---|---|---|---|---|
| I-1 | Onboarding step count | "Step 1–4 of 4" on `OnbSetup`, `Main`, `OnbCategories`, `OnbReminders` | "1–5 of 5" (§4, §5.1) | Canvas (PLAN pre-task) |
| I-2 | Name step | No `OnbName` board | S03a specified | Canvas (PLAN pre-task) |
| I-3 | Income categories | `AddTransactionIncome`: Salary, Freelance, Refund, Gift, Interest, Other. `Categories`: Income has Salary only, and **Gifts is archived**. | Defaults are Salary and Gifts (§5.3, §8) | Canvas (PLAN pre-task). Also un-archive Gifts in `Categories`. |
| I-4 | Settings rows in v1.0 | `Settings` shows App lock (On), Recurring bills (5) and Savings goals (2) | Hidden in v1.0 (§5.8) | Neither is wrong. Add a v1.0 Settings variant, or note on the board that these rows are v1.1. |
| I-5 | Amount input on S12 and S13 | Text input "12.50" | Money keypad (§6.1) | Decide, then align. |
| I-6 | S12 "More" target | Opens `Categories` (the manager) | Opens the full list for picking | Canvas link. |
| I-7 | S12 date row | Not linked | → S43 | Canvas link. |
| I-8 | Add transaction states | Only "Edit transaction" drawn | Three titles | Canvas (U-2). |
| I-9 | Transaction title | Rows show titles; no input exists | `title` field in §8 | Spec (R-1). |
| I-10 | S12 "Opened from" | — | "Edit on S24" (S24 is Add category) | PRD typo: should be S41. |
| I-11 | Screen count | 46 light boards, plus brand and style boards | DESIGN.md says "44 screens"; PRD says 46 | DESIGN.md. |
| I-12 | Profile row | No link or edit state | "Opens a field to change the name" | Canvas (U-4). |
| I-13 | Notification settings icon | Links to `Settings`, which has no notifications section | "Opens notification preferences" | Canvas (U-5). |
| I-14 | Import entry | Settings → `ImportError` directly | Import → validate → all or nothing | Canvas (U-6). |
| I-15 | Category → detail | Only Food links to `CategoryDetail` | Any category row | Canvas links. |
| I-16 | Goal actions | Add money / Withdraw link back to `GoalDetail` | Contributions specified | Canvas (U-12). |
| I-17 | Change PIN / Forgot PIN | Both link to `#` | Mentioned in §5.8 | Canvas (U-14, U-15). |
| I-18 | Biometric wording | "Face ID" only | §10 says "biometric" | Platform-neutral copy on Android. |
| I-19 | Endorsement | `BrandFamily2`: "by ctrlWorks" / App Store developer ctrlWorks. `Splash`: "by BrendanLTW". | Both stated in §9 (consistent) | No change. Noted only so it isn't "fixed" by mistake. |
| I-20 | Bill reminder | AddBill has a Remind toggle | §5.4 has no bill-due notification type | Spec (R-8). |

---

## 6. Priorities

### P0: blocks v1.0 build start (fix in design and spec first)

1. **I-1, I-2, U-1.** Add OnbName and fix "of 5" across onboarding.
2. **I-3.** Align the income categories (Salary, Gifts) and un-archive Gifts in `Categories`.
3. **F-2 / U-2, U-3, I-5, I-6, I-7, I-9, R-1.** Complete the "log a new expense" flow: new state, keypad decision, category picker, date link and title rule.
4. **R-2.** Decide how past periods keep their own budget, before the Drift schema is written in Phase 1.
5. **I-10, I-11.** Fix the documentation typos (S24 → S41; 44 → 46 screens).

### P1: needed for v1.0 to be complete (P0 + P1 release)

1. **U-5, F-3, 9.8–9.10.** Notification preferences, the reminder time and the permission-denied branch.
2. **U-4, F-4.** Edit name.
3. **U-6, F-5, R-6, 7.1–7.3.** One CSV schema, the import success flow and the export custom range.
4. **U-8, R-3, 2.6–2.8.** Over-allocation and budget-change rules and their states.
5. **R-4, R-5, R-7.** Month-start change, currency formatting and alert re-firing rules.
6. **U-9.** Erase all data.
7. **I-4.** A v1.0 Settings variant without the v1.1 rows.
8. **I-15, 4.6.** Every category row links to `CategoryDetail`, including from Insights.
9. **9.12–9.14.** The remaining empty, error and loading states for v1.0 screens.

### P2: needed for v1.1 (bills, goals, app lock)

1. **U-10, F-6, R-8.** Mark bill paid, overdue, edit/delete, bill-due notification, "Custom…" repeat.
2. **U-12, U-13, F-7, R-9.** The goal contribution sheet, edit/delete and the status rules.
3. **U-14, U-15, F-8, F-9, R-10.** PIN creation, change, forgot and lockout.
4. **I-18.** Platform-neutral biometric copy.

### P3: polish, or a later decision

- Activity date-range filter and sort (1.15, 1.16).
- Income and net-savings insights (4.9).
- Motion and haptics spec (9.20).
- Rollover decision (2.13).
- Past periods empty state (U-16).
- Future-scope items in §2.9, which should be re-evaluated after v1.1.

---

## 7. Duplicates avoided

These were considered and deliberately **not** recommended, because an existing feature already covers them:

- "Recurring transactions" is already covered by **Recurring bills** (S27, S28).
- "Subscriptions" is the same as **Recurring bills**.
- "Monthly report" or history pager is covered by **Past periods** (S25, S26) and **6-month trend** (S20).
- "Category spending detail" is **Category detail** (S23). Link to it instead of building a new screen.
- "Backup" is the **CSV export** (S35), given the no-cloud non-goal.
- "Spending limit per category" is the existing **category limits** (S06, S17, S24).

---

## 8. Resolution log (15 Nov 2026)

After this audit, the gaps were drawn on the canvas and written into PRD.md and DESIGN.md. Sections 1–7 above are kept as the original findings. This table records what changed.

| Finding | Resolution | Where |
|---|---|---|
| I-1, I-2, U-1 · Onboarding "of 4", no name step | Added the OnbName screen. Steps 1–5 now read "of 5". How it works → OnbName. | `OnbName`, `OnbSetup`, `Main`, `OnbCategories`, `OnbReminders`, `OnbHow` · PRD §5.1 |
| I-3 · Income categories, Gifts archived | New income shows Salary and Gifts. Gifts is active again in Categories (Coffee is the archived example). | `AddTransactionIncome`, `Categories` |
| I-4 · v1.1 rows visible in Settings | Two boards: Settings v1.1 (full scroll) and Settings v1.0 | `Settings`, `SettingsV10` · PRD §5.8 |
| I-5, I-8, U-2, 1.12 · Text amount, no "New expense" state | New expense (empty, Save disabled with a hint), New income and Edit transaction now all use the money keypad | `AddTransaction`, `AddTransactionIncome`, `EditTransaction` · PRD §5.3 |
| I-6, U-3 · More opens the manager | Category picker sheet | `CategoryPicker` · PRD §5.3 |
| I-7 · Date row not linked | Date chip → DatePicker | Entry screens |
| I-9, R-1 · No title input | Optional title field (≤ 40 characters, defaults to the category name). Note ≤ 200 characters. No future dates. | Entry screens · PRD §5.3, §8 |
| I-10, I-11 · S24 typo, 44 screens | Fixed. The PRD inventory now lists 70 screens. | PRD §4, DESIGN.md |
| I-12, U-4, F-4 · Name not editable | Edit name sheet from the profile row | `EditName` · PRD §5.8 |
| I-13, U-5, F-3, 9.8–9.10 · No notification settings | Notification settings, with reminder time, bill reminders and a permission-denied banner | `NotifPrefs` · PRD §5.4 |
| I-14, U-6, F-5, 7.2, 7.3, R-6 · Import had only an error screen | Checking → Review (duplicates, new categories) → Success. One CSV format shared with export. | `ImportChecking`, `ImportReview`, `ImportSuccess` · PRD §5.8, §6.4 |
| U-7, 7.1 · Export custom range | From/To rows with a live count | `ExportRange` |
| I-15, 4.6 · Only Food linked to detail | Every category row in Categories and Insights → CategoryDetail | `Categories`, `Insights` |
| U-8, R-3, 2.6–2.8 · Over-allocation | Error state on the limit sheet. The same rule applies when lowering the budget. Removing the budget keeps the limits. | `BudgetOverAlloc` · PRD §5.6 |
| U-9, 3.6 · Erase all data | Settings row and confirmation dialog | `EraseData` · PRD §5.8, FR-19 |
| 2.11, R-2 · Budget history | PeriodSnapshot entity, written at each period end | PRD §6.2, §8 |
| R-4, R-5, R-7 · Month-start change, currency format, alert re-firing | Decided | PRD §5.8, §6.5, §5.4 |
| 2.13, 1.15, 1.16 · Rollover, date filter, sort | Listed as v1 non-goals | PRD §2 |
| U-10, F-6, 6.5 · Mark paid | Pay pill on each bill, Mark-as-paid sheet | `Bills`, `BillPay` · PRD §5.11 |
| U-11, 6.8, 6.9, 6.10, R-8 · Bill edit/delete/pause, overdue, empty | Bill detail, overdue state, empty state. "Custom…" repeat defined. A bill-due notification type was added. | `BillDetail`, `BillsOverdue`, `BillsEmpty` · PRD §5.4, §5.11 |
| I-16, U-12, F-7, 5.4 · Goal money sheets | Add money and Withdraw sheets. A withdrawal can't exceed the amount saved. | `GoalContribute`, `GoalWithdraw` · PRD §5.12 |
| U-13, 5.6–5.8, R-9 · Goal edit/delete, status, empty | Options sheet, the three status rules, empty state | `GoalActions`, `SavingsEmpty` · PRD §5.12 |
| I-17, U-14, U-15, F-8, F-9, 7.6–7.9, 7.12, R-10 · PIN flows | Create and confirm PIN (mismatch), escalating lockout after 5 wrong PINs, Forgot PIN, Lock after options | `PinCreate`, `PinConfirm`, `LockWrong`, `ForgotPin`, `LockAfter` · PRD §5.8 |
| I-18 · "Face ID" wording | "Biometrics", with "Face ID or fingerprint" as the subtitle | `SetAppLock`, `LockScreen` |
| U-16 · Past periods empty | Empty state for the first period | `PeriodListEmpty` · PRD §5.10 |
| OnbSetup links | Currency → SetCurrency; Other → SetMonthStart | `OnbSetup` |

**Still open, all P3 polish:**
- the motion and haptics spec (9.20)
- income and net-savings insights (4.9)
- a contrast measurement pass in both themes (9.17)
