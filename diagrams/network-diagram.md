# Network diagram

Logical topology. Addresses are sanitised: `10.0.0.x` = LAN / management,
`10.0.1.x` = storage + cluster. See [`docs/networking.md`](../docs/networking.md).

```mermaid
flowchart TB
    ISP([Internet]) --- Router["Eero Mesh 6<br>router / gateway · 10.0.0.1"]
    Router --- SW["TP-Link SG108S<br>8-port unmanaged switch"]

    subgraph LAN["LAN / management - 10.0.0.0/24 (vmbr0)"]
        N1LAN["pve-node-1 · 10.0.0.11"]
        N2LAN["pve-node-2 · 10.0.0.12"]
        Guests["LXC guests<br>10.0.0.100-112"]
        Pi["Raspberry Pi 4<br>Home Assistant OS"]
        ESP["ESP32 e-ink<br>Proxmox stats (Wi-Fi)"]
    end

    subgraph STOR["storage + cluster - 10.0.1.0/24 (vmbr1)"]
        N1S["pve-node-1 · 10.0.1.11"]
        N2S["pve-node-2 · 10.0.1.12"]
        NAS["NAS · 10.0.1.40<br>NFS export + corosync-qnetd (QDevice)"]
    end

    SW --- N1LAN
    SW --- N2LAN
    SW --- Guests
    SW --- Pi
    Router -. Wi-Fi .- ESP
    SW --- N1S
    SW --- N2S
    SW --- NAS

    N1S -- "NFS: guest root disks + backups" --- NAS
    N2S -- NFS --- NAS
    N1S -. "corosync ring + QDevice vote" .- NAS
    N2S -. corosync .- NAS
    N1S === N2S

    ESP -. "PVE API (read-only)" .-> N1LAN
```

Legend: solid = data path, dotted = cluster / control traffic, `===` = corosync between
the two nodes.
