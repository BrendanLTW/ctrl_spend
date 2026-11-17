# CSV format

One format for export (S35) and import (PRD §6.4), so an exported file always imports back. Code: `lib/features/data_transfer/domain/csv_export.dart`.

## File

- Name: `ctrlspend-YYYY-MM-DD.csv`, dated the day of the export.
- UTF-8, no byte-order mark.
- Comma-separated, RFC 4180 quoting: a field with a comma, quote or line break is wrapped in `"`, and a `"` inside it is doubled.
- `\r\n` line endings.
- A header row, then one row per transaction, newest first.

## Columns

In this order, every time:

| Column | Example | Rules |
|---|---|---|
| `date` | `2026-11-04` | The local calendar date, `YYYY-MM-DD` |
| `time` | `08:05` | Local 24-hour time, `HH:mm` |
| `type` | `expense` | `expense` or `income` |
| `amount` | `12.50` | Positive, two decimal places, `.` as the decimal point, no currency symbol and no thousands separator, so spreadsheets read it as a number |
| `category` | `Food` | The category's name. Archived categories export by name too |
| `title` | `Nasi lemak` | As entered |
| `note` | `with egg` | Always present. Empty when there's no note, or when **Notes** is off |

The currency isn't stored: switching currency changes only the symbol, so amounts mean the same in any currency (CLAUDE.md, Money).

## Example

```csv
date,time,type,amount,category,title,note
2026-11-04,08:05,expense,12.50,Food,Nasi lemak,with egg
2026-11-01,09:00,income,4800.00,Salary,November pay,
2026-10-10,18:00,expense,99.00,Shopping,"Shoes, black",
```

## Import

Code: `lib/features/data_transfer/domain/csv_import.dart` and `TransactionRepository.importAll`.

- **All or nothing.** Every row is checked first. If any row has a problem, nothing is imported and S36 lists each problem by row. Otherwise every row is saved in one database transaction.
- **Row numbers** count the header as row 1, as a spreadsheet shows them.
- **Columns** are found by their header names, in any order and any case. `date`, `type`, `category` and `amount` are required; a missing one is a single row 1 problem. `time`, `title` and `note` are optional.
- **Blank lines** are skipped. A byte-order mark is ignored. A file that isn't UTF-8 text is one row 1 problem.
- **Columns are read by name**, so files exported before 15 Nov 2026 (with the old column order) still import.
- **At most 20,000 rows.** More is a single row 1 problem: `{n} rows; an import takes at most 20,000`.
- **Duplicates are skipped.** A row with the same date, type, amount and category (by name and type, ignoring case) as a saved transaction is a duplicate. Duplicates are skipped and the toast says how many; S52 (task 6.18) will offer to import them anyway.
- **Imports add** to what's there.

| Column | Accepted | Problem shown |
|---|---|---|
| `date` | `YYYY-MM-DD` or `DD/MM/YYYY`, only real dates, not after today | `"31/02/2026" isn't a real date`, `"2026-12-01" is in the future`, `Date is empty` |
| `time` | `HH:mm`, 24-hour. Empty means 12:00 | `"25:00" isn't a time` |
| `type` | `expense` or `income`, any case | `"spend" isn't expense or income`, `Type is empty` |
| `category` | Up to 20 characters. Matched by name and type, ignoring case, archived categories included. A new name creates a category with the wallet icon and the neutral colour | `Category is empty`, `Category is over 20 characters` |
| `title` | Up to 40 characters. Empty means the category name | `Title is over 40 characters` |
| `amount` | Above 0, at most two decimals, `,` allowed as a thousands separator (`1,234.50`) | `"abc" isn't an amount`, `Amount is empty` |
| `note` | Up to 200 characters. Empty means no note | `Note is over 200 characters` |

**Download a sample CSV** on S36 shares `ctrlspend-sample.csv` with three example rows.
