#!/usr/bin/env bash
set -euo pipefail

: "${GH_TOKEN:?Need GH_TOKEN (exported)}"
: "${OWNER:?Need OWNER (exported)}"
: "${REPO:?Need REPO (exported)}"

export API="https://api.github.com"
export AUTH_HEADER="Authorization: Bearer ${GH_TOKEN}"
export ACCEPT_HEADER="Accept: application/vnd.github+json"
BOOTSTRAP_ID="word-addin-tagging-v1"

gh_get () {
  local url="$1"
  curl -sS -H "${AUTH_HEADER}" -H "${ACCEPT_HEADER}" "${url}"
}

gh_post () {
  local url="$1"
  local json="$2"
  curl -sS -X POST -H "${AUTH_HEADER}" -H "${ACCEPT_HEADER}" "${url}" -d "${json}"
}

# --- Load issues.json ---
if [[ ! -f "issues.json" ]]; then
  echo "ERROR: issues.json not found in repo root."
  exit 1
fi

echo "==> Reading issues.json..."
export JSON="$(cat issues.json)"

# --- Create milestones (idempotent: checks by title) ---
echo "==> Creating milestones (skip if exists)..."
export EXISTING_MILESTONES="$(gh_get "${API}/repos/${OWNER}/${REPO}/milestones?state=all&per_page=100")"

python3 - <<'PY'
import json, os, sys, subprocess

API=os.environ["API"]
OWNER=os.environ["OWNER"]
REPO=os.environ["REPO"]
AUTH=os.environ["AUTH_HEADER"]
ACCEPT=os.environ["ACCEPT_HEADER"]

cfg=json.loads(os.environ["JSON"])
existing=json.loads(os.environ["EXISTING_MILESTONES"])

existing_titles={m["title"] for m in existing}
for m in cfg["milestones"]:
    if m["title"] in existing_titles:
        print(f"  - Milestone exists: {m['title']}")
        continue
    payload=json.dumps({"title": m["title"], "description": m.get("description",""), "state":"open"})
    cmd=["curl","-sS","-X","POST","-H",AUTH,"-H",ACCEPT,f"{API}/repos/{OWNER}/{REPO}/milestones","-d",payload]
    subprocess.check_call(cmd)
    print(f"  + Created milestone: {m['title']}")
PY

# Refresh milestones and build key->number map
EXISTING_MILESTONES="$(gh_get "${API}/repos/${OWNER}/${REPO}/milestones?state=all&per_page=100")"
export EXISTING_MILESTONES

MILESTONE_MAP_JSON="$(python3 - <<'PY'
import json, os
cfg=json.loads(os.environ["JSON"])
existing=json.loads(os.environ["EXISTING_MILESTONES"])
title_to_num={m["title"]: m["number"] for m in existing}
mp={}
for m in cfg["milestones"]:
    mp[m["key"]]=title_to_num[m["title"]]
print(json.dumps(mp))
PY
)"
export MILESTONE_MAP_JSON
echo "==> Milestone map: ${MILESTONE_MAP_JSON}"

# --- Create labels (idempotent: ignore if exists) ---
echo "==> Creating labels (skip if exists)..."
python3 - <<'PY'
import json, os, subprocess

API=os.environ["API"]
OWNER=os.environ["OWNER"]
REPO=os.environ["REPO"]
AUTH=os.environ["AUTH_HEADER"]
ACCEPT=os.environ["ACCEPT_HEADER"]

cfg=json.loads(os.environ["JSON"])
for lab in cfg["labels"]:
    payload=json.dumps({"name": lab["name"], "color": lab["color"]})
    cmd=["curl","-sS","-X","POST","-H",AUTH,"-H",ACCEPT,f"{API}/repos/{OWNER}/{REPO}/labels","-d",payload]
    # If label exists, GitHub returns 422. We'll ignore.
    try:
        subprocess.check_call(cmd)
        print(f"  + Created label: {lab['name']}")
    except subprocess.CalledProcessError:
        print(f"  - Label exists: {lab['name']}")
PY

# --- Avoid duplicate issue creation (search for Bootstrap-ID marker) ---
echo "==> Checking for existing bootstrap issues..."
export SEARCH="$(gh_get "${API}/search/issues?q=repo:${OWNER}/${REPO}+in:body+\"Bootstrap-ID:+${BOOTSTRAP_ID}\"&per_page=1")"

EXISTS="$(python3 - <<'PY'
import json, os
res=json.loads(os.environ["SEARCH"])
print("yes" if res.get("total_count",0) > 0 else "no")
PY
)"
if [[ "${EXISTS}" == "yes" ]]; then
  echo "✅ Bootstrap issues already exist (found Bootstrap-ID: ${BOOTSTRAP_ID}). Skipping issue creation."
  exit 0
fi

# --- Create issues ---
echo "==> Creating issues..."
python3 - <<'PY'
import json, os, subprocess

API=os.environ["API"]
OWNER=os.environ["OWNER"]
REPO=os.environ["REPO"]
AUTH=os.environ["AUTH_HEADER"]
ACCEPT=os.environ["ACCEPT_HEADER"]

cfg=json.loads(os.environ["JSON"])
milestone_map=json.loads(os.environ["MILESTONE_MAP_JSON"])

for issue in cfg["issues"]:
    payload={
        "title": issue["title"],
        "body": issue["body"],
        "labels": issue.get("labels", [])
    }
    key=issue.get("milestone_key")
    if key:
        payload["milestone"]=int(milestone_map[key])

    cmd=["curl","-sS","-X","POST","-H",AUTH,"-H",ACCEPT,f"{API}/repos/{OWNER}/{REPO}/issues","-d",json.dumps(payload)]
    subprocess.check_call(cmd)
    print(f"  + Created issue: {issue['title']}")
PY

echo "✅ Done. Milestones, labels, and issues imported."
