# High availability & replication

The goal: **if `pve-node-1` dies at 3am, everything is running again on `pve-node-2`
within a few minutes, with nobody touching a keyboard** - and when `pve-node-1` comes
back, the guests move home on their own.

This page covers how that works, why the pieces are arranged the way they are, and the
manual procedures for planned maintenance.

## The quorum problem on a 2-node cluster

Proxmox HA will only act while the cluster is **quorate** - more than half of the votes
present. A plain 2-node cluster has 2 votes, so losing one node drops you to 1 of 2, the
survivor's `/etc/pve` goes read-only, and the HA manager refuses to start anything.
That is the opposite of what you want.

The fix is a third vote that lives somewhere else: a **QDevice**. This lab runs
`corosync-qnetd` on the **NAS** (an always-on, low-power box that is already central to
the setup). With it:

```
            votes   normal   pve-node-1 down   NAS/QDevice down
pve-node-1    1        ✓            -                 ✓
pve-node-2    1        ✓            ✓                 ✓
QDevice       1        ✓            ✓                 -             ─────    ─────       ─────             ─────
            total      3          2 of 3            2 of 3   → quorate either way
```

Losing any **one** of the three leaves 2 of 3 - still quorate, HA still works. Losing
two at once is game over, but that is true of any 3-vote cluster.

> The QDevice runs on the storage/cluster segment (`10.0.1.x`). If its address ever
> changes, `corosync.conf`'s `quorum.device.net.host` has to be updated and
> `config_version` bumped - pmxcfs then syncs it to both nodes. `pvecm status` should
> show `Qdevice` with `1` vote and an `A,V` (Alive, Voting) flag.

See [`hardware/qdevice-host.md`](../hardware/qdevice-host.md).

## Why the guest disks are on shared storage

HA failover means **either node must be able to start any guest**. On a cluster with no
shared block storage (no Ceph, no SAN), the only way to get there is to put the guest
disk images somewhere both nodes can read: the **NFS export from the NAS** (`PROX-NFS`).

Every guest's root disk is a raw image file on that export. When the HA manager restarts
a guest on `pve-node-2`, the disk is simply already there. There is no replication lag
and nothing to sync, because there is only ever one copy of the disk and both nodes
mount the same filesystem.

This is a deliberate trade: **shared storage buys transparent failover, at the cost of
making the NAS a single point of failure.** Mitigations and the local-storage
alternative are covered in [storage](storage.md).

## HA configuration

* **All 9 running guests are HA-managed** (`ha-manager add ct:<id> --state started`).
  The one container that is normally stopped is left out on purpose.
* A single **node-affinity rule** lists every managed guest and marks `pve-node-1` as
  preferred. Normal state: everything on `pve-node-1`, `pve-node-2` idle.
* **Automatic fail-back is on.** When `pve-node-1` returns from an outage, the HA
  manager migrates the guests back to it.

```
          ┌──────────── pve-node-1 (preferred) ────────────┐
   normal │  ct-dashboard ct-torrent ct-media-a ct-media-b  │   pve-node-2: idle
          │  ct-docker ct-gateway ct-indexer-a/b/c          │
          │  ct-ansible ct-app                              │
          └────────────────────────────────────────────────┘
                              │  pve-node-1 fails
                              ▼
          pve-node-2 fences pve-node-1 (watchdog, ~1 min),
          then starts all 9 guests from PROX-NFS (~2-5 min total)
                              │  pve-node-1 returns
                              ▼
          HA manager migrates the 9 guests back to pve-node-1
```

## What a node failure actually looks like

1. `pve-node-1` stops responding (power, kernel panic, yanked cable).
2. `pve-node-2` + the QDevice still have 2 of 3 votes → the survivor stays quorate.
3. After the fence timeout (~1 minute; the dead node self-fences via its hardware
   watchdog) the HA manager declares `pve-node-1`'s guests recoverable.
4. It starts all 9 on `pve-node-2`, reading their root disks straight from `PROX-NFS`.
   Total time to "everything back up" is roughly **2-5 minutes**.
5. When `pve-node-1` reboots and rejoins, fail-back migrates the guests home.

### Residual caveats (known, accepted)

* **Corosync runs a single ring** on the storage segment. Heavy NFS traffic shares that
  link and could in theory disturb the heartbeat. A second corosync link on the LAN is
  on the roadmap - see [networking](networking.md).
* **The media containers bind-mount the (currently offline) media NAS.** They will start
  on either node without it; the mount just has to exist on whichever node runs them.
* **`pve-node-2` has slightly less RAM.** Fine at real-world usage; there is less
  headroom if every guest spikes at once while running on the smaller node.
* **`pve-node-2`'s local root password is independent** of `pve-node-1`'s. Know it ahead
  of time - you may need that node's own web UI during an outage of the other.

## Planned maintenance - draining a node by hand

For anything that needs a node down (a reboot, hardware work), don't just pull it - use
**HA maintenance mode** so the guests migrate off cleanly first:

```bash
# evacuate pve-node-1 onto pve-node-2, live (no guest restarts)
ha-manager crm-command node-maintenance enable pve-node-1

# wait until nothing is left:
watch "ha-manager status | grep 'pve-node-1,'"

# ... do the work, reboot, etc. ...

# hand the guests back (they return because pve-node-1 is preferred)
ha-manager crm-command node-maintenance disable pve-node-1
```

The [patching automation](patching.md) wraps exactly this sequence in
`reboot-hosts.yml`, with a guard so it never evacuates the node that is currently
running the automation container.

## Verifying HA health

```bash
pvecm status                 # Quorate: Yes, total votes 3, Qdevice A,V
ha-manager status            # every ct:<id> "started" on its node
ha-manager status | grep -c started
cat /etc/pve/ha/rules.cfg    # the node-affinity rule lists every managed guest
```
