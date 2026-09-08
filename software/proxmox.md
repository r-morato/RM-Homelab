# Proxmox VE

The hypervisor. A **2-node cluster** ([`pve-node-1`](../hardware/thinkcentre_m720q.md) +
[`pve-node-2`](../hardware/pve-node-2.md)) running Proxmox VE 9.2 on Debian 13, with an
external [QDevice](../hardware/qdevice-host.md) on the NAS for quorum.

## What it runs

* **10 unprivileged LXC containers** for the services (dashboard, media, Docker host,
  remote-access gateway, download + indexer stack, the automation container, a small
  app) — full list in [architecture](../docs/architecture.md).
* One small utility VM.

Containers are preferred over VMs: lighter, second-long boots, and they share the host's
patched kernel.

## The cluster features in use

| Feature | How it's used | Deep dive |
|---|---|---|
| **Clustering** | 2 nodes + a QDevice third vote so a single-node loss stays quorate | [high availability](../docs/high-availability.md) |
| **HA manager** | all 9 running guests managed, node-affinity rule prefers node 1, auto fail-back on | [high availability](../docs/high-availability.md) |
| **Shared storage** | guest root disks as raw images on NFS from the NAS → either node can run any guest | [storage](../docs/storage.md) |
| **`vzdump`** | nightly backup job + a daily host-config archive + a pre-backup DB hook | [backups](../docs/backups.md) |
| **Notifications** | results pushed to a phone webhook (email path removed) | [backups](../docs/backups.md) |
| **Firewall** | designed, not yet enabled | [security](../docs/security.md) |

## Repos & updates

The paid enterprise repos are disabled; the free `pve-no-subscription` repo and the
Debian security repo are enabled. Patching is handled by the
[Ansible + Semaphore automation](../docs/patching.md): containers weekly, hypervisors
monthly (in place, no reboot), rolling reboots by hand.

## Standalone tooling around it

* **Semaphore** — [Ansible web UI](semaphore.md), runs in `ct-ansible`.
* **ESP32 e-ink display** — read-only consumer of the PVE API, shows cluster stats on
  the rack ([`hardware/esp32_eink_dashboard.md`](../hardware/esp32_eink_dashboard.md)).
