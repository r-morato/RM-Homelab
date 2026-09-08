# Security posture

This is a homelab on a home LAN, not an internet-exposed service. Nothing is
port-forwarded; remote access is via [Guacamole](../software/guacamole.md) or a VPN back
home. Within that context, the design choices below. Hardening is an ongoing effort — the
roadmap at the end lists what's still in progress.

## SSH

* **Key-only root, everywhere.** Hosts and the control container run a drop-in
  (`/etc/ssh/sshd_config.d/10-hardening.conf`): `PermitRootLogin prohibit-password`,
  `PasswordAuthentication no`, `KbdInteractiveAuthentication no`. Applied with
  `sshd -t && systemctl reload ssh` so live sessions aren't dropped.
* **`fail2ban`** on the hosts and in the guests — sshd jail, 5 failures in 10 min → 1 h
  ban via the native packet filter, with the trusted subnets on the ignore list.
* **The automation key is scoped.** The control container's key is authorised as root on
  every target, but each entry is locked:
  `from="<control IP>",no-agent-forwarding,no-port-forwarding,no-x11-forwarding`.
* **Node ↔ node** SSH is the cluster's own key-based trust.

## The control container is the crown jewel

`ct-ansible` holds a key that is root on the entire fleet, so it gets the most
attention: unprivileged, `nesting=0,keyctl=0`, per-guest firewall on, reachable only on
the LAN segment, its own hardened sshd + `fail2ban`, and on the backup job + HA with its
Semaphore DB and SSH key treated as secrets. [Guacamole](../software/guacamole.md)
(`ct-gateway`) is treated as the next most sensitive guest because it holds remote-access
credentials — it's on the backup job, patched promptly, and near the front of the
firewall rollout.

## Container isolation

All guests are **unprivileged** — container root maps to a high, unprivileged UID on the
host, so a break-out doesn't land as host root. `nesting`/`keyctl` are off except on the
Docker host, which needs `nesting=1`.

## Service exposure

* The **Docker Engine API** is on the **local socket only** (no network listener), with
  `live-restore` on so containers survive a daemon restart.
* Internal web UIs are reachable on the LAN; scoping each one to where it's actually
  used is part of the firewall rollout below.

## Firewall

The Proxmox firewall is being rolled out in stages (perimeter filtering is handled by
the Eero in the meantime). The intended shape:

1. **Datacenter level:** default-deny inbound; allow cluster/corosync between the nodes
   and established/related.
2. **Management:** SSH (22), the web UI (8006), and Semaphore (`:3000`) restricted to a
   management address / subnet.
3. **Per-guest:** each guest's app port(s) opened only from where they're used.
4. **Block `rpcbind`/111** except on the storage path.

A log-only pass first, then enforce.

## Secrets handling

* The real Ansible inventory (`inventory/hosts.yml`, with addresses and the webhook
  URL), any `vault.yml`, and the `*.local.md` working docs are **gitignored** — only
  placeholder files are committed.
* Proxmox **Notes** fields carry a pointer to a password manager, never a credential
  (see [provisioning](provisioning.md)).
* The host-config backup archive contains cluster and host keys by necessity — it's
  written mode `0600` to a share restricted to the cluster segment.

## Accounts

Proxmox has one human admin (`root@pam`), one API-token user (read-only, for the stats
display), and a service account. Rationalising the service account to per-host
credentials or key-only is part of the container-hardening work.

## Roadmap

* Complete the firewall rollout (the four stages above).
* 2FA on the Proxmox admin account and Semaphore.
* Second corosync link (resilience, and fewer spurious fencing events).
* Per-host service-account credentials.
