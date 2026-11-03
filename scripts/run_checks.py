"""Run the data-quality rules and write the scorecard.

Usage: python scripts/run_checks.py
Reads data/bank.db, sql/02_dq_rules.sql and docs/dq_rules.csv.
Writes results/dq_scorecard.csv and results/dq_dimension_summary.csv.
"""
import csv, re, sqlite3, os
from collections import defaultdict

DB, SQL, META = "data/bank.db", "sql/02_dq_rules.sql", "docs/dq_rules.csv"
os.makedirs("results", exist_ok=True)

meta = {r["rule_id"]: r for r in csv.DictReader(open(META, encoding="utf-8"))}
blocks = re.split(r"^-- (DQ\d{2}) \|.*$", open(SQL, encoding="utf-8").read(), flags=re.M)
rules = dict(zip(blocks[1::2], (b.strip().rstrip(";") for b in blocks[2::2])))

con = sqlite3.connect(DB)
rows = []
for rid, query in rules.items():
    tested, failed = con.execute(query).fetchone()
    failed = failed or 0
    m = meta[rid]
    pass_pct = round(100 * (tested - failed) / tested, 2) if tested else 100.0
    if m["threshold_pct"] == "n/a":
        status = "Monitor"
    else:
        status = "Pass" if pass_pct >= float(m["threshold_pct"]) else "Fail"
    rows.append({"rule_id": rid, "dimension": m["dimension"], "table": m["table"], "rule": m["rule"],
                 "records_tested": tested, "records_failed": failed, "pass_pct": pass_pct,
                 "threshold_pct": m["threshold_pct"], "status": status, "severity": m["severity"],
                 "rule_owner": m["rule_owner"]})

with open("results/dq_scorecard.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
    w.writeheader(); w.writerows(rows)

dims = defaultdict(lambda: [0, 0, 0, 0])
for r in rows:
    if r["status"] == "Monitor":
        continue
    d = dims[r["dimension"]]
    d[0] += r["records_tested"]; d[1] += r["records_failed"]; d[2] += 1; d[3] += r["status"] == "Pass"
with open("results/dq_dimension_summary.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["dimension", "rules", "rules_passed", "records_tested", "records_failed", "pass_pct"])
    for k, (t, fl, n, p) in sorted(dims.items()):
        w.writerow([k, n, p, t, fl, round(100 * (t - fl) / t, 2)])

for r in rows:
    print(f'{r["rule_id"]} {r["status"]:7} {r["pass_pct"]:>7}% failed={r["records_failed"]:>5}/{r["records_tested"]:<6} {r["rule"]}')
