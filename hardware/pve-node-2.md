# HP EliteDesk 800 (Mini) — `pve-node-2`

The second node of the [Proxmox VE cluster](../software/proxmox.md) — another small
form-factor business desktop, added to make the cluster survive a single-node failure.

## Role

* **Failover node.** The HA node-affinity rule does *not* prefer it, so it normally runs
  nothing and waits. If [`pve-node-1`](thinkcentre_m720q.md) goes down, every HA guest
  restarts here within a few minutes from the shared NFS disks. When `pve-node-1`
  returns, the guests migrate back. See [high availability](../docs/high-availability.md).
* Equal cluster member otherwise — `/etc/pve` is replicated live by pmxcfs, so it can
  administer the cluster on its own during an outage of the other node.

## Configuration

| | |
|---|---|
| RAM | slightly less than `pve-node-1` — fine at real usage, less headroom if everything spikes at once while running here |
| Boot / local storage | single NVMe SSD — LVM root + `local-lvm` thin pool (unused in normal operation) |
| Network | NIC on the LAN (`vmbr0`) + NIC on the storage/cluster segment (`vmbr1`) |
| OS | Proxmox VE 9.2 on Debian 13, kept in lockstep with node 1 by the monthly patch job |

## Notes

* Its **local root password is independent** of `pve-node-1`'s — know it ahead of time,
  because you may need this node's own web UI while the other node is down.
* A twin of the daily host-config backup timer belongs here too (roadmap) — it would
  capture this node's own networking and SSH host keys, which the node-1 archive
  doesn't.
