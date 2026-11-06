# ctrlSpend — Product Requirements Document

| | |
|---|---|
| Product | **ctrlSpend** (package `ctrl_spend`), from ctrlWorks |
| Type | Offline-first personal budgeting app (Flutter, iOS and Android) |
| Purpose | Portfolio project |
| UI source of truth | "CtrlSpend UI" design canvas: 44 light screens, a dark version of each, a design-system board and a brand board. Export the screens to `docs/design/`. |
| Related | `CLAUDE.md` (conventions), `docs/PLAN.md` (tasks) |

This PRD follows the design canvas. Where this file and a screen disagree, the screen wins and this file is updated.

---

## 1. Overview

ctrlSpend answers one question first: **how much is left to spend this period?** The user sets one monthly budget, lines the period up with payday, logs spending in seconds, and the home screen keeps count. Everything stays on the phone: no account, no bank login.

**Promise (splash and onboarding):** "Know what's left to spend, every day."

**Problem.** People who try to track spending give up within weeks. Entry is slow, apps want an account or bank access first, and calendar-month budgets don't match when the money actually arrives.

**Approach.**
- **One number:** a single monthly budget and a big "Left to spend" figure.
- **Payday periods:** the budget period starts on the user's chosen day (e.g. 15 Oct – 14 Nov).
- **Optional category limits:** only for the categories the user tends to overspend on; the rest stays flexible.
- **Ten-second logging:** tap +, type the amount, pick a category.
- **Private by design:** data stays on the device; CSV export and import whenever the user likes.

---

## 2. Goals and non-goals

### Product goals
- Log a transaction in **≤ 10 seconds** from opening the app.
- The dashboard answers "how much is left?" **within 5 seconds** for a first-time viewer.
- Onboarding to a working budget in **under 2 minutes**.
- Work **fully offline**; no account.

### Portfolio goals
- Feature-first Flutter architecture with enforced layer boundaries.
- Unit, widget and end-to-end tests; CI on every push.
- Light and dark themes built from one token set.
- An APK and a README explaining key decisions.

### Non-goals (v1)
- Bank linking, accounts, cloud sync or multi-device use.
- Shared or household budgets.
- Investments, net worth or debt tracking.
- Currency conversion (switching currency changes the symbol only).
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
- **Bottom bar**: four tabs — **Home · Activity · Budgets · Insights** — with a raised round **add button** in the centre that opens Add transaction from any tab.
- **Dashboard header**: period dates and "Hi, {name}" on the left; a **notifications bell** (with unread badge) and an **avatar** that opens **Settings** on the right.
- Sub-screens open with a back button; create and edit screens open as full screens or sheets with a close (✕) button.

### Screen inventory

