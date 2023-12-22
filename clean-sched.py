import datetime
import re
from hashlib import sha1
from pathlib import Path
from sys import argv

from bs4 import BeautifulSoup

path = Path(argv[1])
assert path.is_file(), "Invalid file path {}".format(path)

with open(path, "r") as f:
    html = f.read()


mo = re.search(r"Last Modified on: (\d+ \w+ \d+ \d+:\d+:\d+)", html)
if not mo:
    print(html)
    raise ValueError("Could not find last modified date")

mtime = datetime.datetime.strptime(mo.group(1), "%d %B %Y %H:%M:%S")
print(mtime)

soup = BeautifulSoup(html, "html.parser")
with open(path.with_suffix(".sha1"), "w") as f:
    f.write(sha1(html.encode()).hexdigest())
