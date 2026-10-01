"""Plot the measured request-time blocks from the archived full-day CSV."""

import csv
from pathlib import Path
from statistics import mean

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


def main():
    root = Path(__file__).resolve().parents[1]
    with (root / "plots/conflict_resolution/conflict_resolution_eval.csv").open() as f:
        rows = list(csv.DictReader(f))
    groups = [[r for r in rows if r["conflict_status"] == s] for s in ("clear", "resolved")]
    fig, ax = plt.subplots(figsize=(9, 4.8))
    left = [0.0, 0.0]
    for key, label, color in (
        ("plan_ms_sum", "Planning, including storage", "#386641"),
        ("deconf_ms_sum", "Conflict-checking service call", "#bc4749"),
        ("overhead_ms", "Residual request overhead", "#a7c957"),
    ):
        values = [mean(float(r[key]) for r in group) for group in groups]
        ax.barh([0, 1], values, left=left, label=label, color=color, height=.6)
        for i, value in enumerate(values):
            # Small segments need external labels to remain legible.
            if key == "deconf_ms_sum":
                ax.text(left[i] + value / 2, i, f"{value:.0f}", ha="center", va="center", color="white")
            else:
                ax.annotate(f"{value:.0f}", (left[i] + value / 2, i + .3),
                            xytext=(max(70, left[i] + value / 2), i + .45), ha="center", fontsize=10,
                            arrowprops={"arrowstyle": "-", "color": "black"})
        left = [a + b for a, b in zip(left, values)]
    for total, group in zip(left, groups):
        assert abs(total - mean(float(r["client_elapsed_ms"]) for r in group)) < .02
    ax.set_yticks([0, 1], [f"No conflict detected\nfirst pass (n={len(groups[0])})", f"Resolved by\nre-routing (n={len(groups[1])})"])
    ax.set_ylim(-.55, 1.85)
    ax.set_xlabel("Mean end-to-end latency contribution (ms)")
    ax.legend(loc="upper center", bbox_to_anchor=(.5, -.2), frameon=False)
    fig.tight_layout()
    fig.savefig(root / "figures/conflict_resolution_latency_decomposition.png", dpi=300)
    plt.close(fig)


if __name__ == "__main__":
    main()
