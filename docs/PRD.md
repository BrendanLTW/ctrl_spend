# ctrlSpend — Product Requirements Document

| | |
|---|---|
| Product | **ctrlSpend** (package `ctrl_spend`), from ctrlWorks |
| Type | Offline-first personal budgeting app (Flutter, iOS and Android) |
| Purpose | Portfolio project |
| UI source of truth | The "CtrlSpend UI" design canvas, which has: 70 light screens, a dark version of each, a design-system board and a brand board. Export the screens to `docs/design/`. |
| Related | `CLAUDE.md` (conventions), `docs/PLAN.md` (tasks), `claude/AUDIT.md` (UI and spec audit, 14 Nov 2026) |
| Last updated | 15 Nov 2026: added 26 screens (S21a, S45–S69) and the rules decided in the audit pass |

This PRD follows the design canvas. Where this file and a screen disagree, the screen wins and this file is updated.

---

## 1. Overview

ctrlSpend answers one question first: **how much is left to spend this period?** The user sets one monthly budget and lines the period up with payday. They log spending in seconds, and the home screen keeps count. Everything stays on the phone: there's no account and no bank login.

**Promise (splash and onboarding):** "Know what's left to spend, every day."

**Problem.** People who try to track spending give up within weeks. Logging is slow, and apps want an account or bank access first. Calendar-month budgets also don't line up with when the money actually arrives.

**Approach.**
- **One number:** a single monthly budget and a big "Left to spend" figure.
- **Payday periods:** the budget period starts on the user's chosen day (e.g. 15 Oct – 14 Nov).
- **Optional category limits:** set only for the categories the user tends to overspend on. The rest stays flexible.
- **Ten-second logging:** tap +, type the amount, pick a category.
- **Private by design:** data stays on the device, with CSV export and import whenever the user likes.

---

## 2. Goals and non-goals

### Product goals
- Log a transaction in **≤ 10 seconds** from opening the app.
- The dashboard answers "how much is left?" **within 5 seconds** for a first-time viewer.
- Onboarding to a working budget in **under 2 minutes**.
- Work **fully offline**, with no account.

### Portfolio goals
- Feature-first Flutter architecture with enforced layer boundaries.
- Unit, widget and end-to-end tests, with CI on every push.
- Light and dark themes built from one token set.
- A live demo, an APK, and a README explaining key decisions.

### Non-goals (v1)
- Bank linking, accounts, cloud sync or multi-device use. CSV export is the backup.
- Multiple wallets or accounts (cash, e-wallet, card). Use categories or notes instead.
- Shared or household budgets.
- Investments, net worth or debt tracking.
- Currency conversion. Switching currency changes the symbol and format only.
- Rolling unspent budget into the next period. Each period starts fresh.
- Activity date-range filters and sorting. Past periods (S25–S26) cover history.
- The other ctrlWorks apps (ctrlBill, ctrlHome, ctrlPlay).

---

## 3. Target users

| Persona | Context | Needs |
|---|---|---|
| **Alex**, 27, salaried, paid on the 15th | Rent, transport and food take most of the salary | A period that starts on payday; one clear "left to spend" number |
| **Daniel**, 31, freelancer | Irregular income, several subscriptions | Income logging, recurring bills, what's left after bills |
| **Mei**, 21, student | Tight allowance, cash and e-wallet | Fast entry, no sign-up, reminders to log |

The design uses **Alex** as the sample user.

---

## 4. Information architecture

### Navigation
- **Bottom bar:** four tabs (**Home · Activity · Budgets · Insights**) and a raised round **add button** in the centre. The add button opens New expense (S12) from any tab.
- **Dashboard header:** on the left, the period dates and "Hi, {name}". On the right, a **notifications bell** (with an unread badge) and an **avatar** that opens **Settings**.
- Sub-screens open with a back button. Create and edit screens open as full screens or sheets with a close (✕) button.

### Screen inventory

