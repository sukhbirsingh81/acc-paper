#!/usr/bin/env python3
"""Generate the conflict-resolution LaTeX tables and number macros.

The evaluation script (``devtools/paper_conflict_resolution_evaluation.py`` in
acc-trajcalc) records ``peer_set_size`` after appending an accepted candidate to
the peer list, so an accepted request counts itself as one of its own peers.
This tool derives the peer count the paper reports,

    peers_available = peer_set_size - (1 if the request was accepted else 0)

and writes every number the manuscript quotes into a macro file, so no value is
typed by hand. Run it after regenerating the experiment outputs:

    python3 tools/make_conflict_tables.py \
        --results plots/conflict_resolution \
        --out-rows plots/conflict_resolution/conflict_resolution_cases_rows.tex \
        --out-macros plots/conflict_resolution/conflict_numbers.tex

Deterministic: identical inputs produce identical output bytes.
"""

from __future__ import annotations

import argparse
import ast
import csv
import json
from pathlib import Path

WINDOWS = [
    ("fullday", "."),
    ("sixty", "window_60min"),
    ("thirty", "window_30min"),
    ("fifteen", "window_15min"),
]

STATUS_LABELS = {
    "clear": "Conflict-free",
    "resolved": "Resolved by re-routing",
    "not_checked_no_other_trajectories": "Empty peer set",
    "stalled_no_new_edges": "Mapping stalled",
    "max_attempts_exceeded": "Retry limit",
    "no_path": "No route",
    "": "Routing failed",
}

STATUS_KEYS = [
    "clear",
    "resolved",
    "max_attempts_exceeded",
    "no_path",
    "stalled_no_new_edges",
    "not_checked_no_other_trajectories",
]


def latex_escape(text: str) -> str:
    for old, new in (("\\", r"\textbackslash{}"), ("_", r"\_"), ("&", r"\&"),
                     ("%", r"\%"), ("#", r"\#")):
        text = text.replace(old, new)
    return text


