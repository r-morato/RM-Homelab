# Cluster QDevice

Not a separate box - the QDevice role runs on the [NAS](nas.md). This page is about the
role.

## What it does

A 2-node Proxmox cluster has 2 quorum votes. Lose a node and the survivor has 1 of 2,
which is not a majority: `/etc/pve` goes read-only and the HA manager won't start
anything. A **QDevice** adds a third vote from a machine that isn't a cluster node, so
losing one node still leaves 2 of 3 - a majority - and everything keeps working.

The NAS runs `corosync-qnetd`. Each node runs `corosync-qdevice`, which connects to it
and casts the extra vote on the node's behalf.

## Where it lives

* On the **storage / cluster segment** (`10.0.1.x`), the same network corosync uses.
* `corosync.conf` points at it via `quorum.device.net.host`. If that address changes,
  update the file and bump `config_version` - pmxcfs then syncs it to both nodes, and
  each node's `corosync-qdevice` service is restarted.

## Verifying

```bash
pvecm status
# Expect:  Quorate: Yes
#          Total votes: 3
#          Qdevice line showing 1 vote with flags "A,V" (Alive, Voting)
```

On the NAS: `corosync-qnetd-tool -l` shows both nodes connected and on the same
`config_version`.

## Failure behaviour

| Down | Votes | Quorate? |
|---|---|---|
| nothing | 3 / 3 | yes |
| one node | 2 / 3 | yes - HA acts |
| the QDevice (NAS) | 2 / 3 | yes - but now a single-node loss would freeze the cluster, so fix it before touching a node |
| a node **and** the QDevice | 1 / 3 | no - cluster frozen |

The historical failure here was subtler than an outage: the config pointed at an
**old address** of the NAS that no longer existed, so `corosync-qdevice` looped on a
failed connection and the device contributed **zero votes** while still showing as
"present". A one-line address fix restored the third vote.