| ID | Screen (canvas title) | File | Opened from |
|---|---|---|---|
| **Onboarding** | | | |
| S01 | Splash | `Splash` | App launch |
| S02 | Onboarding 1 · Welcome | `OnbWelcome` | First launch |
| S03 | Onboarding 2 · How it works | `OnbHow` | Welcome → Get started |
| S03a | Onboarding · Your name (step 1 of 5) | `OnbName` | How it works → Continue or Skip |
| S04 | Onboarding · Currency & period (step 2 of 5) | `OnbSetup` | Your name → Continue |
| S05 | Onboarding · Set budget (step 3 of 5) | `Main` | Continue |
| S06 | Onboarding · Category limits (step 4 of 5) | `OnbCategories` | Continue |
| S07 | Onboarding · Reminders (step 5 of 5) | `OnbReminders` | Continue |
| S08 | Onboarding · All set | `OnbDone` | Turn on notifications / Not now |
| **Home and adding** | | | |
| S09 | Dashboard | `Dashboard` | Home tab |
| S10 | Dashboard · First run | `DashboardEmpty` | Home tab with no transactions |
| S11 | Budget hero · 4 states | `HeroStates` | Reference for S09 |
| S12 | New expense (Save disabled until valid) | `AddTransaction` | Add button; S08; S10 |
| S13 | New income | `AddTransactionIncome` | Income toggle on S12 |
| S45 | Edit transaction | `EditTransaction` | Edit on S41 |
| S46 | Picker · Category | `CategoryPicker` | More on S12, S13, S45 |
| S14 | Notifications | `Notifications` | Bell on S09 |
| S15 | Notifications · Empty | `NotificationsEmpty` | Bell, none yet |
| **Tabs and management** | | | |
| S16 | Activity | `Activity` | Activity tab |
| S17 | Budgets (with Edit budget sheet) | `Budgets` | Budgets tab |
| S18 | Insights · Month | `Insights` | Insights tab |
| S19 | Insights · Week | `InsightsWeek` | Week segment |
| S20 | Insights · 6-month trend | `InsightsTrend` | 6 months segment |
| S21 | Settings · v1.1 (full scroll) | `Settings` | Avatar on S09 (v1.1) |
| S21a | Settings · v1.0 | `SettingsV10` | Avatar on S09 (v1.0) |
| S22 | Category manager | `Categories` | Settings → Categories |
| S23 | Category detail | `CategoryDetail` | Any category row on S22 or S18 |
| S24 | Add category (sheet) | `AddCategory` | Add on S22; New category on S46 |
| **Periods, bills and goals** | | | |
| S25 | Past periods | `PeriodList` | View past periods on S20 |
| S55 | Past periods · Empty | `PeriodListEmpty` | S25 during the first period |
| S26 | Past period detail | `PeriodDetail` | A period row |
| S27 | Recurring bills | `Bills` | Settings → Recurring bills |
| S58 | Recurring bills · Overdue | `BillsOverdue` | S27 when a bill is overdue |
| S59 | Recurring bills · Empty | `BillsEmpty` | S27 with no bills |
| S56 | Bill detail | `BillDetail` | A bill row on S27 |
| S57 | Sheet · Mark bill as paid | `BillPay` | Pay on S27; Mark as paid on S56 |
| S28 | Add bill | `AddBill` | Add on S27; Edit on S56 |
| S29 | Savings goals | `Savings` | Settings → Savings goals |
| S63 | Savings goals · Empty | `SavingsEmpty` | S29 with no goals |
| S30 | Goal detail | `GoalDetail` | A goal row |
| S60 | Sheet · Add money to goal | `GoalContribute` | Add money on S30 |
| S61 | Sheet · Withdraw from goal | `GoalWithdraw` | Withdraw on S30 |
| S62 | Sheet · Goal options | `GoalActions` | ••• on S30 |
| S31 | Add goal | `AddGoal` | Add on S29; Edit goal on S62 |
| **Settings, data, security and states** | | | |
| S47 | Settings · Edit name | `EditName` | Profile row on S21 |
| S48 | Settings · Notifications | `NotifPrefs` | Settings → Notifications; settings icon on S14 |
| S32 | Settings · Month start | `SetMonthStart` | Settings → Month starts on; Other on S04 |
| S33 | Settings · Theme | `SetTheme` | Settings → Theme |
| S34 | Settings · Currency | `SetCurrency` | Settings → Currency; S04 |
| S35 | Settings · Export CSV | `ExportCSV` | Settings → Export to CSV |
| S50 | Settings · Export · Custom range | `ExportRange` | Custom on S35 |
| S51 | Import · Checking file | `ImportChecking` | Settings → Import from CSV, after a file is picked |
| S52 | Import · Review | `ImportReview` | S51 when every row is valid |
| S53 | Import · Success | `ImportSuccess` | Import on S52 |
| S36 | Error · Import failed | `ImportError` | S51 when any row is invalid |
| S49 | Dialog · Erase all data | `EraseData` | Settings → Erase all data |
| S37 | Settings · App lock | `SetAppLock` | Settings → App lock |
| S68 | Picker · Lock after | `LockAfter` | Lock after on S37 |
| S64 | App lock · Create PIN | `PinCreate` | Turning on app lock; Change PIN; S67 |
| S65 | App lock · Confirm PIN (mismatch) | `PinConfirm` | After S64 |
| S38 | Lock screen | `LockScreen` | App open with lock on |
| S66 | Lock screen · Too many attempts | `LockWrong` | 5 wrong PINs on S38 |
| S67 | App lock · Forgot PIN | `ForgotPin` | Forgot PIN? on S38 |
| S39 | Empty · No search results | `SearchEmpty` | Search on S16 |
| S40 | Empty · Insights no data | `InsightsEmpty` | Insights with no data |
| S54 | Error · Category limits over budget | `BudgetOverAlloc` | Edit sheet on S17; S06 |
| **Detail, dialogs and pickers** | | | |
| S41 | Transaction detail | `TxnDetail` | A transaction row |
| S42 | Dialog · Delete transaction | `TxnDelete` | Delete on S41 or S45 |
| S43 | Picker · Date | `DatePicker` | Date fields |
| S44 | Picker · Repeats | `RepeatPicker` | Repeats on S28 |

Every screen also has a **Dark** variant on the canvas (`<File>Dark`), which shows the same layout with dark tokens. S21 and S22 are taller boards (1064 px and 904 px) because they show the full scrolled content.

---

## 5. Screen requirements

### 5.1 Onboarding (S01–S08, including S03a)

**S01 Splash.** Shows:
- the ctrlSpend logo
- the line "Know what's left to spend."
- a loading indicator
- the footer **"by BrendanLTW"**

Tapping continues.

**S02 Welcome.** Shows:
- a preview of the dashboard hero (Left to spend RM 1,240.00, with sample cards)
- the headline "Know what's left to spend, every day."
- the subtext "Set one monthly budget, log what you spend, and ctrlSpend keeps count."
- a **Get started** button
- a **Skip the tour** link, which skips S03

**S03 How it works.** "Three steps, then you're in control." Three basics: *Set one monthly budget*, *Log spending in seconds*, *See where it goes*. A privacy block: *Stays on this phone — No account, no bank login. Export a CSV whenever you like.* **Continue** and the header's **Skip** both go to S03a.

**S03a What should we call you? (1 of 5).** Shows:
- back button and step indicator
- the subtext "We'll use your name to greet you. It stays on this phone."
- a **First name** field with the keyboard open and a character counter ("4/30")
- **Continue**, which sits above the keyboard

Rules:
- The name is used in the dashboard greeting ("Hi, Alex"), the lock screen ("Welcome back, Alex") and the Settings profile row.
- Continue is disabled until the field has at least one non-space character. The value is trimmed and limited to 30 characters.
- The name stays on the device. It can be changed from the Settings profile row (S47).

**S04 Set up your month (2 of 5).** Copy: "Line your budget period up with payday, so each month starts fresh when the money comes in."
- **Currency** row (default Malaysian Ringgit, RM) → S34.
- **Month starts on**: segmented **1st · 15th · 25th · Other** (Other → S32).
- A live preview: "Current period 15 Oct – 14 Nov · 10 days left".