| ID | Screen (canvas title) | File | Opened from |
|---|---|---|---|
| **Onboarding** | | | |
| S01 | Splash | `Splash` | App launch |
| S02 | Onboarding 1 · Welcome | `OnbWelcome` | First launch |
| S03 | Onboarding 2 · How it works | `OnbHow` | Welcome → Get started |
| S03a | Onboarding · Your name (step 1 of 5) — *new, not yet on the canvas* | `OnbName` | How it works → Continue |
| S04 | Onboarding 3 · Currency & period (step 2 of 5) | `OnbSetup` | Your name → Continue |
| S05 | Onboarding 4 · Set budget (step 3 of 5) | `Main` | Continue |
| S06 | Onboarding 5 · Category limits (step 4 of 5) | `OnbCategories` | Continue |
| S07 | Onboarding 6 · Reminders (step 5 of 5) | `OnbReminders` | Continue |
| S08 | Onboarding 7 · All set | `OnbDone` | Turn on notifications / Not now |
| **Home and adding** | | | |
| S09 | Dashboard | `Dashboard` | Home tab |
| S10 | Dashboard · First run | `DashboardEmpty` | Home tab with no transactions |
| S11 | Budget hero · 4 states | `HeroStates` | Reference for S09 |
| S12 | Add / Edit transaction | `AddTransaction` | Add button; Edit on S41 |
| S13 | Add income | `AddTransactionIncome` | Income toggle on S12 |
| S14 | Notifications | `Notifications` | Bell on S09 |
| S15 | Notifications · Empty | `NotificationsEmpty` | Bell, none yet |
| **Tabs and management** | | | |
| S16 | Activity | `Activity` | Activity tab |
| S17 | Budgets (with Edit budget sheet) | `Budgets` | Budgets tab |
| S18 | Insights · Month | `Insights` | Insights tab |
| S19 | Insights · Week | `InsightsWeek` | Week segment |
| S20 | Insights · 6-month trend | `InsightsTrend` | 6 months segment |
| S21 | Settings | `Settings` | Avatar on S09 |
| S22 | Category manager | `Categories` | Settings → Categories |
| S23 | Category detail | `CategoryDetail` | A category row |
| S24 | Add category (sheet) | `AddCategory` | Add on S22 |
| **Periods, bills and goals** | | | |
| S25 | Past periods | `PeriodList` | View past periods on S20 |
| S26 | Past period detail | `PeriodDetail` | A period row |
| S27 | Recurring bills | `Bills` | Settings → Recurring bills |
| S28 | Add bill | `AddBill` | Add on S27 |
| S29 | Savings goals | `Savings` | Settings → Savings goals |
| S30 | Goal detail | `GoalDetail` | A goal row |
| S31 | Add goal | `AddGoal` | Add on S29 |
| **Settings, security and states** | | | |
| S32 | Settings · Month start | `SetMonthStart` | Settings → Month starts on |
| S33 | Settings · Theme | `SetTheme` | Settings → Theme |
| S34 | Settings · Currency | `SetCurrency` | Settings → Currency |
| S35 | Settings · Export CSV | `ExportCSV` | Settings → Export to CSV |
| S36 | Error · Import failed | `ImportError` | Settings → Import from CSV |
| S37 | Settings · App lock | `SetAppLock` | Settings → App lock |
| S38 | Lock screen | `LockScreen` | App open with lock on |
| S39 | Empty · No search results | `SearchEmpty` | Search on S16 |
| S40 | Empty · Insights no data | `InsightsEmpty` | Insights with no data |
| **Detail, dialogs and pickers** | | | |
| S41 | Transaction detail | `TxnDetail` | A transaction row |
| S42 | Dialog · Delete transaction | `TxnDelete` | Delete on S41 |
| S43 | Picker · Date | `DatePicker` | Date fields |
| S44 | Picker · Repeats | `RepeatPicker` | Repeats on S28 |

Every screen also has a **Dark** variant on the canvas (`<File>Dark`), which shows the same layout with dark tokens.

---

## 5. Screen requirements

### 5.1 Onboarding (S01–S08, including S03a)

**S01 Splash.** The ctrlSpend logo, the line "Know what's left to spend.", a loading indicator and the footer **"by BrendanLTW"**; tapping continues.

**S02 Welcome.** A preview of the dashboard hero (Left to spend RM 1,240.00, with sample cards), the headline "Know what's left to spend, every day.", the subtext "Set one monthly budget, log what you spend, and ctrlSpend keeps count.", a **Get started** button and a **Skip the tour** link (skips S03).

**S03 How it works.** "Three steps, then you're in control." Three basics: *Set one monthly budget*, *Log spending in seconds*, *See where it goes*. A privacy block: *Stays on this phone — No account, no bank login. Export a CSV whenever you like.* **Continue**; **Skip** in the header.

**S03a What should we call you? (1 of 5).** A new step, to be added to the canvas in the same style as the other steps: back button, step indicator, a page title, one line of supporting copy, a single **First name** text field with the keyboard open, and **Continue**.
- The name is used in the dashboard greeting ("Hi, Alex"), the lock screen ("Welcome back, Alex") and the Settings profile row.
- Continue is disabled until the field has at least one non-space character; the value is trimmed and limited to 30 characters.
- The name stays on the device and can be changed from the Settings profile row.

**S04 Set up your month (2 of 5).** Copy: "Line your budget period up with payday, so each month starts fresh when the money comes in."
- **Currency** row (default Malaysian Ringgit, RM) → S34.
- **Month starts on**: segmented **1st · 15th · 25th · Other** (Other → S32).
- A live preview: "Current period 15 Oct – 14 Nov · 10 days left".

**S05 Set your monthly budget (3 of 5).** "How much do you want to spend each month? You can change this any time in Budgets." A large amount display ("RM 2,000.00 per month") with the shared money keypad (§6.1). **Continue**; **Skip** leaves no overall budget (hero shows the "No overall budget" state).

