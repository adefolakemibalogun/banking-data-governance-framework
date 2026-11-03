"""Load the synthetic banking tables from the portfolio workbook into SQLite.

Usage: python scripts/load_data.py path/to/banking-operations-mi.xlsx
Creates data/bank.db with tables: customer_account, transactions, loans.
"""
import sqlite3, sys, os
import openpyxl

SHEETS = {
    "Customer Portfolio": ("customer_account", ["customer_id", "customer_type", "account_id", "account_type",
                                                "account_status", "account_balance", "opening_date", "account_type_display"]),
    "Banking Operations": ("transactions", ["transaction_id", "transaction_date", "transaction_year", "transaction_month",
                                            "transaction_type", "branch_name", "account_type", "customer_type", "amount"]),
    "Loan Portfolio": ("loans", ["loan_id", "account_id", "customer_id", "customer_type", "account_type",
                                 "loan_status", "principal_amount", "interest_rate", "start_date", "estimated_end_date"]),
}

def norm(v):
    if hasattr(v, "date"):
        return v.date().isoformat()
    return v

def main(xlsx, db="data/bank.db"):
    os.makedirs(os.path.dirname(db), exist_ok=True)
    if os.path.exists(db):
        os.remove(db)
    wb = openpyxl.load_workbook(xlsx, read_only=True, data_only=True)
    con = sqlite3.connect(db)
    for sheet, (table, cols) in SHEETS.items():
        ws = wb[sheet]
        rows = ws.iter_rows(values_only=True)
        next(rows)  # header
        data = [tuple(norm(v) for v in r[: len(cols)]) for r in rows if any(v is not None for v in r[: len(cols)])]
        con.execute(f"CREATE TABLE {table} ({', '.join(cols)})")
        con.executemany(f"INSERT INTO {table} VALUES ({', '.join('?' * len(cols))})", data)
        print(f"{table}: {len(data)} rows")
    con.commit()
    con.close()

if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "banking-operations-mi.xlsx")
