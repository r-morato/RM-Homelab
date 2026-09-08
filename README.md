# RM-Homelab

<img width="583" alt="The rack" src="https://github.com/user-attachments/assets/839070fc-07c0-4ad8-93b7-052136dc8fb8" />

A compact, quiet, movable homelab in a custom 10-inch rack — two cables to run it
(power and Ethernet), enough capability to host the services I use every day, and
built so a single hardware failure or a bad upgrade doesn't take anything down for long.

This repo documents **how it works**: the cluster, the storage and replication model,
backups, the automation that patches everything, and the security choices. It is written
so I can rebuild from it.

> **Addresses and hostnames in this repo are sanitised.** `10.0.0.x` is the LAN /
> management segment, `10.0.1.x` the storage + cluster segment, and hostnames are
> generic labels (`pve-node-1`, `ct-dashboard`, …). Real values live only in a
> gitignored inventory on the host.

## Why build it

I wanted one place to learn, experiment, and self-host — with real control over my data
and no monthly bill for things I can run myself. The constraints that shaped every
decision: **low noise** (it lives near people), **low power**, **physically mobile**
(hence wheels), and **cheap** — no enterprise hardware. Not the most powerful lab; the
sweet spot between capability, cost, and cleanliness.

## What it is now

- **2-node Proxmox VE cluster** (a Lenovo ThinkCentre M720q and an HP EliteDesk 800
  mini-PC) with an external **QDevice** on the NAS for quorum.
- **High availability across every running guest** — lose a node and everything restarts
  on the other in a few minutes, then moves home when the node returns.
- **Shared storage over NFS from the NAS** — guest disks live there so either node can
  run any guest.
- **Nightly backups to the NAS** — `vzdump` for the stateful containers, a daily
  host-config archive, and a database-consistent dump for the one guest that needs it.
  Restores are tested.
- **Scheduled, hands-off patching** — a dedicated Ansible container with a
  [Semaphore](https://github.com/semaphoreui/semaphore) web UI patches the containers
  weekly and the hypervisors monthly, and pushes a summary to my phone. Reboots stay
  manual.
- **Hardened baseline** — key-only SSH with `fail2ban`, the Docker API on a local socket
  only, secrets kept out of git, and a staged firewall rollout.

## Documentation

| | |
|---|---|
| [Architecture](docs/architecture.md) | how it all fits together — nodes, guests, storage, boot order |
| [High availability & replication](docs/high-availability.md) | quorum on 2 nodes, HA failover, planned-maintenance drains |
| [Storage](docs/storage.md) | the NFS / local-lvm / media-NAS tiers and the trade-offs |
| [Networking](docs/networking.md) | the two segments, addressing, DNS, the corosync caveat |
| [Backups](docs/backups.md) | the `vzdump` job, host-config backup, the DB hook, restore test |
| [Automation](docs/automation.md) | the Ansible + Semaphore control container and repo |
| [Automated patching](docs/patching.md) | the "patch on schedule, notify-to-reboot" model |
| [Provisioning & configuration](docs/provisioning.md) | how a new guest is built and wired in |
| [Security](docs/security.md) | SSH, isolation, service exposure, the firewall plan |
| [Ansible playbooks](ansible/) | the actual automation code, with its own README |
| [Rack build](rack-build.md) | the custom 10-inch enclosure |
| [Hardware](hardware/) · [Software](software/) | per-component notes |
| [Diagrams](diagrams/) · [3D prints](3d_prints/) | network + cluster diagrams, printed mounts |

## Hardware at a glance

| Component | Role |
|---|---|
| Lenovo ThinkCentre M720q Tiny | Proxmox VE cluster node 1 (primary) |
| HP EliteDesk 800 (Mini) | Proxmox VE cluster node 2 (failover) |
| NAS (mirrored disks) | NFS shared storage, backup target, corosync QDevice |
| Raspberry Pi 4 | Home Assistant OS (bare metal, outside the cluster) |
| ESP32 + e-ink display | Proxmox stats display on the rack |
| Mac Mini | jump box / daily driver |
| TP-Link TL-SG108S | 8-port gigabit switch (unmanaged) |
| Eero Mesh 6 | router / gateway / Wi-Fi |
| APC Back-UPS 300W | battery backup |
| Oimaster HE-2006 + PCIe SATA card | hot-swap SSD bays |
| Hive Hub | heating control (Home Assistant integration) |

Full notes in [`hardware/`](hardware/) and [`rack-build.md`](rack-build.md).

## Lessons learned

- **Noise matters more than you think** when servers live near bedrooms.
- **Cheap gear goes surprisingly far** if you're willing to tinker.
- **Power and thermals aren't optional** — the SSDs show a high unclean-shutdown count,
  which is why a UPS with automatic graceful shutdown is near the top of the list.
- **A 2-node cluster needs a third vote.** Without the QDevice, losing either node
  freezes the survivor. With it, failover is a non-event.
- **`curl | bash` from someone else's `main` branch, as root, on a schedule** is a bad
  idea however convenient — replacing it with version-controlled Ansible was worth it.
- **Snapshots and tested restores turn mistakes into footnotes.**

## Roadmap

- Off-NAS / offsite copy of the backup archives (currently the biggest gap).
- Finish the staged Proxmox firewall rollout (see [security](docs/security.md)).
- Second corosync link so the heartbeat doesn't share one wire with NFS.
- Move small stateful containers onto local storage for snapshot-mode backups.
- 2FA on the Proxmox admin account and Semaphore.
- Dynamic Ansible inventory from the PVE API.
- More Home Assistant sensors and automations.

## License

[MIT](LICENSE) © Roger Morato