**S06 Split by category (4 of 5).** "Optional. Give limits to the categories you tend to overspend on."
- A summary: "Allocated RM 900 of RM 2,000", a progress bar, and "RM 1,100 stays flexible for everything else."
- A list of expense categories, each with its limit or an **Add limit** button.
- Category limits can't add up to more than the monthly budget.

**S07 Stay on track (5 of 5).** "A nudge at the end of the day helps you log spending before you forget it." A sample notification, then three toggles: **Daily reminder** (every day at 9:00 PM), **Budget alerts** (at 80% and 100%), **Weekly summary** (Sunday evenings). **Turn on notifications** requests OS permission; **Not now** continues without it.

**S08 You're all set.** "Add what you've spent since {period start} to see what's really left this period." A setup summary: monthly budget, month start, category limits ("3 of 5"), reminders. **Add your first expense** (→ S12) and **Go to dashboard** (→ S10).

Acceptance:
- [ ] Onboarding runs once; afterwards the app opens on S09 (or S38 if app lock is on).
- [ ] Every value chosen in onboarding appears in Settings and can be changed later.
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
- **Recent activities** with **View all** → S16: the latest three transactions with category tile, title, "Today · Food" and signed amount.
- **First run (S10)**: hero at "RM 2,000.00 left", RM 0 spent and income, and an empty state "No transactions yet — Add what you spend and your budget updates as you go." with **Add your first expense**.

Acceptance:
- [ ] Hero state thresholds are exactly < 80%, 80–99%, ≥ 100%, and "no budget".
- [ ] All figures update immediately after adding, editing or deleting a transaction.
- [ ] The progress bar's screen-reader label reads "{n}% of monthly budget spent".

### 5.3 Add / edit transaction (S12–S13)

- Header: ✕ close, title (**New expense**, **New income** or **Edit transaction**) and, when editing, a **Delete** action.
- **Expense | Income** segmented toggle.
- **Total amount** in RM, typed with the money keypad (§6.1).
- **Select category**: a row of category tiles and **More**. Expense categories: Food, Transport, Shopping, Bills, Fun, Health. Income categories: Salary, Gifts. **More** opens the full list, including any categories the user has added.
- **Date** row ("Today, 4 Nov") → date picker (S43).
- **Note** field, placeholder "Add a note…".
- **Save**.

Acceptance:
- [ ] Amount 0 or no category disables Save.
- [ ] Switching Expense/Income swaps the category set and clears an incompatible selection.
- [ ] Edit opens with every field prefilled; Delete asks for confirmation (S42).

### 5.4 Notifications (S14–S15)

- Grouped **Today** / **Earlier**, unread items marked.
- Types: budget at 80% ("Food is at 82% of its limit · RM 72 left with 10 days to go."), over budget ("Shopping is over budget · You've spent RM 210 of your RM 200 limit."), daily reminder, income recorded ("Salary added"), weekly summary ("You spent RM 298 last week, RM 41 less than the week before."), and new period started ("Your RM 2,000 budget has reset.").
- A settings icon opens notification preferences.
- **Empty (S15)**: "No notifications yet" with the three notification types and their on/off state.

Acceptance:
- [ ] Opening the screen marks items read and clears the bell badge.
- [ ] All notifications are generated and scheduled on the device; nothing is sent to a server.

### 5.5 Activity (S16, S39)

- Search field "Search notes and categories".
- Filter chips: **All · Expense · Income** plus category chips (Food, Transport, …).
- Day groups ("Today", "Yesterday, 3 Nov", "Sun, 1 Nov"), each with the day's net total.
- Rows: category tile, title, category, signed amount. Tap → S41.
- Swipe left reveals **Delete**; after deleting, a toast "Transaction deleted" with **Undo**.
- **No results (S39)**: "No results for "netflix" — Nothing matches in Expense. Try another word, or search all transactions." with **Search all**, which clears the type filter.

Acceptance:
- [ ] Search is case-insensitive over title, note and category name, and respects the active chips.
- [ ] Undo restores the transaction exactly, within 5 seconds.

### 5.6 Budgets (S17)

- Period header and a **Monthly budget** card: "RM 1,240.00 left · RM 760.00 of RM 2,000.00 spent".
- **By category** with **Add**: each limited category shows its percentage, spent and left (e.g. "Food 82% · Spent RM 328 · Left RM 72").
- Tapping a category or the monthly budget opens an **edit sheet** with the money keypad, "Per month" amount, **Remove** and **Save**.

