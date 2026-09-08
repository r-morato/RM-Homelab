#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Authorise the Ansible control node (CT 109) to log in as root on:
#   - every LXC guest  -> via `pct exec`, no SSH needed
#   - the peer PVE node -> appended to /etc/pve/priv/authorized_keys (cluster-synced)
#
# Run as root ON pve-node-1 AFTER 01-create-control-node.sh.
# Every entry is locked with from="<control-node IP>".
#
# The authorized_keys line is passed to each container base64-encoded to keep
# the shell quoting sane (the key contains + and /).
# ---------------------------------------------------------------------------
set -euo pipefail

CTID=109
CONTROL_IP="10.0.0.109"
GUEST_IDS=(100 101 102 103 104 105 106 107 108 112)
TAG="ansible@ct109"
BK_DIR="/root/homelab-backups-$(date +%Y%m%d)"

PUBKEY="$(pct exec "$CTID" -- cat /root/.ssh/id_ed25519_ansible.pub)"
LINE="from=\"${CONTROL_IP}\",no-agent-forwarding,no-port-forwarding,no-x11-forwarding ${PUBKEY}"
LINE_B64="$(printf '%s\n' "$LINE" | base64 -w0)"

echo "==> Key to install:"
echo "    ${LINE}"
echo

install -d -m 0700 "$BK_DIR" 2>/dev/null || true

append_via_pct() {
  local id="$1"
  pct exec "$id" -- /bin/sh -s <<EOF
set -eu
umask 077
mkdir -p /root/.ssh
touch /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
line="\$(printf '%s' '${LINE_B64}' | base64 -d)"
if ! grep -qF '${TAG}' /root/.ssh/authorized_keys; then
    printf '%s\n' "\$line" >> /root/.ssh/authorized_keys
    echo "  ct ${id}: added"
else
    echo "  ct ${id}: already present"
fi
EOF
}

for id in "${GUEST_IDS[@]}"; do
  if ! pct status "$id" >/dev/null 2>&1; then
    echo "  ct $id: does not exist, skipping"; continue
  fi
  append_via_pct "$id"
done

# --- peer node: cluster-synced authorized_keys ---------------------------
PVE_KEYS=/etc/pve/priv/authorized_keys
if grep -qF "$TAG" "$PVE_KEYS"; then
  echo "  ${PVE_KEYS}: already present"
else
  cp -a "$PVE_KEYS" "${BK_DIR}/authorized_keys.pve.bak-$(date +%Y%m%d-%H%M%S)"
  printf '%s\n' "$LINE" >> "$PVE_KEYS"
  echo "  ${PVE_KEYS}: added (syncs to all nodes)"
fi

echo
echo "==> Verify from inside CT $CTID:"
echo "    pct exec $CTID -- ansible -i /opt/ansible/inventory/hosts.yml all -m ping"