**S05 Set your monthly budget (3 of 5).** "How much do you want to spend each month? You can change this any time in Budgets." A large amount display ("RM 2,000.00 per month") with the shared money keypad (§6.1). **Continue** moves on. **Skip** leaves no overall budget, and the hero shows the "No overall budget" state.

**S06 Split by category (4 of 5).** "Optional. Give limits to the categories you tend to overspend on."
- A summary: "Allocated RM 900 of RM 2,000", a progress bar, and "RM 1,100 stays flexible for everything else."
- A list of expense categories, each with its limit or an **Add limit** button.
- Category limits can't add up to more than the monthly budget. The limit sheet shows the same error as S54.

**S07 Stay on track (5 of 5).** "A nudge at the end of the day helps you log spending before you forget it." A sample notification, then three toggles:
- **Daily reminder:** every day at 9:00 PM.
- **Budget alerts:** at 80% and 100%.
- **Weekly summary:** Sunday evenings.

**Turn on notifications** requests OS permission. **Not now** continues without it. If permission is denied, the choices are still saved, and S48 shows how to turn notifications on.

**S08 You're all set.** "Add what you've spent since {period start} to see what's really left this period." A setup summary: monthly budget, month start, category limits ("3 of 5"), reminders. **Add your first expense** goes to S12 and **Go to dashboard** goes to S10.

Acceptance:
- [ ] Onboarding runs once. Afterwards the app opens on S09, or S38 if app lock is on.
- [ ] Every value chosen in onboarding appears in Settings and can be changed later: name (S47), currency (S34), month start (S32), budget (S17), limits (S17), reminders (S48).
- [ ] Back works on every step without losing entered values.

### 5.2 Dashboard (S09–S11)

- **Header**: period ("15 Oct – 14 Nov"), "Hi, Alex", notifications bell with unread count, avatar → Settings.
- **Budget hero card** (dark navy card), in one of four states (S11):

| State | Label | Big figure | Caption |
|---|---|---|---|
| Under 80% spent | Left to spend | Budget − spent | "RM 760 spent of RM 2,000" |
| 80–99% spent | Left to spend | Budget − spent, warning colour | "RM 1,840 spent of RM 2,000" |
| Over budget | Over budget by | Spent − budget, negative colour | "RM 2,010 spent of RM 2,000" |
| No overall budget | Spent this period | Spent | "Set a monthly budget" link |

  The hero also shows a progress bar of budget spent.
- **Spent** and **Income** summary cards for the period.
- **Recent activities** with **View all** → S16. Shows the latest three transactions, each with category tile, title, "Today · Food" and signed amount.
- **First run (S10)**:
  - hero at "RM 2,000.00 left", with RM 0 spent and RM 0 income
  - an empty state: "No transactions yet — Add what you spend and your budget updates as you go."
  - **Add your first expense**

Acceptance:
- [ ] Hero state thresholds are exactly < 80%, 80–99%, ≥ 100%, and "no budget".
- [ ] All figures update immediately after adding, editing or deleting a transaction.
- [ ] The progress bar's screen-reader label reads "{n}% of monthly budget spent".

### 5.3 New, edit and pick (S12, S13, S45, S46)

Layout, top to bottom:
1. **Header:** ✕ close and a title (**New expense**, **New income** or **Edit transaction**). When editing, there is also a **Delete** action (→ S42).
2. **Expense | Income** segmented toggle.
3. **Total amount** display, typed with the money keypad (§6.1), which is always visible at the bottom of the screen. An empty amount shows a muted "RM 0.00" with a cursor.
4. **Category:** a single scrolling row of category tiles, with **More** (→ S46).
   - Expense defaults: Food, Transport, Shopping, Bills, Fun, Health.
   - Income defaults: Salary, Gifts.
5. **Title** field, placeholder "What was it? (optional)".
6. **Date** chip ("Today, 4 Nov") → S43, and **Note** chip ("Add a note").
7. **Save**.

Field rules:
- **Title** is up to 40 characters. If it's left empty, the category name is used as the title (e.g. "Food").
- **Date** can't be in the future. When editing, the date chip also shows the time ("4 Nov, 12:40"). New transactions use the current time.
- **Note** is up to 200 characters.

**S46 Category picker** (sheet):
- a search field
- every active category of the current type, with its limit status ("RM 72 left", "Over by RM 10")
- categories the user added, marked "Added by you"
- **New category** (→ S24)

Archived categories don't appear.

Acceptance:
- [ ] Amount 0 or no category disables Save. Below the keypad, the hint reads "Enter an amount and pick a category to save".
- [ ] Switching Expense/Income swaps the category set and clears an incompatible selection.
- [ ] Edit (S45) opens with every field prefilled. Delete asks for confirmation (S42).

### 5.4 Notifications (S14–S15, S48)

- Grouped **Today** / **Earlier**, with unread items marked.
- Types:

| Type | Example |
|---|---|
| Budget at 80% | "Food is at 82% of its limit · RM 72 left with 10 days to go." |
| Over budget | "Shopping is over budget · You've spent RM 210 of your RM 200 limit." |
| Daily reminder | — |
| Income recorded | "Salary added" |
| Weekly summary | "You spent RM 298 last week, RM 41 less than the week before." |
| New period started | "Your RM 2,000 budget has reset." |
| Bill due (v1.1) | "Netflix is due in 2 days · RM 55.00" |

- The settings icon opens **S48**.
- **Empty (S15)**: "No notifications yet" with the three notification types and their on/off state.

**S48 Notification settings:**
- **Reminders:**
  - Daily reminder (toggle)
  - **Remind me at** (time picker, default 9:00 PM)