Acceptance:
- [ ] Category status uses the same thresholds as the hero.
- [ ] Removing a category limit keeps the category and its transactions.

### 5.7 Insights (S18–S20, S40)

Segmented **Week · Month · 6 months**.

- **Month (S18)**: "Spent 15 Oct – 14 Nov RM 760.00" and **Spending categories**: a ranked list with share, amount and category colour (Food 43% · RM 328, …). A text summary for screen readers lists every category share.
- **Week (S19)**: "Last 7 days RM 356", "29 Oct – 4 Nov · avg RM 51 a day", a daily bar chart against a **daily pace** line (RM 65/day), with each day marked under or over pace and today highlighted. Two stats: **Under pace** "6 of 7 days this week" and **Biggest day** with its largest transaction.
- **6 months (S20)**: "Avg per month RM 1,786 (Jun – Oct, full months)", monthly bars against the budget line, each marked under or over budget and the current period marked "so far". Stats: **Under budget** "4 of 5 full months" and **Highest month**. **View past periods** → S25.
- **No data (S40)**: "Not enough data yet — Charts appear once you've logged a few days of spending." with **Add an expense**.

Acceptance:
- [ ] Daily pace = monthly budget ÷ days in the period.
- [ ] Averages and "under budget" counts use full periods only; the current period is labelled "so far".
- [ ] Every chart has a text alternative listing its values.

### 5.8 Settings (S21, S32–S38)

**S21 Settings**: profile row ("Alex · Data stored on this phone"), which opens a field to change the name; **Preferences** — Month starts on, Theme, Currency, App lock; **Manage** — Categories (count), Recurring bills (count), Savings goals (count), Export to CSV, Import from CSV. In v1.0 the App lock, Recurring bills and Savings goals rows are hidden; they appear with v1.1.

- **S32 Month start**: "Pick the day your budget resets. Most people choose payday." A grid of days 1–28 plus **Last day of the month**, a preview of the current and next period, and **Save**.
- **S33 Theme**: **Light · Dark · System**. "System matches your phone's light or dark setting automatically."
- **S34 Currency**: a search field, **Suggested** (Malaysian Ringgit, Singapore Dollar, US Dollar) and **All currencies**. Note: "Switching currency changes the symbol only. Existing amounts aren't converted."
- **S35 Export data**: Range (**This period · All time · Custom**); include toggles for Expenses, Income and Notes; **Export CSV** saves `ctrlspend-YYYY-MM-DD.csv` and shows a toast "Saved {n} transactions to Files".
- **S36 Import failed**: "We couldn't import that file — {n} rows have problems, so nothing was imported. Fix them and try again." Lists the file name and each problem by row (e.g. "Row 14 "31/02/2026" isn't a real date", "Row 27 Amount is empty"). Actions: **Choose another file**, **Download a sample CSV**.
- **S37 App lock**: toggle "Ask for your PIN when you open ctrlSpend"; **Unlock with Face ID**; **Lock after** (Immediately…); **Change PIN**; **Hide amounts in app switcher**; **Preview lock screen**. Note: "If you forget your PIN, you can reset it with Face ID or your phone's passcode."
- **S38 Lock screen**: "Welcome back, Alex", "Enter your PIN", 4-digit indicator, number pad with a Face ID key and delete, **Forgot PIN?**.

Acceptance:
- [ ] Changing the month start recalculates every period, budget and chart.
- [ ] Import validates every row first and imports all or nothing.
- [ ] The PIN is stored with the platform's secure storage, never in the database.
- [ ] With "Hide amounts in app switcher" on, the app's snapshot in the task switcher is obscured.

### 5.9 Categories (S22–S24)

- **S22 Category manager**: **Expense**, **Income** and **Archived** sections; **Add**; archived categories have **Restore**. Note: "Categories with transactions are archived instead of deleted, so your history stays intact."
- **S23 Category detail**: name, type, transaction count and usage %; **This period** ("RM 328 of RM 400", "RM 72 left · 10 days to go"); settings rows for Name, Icon & colour and Monthly limit; recent transactions; **Archive category**.
- **S24 Add category (sheet)**: Expense/Income toggle, name, **Icon** (Food, Coffee, Car, Bag, Bolt, Film, Heart, Gift, Book, Travel, Home, Phone), **Colour** (Orange, Blue, Pink, Yellow, Purple, Green, Red), optional **Monthly limit**, **Create category**.

