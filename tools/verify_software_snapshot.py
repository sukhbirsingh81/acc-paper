"""Verify integrity of the recovered local archive, not historical execution identity."""

import hashlib
import json
import tarfile
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parents[1]


def check_hash(path, expected):
    actual = hashlib.sha256(path.read_bytes()).hexdigest()
    if actual != expected:
        raise ValueError(f"Checksum mismatch: {path.relative_to(ROOT)}")


def main():
    snapshot = json.loads((ROOT / "reproducibility/software_snapshot.json").read_text())
    for item in snapshot["archives"]:
        path = ROOT / item["archive"]
        check_hash(path, item["sha256"])
        with tarfile.open(path) as archive:
            members = archive.getmembers()
            if len(members) != item["files"]:
                raise ValueError(f"File count mismatch: {item['component']}")
            for member in members:
                name = PurePosixPath(member.name)
                if name.is_absolute() or ".." in name.parts or not member.isfile():
                    raise ValueError(f"Unsafe archive member: {member.name}")
                if member.name in item["omitted_paths"]:
                    raise ValueError(f"Excluded file present: {member.name}")
        print(f"Verified {item['component']}: {item['files']} files")
    perf = ROOT / ".preserved/2026-09-21-software-snapshot/configuration/planner/data/uam_performance_params.txt"
    check_hash(perf, snapshot["aircraft"]["performance_file_sha256"])
    manifest = json.loads((ROOT / "results_manifest.json").read_text())
    check_hash(ROOT / "reproducibility/software_snapshot.json",
               manifest["provenance_recovery"]["record_sha256"])
    for name, checksum in snapshot["preserved_support_files"].items():
        check_hash(ROOT / name, checksum)
    for group in ("result_hashes", "paper_figure_hashes"):
        for name, checksum in manifest[group].items():
            path = (ROOT / "figures" / name if group == "paper_figure_hashes"
                    else ROOT / "plots" / name.replace("evaluation/", "trajcalc_scalability/"))
            check_hash(path, checksum)
    print("Verified aircraft default file and all recorded result/figure hashes.")
    print("Historical runtime selection remains unverified; see reproducibility/README.md.")


if __name__ == "__main__":
    main()
