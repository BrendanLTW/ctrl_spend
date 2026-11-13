# CSV format

The file S35 exports and S36 (task 3.11) imports. Code: `lib/features/data_transfer/domain/csv_export.dart`.

## File

- Name: `ctrlspend-YYYY-MM-DD.csv`, dated the day of the export.
- UTF-8, no byte-order mark.
- Comma-separated, RFC 4180 quoting: a field with a comma, quote or line break is wrapped in `"`, and a `"` inside it is doubled.
- `\r\n` line endings.
- A header row, then one row per transaction, newest first.

## Columns

| Column | Example | Rules |
|---|---|---|
| `date` | `2026-11-04` | The local calendar date, `YYYY-MM-DD` |
| `time` | `08:05` | Local 24-hour time, `HH:mm` |
| `type` | `expense` | `expense` or `income` |
| `category` | `Food` | The category's name. Archived categories export by name too |
| `title` | `Nasi lemak` | As entered |
| `amount` | `12.50` | Positive, two decimal places, `.` as the decimal point, no currency symbol and no thousands separator, so spreadsheets read it as a number |
| `note` | `with egg` | Only when **Notes** is on. Empty when there's no note |

The currency isn't stored: switching currency changes only the symbol, so amounts mean the same in any currency (CLAUDE.md, Money).

## Example

```csv
date,time,type,category,title,amount,note
2026-11-04,08:05,expense,Food,Nasi lemak,12.50,with egg
2026-11-01,09:00,income,Salary,November pay,4800.00,
2026-10-10,18:00,expense,Shopping,"Shoes, black",99.00,
```

## Import

Code: `lib/features/data_transfer/domain/csv_import.dart` and `TransactionRepository.importAll`.

- **All or nothing.** Every row is checked first. If any row has a problem, nothing is imported and S36 lists each problem by row. Otherwise every row is saved in one database transaction.
- **Row numbers** count the header as row 1, as a spreadsheet shows them.
- **Columns** are found by their header names, in any order and any case. `date`, `type`, `category` and `amount` are required; a missing one is a single row 1 problem. `time`, `title` and `note` are optional.
- **Blank lines** are skipped. A byte-order mark is ignored. A file that isn't UTF-8 text is one row 1 problem.
- **Imports add** to what's there; there is no duplicate check.

| Column | Accepted | Problem shown |
|---|---|---|
| `date` | `YYYY-MM-DD` or `DD/MM/YYYY`, only real dates | `"31/02/2026" isn't a real date`, `Date is empty` |
| `time` | `HH:mm`, 24-hour. Empty means 12:00 | `"25:00" isn't a time` |
| `type` | `expense` or `income`, any case | `"spend" isn't expense or income`, `Type is empty` |
| `category` | Any name. Matched by name and type, ignoring case, archived categories included. A new name creates a category with the wallet icon and the neutral colour | `Category is empty` |
| `title` | Any text. Empty means the category name | — |
| `amount` | Above 0, at most two decimals, `,` allowed as a thousands separator (`1,234.50`) | `"abc" isn't an amount`, `Amount is empty` |
| `note` | Any text. Empty means no note | — |

**Download a sample CSV** on S36 shares `ctrlspend-sample.csv` with three example rows.