Acceptance:
- [ ] A category with no transactions is deleted; one with transactions is archived.
- [ ] Archived categories don't appear in pickers but keep their history in Activity, Insights and past periods.

### 5.10 Past periods (S25–S26)

- **S25**: the **Current period** with days left and progress; **Previous** periods, each with spent vs budget and "Over by RM 10" or "RM 90 under".
- **S26 Period detail**: total spent, over/under, budget, and **By category** with each category's spent and its result against its limit ("RM 112 over · limit RM 400") or "No limit".

### 5.11 Recurring bills (S27–S28, S43–S44)

- **S27**: "Due before {period end} RM 282.00 — 3 bills. After these, RM 958 is left to spend." **Upcoming** (name, due date, "in 4 days", amount) and **Paid this period**.
- **S28 New bill**: amount each time, Name, Category (default Bills), **Repeats** (S44: Every week, Every 2 weeks, Every month on the {day}, Every 3 months, Every year, Custom…), **Next due** (S43 calendar), **Remind me 2 days before it's due** toggle, **Save bill**.

Acceptance:
- [ ] Unpaid bills don't reduce "Left to spend" on the dashboard; they're shown only as "Left after bills" on this screen. A bill counts as spending once it's marked paid, because paying creates a transaction.
- [ ] "Left after bills" = left to spend − unpaid bills due before the period ends.
- [ ] Marking a bill paid creates a transaction in its category and moves the bill's next due date forward.
- [ ] Bill reminders fire the set number of days before the due date.

### 5.12 Savings goals (S29–S31)

- **S29**: **Total saved** with "+RM 400 this month"; **Active goals** with name, type, target date, % saved, saved and to go; a collapsed "1 completed goal".
- **S30 Goal detail**: saved of target, progress, to go, target date; a status ("On track — Save RM 360 a month to reach it by March."); **Contributions** history; **Add money** and **Withdraw**.
- **S31 New goal**: target amount, Name, Target date, Icon (Travel, Car, Home, Laptop, Heart, Gift), a live hint ("RM 616 a month to reach RM 8,000 by December 2027"), **Create goal**.

Acceptance:
- [ ] Monthly amount needed = amount to go ÷ months left until the target date, rounded up to the whole currency unit.
- [ ] A goal is completed when saved ≥ target; it moves to the completed group.
- [ ] Goal contributions are tracked separately: they don't count as spending and don't reduce "Left to spend". Withdrawals don't add to it either.

### 5.13 Transaction detail and delete (S41–S42)

- **S41**: title, signed amount and type; **Details** (Category, Date with time, Note); **Budget impact** ("Food RM 72 left · RM 328 of RM 400 this period"); **Edit** and **Delete transaction**.
- **S42 dialog**: "Delete this transaction? {title} ({amount}) will be removed and {amount} goes back to your {category} budget." **Delete** (destructive) and **Cancel**.

---

## 6. Shared behaviour

### 6.1 Money keypad
Used on S05, S12, S13, S17, S28 and S31: a 3 × 4 pad — 1–9, **00**, 0, **backspace**.
- [ ] Typing fills from the cents: `1`, `2`, `5`, `0` → RM 12.50.
- [ ] `00` appends two zeros; backspace removes the last digit; the value is capped at 9 digits.
- [ ] The amount is stored as integer minor units.
- [ ] The screen-reader label reads the full amount (e.g. "Budget RM 2,000.00 per month").

### 6.2 Periods
- A period runs from the start day to the day before it in the next month (e.g. 15 Oct – 14 Nov).
- Start day options: 1–28 or **last day of the month**.
- One pure function, `periodFor(date, startDay)`, is used everywhere; it handles short months and leap years.

### 6.3 Thresholds and colours
- Under 80% → neutral; 80–99% → **Warning**; ≥ 100% → **Negative**.
- Colour is always paired with text ("82%", "Over by RM 10").

---

## 7. Requirements and priorities

**P0** = core app · **P1** = complete experience · **P2** = extended features, shipped in a later update (**v1.1**), not in v1.0

