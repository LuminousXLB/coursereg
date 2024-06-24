#!/usr/bin/env python3
import datetime
import json
import re
import unicodedata
from pathlib import Path

from bs4 import BeautifulSoup


def drop_empty_lines(text: list[str]) -> list[str]:
    return [ln.strip() for ln in text if ln.strip()]


def extract_mtime(html: str) -> datetime.datetime:
    mo = re.search(r"Last Modified on: (\d+ \w+ \d+ \d+:\d+:\d+)", html)
    if not mo:
        print(html)
        raise ValueError("Could not find last modified date")

    mtime = datetime.datetime.strptime(mo.group(1), "%d %B %Y %H:%M:%S")
    return mtime


def parse_table(table: BeautifulSoup):
    headers = [
        th.get_text(separator="\n").strip() for th in table.find("thead").find_all("th")
    ]

    assert headers[0] in ("Module Code", "Course Code"), headers[0]
    assert headers[1] in ("Module Title", "Course Title"), headers[1]

    meta = {}
    for header in headers[2:]:
        pairs = drop_empty_lines(header.replace(",", "\n").splitlines())
        assert len(pairs) == 2, pairs
        meta[pairs[0]] = pairs[1]

    sched = []
    for tr in table.find("tbody").find_all("tr"):
        cells = tr.find_all("td")

        data = {
            headers[0]: cells[0].get_text().strip(),
            headers[1]: drop_empty_lines(
                cells[1].get_text(separator="\n").splitlines()
            ),
        }

        for key, cell in zip(meta.keys(), cells[2:]):
            text = unicodedata.normalize("NFKD", cell.get_text(separator="\n"))
            data[key] = drop_empty_lines(text.splitlines())

        sched.append(data)

    return meta, sched


def clean_sched(path: Path, html: str) -> str:
    mtime = extract_mtime(html)
    print(mtime)

    soup = BeautifulSoup(html, "html.parser")
    meta, sched = parse_table(soup.find("table"))
    with open(path.with_suffix(".json"), "w") as f:
        meta["last_modified"] = mtime.isoformat()
        json.dump({"meta": meta, "schedule": sched}, f, indent=2)


if __name__ == "__main__":
    from sys import argv

    path = Path(argv[1])
    assert path.is_file(), "Invalid file path {}".format(path)

    with path.open() as f:
        clean_sched(path, f.read())