- **Alerts and summaries:**
  - Budget alerts (80% and 100%)
  - Weekly summary (Sunday evenings)
  - Bill reminders (v1.1; uses each bill's own setting)
- When OS permission is denied, an amber banner reads "Notifications are off for ctrlSpend", with **Open phone settings**. The toggles still save the user's choices.

Acceptance:
- [ ] Opening S14 marks items read and clears the bell badge.
- [ ] All notifications are generated and scheduled on the device. Nothing is sent to a server.
- [ ] A budget alert fires **once per category per threshold per period**. It doesn't fire again if an edit drops spending below the threshold and it then crosses again.

### 5.5 Activity (S16, S39)

- Search field "Search notes and categories".
- Filter chips: **All · Expense · Income**, then category chips for the expense categories, ordered by spending this period.
- Day groups ("Today", "Yesterday, 3 Nov", "Sun, 1 Nov"), each with the day's net total.
- Rows: category tile, title, category, signed amount. Tap → S41.
- Swipe left reveals **Delete**. After deleting, a toast shows "Transaction deleted" with **Undo**.
- **No results (S39)**:
  - text: "No results for "netflix" — Nothing matches in Expense. Try another word, or search all transactions."
  - **Search all**, which clears the type filter

Acceptance:
- [ ] Search is case-insensitive over title, note and category name, and respects the active chips.
- [ ] Undo restores the transaction exactly, within 5 seconds.

### 5.6 Budgets (S17, S54)

- Period header, and a **Monthly budget** card: "RM 1,240.00 left · RM 760.00 of RM 2,000.00 spent".
- **By category** with **Add**. Each limited category shows its percentage, spent and left (e.g. "Food 82% · Spent RM 328 · Left RM 72").
- Tapping a category or the monthly budget opens an **edit sheet** with:
  - the money keypad
  - the "Per month" amount
  - **Remove** and **Save**

**S54 Over-allocation error.** This shows when a category limit would make the total of all limits more than the monthly budget:
- The amount box gets a red outline.
- A message reads: "Your limits would add up to RM 2,200, which is more than your RM 2,000 monthly budget. Food can be up to RM 1,500."
- **Save** is disabled.

The same check applies when the monthly budget is lowered below the allocated total ("Your category limits add up to RM 900. Lower them first, or set the budget to at least RM 900.").

Acceptance:
- [ ] Category status uses the same thresholds as the hero.
- [ ] Removing a category limit keeps the category and its transactions.
- [ ] Removing the **monthly budget** switches the hero to "No overall budget". Category limits stay.

### 5.7 Insights (S18–S20, S40)

Segmented **Week · Month · 6 months**.

- **Month (S18)**: "Spent 15 Oct – 14 Nov RM 760.00" and **Spending categories**, a ranked list with share, amount and category colour (Food 43% · RM 328, …). Each category opens S23. A text summary for screen readers lists every category share.
- **Week (S19)**:
  - "Last 7 days RM 356" and "29 Oct – 4 Nov · avg RM 51 a day"
  - a daily bar chart against a **daily pace** line (RM 65/day), with each day marked under or over pace and today highlighted
  - two stats: **Under pace** "6 of 7 days this week" and **Biggest day** with its largest transaction
- **6 months (S20)**:
  - "Avg per month RM 1,786 (Jun – Oct, full months)"
  - monthly bars against the budget line, each marked under or over budget, with the current period marked "so far"
  - stats: **Under budget** "4 of 5 full months" and **Highest month**
  - **View past periods** → S25. Insights has no previous/next pager; history lives in S25 and S26.
- **No data (S40)**: "Not enough data yet — Charts appear once you've logged a few days of spending." with **Add an expense**. "A few days" means transactions on at least 3 different days.

Acceptance:
- [ ] Daily pace = monthly budget ÷ days in the period.
- [ ] Averages and "under budget" counts use full periods only. The current period is labelled "so far".
- [ ] Every chart has a text alternative listing its values.

### 5.8 Settings (S21, S21a, S32–S38, S47–S53, S64–S68)

**S21 Settings (v1.1)** and **S21a Settings (v1.0)**:
- **Profile row** ("Alex · Data stored on this phone · Edit name") → S47.
- **Preferences:** Month starts on, Theme, Currency, Notifications (→ S48), App lock.
- **Manage:** Categories (count), Recurring bills (count), Savings goals (count), Export to CSV, Import from CSV.
- **Data:** **Erase all data** (→ S49).
- Footer: "ctrlSpend {version} · by BrendanLTW".

In v1.0 (S21a), the App lock, Recurring bills and Savings goals rows are hidden. They appear with v1.1 (S21).

**S47 Edit name:** a sheet above the keyboard with the name field (same rules as S03a), a counter and **Save**.

**S49 Erase all data:**
- a dialog: "This deletes your {n} transactions, budget, categories and settings from this phone and starts ctrlSpend fresh. It can't be undone."
- an **Export a CSV first** link (→ S35)
- **Erase everything** (destructive) and **Cancel**

Erasing also removes the PIN and notification schedules, then restarts at S01.

**S32 Month start:**
- "Pick the day your budget resets. Most people choose payday."
- a grid of days 1–28, plus **Last day of the month**
- a preview of the current and next period
- **Save**

**S33 Theme:** **Light · Dark · System**. "System matches your phone's light or dark setting automatically."

**S34 Currency:**
- a search field
- **Suggested** (Malaysian Ringgit, Singapore Dollar, US Dollar) and **All currencies**
- the note "Switching currency changes the symbol only. Existing amounts aren't converted." (formatting rules: §6.5)

**S35 Export data:**
- **Range:** **This period · All time · Custom**
- **Include** toggles: Expenses, Income, Notes
- **Export CSV** saves `ctrlspend-YYYY-MM-DD.csv` and shows the toast "Saved {n} transactions to Files"
- the file format is in §6.4

**S50 Custom range:**
- **From** and **To** rows (→ S43)
- a live count ("86 transactions in this range")
- **Export {n} transactions**

**Import flow.** The user picks a file with the system file picker, then:
1. **S51 Checking file** shows a spinner, "Row 128 of 214", a progress bar and **Cancel**.
2. If any row fails, **S36 Import failed** appears:
   - the message "We couldn't import that file — {n} rows have problems, so nothing was imported. Fix them and try again."
   - the file name, and each problem by row (e.g. "Row 14 "31/02/2026" isn't a real date", "Row 27 Amount is empty")
   - actions: **Choose another file** and **Download a sample CSV**
3. If every row is valid, **S52 Review** appears:
   - the file name, "All {n} rows look good"
   - the date range, the expense and income counts, and any new categories that will be created
   - a choice for rows that match existing transactions on date, amount and category: **Skip duplicates** (default) or **Import them anyway**
   - a reminder that imports can't be undone
   - **Import {n} transactions**
4. **S53 Success** shows: "Imported {n} transactions", how many duplicates were skipped, which categories were added, then **See in Activity** and **Back to Settings**.

**S37 App lock:**
- a toggle, "Ask for your PIN when you open ctrlSpend"
- **Unlock with biometrics** ("Face ID or fingerprint, if set up on this phone")
- **Lock after** (→ S68)
- **Change PIN** (→ S64)
- **Hide amounts in app switcher**
- **Preview lock screen**

The note under the options reads: "Turning app lock on asks you to create a PIN. If you forget it, you can reset it with biometrics or your phone's passcode."

**S68 Lock after:** Immediately (default), After 1 minute, After 5 minutes, After 15 minutes, After 1 hour. The time counts from when the app goes to the background.

**S64 / S65 Create PIN:** a two-step flow.
1. "Create a 4-digit PIN", which warns against obvious PINs.
2. "Enter it again". If the PINs don't match, the dots turn red with the message "Those PINs don't match. Enter your new PIN again." and the flow restarts at step 1.

Turning app lock on, Change PIN, and resetting from S67 all use this flow. Change PIN first asks for the current PIN.

**S38 Lock screen:**
- "Welcome back, Alex" and "Enter your PIN"
- a 4-digit indicator
- a number pad with a biometric key and delete
- **Forgot PIN?** (→ S67)

**S66 Too many attempts:** after **5 wrong PINs**, entry pauses for 30 seconds. The wait doubles after each further 5 wrong PINs, up to 15 minutes. The screen shows "Too many wrong PINs · Try again in 0:28, or use biometrics", with red dots and a dimmed keypad. The biometric key stays active.

**S67 Forgot PIN:** "Confirm it's you with biometrics or your phone's passcode, then choose a new PIN. Your data stays as it is." **Continue with biometrics** and **Use phone passcode** both lead to S64. If neither is set up on the phone, the only way back in is to erase the app's data, which uses the same flow as S49.

Acceptance:
- [ ] Changing the month start recalculates the current period immediately, and alerts are re-evaluated for the new period. Past periods keep their snapshots (§8).
- [ ] Import validates every row first and imports all or nothing.
- [ ] The PIN is stored with the platform's secure storage, never in the database.
- [ ] With "Hide amounts in app switcher" on, the app's snapshot in the task switcher is obscured.

### 5.9 Categories (S22–S24)

**S22 Category manager:**
- **Expense**, **Income** and **Archived** sections. Archived categories show **Restore** and their transaction count.
- **Add**.
- Every row opens S23.
- The note: "Categories with transactions are archived instead of deleted, so your history stays intact."

**S23 Category detail:**
- name, type, transaction count and usage %
- **This period** ("RM 328 of RM 400", "RM 72 left · 10 days to go")
- settings rows for Name, Icon & colour and Monthly limit
- recent transactions
- **Archive category**

**S24 Add category (sheet):**
- Expense/Income toggle
- name, up to 20 characters
- **Icon:** Food, Coffee, Car, Bag, Bolt, Film, Heart, Gift, Book, Travel, Home, Phone
- **Colour:** Orange, Blue, Pink, Yellow, Purple, Green, Red
- optional **Monthly limit**, for expense categories only
- **Create category**

Acceptance:
- [ ] A category with no transactions is deleted after a confirmation. One with transactions is archived.
- [ ] Archived categories don't appear in pickers, but keep their history in Activity, Insights and past periods.

### 5.10 Past periods (S25–S26, S55)

**S25:**
- the **Current period**, with days left and progress
- **Previous** periods, each with spent vs budget and "Over by RM 10" or "RM 90 under"

**S26 Period detail:**
- total spent, over/under, and budget
- **By category**: each category's spent amount and its result against its limit ("RM 112 over · limit RM 400") or "No limit"

**S55 Empty:** shown during the very first period. It shows the current period card and "No past periods yet — Your first period ends on {date}. After that, each period's total and how it did against your budget will show here."

Past periods use the budget and limits **snapshotted when that period ended** (§8 PeriodSnapshot), not the current ones.

### 5.11 Recurring bills (S27–S28, S43–S44, S56–S59)

**S27:**
- the summary: "Due before {period end} RM 282.00 — 3 bills. After these, RM 958 is left to spend."
- **Upcoming:** name, due date ("in 4 days"), amount, and a **Pay** button (→ S57). The row opens S56.
- **Paid this period**

**S58 Overdue:** a bill whose `nextDue` has passed unpaid shows in red ("Overdue · was due 1 Nov"), stays at the top of Upcoming, and still counts in "Left after bills".

**S59 Empty:** "No recurring bills yet — Add rent, phone or streaming bills to see what's left after they're paid, and get a reminder before each one is due." with **Add a bill**.

**S56 Bill detail:**
- name, amount, repeat rule and due status
- category and reminder
- a **Pause this bill** toggle
- **History** of payments
- **Mark as paid**, **Edit** (→ S28) and **Delete bill**

Pausing and deleting:
- A paused bill drops out of Upcoming and "Left after bills", and sends no reminders.
- Deleting a bill keeps the transactions it already created.

**S57 Mark as paid (sheet):**
- Amount (editable, defaults to the bill amount)
- Paid on (defaults to today → S43)
- Category
- the note "This adds a RM 129.00 expense to Bills and moves the next due date to 8 Dec."
- **Mark as paid**

**S28 New bill:**
- amount each time, Name, Category (default Bills)
- **Repeats** (S44): Every week, Every 2 weeks, Every month on the {day}, Every 3 months, Every year, or Custom… (every N days, weeks or months, N from 1 to 12)
- **Next due** (S43 calendar)
- the toggle **Remind me 2 days before it's due**
- **Save bill**

Acceptance:
- [ ] Unpaid bills don't reduce "Left to spend" on the dashboard. They're shown only as "Left after bills" on this screen. A bill counts as spending once it's marked paid, because paying creates a transaction.
- [ ] "Left after bills" = left to spend − unpaid, unpaused bills due before the period ends (overdue included).
- [ ] Marking a bill paid creates a transaction in its category (with `billId`) and moves the bill's next due date forward one repeat.
- [ ] Bill reminders fire the set number of days before the due date.

### 5.12 Savings goals (S29–S31, S60–S63)

**S29:**
- **Total saved**, with "+RM 400 this month"
- **Active goals:** name, type, target date, % saved, saved and to go
- a collapsed "1 completed goal", which expands into the same rows with a "Completed {date}" label

**S63 Empty:** "Start your first goal — Pick a target and a date, and ctrlSpend shows how much to put aside each month. Savings don't count as spending." with **Create a goal**.

**S30 Goal detail:**
- saved of target, progress, to go, and target date
- a status
- **Contributions** history
- **Add money**, **Withdraw**, and **•••** (→ S62)

Statuses:
- **On track:** the money saved so far is at least what the plan says by now, assuming an even monthly amount since the goal was created.
- **Behind:** the money saved is below that.
- **Past target date:** the date has passed and the goal isn't reached.

Each status shows the monthly amount now needed.

**S60 Add money / S61 Withdraw (sheet):**
- an Add money | Withdraw toggle
- the amount, with the money keypad
- a **Label** (default "From salary")
- a **Date** (→ S43)
- the confirm button ("Add RM 400")

When adding money, an info note says it doesn't count as spending. A withdrawal can't exceed the amount saved: S61 shows "You can withdraw up to RM 3,200, the amount saved so far." and disables the button.

**S62 Goal options:**
- **Edit goal** (→ S31, prefilled)
- **Mark as completed**
- **Delete goal**: "Removes the goal and its {n} contributions. Your spending isn't affected."
- **Cancel**

**S31 New goal:**
- target amount, Name, Target date
- Icon: Travel, Car, Home, Laptop, Heart, Gift
- a live hint ("RM 616 a month to reach RM 8,000 by December 2027")
- **Create goal**

Acceptance:
- [ ] Monthly amount needed = amount to go ÷ months left until the target date, rounded up to the whole currency unit.
- [ ] A goal is completed when saved ≥ target, or when it's marked completed. It then moves to the completed group.
- [ ] Goal contributions are tracked separately. They don't count as spending and don't reduce "Left to spend". Withdrawals don't add to it either.

### 5.13 Transaction detail and delete (S41–S42)

**S41:**
- title, signed amount and type
- **Details:** Category, Date with time, Note
- **Budget impact** ("Food RM 72 left · RM 328 of RM 400 this period")
- **Edit** (→ S45) and **Delete transaction**

**S42 dialog:** "Delete this transaction? {title} ({amount}) will be removed and {amount} goes back to your {category} budget." **Delete** (destructive) and **Cancel**.

---

## 6. Shared behaviour

### 6.1 Money keypad
Used on S05, S12, S13, S17, S28, S31, S45, S57 and S60: a 3 × 4 pad with 1–9, **00**, 0 and **backspace**.
- [ ] Typing fills from the cents: `1`, `2`, `5`, `0` → RM 12.50.
- [ ] `00` appends two zeros, and backspace removes the last digit. The value is capped at 9 digits.
- [ ] The amount is stored as integer minor units.
- [ ] The screen-reader label reads the full amount (e.g. "Budget RM 2,000.00 per month").

### 6.2 Periods
- A period runs from the start day to the day before it in the next month (e.g. 15 Oct – 14 Nov).
- Start day options: 1–28 or **last day of the month**.
- One pure function, `periodFor(date, startDay)`, is used everywhere. It handles short months and leap years.
- When a period ends, its budget, limits and totals are saved as a **PeriodSnapshot** (§8).

### 6.3 Thresholds and colours
- Under 80% → neutral. 80–99% → **Warning**. ≥ 100% → **Negative**.
- Colour is always paired with text ("82%", "Over by RM 10").

### 6.4 CSV format (export and import)
Export and import use the same format, so an exported file always imports back.
- UTF-8, comma-separated, with a header row.
- Columns, in order: `date` (YYYY-MM-DD), `time` (HH:MM, optional), `type` (`expense` / `income`), `amount` (decimal with a dot, e.g. `12.50`, always positive), `category` (name), `title`, `note`.
- `category` is matched to existing categories of the same type by name, ignoring case. Unknown names become new categories, with a default icon and colour, and are listed on S52.
- Duplicates are rows with the same date, type, amount and category as an existing transaction. They're skipped by default (S52).
- At most 20,000 rows per file. Any invalid row fails the whole import (S36).

### 6.5 Currency formatting
- Each currency uses its ISO 4217 minor units (RM, S$, US$: 2; ¥ JPY: 0). The keypad and display follow that number of decimals.
- The symbol and its position follow the currency's usual style. Thousands are grouped with commas.

---

## 7. Requirements and priorities

Priorities:
- **P0** = core app
- **P1** = complete experience
- **P2** = extended features, shipped in a later update (**v1.1**), not in v1.0

| ID | Requirement | Screens | Priority |
|---|---|---|---|
| FR-01 | Onboarding: name, currency, month start, monthly budget | S01–S05, S03a, S08 | P0 |
| FR-02 | Dashboard with four hero states, spent/income, recent | S09–S11 | P0 |
| FR-03 | Add, edit and delete expenses and income with the money keypad and category picker | S12, S13, S41, S42, S45, S46 | P0 |
| FR-04 | Activity list with day groups, swipe delete and undo | S16 | P0 |
| FR-05 | Monthly budget and category limits, with over-allocation checks | S06, S17, S54 | P0 |
| FR-06 | Default categories; category manager with archive and restore | S22–S24 | P0 |
| FR-07 | Payday periods with configurable start day; period snapshots | S04, S32 | P0 |
| FR-08 | Search and filter chips with empty state | S16, S39 | P1 |
| FR-09 | Insights: week, month and 6-month views with empty state | S18–S20, S40 | P1 |
| FR-10 | Settings: name, theme (light, dark, system), currency | S21a, S33, S34, S47 | P1 |
| FR-11 | Dark mode for every screen | all | P1 |
| FR-12 | Local notifications: daily reminder, budget alerts, weekly summary; inbox; settings | S07, S14, S15, S48 | P1 |
| FR-13 | Past periods and period detail | S25, S26, S55 | P1 |
| FR-14 | CSV export (with custom range) and validated import with review | S35, S36, S50–S53 | P1 |
| FR-15 | Category detail with period stats | S23 | P1 |
| FR-19 | Erase all data | S49 | P1 |
| FR-16 | Recurring bills with reminders, mark paid, pause, overdue and "left after bills" | S27, S28, S43, S44, S56–S59 | P2 |
| FR-17 | Savings goals with contributions, withdrawals, edit and delete | S29–S31, S60–S63 | P2 |
| FR-18 | App lock with PIN setup, lockout, reset, biometrics and app-switcher privacy | S21, S37, S38, S64–S68 | P2 |

---

## 8. Data model

| Entity | Fields | Rules |
|---|---|---|
| **Category** | `id`, `name`, `type` (expense / income), `iconKey`, `colorKey`, `limitMinor?`, `archived`, `sortOrder` | Name unique per type, ≤ 20 characters. Limits only on expense categories. Archived instead of deleted when it has transactions. |
| **Transaction** | `id`, `amountMinor`, `type`, `categoryId`, `occurredAt` (UTC), `title`, `note?`, `billId?` | `amountMinor > 0`. Type matches the category. `occurredAt` ≤ now. `title` ≤ 40 characters, defaulting to the category name. `note` ≤ 200 characters. |
| **PeriodSnapshot** | `id`, `periodStart`, `periodEnd`, `budgetMinor?`, `limits` (categoryId → limitMinor), `spentMinor`, `incomeMinor` | Written when a period ends. S25, S26 and S20 read past periods from here. |
| **Bill** (P2, v1.1) | `id`, `name`, `amountMinor`, `categoryId`, `repeat` (weekly, 2-weekly, monthly on day, 3-monthly, yearly, custom N days/weeks/months), `nextDue`, `remindDaysBefore?`, `paused` | Paying creates a Transaction and advances `nextDue`. Deleting keeps created transactions. |
| **Goal** (P2, v1.1) | `id`, `name`, `iconKey`, `targetMinor`, `targetMonth`, `createdAt`, `completedAt?` | Deleting removes its contributions. |
| **GoalContribution** (P2, v1.1) | `id`, `goalId`, `amountMinor` (+ add / − withdraw), `label`, `date` | Not counted as spending. A withdrawal can't exceed the amount saved. |
| **Notification** | `id`, `kind` (incl. `billDue`), `title`, `body`, `createdAt`, `readAt?` | Generated locally. Budget alerts are deduplicated per category, threshold and period. |

**Preferences** (key-value):
- `userName`, `currencyCode`, `monthStartDay` (1–28 or `last`), `monthlyBudgetMinor?`, `theme` (light / dark / system)
- reminders: daily on/off and time (default 21:00), budget alerts on/off, weekly summary on/off, bill reminders on/off
- app lock: enabled, biometrics, `lockAfter` (0, 1, 5, 15 or 60 minutes), hide-in-switcher, failed-attempt count and lockout-until
- `onboardingComplete`

**PIN** (P2, v1.1): stored hashed in platform secure storage, never in the database.

**Default categories (8):** expense: Food, Transport, Shopping, Bills, Fun, Health. Income: Salary, Gifts. Seeded on first launch. The Settings count ("Categories 8") includes archived categories.

### Derived values
- **Spent / Income** = sums for the period.
- **Left to spend** = monthly budget − spent. A negative result shows as "Over budget by". Savings goal contributions and withdrawals are excluded.
- **Category used %** = category spent ÷ category limit.
- **Allocated** = sum of category limits. Must be ≤ the monthly budget. **Flexible** = budget − allocated.
- **Daily pace** = monthly budget ÷ days in the period.
- **Left after bills** = left to spend − unpaid, unpaused bills due in the period (overdue included). Shown on Recurring bills only. It never replaces "Left to spend".
- **Goal monthly need** = (target − saved) ÷ months left, rounded up.

---

## 9. Design system

From the canvas's design-system and brand boards.

### Brand
- The name is written **ctrlSpend**: lowercase "ctrl". In the wordmark, "ctrl" is weight 400 in grey and "Spend" is 700 (DESIGN §2). It comes from **ctrlWorks**.
- Logo: a **green budget ring** on a charcoal keycap (DESIGN §2).
- Endorsed lockup "ctrlSpend by ctrlWorks" for the App Store page and website.
- The splash footer and the Settings footer credit the maker instead: **"by BrendanLTW"**.
- In sentences: "ctrlSpend, from ctrlWorks". Never "ctrlWorks Spend".

### Colour tokens
| Token | Light | Dark |
|---|---|---|
| `ground` | `#F7F8FA` | `#0B1018` |
| `surface` | `#FFFFFF` | `#161D29` |
| `raised` | — | `#232C3A` |
| `ink` (text and primary accent) | `#101828` | `#F2F4F7` |
| `muted` | `#5B6B86` | `#98A2B3` |
| `fill` | `#EEF1F6` | — |
| `positive` | `#067647` | `#47CD89` |
| `negative` | `#D92D20` | `#F97066` |
| `warning` | `#B54708` | `#FDB022` |

**Message boxes** (added for the audit-pass screens; background / text):

| Box | Light | Dark |
|---|---|---|
| Error | `#FEE4E2` / `#B42318` | red at 16% / `#FDA29B` |
| Warning | `#FEF0C7` / `#93370D` | amber at 16% / `#FEC84B` |
| Success | `#D1FADF` / `#05603A` | green at 16% / `#75E0A7` |
| Info | `#EEF1F6` / `#344054` | `#1C2536` / `#D0D5DD` |

**Category tiles** (background / icon):

| Category | Background | Icon |
|---|---|---|
| Food | `#FFE2B8` | `#C25E00` |
| Transport | `#CDE6FB` | `#1769C2` |
| Shopping | `#FBD3E1` | `#C8174F` |
| Bills | `#FFF0B8` | `#8A6100` |
| Fun | `#E4DBF7` | `#6D3FD1` |
| Income | `#C9F3D5` | `#1E8A43` |
| Health | `#FEE4E2` | `#D92D20` |

**Chart colours:** Food `#FB8C00` · Shopping `#F0457A` · Transport `#2196F3` · Bills `#F5B800` · Fun `#7C4DDB` · Over budget `#F97066` · Under budget `#98A2B3`.

### Typography — Poppins
| Style | Size / weight | Example |
|---|---|---|
| Display | 56 / 800 | RM 2,000 |
| Amount | 32 / 700 (40 / 800 on entry screens) | RM 1,240.00 |
| Page title | 26–28 / 700 | Set your monthly budget |
| Header | 20 / 700 | Transaction |
| Row title | 16 / 600 | Nasi lemak |
| Body | 15 / 400–500 | How much do you want to spend each month? |
| Caption | 13 / 400 | Today · Food |
| Label | 13 / 600, caps | RECENT ACTIVITIES |

Large amounts show the cents smaller than the whole number (e.g. RM 1,240**.00**).

### Shape and spacing
- Radius scale: 12, 16, 20, 24, 28, 32 and pill (999).
- 16 px screen margin, 8–14 px between cards, and 20–24 px inside cards.
- Touch targets ≥ 44 px.

### Components
- Buttons: primary, disabled primary, pill, text link, destructive, and a small **Pay** pill.
- Selection: segmented control (Week · Month · 6 months), filter chips, toggles, radio rows, day/option selectors (1st · 15th).
- Display: category icon tiles, list groups, progress bars, the four message boxes, and a loading spinner.
- Overlays: bottom sheet with handle, centred dialog, toast ("Saved 214 transactions to Files").
- Navigation: the bottom bar with the centre add button.
- Entry: money keypad, PIN pad, text field with focus and error outlines.

### Accessibility
- Text contrast ≥ 4.5:1 in both themes.
- Every progress bar and chart has a screen-reader label with its values.
- Icon-only buttons are labelled (Back, Close, Settings, Notifications, Add transaction, Backspace, More options).
- Errors use `role="alert"` and are never shown by colour alone.

---

## 10. Non-functional requirements

| Area | Requirement |
|---|---|
| Performance | Cold start to an interactive dashboard in < 2 s on a mid-range Android device; 60 fps lists with 5,000 transactions; import of 20,000 rows checked in < 5 s |
| Offline | Every feature works without a network |
| Correctness | Money as integer minor units; dates stored in UTC, shown in local time |
| Privacy | No accounts, analytics, ads or network calls; data leaves only through export; Erase all data removes everything, including the PIN |
| Security | PIN in secure storage; optional biometric unlock; escalating lockout after wrong PINs; app-switcher snapshot hidden on request |
| Platforms | iOS and Android; a web build for the demo with notifications, biometrics and app lock hidden |
| Quality | `flutter analyze` clean; unit tests for derived values, `periodFor`, CSV round trip and lockout timing; widget tests per screen in both themes; one end-to-end test (onboarding → add expense → dashboard → delete → undo); CI on every push |
| Design fidelity | Each screen is compared with its light and dark design before its task is done |

---

## 11. Milestones

The design now covers far more than the original six-week scope. Suggested phases:

| Phase | Scope | Exit criteria |
|---|---|---|
| 0 Foundation | Project, tokens (light and dark), Poppins, routing shell with 4 tabs and add button, money formatter, keypad widget, CI | Shell and keypad match the design in both themes |
| 1 Data | Drift schema (including PeriodSnapshot), `periodFor`, repositories, derived values | Unit tests pass |
| 2 Core | Onboarding, dashboard (4 hero states), add/edit and category picker, activity, budgets with over-allocation, categories, transaction detail and delete | **All P0 done** |
| 3 Complete | Search and filters, insights (3 views), settings screens (name, notifications, erase), notifications, past periods, CSV export and import flow | **All P1 done** |
| 4 Ship | Accessibility and fidelity pass, end-to-end test, demo, APK, README | **v1.0 released** with all P0 + P1 |
| 5 Update | Recurring bills, savings goals, app lock; schema migration adding the Bill, Goal and GoalContribution tables | P2 tests pass; migration test from v1.0 data; **v1.1 released** |

---

## 12. Risks and open questions

| Risk | Mitigation |
|---|---|
| Scope has roughly tripled since the first plan | P2 moved to v1.1, so v1.0 ships with P0 + P1 only |
| Payday periods with "last day of month" | Exhaustive tests for `periodFor` across month lengths and leap years |
| Local notification scheduling differs by platform | Spike on both platforms in Phase 0 |
| App lock and secure storage on web | Hide lock features on web |
| Category limits exceeding the monthly budget | Validated in the domain layer; S54 error state; remaining allocation shown in S06 and S17 |
| Budget changes rewriting history | PeriodSnapshot written at each period end |

### Open questions
None at the moment. The decisions from the 14 Nov 2026 audit are recorded above and in `claude/AUDIT.md` (§8).