| ID | Requirement | Screens | Priority |
|---|---|---|---|
| FR-01 | Onboarding: name, currency, month start, monthly budget | S01–S05, S03a, S08 | P0 |
| FR-02 | Dashboard with four hero states, spent/income, recent | S09–S11 | P0 |
| FR-03 | Add, edit and delete expenses and income with the money keypad | S12, S13, S41, S42 | P0 |
| FR-04 | Activity list with day groups, swipe delete and undo | S16 | P0 |
| FR-05 | Monthly budget and category limits | S06, S17 | P0 |
| FR-06 | Default categories; category manager with archive and restore | S22–S24 | P0 |
| FR-07 | Payday periods with configurable start day | S04, S32 | P0 |
| FR-08 | Search and filter chips with empty state | S16, S39 | P1 |
| FR-09 | Insights: week, month and 6-month views with empty state | S18–S20, S40 | P1 |
| FR-10 | Settings: theme (light, dark, system), currency | S21, S33, S34 | P1 |
| FR-11 | Dark mode for every screen | all | P1 |
| FR-12 | Local notifications: daily reminder, budget alerts, weekly summary; notifications inbox | S07, S14, S15 | P1 |
| FR-13 | Past periods and period detail | S25, S26 | P1 |
| FR-14 | CSV export and validated import | S35, S36 | P1 |
| FR-15 | Category detail with period stats | S23 | P1 |
| FR-16 | Recurring bills with reminders and "left after bills" | S27, S28, S43, S44 | P2 |
| FR-17 | Savings goals with contributions | S29–S31 | P2 |
| FR-18 | App lock with PIN, biometrics and app-switcher privacy | S37, S38 | P2 |

---

## 8. Data model

| Entity | Fields | Rules |
|---|---|---|
| **Category** | `id`, `name`, `type` (expense / income), `iconKey`, `colorKey`, `limitMinor?`, `archived`, `sortOrder` | Name unique per type; archived instead of deleted when it has transactions |
| **Transaction** | `id`, `amountMinor`, `type`, `categoryId`, `occurredAt` (UTC), `title`, `note?`, `billId?` | `amountMinor > 0`; type matches the category |
| **Bill** (P2, v1.1) | `id`, `name`, `amountMinor`, `categoryId`, `repeat` (weekly, 2-weekly, monthly on day, 3-monthly, yearly, custom), `nextDue`, `remindDaysBefore?` | Paying creates a Transaction and advances `nextDue` |
| **Goal** (P2, v1.1) | `id`, `name`, `iconKey`, `targetMinor`, `targetMonth`, `completedAt?` | — |
| **GoalContribution** (P2, v1.1) | `id`, `goalId`, `amountMinor` (+ add / − withdraw), `label`, `date` | Not counted as spending |
| **Notification** | `id`, `kind`, `title`, `body`, `createdAt`, `readAt?` | Generated locally |

**Preferences** (key-value): `userName`, `currencyCode`, `monthStartDay` (1–28 or `last`), `monthlyBudgetMinor?`, `theme` (light / dark / system), reminder settings (daily on/off and time, budget alerts on/off, weekly summary on/off), app-lock settings (enabled, biometrics, lock-after, hide-in-switcher), `onboardingComplete`.

**PIN** (P2, v1.1): stored hashed in platform secure storage, never in the database.

**Default categories (8):** expense — Food, Transport, Shopping, Bills, Fun, Health; income — Salary, Gifts. Seeded on first launch; the Settings count ("Categories 8") includes archived categories.

### Derived values
- **Spent / Income** = sums for the period.
- **Left to spend** = monthly budget − spent (negative → "Over budget by"). Savings goal contributions and withdrawals are excluded.
- **Category used %** = category spent ÷ category limit.
- **Allocated** = sum of category limits; **flexible** = budget − allocated.
- **Daily pace** = monthly budget ÷ days in the period.
- **Left after bills** = left to spend − unpaid bills due in the period. Shown on Recurring bills only; it never replaces "Left to spend".
- **Goal monthly need** = (target − saved) ÷ months left, rounded up.

---

## 9. Design system

From the canvas's design-system and brand boards.

### Brand
- Name written **ctrlSpend** (lowercase "ctrl"; "ctrl" in weight 800 and "Spend" in 500 in the wordmark), from **ctrlWorks**.
- Logo: an **amber coin** with a navy **⌃** caret cut into it, on a navy key-shaped tile.
- Endorsed lockup "ctrlSpend by ctrlWorks" for the App Store page and website.
- The splash footer credits the maker instead: **"by BrendanLTW"**.
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

