#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Create the Ansible control node — CT 109 — on the Proxmox host.
# Run as root ON a cluster node (pve-node-1). Review every value first.
#
# Idempotent-ish: it refuses to run if CT 109 already exists.
# ---------------------------------------------------------------------------
set -euo pipefail

CTID=109
HOSTNAME="ansible"
LAN_IP="10.0.0.109/24"
LAN_GW="10.0.0.1"
BRIDGE="vmbr0"
STORAGE="local-lvm"
DISK_GB=4
CORES=1
MEMORY_MB=512
SWAP_MB=512
TEMPLATE_STORE="local"
TEMPLATE_NAME="debian-13-standard_13.6-1_amd64.tar.zst"   # from `pveam available --section system` on 2026-09-08
UNPRIVILEGED=1

if pct status "$CTID" &>/dev/null; then
  echo "CT $CTID already exists — aborting." >&2
  exit 1
fi

echo "==> Refreshing template catalogue"
pveam update

if ! pveam list "$TEMPLATE_STORE" | grep -q "$TEMPLATE_NAME"; then
  echo "==> Downloading $TEMPLATE_NAME"
  pveam download "$TEMPLATE_STORE" "$TEMPLATE_NAME"
fi

echo "==> Creating CT $CTID ($HOSTNAME)"
pct create "$CTID" "${TEMPLATE_STORE}:vztmpl/${TEMPLATE_NAME}" \
  --hostname "$HOSTNAME" \
  --cores "$CORES" \
  --memory "$MEMORY_MB" \
  --swap "$SWAP_MB" \
  --rootfs "${STORAGE}:${DISK_GB}" \
  --net0 "name=eth0,bridge=${BRIDGE},ip=${LAN_IP},gw=${LAN_GW},firewall=1" \
  --onboot 1 \
  --unprivileged "$UNPRIVILEGED" \
  --features nesting=0,keyctl=0 \
  --description "Ansible / Semaphore control node. Holds root SSH keys to the whole cluster — keep locked down. Managed: this repo (ansible/)."

echo "==> Starting CT $CTID"
pct start "$CTID"
sleep 5

echo "==> Base packages + Ansible + Semaphore prerequisites"
pct exec "$CTID" -- bash -eux -c '
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get -y dist-upgrade
  apt-get -y install --no-install-recommends \
      ansible python3-argcomplete openssh-client git curl ca-certificates \
      sshpass jq logrotate unattended-upgrades
  # unattended-upgrades on the control node itself (security pocket only)
  dpkg-reconfigure -f noninteractive unattended-upgrades
  install -d -m 0750 /var/log/ansible
  install -d -m 0700 /root/.ssh
'

echo "==> Generating the dedicated Ansible SSH key (ed25519, no passphrase)"
pct exec "$CTID" -- bash -eux -c '
  if [ ! -f /root/.ssh/id_ed25519_ansible ]; then
    ssh-keygen -t ed25519 -N "" -C "ansible@ct109" -f /root/.ssh/id_ed25519_ansible
  fi
  cat > /root/.ssh/config <<EOF
Host *
    IdentityFile ~/.ssh/id_ed25519_ansible
    IdentitiesOnly yes
    StrictHostKeyChecking accept-new
EOF
  chmod 600 /root/.ssh/config
'

echo
echo "==> Control node public key (feed this to 02-deploy-control-node-key.sh):"
pct exec "$CTID" -- cat /root/.ssh/id_ed25519_ansible.pub
echo
echo "Next:"
echo "  1. Add CT $CTID to HA and to the vzdump job (it is now important infra)."
echo "  2. Run bootstrap/02-deploy-control-node-key.sh on this node."
echo "  3. Clone/copy the this repo (ansible/) tree into CT $CTID (e.g. /opt/ansible)."
echo "  4. Follow docs/semaphore.md."
