# Storage

## The three tiers

| Storage | Backing | Mounted where | Holds |
|---|---|---|---|
| `local-lvm` | LVM-thin on each node's internal NVMe SSD | that node only | the control container; scratch guests; **the restore target** |
| `PROX-NFS` | NFS export from the **NAS** | both nodes, at `/mnt/pve/PROX-NFS` | **every guest root disk**, the nightly backup archives, host-config backups |
| media NAS | a second NAS (SMB/NFS) — currently offline | bind-mounted into the media containers | bulk media library |

There is **no ZFS and no Ceph.** Each node boots from a single consumer SSD carved into
an LVM root, swap, and a thin pool. The thin pool is mostly empty by design — it exists
as headroom and as the place restores land.

## Why the guest disks live on NFS

A 2-node cluster with no shared block storage can't do HA failover unless the guest disk
images are reachable from both nodes. NFS from the NAS is the simplest way to get there:
every container's root disk is a **raw image file** on `PROX-NFS`, so either node can
start any guest with nothing to copy or sync first. This is the foundation the
[high-availability](high-availability.md) design rests on.

## The trade-off, stated plainly

Shared-storage HA means **the NAS is a single point of failure for the whole fleet**:

* The NAS's disks are mirrored, so a single drive failure is survivable.
* Its OS is on a removable card; the data array can be re-assembled independently if the
  card dies.
* But if the *box* goes down, every guest's root disk disappears at once. The NFS mount
  is `hard`, so guests block rather than get I/O errors — they freeze until it's back.

This is accepted for a homelab where the NAS has been reliable and the recovery story
(restore from backup onto `local-lvm`) is tested. The mitigations:

1. **Backups go to the NAS too, but restores are proven to work onto `local-lvm`** — so
   a lost NAS is a rebuild, not a data-loss event, as long as an off-NAS copy of the
   archives exists (see below).
2. **The control container is on `local-lvm`, not NFS** — so the automation that can
   rebuild everything still runs during an NFS outage.
3. **Roadmap: move the small, stateful containers' root disks onto `local-lvm`** and
   keep only bulk data on NFS. Restore testing has confirmed this works; it also removes
   the nightly backup suspend pause (see [backups](backups.md)).

## The backup-copy gap

The nightly `vzdump` archives currently land on the **same NAS** that holds the live
disks. Disk redundancy on that box does not protect against the box itself failing, a
filesystem bug, or a bad delete. Closing this needs a second copy that does not live on
that NAS — a periodic pull to another machine, or Proxmox Backup Server on separate
hardware. This is **parked** until the second (media) NAS is back in service, which is
the intended target. Until then it is the biggest known weakness in the storage design.

## Snapshot capability

Raw images on NFS have **no snapshot support**, which has two consequences:

* `vzdump` falls back to **suspend mode** for running containers whose root disk is on
  NFS — a few seconds of guest pause per nightly backup. Containers that are stopped, or
  whose disk is on `local-lvm`, back up in **snapshot mode** with no pause.
* You can't take an ad-hoc "before I change this" snapshot of an NFS-backed guest. The
  pre-patch `vzdump` in the [automation](automation.md) exists partly to fill that gap.

Moving a guest's disk to `local-lvm` (`pct move-volume <id> rootfs local-lvm`) gives it
real snapshots back, at the cost of pinning it to one node's local disk.

## vzdump temp staging

One non-obvious detail, learned the hard way: `vzdump`'s temp staging directory must be
**local and mode `0711`** (not the default-on-NFS, and never `0700`).

* Staging on the NFS share itself is slow and trips a warning; a local
  `tmpdir` in `/etc/vzdump.conf` is ~40× faster.
* The archiver `tar` runs under the unprivileged-container UID remap and **cannot
  traverse a `0700` root-owned directory** — the backup fails with
  `Cannot open: Permission denied`. `0711` lets it through while keeping the directory
  unlistable.

## Health checks

```bash
pvesm status                       # all storages "active", free space
df -h /mnt/pve/PROX-NFS            # NFS export headroom
lvs                                # local-lvm thin-pool usage per node
smartctl -a /dev/nvme0            # per-node SSD wear + error counters
```

The SSDs report low wear but a high count of **unsafe shutdowns / power cycles** —
consistent with unclean power loss. A UPS with automatic graceful shutdown is on the
roadmap; see [`hardware/apc_ups.md`](../hardware/apc_ups.md).