**Category tiles** (background / icon): Food `#FFE2B8` / `#C25E00` · Transport `#CDE6FB` / `#1769C2` · Shopping `#FBD3E1` / `#C8174F` · Bills `#FFF0B8` / `#8A6100` · Fun `#E4DBF7` / `#6D3FD1` · Income `#C9F3D5` / `#1E8A43` · Health `#FEE4E2` / `#D92D20`.

**Chart colours**: Food `#FB8C00` · Shopping `#F0457A` · Transport `#2196F3` · Bills `#F5B800` · Fun `#7C4DDB` · Over budget `#F97066` · Under budget `#98A2B3`.

### Typography — Poppins
| Style | Size / weight | Example |
|---|---|---|
| Display | 56 / 800 | RM 2,000 |
| Amount | 32 / 700 | RM 1,240.00 |
| Page title | 26–28 / 700 | Set your monthly budget |
| Header | 20 / 700 | Transaction |
| Row title | 16 / 600 | Nasi lemak |
| Body | 15 / 400–500 | How much do you want to spend each month? |
| Caption | 13 / 400 | Today · Food |
| Label | 13 / 600, caps | RECENT ACTIVITIES |

Large amounts show the cents smaller than the whole number (e.g. RM 1,240**.00**).

### Shape and spacing
- Radius scale: 12, 16, 20, 24, 28, 32 and pill (999).
- 16 px screen margin; 8–14 px between cards; 20–24 px inside cards.
- Touch targets ≥ 44 px.

### Components
Primary button, pill button, text link, destructive button; segmented control (Week · Month · 6 months); filter chips; toggles; day/option selectors (1st · 15th); category icon tiles; list groups; progress bars; bottom bar with the centre add button; toast ("Saved 214 transactions to Files").

### Accessibility
- Text contrast ≥ 4.5:1 in both themes.
- Every progress bar and chart has a screen-reader label with its values.
- Icon-only buttons are labelled (Back, Close, Settings, Notifications, Add transaction, Backspace).
- Colour is never the only signal.

---

## 10. Non-functional requirements

| Area | Requirement |
|---|---|
| Performance | Cold start to an interactive dashboard in < 2 s on a mid-range Android device; 60 fps lists with 5,000 transactions |
| Offline | Every feature works without a network |
| Correctness | Money as integer minor units; dates stored in UTC, shown in local time |
| Privacy | No accounts, analytics, ads or network calls; data leaves only through export |
| Security | PIN in secure storage; optional biometric unlock; app-switcher snapshot hidden on request |
| Platforms | iOS and Android |
| Quality | `flutter analyze` clean; unit tests for derived values and `periodFor`; widget tests per screen in both themes; one end-to-end test (onboarding → add expense → dashboard → delete → undo); CI on every push |
| Design fidelity | Each screen is compared with its light and dark design before its task is done |

---

## 11. Milestones

The design now covers far more than the original six-week scope. Suggested phases:

| Phase | Scope | Exit criteria |
|---|---|---|
| 0 Foundation | Project, tokens (light and dark), Poppins, routing shell with 4 tabs and add button, money formatter, keypad widget, CI | Shell and keypad match the design in both themes |
| 1 Data | Drift schema, `periodFor`, repositories, derived values | Unit tests pass |
| 2 Core | Onboarding, dashboard (4 hero states), add/edit, activity, budgets, categories, transaction detail and delete | **All P0 done** |
| 3 Complete | Search and filters, insights (3 views), settings screens, notifications, past periods, CSV export and import | **All P1 done** |
| 4 Ship | Accessibility and fidelity pass, end-to-end test, APK, README | **v1.0 released** with all P0 + P1 |
| 5 Update | Recurring bills, savings goals, app lock; schema migration adding the Bill, Goal and GoalContribution tables | P2 tests pass; migration test from v1.0 data; **v1.1 released** |

---

## 12. Risks and open questions

| Risk | Mitigation |
|---|---|
| Scope has roughly tripled since the first plan | P2 moved to v1.1, so v1.0 ships with P0 + P1 only |
| Payday periods with "last day of month" | Exhaustive tests for `periodFor` across month lengths and leap years |
| Local notification scheduling differs by platform | Spike on both platforms in Phase 0 |
| Category limits exceeding the monthly budget | Validate in the domain layer; show remaining allocation in S06 and S17 |

### Open questions
None at the moment.
