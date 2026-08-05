#!/usr/bin/env python3
"""Generate the Experiment A statistics, macros, table and regression figure.

Experiment A measures 100 unique origin--destination (OD) pairs three times
each, giving 300 timing observations. The three repetitions of one OD pair are
not independent route geometries: ``path_distance_km`` and
``trajectory_sample_count`` are identical within a pair, and only the timings
differ. This tool therefore keeps the two sample units apart:

* descriptive runtime distributions use all 300 timing observations;
* every route-length regression, confidence interval and correlation uses the
  100 OD-level means (the mean of the three repetitions per pair).

Outputs (all consumed by the manuscript, never edited by hand):

* ``plots/trajcalc_scalability/planner_numbers.tex``      -- LaTeX macros
* ``plots/trajcalc_scalability/planner_runtime_table.tex``-- complete tabular
* ``figures/planner_scalability_stage_times_vs_distance.png`` -- OD-level
  regression figure

Usage:
    python3 tools/make_planner_stats.py
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import statistics
from collections import OrderedDict
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CSV = REPO_ROOT / "plots" / "trajcalc_scalability" / "planner_scalability.csv"
DEFAULT_FIGURES = REPO_ROOT / "figures"

# (csv key, table label, macro stem, plot colour)
STAGES = [
    ("planner_ms", "Planner-stage subtotal", "Planner", "#C44E52"),
    ("traj_generator_ms", "CFMS invocation + generation", "Gen", "#55A868"),
    ("waypoints_ms", "Waypoint synthesis", "Wp", "#8172B3"),
    ("astar_ms", "A* path search", "Astar", "#4C72B0"),
]

# Two-sided 97.5% Student-t quantiles by degrees of freedom (same lookup as the
# benchmark script, so regenerated numbers stay comparable with the archived run).
_T_TABLE = [
    (1, 12.706), (2, 4.303), (3, 3.182), (5, 2.571), (10, 2.228), (20, 2.086),
    (30, 2.042), (50, 2.009), (100, 1.984), (200, 1.972), (1000, 1.962),
]


def t_975(dof: int) -> float:
    for max_dof, value in _T_TABLE:
        if dof <= max_dof:
            return value
    return 1.960


def quantile_floor(sorted_values: list[float], p: float) -> float:
    """Order statistic at zero-based index floor(p*(n-1)); no interpolation.

    This is the rule the benchmark script implements. It is deliberately not
    described as "nearest rank", which would be ceil(p*n) and gives a different
    order statistic for most sample sizes.
    """
    return sorted_values[int(p * (len(sorted_values) - 1))]


def summarize(values: list[float]) -> dict[str, float]:
    ordered = sorted(values)
    n = len(ordered)
    return {
        "count": float(n),
        "mean": statistics.fmean(ordered),
        "std": statistics.pstdev(ordered) if n > 1 else 0.0,
        "p50": statistics.median(ordered),
        "p90": quantile_floor(ordered, 0.90),
        "max": ordered[-1],
    }


def regression(xs: list[float], ys: list[float]) -> dict[str, float]:
    """OLS y = a + b*x with the 95% slope CI, R^2 and Pearson r."""
    n = len(xs)
    mx, my = statistics.fmean(xs), statistics.fmean(ys)
    sxx = sum((x - mx) ** 2 for x in xs)
    syy = sum((y - my) ** 2 for y in ys)
    sxy = sum((x - mx) * (y - my) for x, y in zip(xs, ys, strict=True))
    slope = sxy / sxx
    intercept = my - slope * mx
    sse = sum((y - (intercept + slope * x)) ** 2 for x, y in zip(xs, ys, strict=True))
    se_slope = math.sqrt(sse / (n - 2) / sxx)
    half = t_975(n - 2) * se_slope
    return {
        "n": float(n),
        "slope": slope,
        "intercept": intercept,
        "slope_ci95_low": slope - half,
        "slope_ci95_high": slope + half,
        "r_squared": 1.0 - sse / syy,
        "pearson_r": sxy / math.sqrt(sxx * syy),
    }


def bucket_label(distance_km: float) -> str:
    start = int(distance_km // 10) * 10
    return f"{start}-{start + 10} km"


def load(csv_path: Path) -> tuple[list[dict[str, str]], OrderedDict]:
    with csv_path.open(newline="", encoding="utf-8") as fh:
        rows = [r for r in csv.DictReader(fh) if r.get("status") == "200"]
    groups: OrderedDict = OrderedDict()
    for row in rows:
        groups.setdefault((row["takeoff"], row["landing"]), []).append(row)
    return rows, groups


def od_means(groups: OrderedDict, key: str) -> list[float]:
    """Mean of the repeated measurements of ``key``, one value per OD pair."""
    return [statistics.fmean(float(r[key]) for r in reps) for reps in groups.values()]


def fmt(value: float, digits: int) -> str:
    return f"{value:.{digits}f}"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--csv", type=Path, default=DEFAULT_CSV)
    parser.add_argument("--figures", type=Path, default=DEFAULT_FIGURES)
    parser.add_argument("--no-figure", action="store_true", help="skip the regression figure")
    args = parser.parse_args()

    rows, groups = load(args.csv)
    n_obs, n_pairs = len(rows), len(groups)
    reps = sorted({len(v) for v in groups.values()})
    if len(reps) != 1:
        raise SystemExit(f"Unequal repetition counts per OD pair: {reps}")
    n_reps = reps[0]

    # Geometry is deterministic per OD pair; assert it so the aggregation is sound.
    for pair, group in groups.items():
        for key in ("path_distance_km", "trajectory_sample_count"):
            if len({r[key] for r in group}) != 1:
                raise SystemExit(f"{key} varies within OD pair {pair}; cannot aggregate")

    # ---- descriptive runtime distributions: all timing observations ----------
    obs_stats = {key: summarize([float(r[key]) for r in rows]) for key, _, _, _ in STAGES}

    # ---- regressions and correlations: OD-level means ----------------------
    od = {
        key: od_means(groups, key)
        for key in ("planner_ms", "traj_generator_ms", "waypoints_ms",
                    "astar_ms", "path_distance_km", "trajectory_sample_count")
    }
    regs = {
        "planner_vs_distance": regression(od["path_distance_km"], od["planner_ms"]),
        "gen_vs_distance": regression(od["path_distance_km"], od["traj_generator_ms"]),
        "samples_vs_distance": regression(od["path_distance_km"], od["trajectory_sample_count"]),
        "gen_vs_samples": regression(od["trajectory_sample_count"], od["traj_generator_ms"]),
        "wp_vs_distance": regression(od["path_distance_km"], od["waypoints_ms"]),
        "astar_vs_distance": regression(od["path_distance_km"], od["astar_ms"]),
    }

    # ---- distance buckets, counted in both units ---------------------------
    obs_buckets: dict[str, int] = {}
    for row in rows:
        label = bucket_label(float(row["path_distance_km"]))
        obs_buckets[label] = obs_buckets.get(label, 0) + 1
    pair_buckets: dict[str, int] = {}
    for group in groups.values():
        label = bucket_label(float(group[0]["path_distance_km"]))
        pair_buckets[label] = pair_buckets.get(label, 0) + 1
    order = sorted(obs_buckets, key=lambda s: int(s.split("-")[0]))

    outdir = args.csv.parent

    # ---- runtime table -----------------------------------------------------
    table = ["\\begin{tabular}{lrrrrr}", "  \\toprule",
             "  Metric & Mean (ms) & Std (ms) & \\(p_{50}\\) (ms) & "
             "\\(p_{90}\\) (ms) & Max (ms) \\\\", "  \\midrule"]
    for key, label, _, _ in STAGES:
        s = obs_stats[key]
        table.append(
            f"  {label} & {s['mean']:.2f} & {s['std']:.2f} & "
            f"{s['p50']:.2f} & {s['p90']:.2f} & {s['max']:.2f} \\\\"
        )
    table += ["  \\bottomrule", "\\end{tabular}"]
    (outdir / "planner_runtime_table.tex").write_text("\n".join(table) + "\n", encoding="utf-8")

    # ---- macros ------------------------------------------------------------
    m: list[str] = [
        "% Generated by tools/make_planner_stats.py -- do not edit by hand.",
        "% Descriptive runtime statistics use all timing observations;",
        "% every regression and correlation uses the OD-level means.",
        f"\\newcommand{{\\paObs}}{{{n_obs}}}",
        f"\\newcommand{{\\paPairs}}{{{n_pairs}}}",
        f"\\newcommand{{\\paReps}}{{{n_reps}}}",
    ]
    for key, _, stem, _ in STAGES:
        s = obs_stats[key]
        digits = 2
        # LaTeX control sequences may not contain digits, hence "Pninety".
        m.append(f"\\newcommand{{\\pa{stem}Mean}}{{{fmt(s['mean'], digits)}}}")
        m.append(f"\\newcommand{{\\pa{stem}Pninety}}{{{fmt(s['p90'], digits)}}}")
        m.append(f"\\newcommand{{\\pa{stem}Max}}{{{fmt(s['max'], digits)}}}")
    share = 100.0 * obs_stats["traj_generator_ms"]["mean"] / obs_stats["planner_ms"]["mean"]
    m.append(f"\\newcommand{{\\paGenShare}}{{{share:.1f}}}")

    spec = [
        ("PlannerDist", "planner_vs_distance", 2),
        ("GenDist", "gen_vs_distance", 2),
        ("SamplesDist", "samples_vs_distance", 1),
        ("GenSamples", "gen_vs_samples", 3),
        ("WpDist", "wp_vs_distance", 4),
        ("AstarDist", "astar_vs_distance", 4),
    ]
    for stem, name, digits in spec:
        r = regs[name]
        m.append(f"\\newcommand{{\\pa{stem}Slope}}{{{fmt(r['slope'], digits)}}}")
        m.append(f"\\newcommand{{\\pa{stem}Lo}}{{{fmt(r['slope_ci95_low'], digits)}}}")
        m.append(f"\\newcommand{{\\pa{stem}Hi}}{{{fmt(r['slope_ci95_high'], digits)}}}")
        m.append(f"\\newcommand{{\\pa{stem}Rsq}}{{{fmt(r['r_squared'], 2)}}}")
        m.append(f"\\newcommand{{\\pa{stem}R}}{{{fmt(r['pearson_r'], 2)}}}")

    for stem, labels in (("Obs", obs_buckets), ("Pair", pair_buckets)):
        m.append(
            f"\\newcommand{{\\paBucket{stem}List}}{{"
            + ", ".join(str(labels[b]) for b in order) + "}"
        )
    m.append("\\newcommand{\\paBucketRanges}{" + ", ".join(b.replace("-", "--") for b in order) + "}")
    for key, _, stem, _ in STAGES:
        vals = [statistics.pstdev([float(r[key]) for r in rows
                                   if bucket_label(float(r["path_distance_km"])) == b])
                for b in order]
        if stem == "Planner":
            m.append("\\newcommand{\\paPlannerBucketStd}{"
                     + ", ".join(f"{v:.1f}" for v in vals) + "}")
    (outdir / "planner_numbers.tex").write_text("\n".join(m) + "\n", encoding="utf-8")

    # ---- machine-readable summary -----------------------------------------
    summary = {
        "sample_units": {
            "timing_observations": n_obs,
            "unique_od_pairs": n_pairs,
            "repetitions_per_od_pair": n_reps,
            "note": "Regressions use the per-OD-pair mean of the repetitions; "
                    "descriptive runtime distributions use all timing observations.",
        },
        "quantile_method": "order statistic at zero-based index floor(p*(n-1)); "
                           "p50 is the standard median (mean of the two central "
                           "order statistics for even n)",
        "runtime_observations": {label: obs_stats[key] for key, label, _, _ in STAGES},
        "regressions_od_level": {k: {kk: round(vv, 6) for kk, vv in v.items()}
                                 for k, v in regs.items()},
        "distance_buckets": {
            "timing_observations": {b: obs_buckets[b] for b in order},
            "unique_od_pairs": {b: pair_buckets[b] for b in order},
        },
    }
    (outdir / "planner_stats_summary.json").write_text(
        json.dumps(summary, indent=2) + "\n", encoding="utf-8"
    )

    for name in ("planner_runtime_table.tex", "planner_numbers.tex", "planner_stats_summary.json"):
        print(f"wrote {(outdir / name).relative_to(REPO_ROOT)}")

    if not args.no_figure:
        write_figure(od, regs, args.figures, n_pairs)
    return 0


def write_figure(od: dict, regs: dict, figures_dir: Path, n_pairs: int) -> None:
    """Regression figure over the OD-level means, one panel per planner stage."""
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    panels = [
        ("astar_ms", "A* path search", "#4C72B0", "astar_vs_distance"),
        ("waypoints_ms", "Waypoint synthesis", "#8172B3", "wp_vs_distance"),
        ("traj_generator_ms", "Trajectory generation", "#55A868", "gen_vs_distance"),
        ("planner_ms", "Planner subtotal", "#C44E52", "planner_vs_distance"),
    ]
    rc = {"axes.titlesize": 20, "axes.labelsize": 19,
          "xtick.labelsize": 17, "ytick.labelsize": 17}
    with plt.rc_context(rc):
        fig, axes = plt.subplots(2, 2, figsize=(12.5, 8.5), sharex=True)
        xs = od["path_distance_km"]
        xline = [min(xs), max(xs)]
        for ax, (key, title, color, reg_name) in zip(axes.flat, panels, strict=True):
            reg = regs[reg_name]
            ax.scatter(xs, od[key], alpha=0.82, s=48, color=color,
                       edgecolors="#1f1f1f", linewidths=0.35)
            ax.plot(xline, [reg["intercept"] + reg["slope"] * x for x in xline],
                    color="#1f1f1f", lw=1.6, ls="--", alpha=0.8)
            ax.set_title(f"{title}\nPearson r = {reg['pearson_r']:.2f}")
            ax.set_ylabel("Time (ms)")
            ax.grid(True, ls="--", alpha=0.35)
        for ax in axes[-1]:
            ax.set_xlabel("Path distance (km)")
        fig.suptitle(
            f"Planner-Stage Latency vs. Path Distance ({n_pairs} OD pairs, "
            "mean of 3 repetitions)", fontsize=20,
        )
        fig.tight_layout()
        figures_dir.mkdir(parents=True, exist_ok=True)
        out = figures_dir / "planner_scalability_stage_times_vs_distance.png"
        fig.savefig(str(out), dpi=260)
        plt.close(fig)
    print(f"wrote {out.relative_to(REPO_ROOT)}")


if __name__ == "__main__":
    raise SystemExit(main())