def read_rows(directory: Path) -> list[dict[str, str]]:
    path = directory / "conflict_resolution_eval.csv"
    with path.open(encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def peers_available(row: dict[str, str]) -> int:
    """Peer trajectories available at request time, excluding the candidate."""
    size = int(row["peer_set_size"])
    return size - 1 if row["accepted"] == "1" else size


def fmt(value: object, digits: int = 2) -> str:
    if value in (None, ""):
        return "--"
    try:
        return f"{float(value):.{digits}f}"
    except (TypeError, ValueError):
        return str(value)


def build_case_rows(rows: list[dict[str, str]]) -> str:
    """Complete tabular of every request that had at least one initial conflict.

    The whole environment is generated, not just the rows: an ``\\input`` that
    ends inside a tabular leaves the alignment mid-row and misplaces the
    following ``\\bottomrule``.
    """
    lines: list[str] = [
        r"\begin{tabular}{@{}p{1.35cm}cp{2.15cm}p{1.75cm}ccrrrp{1.3cm}@{}}",
        r"  \toprule",
        r"  OD pair & Att. & Blocked edges & Encounter & Peers & Detour & "
        r"\makecell{Plan\\(ms)} & \makecell{Detect\\(ms)} & \makecell{E2E\\(ms)} & Status \\",
        r"  \midrule",
    ]
    for row in rows:
        if int(row["initial_conflict_count"] or 0) <= 0:
            continue
        edges = ast.literal_eval(row["blocked_edges"]) if row["blocked_edges"].strip() else []
        edge_str = "; ".join(
            f"{latex_escape(e['from'])}\\(\\to\\){latex_escape(e['to'])}" for e in edges
        ) or "--"
        encounter = latex_escape(row["encounter_types"].replace(",", ";")) or "unclassified"
        od = f"{row['takeoff']}--{row['landing']}"
        plan = row["plan_ms_sum"] or row["planner_ms"]
        lines.append(
            f"  \\texttt{{{latex_escape(od)}}} & {row['attempt_count']} & {edge_str} & "
            f"{encounter} & {peers_available(row)} & {fmt(row['detour_ratio'], 4)} & "
            f"{fmt(plan)} & {fmt(row['deconf_ms_sum'])} & {fmt(row['client_elapsed_ms'])} & "
            f"{latex_escape(STATUS_LABELS.get(row['conflict_status'], 'other'))} \\\\"
        )
    lines.append(r"  \bottomrule")
    lines.append(r"\end{tabular}")
    return "\n".join(lines) + "\n"


def window_stats(directory: Path) -> dict[str, object]:
    rows = read_rows(directory)
    with (directory / "conflict_resolution_summary.json").open(encoding="utf-8") as handle:
        summary = json.load(handle)

    counts = {key: summary["status_counts"].get(key, 0) for key in STATUS_KEYS}
    comparisons = sum(peers_available(r) for r in rows)
    overlapping = sum(int(r["overlapping_peer_count"]) for r in rows)
    with_overlap = sum(1 for r in rows if int(r["overlapping_peer_count"]) > 0)
    conflicted = sum(1 for r in rows if int(r["initial_conflict_count"] or 0) > 0)
    blocked = sum(int(r["blocked_edge_count"] or 0) for r in rows)
    attempts = [int(r["attempt_count"] or 0) for r in rows]
    checked = [a for a in attempts if a > 0]
    detours = sorted(
        float(r["detour_ratio"])
        for r in rows
        if r["conflict_status"] == "resolved" and r["detour_ratio"]
    )
    all_detours = sorted(float(r["detour_ratio"]) for r in rows if r["detour_ratio"])

    return {
        **counts,
        "requests": len(rows),
        "comparisons": comparisons,
        "overlapping_pairs": overlapping,
        "with_overlap": with_overlap,
        "conflicted": conflicted,
        "conflict_rate": (conflicted / with_overlap) if with_overlap else 0.0,
        "blocked_edges": blocked,
        "attempts_mean": (sum(checked) / len(checked)) if checked else 0.0,
        "attempts_max": max(attempts) if attempts else 0,
        "detour_median": detours[len(detours) // 2] if detours else 0.0,
        "detour_max": max(all_detours) if all_detours else 0.0,
        "latency": summary.get("latency_decomposition_ms", {}),
    }


def build_density_table(stats: dict[str, dict[str, object]]) -> str:
    order = [name for name, _ in WINDOWS]
    labels = {
        "clear": "Conflict-free first check",
        "resolved": "Resolved by re-routing",
        "max_attempts_exceeded": "Retry limit (5 attempts)",
        "no_path": "No route left",
        "stalled_no_new_edges": "Mapping stalls",
        "conflicted": "Requests with initial conflict",
        "overlapping_pairs": "Temporally overlapping pairs",
        "blocked_edges": "Blocked directed edges",
    }
    ordered = [
        "clear", "resolved", "max_attempts_exceeded", "no_path",
        "stalled_no_new_edges", "conflicted", "overlapping_pairs",
    ]
    out = [
        r"\begin{tabular}{lrrrr}",
        r"  \toprule",
        r"  & Full day & 60 min & 30 min & 15 min \\",
        r"  \midrule",
    ]
    out += [
        f"  {labels[key]} & " + " & ".join(str(stats[n][key]) for n in order) + r" \\"
        for key in ordered
    ]
    rate = " & ".join(f"{100 * float(stats[n]['conflict_rate']):.1f}\\%" for n in order)
    out.append(f"  Conflict rate given overlap & {rate} \\\\")
    out.append(
        "  Blocked directed edges & "
        + " & ".join(str(stats[n]["blocked_edges"]) for n in order)
        + r" \\"
    )
    out.append(r"  \bottomrule")
    out.append(r"\end{tabular}")
    return "\n".join(out) + "\n"


def build_macros(stats: dict[str, dict[str, object]], rows: list[dict[str, str]]) -> str:
    """One \\newcommand per number the manuscript quotes."""
    lines = [
        "% Generated by tools/make_conflict_tables.py -- do not edit by hand.",
    ]

    def add(name: str, value: object) -> None:
        lines.append(f"\\newcommand{{\\{name}}}{{{value}}}")

    base = stats["fullday"]
    add("cfRequests", base["requests"])
    add("cfClear", base["clear"])
    add("cfResolved", base["resolved"])
    add("cfEmptyPeer", base["not_checked_no_other_trajectories"])
    add("cfRetryLimit", base["max_attempts_exceeded"])
    add("cfNoRoute", base["no_path"])
    add("cfStalled", base["stalled_no_new_edges"])
    add("cfComparisons", base["comparisons"])
    add("cfOverlapPairs", base["overlapping_pairs"])
    add("cfWithOverlap", base["with_overlap"])
    add("cfConflicted", base["conflicted"])
    add("cfConflictRate", f"{100 * float(base['conflict_rate']):.1f}")
    add("cfBlockedEdges", base["blocked_edges"])

    resolved = [r for r in rows if r["conflict_status"] == "resolved"]
    add("cfAttemptList", ", ".join(str(int(r["attempt_count"])) for r in resolved))
    add("cfDetourList", ", ".join(f"{float(r['detour_ratio']):.2f}" for r in resolved))

    latency = base["latency"]
    clear = latency.get("clear_first_pass", {})
    res = latency.get("resolved", {})
    add("cfClearClientMs", f"{clear.get('client_mean', 0):.0f}")
    add("cfClearPlanMs", f"{clear.get('planner_mean', 0):.0f}")
    add("cfClearDetectMs", f"{clear.get('detection_mean', 0):.0f}")
    add("cfClearOverheadMs", f"{clear.get('overhead_mean', 0):.0f}")
    add("cfResolvedClientMs", f"{res.get('client_mean', 0):.0f}")
    add("cfResolvedPlanMs", f"{res.get('planner_sum_mean', 0):.0f}")
    add("cfResolvedDetectMs", f"{res.get('detection_sum_mean', 0):.0f}")
    add("cfResolvedOverheadMs", f"{res.get('overhead_mean', 0):.0f}")

    for name, _ in WINDOWS:
        s = stats[name]
        prefix = f"cf{name.capitalize()}"
        add(f"{prefix}Clear", s["clear"])
        add(f"{prefix}Resolved", s["resolved"])
        add(f"{prefix}Retry", s["max_attempts_exceeded"])
        add(f"{prefix}NoRoute", s["no_path"])
        add(f"{prefix}Stalled", s["stalled_no_new_edges"])
        add(f"{prefix}Conflicted", s["conflicted"])
        add(f"{prefix}OverlapPairs", s["overlapping_pairs"])
        add(f"{prefix}Blocked", s["blocked_edges"])
        add(f"{prefix}Rate", f"{100 * float(s['conflict_rate']):.1f}")
        add(f"{prefix}DetourMedian", f"{float(s['detour_median']):.2f}")
        add(f"{prefix}DetourMax", f"{float(s['detour_max']):.1f}")

    dense = [stats[n] for n in ("sixty", "thirty", "fifteen")]
    add("cfDenseDetourMedianMin", f"{min(float(s['detour_median']) for s in dense):.1f}")
    add("cfDenseDetourMedianMax", f"{max(float(s['detour_median']) for s in dense):.1f}")
    add("cfDenseDetourMax", f"{max(float(s['detour_max']) for s in dense):.1f}")

    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--results", type=Path, default=Path("plots/conflict_resolution"))
    parser.add_argument("--out-rows", type=Path,
                        default=Path("plots/conflict_resolution/conflict_resolution_cases_rows.tex"))
    parser.add_argument("--out-density", type=Path,
                        default=Path("plots/conflict_resolution/conflict_density_rows.tex"))
    parser.add_argument("--out-macros", type=Path,
                        default=Path("plots/conflict_resolution/conflict_numbers.tex"))
    args = parser.parse_args()

    stats = {name: window_stats(args.results / sub) for name, sub in WINDOWS}
    base_rows = read_rows(args.results)

    args.out_rows.write_text(build_case_rows(base_rows), encoding="utf-8")
    args.out_density.write_text(build_density_table(stats), encoding="utf-8")
    args.out_macros.write_text(build_macros(stats, base_rows), encoding="utf-8")

    print(f"wrote {args.out_rows}")
    print(f"wrote {args.out_density}")
    print(f"wrote {args.out_macros}")


if __name__ == "__main__":
    main()
