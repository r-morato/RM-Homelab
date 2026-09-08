#!/usr/bin/env bash
# Configure the Semaphore "Homelab" project via the API. Idempotent-ish:
# it errors if objects already exist - safe to read the errors and move on.
set -euo pipefail
BASE="http://127.0.0.1:3000/api"
CJ=/tmp/sem.cookies
ADMIN_PW="${1:?usage: semaphore-configure.sh <admin-password>}"

api() { curl -fsS -b "$CJ" -c "$CJ" -H 'Content-Type: application/json' "$@"; }

echo "== login =="
curl -fsS -c "$CJ" -H 'Content-Type: application/json' \
  -d "{\"auth\":\"admin\",\"password\":\"${ADMIN_PW}\"}" "$BASE/auth/login" -o /dev/null -w 'login HTTP %{http_code}\n'

echo "== project =="
PID=$(api -d '{"name":"Homelab","alert":false}' "$BASE/projects" | tee /tmp/sem.proj | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])')
echo "project id=$PID"

echo "== keys =="
NONE_ID=$(api -d '{"name":"none","type":"none","project_id":'"$PID"'}' "$BASE/project/$PID/keys" | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])')
PRIV=$(python3 -c 'import json,sys;print(json.dumps(open("/root/.ssh/id_ed25519_ansible").read()))')
SSH_ID=$(api -d '{"name":"ansible-ssh","type":"ssh","project_id":'"$PID"',"ssh":{"login":"root","private_key":'"$PRIV"'}}' "$BASE/project/$PID/keys" | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])')
echo "none=$NONE_ID ssh=$SSH_ID"

echo "== repository (local git) =="
REPO_ID=$(api -d '{"name":"homelab-ansible","project_id":'"$PID"',"git_url":"file:///opt/ansible","git_branch":"main","ssh_key_id":'"$NONE_ID"'}' "$BASE/project/$PID/repositories" | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])')
echo "repo=$REPO_ID"

echo "== inventory (static, real values) =="
INV_CONTENT=$(python3 -c 'import json;print(json.dumps(open("/opt/ansible/inventory/hosts.yml").read()))')
INV_ID=$(api -d '{"name":"production","project_id":'"$PID"',"type":"static-yaml","inventory":'"$INV_CONTENT"',"ssh_key_id":'"$SSH_ID"',"become_key_id":'"$NONE_ID"'}' "$BASE/project/$PID/inventory" | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])')
echo "inventory=$INV_ID"

echo "== environment =="
ENV_ID=$(api -d '{"name":"default","project_id":'"$PID"',"json":"{}","env":"{}"}' "$BASE/project/$PID/environment" | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])')
echo "env=$ENV_ID"

mktpl() {
  local name="$1" pb="$2" args="$3" desc="$4"
  api -d '{
    "project_id":'"$PID"',"name":"'"$name"'","playbook":"'"$pb"'",
    "inventory_id":'"$INV_ID"',"repository_id":'"$REPO_ID"',"environment_id":'"$ENV_ID"',
    "arguments":"'"$args"'","description":"'"$desc"'","app":"ansible","allow_override_args_in_task":true
  }' "$BASE/project/$PID/templates" | python3 -c 'import sys,json;d=json.load(sys.stdin);print("  tpl",d["id"],d["name"])'
}
echo "== templates =="
mktpl "Ping fleet"                "playbooks/ping.yml"          "[]" "Connectivity + privilege check"
mktpl "Patch - containers (dry run)" "playbooks/patch-guests.yml" "[\"--check\"]" "Dry run of the container patch"
mktpl "Patch - containers"        "playbooks/patch-guests.yml"  "[]" "Pre-backup + dist-upgrade every LXC guest + notify"
mktpl "Patch - hypervisors"      "playbooks/patch-hosts.yml"   "[]" "Patch both PVE nodes, serial 1, NO reboot"
mktpl "Reboot - hypervisors"    "playbooks/reboot-hosts.yml"  "[]" "DANGER: rolling reboot of the PVE nodes, run manually"

echo
echo "Done. Project id $PID."
