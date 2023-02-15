import sys
from pathlib import Path
import subprocess

RUN_DIR = Path.cwd() / "run"
EXCLUDE_MANIFESTS = ["params.json"]

VERSION_NAME = "version-store--main--first-run"
VERSION_NAMESPACE = f"vl--{VERSION_NAME}"
VERSION_URL = ".".join(list(reversed(VERSION_NAME.split("--"))))
VCLUSTER_NAMESPACE = f"vc--{VERSION_NAME}"

OUT_DIR = "test-run"
subprocess.run(f"rm -rf {OUT_DIR}", shell=True, check=True)
Path(OUT_DIR).mkdir()

jsonnet_files = RUN_DIR.glob("*.jsonnet")
for x in jsonnet_files:
    jsonnet_cmd = f"jsonnet --ext-str VERSION_NAME={VERSION_NAME} --ext-str VERSION_NAMESPACE={VERSION_NAMESPACE} --ext-str VERSION_URL={VERSION_URL} --ext-str VERSION_STORE_BACKEND_SHA=4d2e34d0d86f29c6d3e425ddd73626dad0b35fd9 --ext-str VERSION_STORE_FRONTEND_SHA=7107430265a701529877b5bffd0d855989dfc127 {x} > {OUT_DIR}/{(x.with_suffix('.json')).name}"
    print(jsonnet_cmd)
    p = subprocess.run(jsonnet_cmd, shell=True, check=True)
print("Jsonnet -> JSON files ✅")

manifests = [
    x
    for x in list(RUN_DIR.glob("*.yaml")) + list(RUN_DIR.glob("*.json"))
    if not x.name in EXCLUDE_MANIFESTS
]
for x in manifests:
    ln_cmd = f"ln -s {x} {OUT_DIR}/{x.name}"
    print(ln_cmd)
    p = subprocess.run(ln_cmd, shell=True, check=True)
print("Symlinked other manifests ✅")
