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

## Import (task 3.11)

Import reads the same columns. Its validation rules (unknown categories, bad dates, empty amounts) and the all-or-nothing behaviour are defined in that task.
