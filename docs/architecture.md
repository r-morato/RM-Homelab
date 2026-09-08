# Architecture

This is the "how it all fits together" page. Individual subsystems get their own deep
dives — [high availability](high-availability.md), [storage](storage.md),
[networking](networking.md), [backups](backups.md), [automation](automation.md),
[patching](patching.md), [provisioning](provisioning.md), [security](security.md).

> **Addressing in this repo is sanitised.** `10.0.0.x` = the LAN / management segment,
> `10.0.1.x` = the storage + cluster segment, hostnames are generic labels
> (`pve-node-1`, `ct-dashboard`, …). The real values live only in a gitignored inventory
> on the host.

## The shape of it

```
                          ┌───────────────────────────── LAN / mgmt  10.0.0.0/24 ──┐
                          │                                                        │
   Internet ── Router ── Switch ──┬── pve-node-1 (Proxmox VE)  ── vmbr0            │
                                  │        │                                       │
                                  │        └── vmbr1 ──┐                           │
                                  │                     │  storage + cluster       │
                                  ├── pve-node-2 ───────┤  10.0.1.0/24             │
                                  │                     │                          │
                                  ├── NAS ──────────────┘  NFS export + corosync   │
                                  │        (guest root disks, backups, QDevice)    │
                                  │                                                │
                                  ├── Raspberry Pi 4  ── Home Assistant OS (bare)  │
                                  └── ESP32 e-ink  ── Proxmox stats display  ──────┘
```

Two mini-PCs run a **2-node Proxmox VE cluster**. A low-power **NAS** provides shared
storage over NFS *and* acts as the cluster's quorum tie-breaker. Everything else in the
rack is either a cluster guest or a standalone appliance (the Pi running Home Assistant,
the ESP32 display).

Design priorities, in order: **survive a single node failure without hands on
keyboard**, **never lose a guest to a bad disk or a bad upgrade**, and **keep routine
maintenance boring** (scheduled, reversible, self-announcing).

## The cluster nodes

| | `pve-node-1` | `pve-node-2` |
|---|---|---|
| Hardware | Lenovo ThinkCentre M720q Tiny | HP EliteDesk 800 (Mini), slightly less RAM |
| Role | primary — HA node-affinity prefers it | failover target |
| OS | Proxmox VE 9.2 on Debian 13 | same |
| Local disk | single NVMe SSD, LVM-thin pool (`local-lvm`) | same |

Both nodes are equal members of the cluster (`/etc/pve` is replicated live by pmxcfs).
`pve-node-1` is "primary" only in the sense that the HA placement rule prefers it, so
guests normally run there and `pve-node-2` sits mostly idle until it's needed.

See [`hardware/thinkcentre_m720q.md`](../hardware/thinkcentre_m720q.md) and
[`hardware/pve-node-2.md`](../hardware/pve-node-2.md).

## The guests

All guests are **unprivileged LXC containers**. There is one small utility VM; it is not
covered here.

| ID | Label | What it is | HA | Backed up |
|---|---|---|---|---|
| 100 | `ct-dashboard` | [Homepage](../software/homepage.md) start-page / dashboard | yes | yes |
| 101 | `ct-torrent` | download client ([media stack](../software/media-stack.md)) | yes | no |
| 102 | `ct-media-a` | [Jellyfin](../software/jellyfin.md) (iGPU transcode) | yes | no |
| 103 | `ct-media-b` | [Plex](../software/plex.md) (iGPU transcode) | yes | no |
| 104 | `ct-docker` | [Docker host](../software/docker-host.md) — Portainer, Uptime-Kuma | yes | yes |
| 105 | `ct-gateway` | [Apache Guacamole](../software/guacamole.md) remote-access gateway | yes | yes |
| 106–108 | `ct-indexer-a/b/c` | media indexer / automation ([media stack](../software/media-stack.md)) | yes | no |
| 109 | `ct-ansible` | [Ansible + Semaphore](../software/ansible.md) control container | yes | yes |
| 112 | `ct-app` | [small Laravel app](../software/app-container.md) | yes | yes |

"Backed up" = on the nightly `vzdump` job. The media-acquisition and streaming
containers are deliberately excluded — they hold no unique state worth an archive
(everything is re-downloadable or lives on the media NAS), and they are the largest and
noisiest to back up. See [backups](backups.md) for the reasoning.

Two containers — `ct-media-a` and `ct-media-b` — share the host's integrated GPU for
hardware transcoding.

## Storage layout

| Storage | Type | Holds |
|---|---|---|
| `local-lvm` (per node) | LVM-thin on the internal SSD | the control container; scratch; **restore target** |
| `PROX-NFS` | NFS export from the NAS | **every guest's root disk**, the backup archives, host-config backups |
| media NAS | second NAS (SMB/NFS), currently offline | bulk media, bind-mounted into the media containers |

Putting the guest root disks on NFS is what makes HA failover possible on a 2-node
cluster with no shared block storage — either node can start any guest because the disk
image is reachable from both. The cost is that the NAS is a broad single point of
failure. Both sides of that trade-off are discussed in [storage](storage.md).

## What happens on power-on

1. Both nodes boot Proxmox VE and form the cluster; the NAS's `corosync-qnetd` provides
   the third quorum vote.
2. The NFS export from the NAS is mounted on both nodes as `PROX-NFS`.
3. The HA manager starts every managed guest on its preferred node (`pve-node-1`).
4. `unattended-upgrades` and the Semaphore schedules take over routine patching from
   there; the `vzdump` timer fires nightly at 02:30.

If `pve-node-1` never comes back, step 3 happens on `pve-node-2` instead — see
[high availability](high-availability.md).

## Standalone appliances (not in the cluster)

* **Raspberry Pi 4** — runs Home Assistant OS on bare metal. Deliberately independent of
  the cluster so home automation keeps working during cluster maintenance. See
  [`software/homeassistant.md`](../software/homeassistant.md).
* **ESP32 + e-ink display** — pulls Proxmox stats over the API and shows them on a
  low-power screen on the rack. See
  [`hardware/esp32_eink_dashboard.md`](../hardware/esp32_eink_dashboard.md).
