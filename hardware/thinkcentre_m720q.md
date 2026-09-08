# Lenovo ThinkCentre M720q Tiny - `pve-node-1`

The primary node of the [Proxmox VE cluster](../software/proxmox.md). An ultra-compact
1-litre business desktop - quiet, low-power, and cheap on the used market, which is the
whole point of this build.

## Role

* **Primary cluster node.** The HA node-affinity rule prefers it, so all guests normally
  run here and [`pve-node-2`](pve-node-2.md) sits idle as failover.
* Hosts the integrated GPU that [`ct-media-a`](../software/jellyfin.md) and
  [`ct-media-b`](../software/plex.md) share for hardware transcoding.
* Runs the daily host-config backup timer (see [backups](../docs/backups.md)).

## Configuration

| | |
|---|---|
| CPU | 6-core Intel (no hyper-threading) |
| RAM | 16 GiB DDR4 SODIMM |
| Boot / local storage | single consumer NVMe SSD - LVM root + swap + `local-lvm` thin pool |
| Extra SATA | PCIe → 4-port SATA card into the [Oimaster HE-2006](oimaster_he2006.md) bays |
| Network | onboard NIC (LAN, `vmbr0`) + a second NIC (storage/cluster, `vmbr1`) |
| OS | Proxmox VE 9.2 on Debian 13 |

## Notes

* **Single SSD = no local redundancy.** This is tolerated because the guests' disks live
  on the [NAS](nas.md) over NFS and are backed up; the node itself is reproducible from
  the host-config archive.
* The SSD's SMART data is healthy (low wear, zero media errors) but shows a **high
  unclean-shutdown / power-cycle count** - the reason a UPS with automatic graceful
  shutdown is on the roadmap. See [`apc_ups.md`](apc_ups.md).
* Mounted in the rack on a custom 3D-printed tray - see [`3d_prints/`](../3d_prints/).
