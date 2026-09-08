# NAS - shared storage, backup target & QDevice

A low-power, always-on network-attached storage box that does three jobs for the
cluster. It is the most load-bearing single device in the lab.

## The three roles

1. **Shared storage over NFS.** It exports a filesystem that both cluster nodes mount as
   `PROX-NFS`. Every guest's root disk is a raw image on that export - which is what lets
   either node start any guest, and therefore what makes HA failover possible on a
   cluster with no shared block storage. See [storage](../docs/storage.md).
2. **Backup target.** The nightly `vzdump` archives and the daily host-config archives
   land on the same export. See [backups](../docs/backups.md).
3. **Cluster QDevice.** It runs `corosync-qnetd`, providing the third quorum vote so the
   2-node cluster stays quorate when a node is down. See
   [high availability](../docs/high-availability.md) and [`qdevice-host.md`](qdevice-host.md).

## Configuration

| | |
|---|---|
| Disks | 2 × HDD, **mirrored** (RAID-1) |
| OS media | separate from the data array - a card / small device, so the data survives an OS-media failure and can be re-assembled independently |
| Filesystem | EXT4 on the mirror |
| Network | on the storage/cluster segment (`10.0.1.x`); NFS export is restricted to that subnet |
| Free space | ~800 GB headroom for backups |

## Why this is a deliberate risk

Mirrored disks protect against a **drive** failure. They do not protect against the
**box** failing, a filesystem bug, or an accidental delete - and if this box goes down,
every guest's root disk vanishes at once and the NFS mount blocks (`hard` mount) until
it's back.

This is accepted because the box has been reliable, restores onto local storage are
tested, and the control container that can rebuild everything is deliberately **not** on
NFS. The open mitigation is a copy of the backup archives that doesn't live on this box - see the gap noted in [storage](../docs/storage.md) and [backups](../docs/backups.md).

## A second NAS

There is a second, larger NAS for the bulk media library, bind-mounted into the media
containers. It is currently **offline**; it is also the intended destination for the
off-box backup copy once it's back in service.
