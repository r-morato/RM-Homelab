# Cluster, quorum & HA diagram

How the 2-node cluster stays quorate and how guests fail over. See
[`docs/high-availability.md`](../docs/high-availability.md).

## Quorum — 3 votes across 3 boxes

```mermaid
flowchart LR
    subgraph Cluster
        N1["pve-node-1<br>1 vote · HA-preferred"]
        N2["pve-node-2<br>1 vote"]
        N1 === N2
    end
    QD["NAS<br>corosync-qnetd<br>1 vote"]
    N1 -. QDevice .- QD
    N2 -. QDevice .- QD

    R["Lose any one box → 2 of 3 votes → still quorate → HA still acts"]
```

## Normal state vs. node failure

```mermaid
flowchart TB
    subgraph Normal
        A1["pve-node-1<br>runs all 9 HA guests"]
        A2["pve-node-2<br>idle"]
        NFS1[("PROX-NFS<br>guest root disks")]
        A1 --- NFS1
        A2 --- NFS1
    end

    subgraph "pve-node-1 fails"
        B1["pve-node-1<br>DOWN (self-fenced via watchdog, ~1 min)"]
        B2["pve-node-2<br>quorate with QDevice → starts all 9<br>from PROX-NFS (~2–5 min)"]
        NFS2[("PROX-NFS")]
        B2 --- NFS2
    end

    subgraph "pve-node-1 returns"
        C1["pve-node-1<br>rejoins → HA fails guests back (preferred)"]
        C2["pve-node-2<br>idle again"]
    end

    Normal --> B1
    B1 --> C1
```

Failover works because there is only ever **one copy** of each guest disk, on NFS, and
both nodes mount it — no replication, no sync lag. The cost is that the NAS is a shared
single point of failure; see [`docs/storage.md`](../docs/storage.md).
