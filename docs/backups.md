# Backups

**Backups go to the NAS.** A nightly `vzdump` job archives the containers that hold
unique state; a separate daily job archives the hypervisor's own configuration; and a
pre-backup hook takes a database-consistent dump of the one container that needs it.
Restores have been tested end to end.

## What is protected, and why not everything

| Container | On the job? | Why |
|---|---|---|
| `ct-dashboard` (Homepage) | ✅ | hand-built config, annoying to recreate |
| `ct-docker` (Docker host) | ✅ | Portainer stacks, Uptime-Kuma monitor definitions |
| `ct-gateway` (Guacamole) | ✅ | connection list + settings live in its database |
| `ct-app` (Laravel app) | ✅ | application data |
| `ct-ansible` (control container) | ✅ | Semaphore DB, the automation SSH key |
| `ct-torrent`, `ct-media-a/b`, `ct-indexer-a/b/c` | ❌ | no unique state — media lives on the media NAS, everything else is re-downloadable; also the largest and slowest to archive |

Backing up only what matters keeps the nightly run small and fast, and keeps the
archive store from filling with re-creatable data.

## The nightly job

| Setting | Value |
|---|---|
| Schedule | daily, **02:30** |
| Target | `PROX-NFS` (the NFS export on the NAS) |
| Mode | snapshot where possible, else suspend (see below) |
| Compression | zstd |
| Retention | **7 daily + 4 weekly** |
| Missed runs | repeated on next boot (`Persistent`) |
| Notification | pushed to the phone on failure (see below) |

### snapshot vs suspend

Containers whose root disk is on `local-lvm`, or that are stopped, back up in
**snapshot mode** — zero interruption. The running containers whose root disk is a raw
image on NFS have **no snapshot capability**, so `vzdump` falls back to **suspend mode**:
a few seconds of guest pause during the final sync, once a night. Removing that pause
means moving those root disks to `local-lvm` (see [storage](storage.md)) or deploying
Proxmox Backup Server.

### temp staging gotcha

`vzdump` stages the archive before writing it to the target. That staging directory is
set (in `/etc/vzdump.conf`) to a **local** path — staging on the NFS share is slow and
warns — and it must be mode **`0711`**, never `0700`: the archiver runs under the
unprivileged-container UID remap and can't traverse a `0700` root-owned directory
(`tar: Cannot open: Permission denied`, exit 2).

## Host / cluster configuration backup

`vzdump` only covers guests. A separate **daily systemd timer** (just before the guest
job) tars up the hypervisor's own configuration to the same NAS share:

* `/etc/pve` in full — every guest config, storage, firewall, HA, jobs, notification
  config, **and** the cluster CA key + pmxcfs auth key (exactly what a bare-metal
  rebuild needs);
* host networking, `/etc/ssh` (including host keys), `fail2ban`, mail, apt sources, LVM
  metadata, custom systemd units, cron, boot/kernel config, `/usr/local/{sbin,bin}`;
* a `state/` directory of command outputs — `pveversion`, `pvecm status`, `ha-manager
  status`, `pvesm status`, `lsblk` with serials, `lvs`, routes — so the archive also
  documents what the hardware looked like.

Output is a mode-`0600` `.tar.gz` + `.sha256`, newest **14** kept. It runs on
`pve-node-1` only; `pve-node-2`'s `/etc/pve` is identical via pmxcfs, so only that
node's own networking and host keys would be additionally useful (a twin timer there is
a roadmap item).

## Database-consistent dump for Guacamole

`ct-gateway` backs up in suspend mode with its database engine running, so the database
files in the archive are only crash-consistent. A **pre-backup hook**
(`script:` in `/etc/vzdump.conf`) fixes that: on the `backup-start` phase, for that one
VMID, it runs a transaction-consistent `mariadb-dump --single-transaction` **inside the
container**, gzipped, written atomically to a path in the container's own filesystem —
so it rides along in the same archive and also stays on the running guest as a ~0.5 MB
standby copy, refreshed each run.

The hook **always exits 0** — a dump failure is logged as a warning in the task log
(and shows in the notification), never aborts the backup.

## Restore test

One `ct-dashboard` archive was restored from the NAS onto `local-lvm` under a scratch
VMID, with its network link forced down, booted cleanly (service up, files intact), then
destroyed. This confirms two things: the archives on NFS are actually restorable, and
restoring onto local snapshot-capable storage works — which is both the disaster-recovery
path and the mechanism for moving guests off raw-on-NFS.

```bash
# the shape of a restore
pct restore 999 /mnt/pve/PROX-NFS/dump/vzdump-lxc-100-<date>.tar.zst \
  --storage local-lvm --hostname restore-test
pct set 999 --net0 name=eth0,bridge=vmbr0,link_down=1
pct start 999 && pct exec 999 -- systemctl is-system-running
pct destroy 999
```

## Notifications

Backup results are pushed to a **phone-push webhook** (the sole notification channel —
the email path was removed because it was undeliverable from a residential IP and caused
duplicate alerts). Two quirks shaped the setup:

* The push endpoint returns **HTTP 500 for bodies over ~5–7 KB**. Proxmox's stock
  backup notification embeds the entire task log, which blew that limit on multi-guest
  runs. Fix: a custom notification template (`vzdump-body.txt.hbs`) that keeps the
  per-guest result table and totals but drops the full-log section.
* Only the phone-push matcher → phone-push webhook route is active; the built-in email
  matcher is disabled and the root user's notify address is cleared, so local system
  mail just stays in `/var/mail/root`.

## The gap

The archives currently sit on the **same NAS as the live disks**. That box's disk
redundancy doesn't protect against the box failing, a filesystem bug, or a bad delete.
An off-NAS copy (a pull to another machine, or PBS on separate hardware) is **parked**
until the second NAS is back in service — it's the intended target. This is the one
open item in the backup design.

## Roadmap

* Off-NAS / offsite copy of the archives (the parked item above).
* Move the small stateful containers' root disks to `local-lvm` → snapshot-mode backups,
  no suspend pause.
* Twin host-config timer on `pve-node-2`.
* Disk-space pre-check in the pre-patch backup step (a container has run its 4 GB rootfs
  full mid-upgrade before).
