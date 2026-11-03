"""Build the steward work queue from failed rules.

Usage: python scripts/extract_exceptions.py [--all]
Writes results/exceptions.csv. By default each rule is capped at 25 records
so the published file stays readable; pass --all for the full extract.
"""
import csv, re, sqlite3, sys, os

cap = None if "--all" in sys.argv else 25
blocks = re.split(r"^-- (DQ\d{2}) \|.*$", open("sql/03_exception_extracts.sql", encoding="utf-8").read(), flags=re.M)
con = sqlite3.connect("data/bank.db")
os.makedirs("results", exist_ok=True)
with open("results/exceptions.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["rule_id", "record_id", "detail", "total_failures_for_rule"])
    for rid, q in zip(blocks[1::2], blocks[2::2]):
        rows = con.execute(q.strip().rstrip(";")).fetchall()
        for rec, detail in rows[:cap]:
            w.writerow([rid, rec, detail, len(rows)])
        print(rid, len(rows))
