# Networking

## Two segments, on purpose

| Segment | Subnet (sanitised) | Bridge | Carries |
|---|---|---|---|
| LAN / management | `10.0.0.0/24` | `vmbr0` | guest traffic, the web UIs, SSH, the automation container → targets |
| Storage + cluster | `10.0.1.0/24` | `vmbr1` | NFS to the NAS, corosync, the QDevice vote |

Each node has a physical NIC on each segment. Keeping storage and cluster traffic off
the LAN means a busy download or a Plex transcode pulling from the NAS doesn't compete
with the corosync heartbeat for the same wire - mostly. See the known limitation below.

```
   Router ── Switch ─┬─ pve-node-1 vmbr0 (10.0.0.11)  ── guests, mgmt
                     │  pve-node-1 vmbr1 (10.0.1.11)  ── NFS + corosync
                     ├─ pve-node-2 vmbr0 (10.0.0.12)
                     │  pve-node-2 vmbr1 (10.0.1.12)
                     ├─ NAS         (10.0.1.40)        ── NFS export + corosync-qnetd
                     ├─ Raspberry Pi 4 (10.0.0.x)      ── Home Assistant
                     └─ ESP32 e-ink   (Wi-Fi)          ── Proxmox stats display
```

## Guest addressing

Guests are on `vmbr0` with static addresses in `10.0.0.100`-`10.0.0.112`, chosen to
match the Proxmox VMID (guest `104` is `10.0.0.104`). It makes the inventory readable
and means you can guess a guest's address from its ID. The automation container is
`10.0.0.109`.

## The router and DNS

* The perimeter router / gateway is an **Eero mesh** (`10.0.0.1`) doing DHCP for
  dynamic clients, NAT, and the basic firewall. Static infra addresses are outside the
  DHCP pool. See [`hardware/eero_mesh_6.md`](../hardware/eero_mesh_6.md).
* **Pi-hole** provides LAN DNS and ad/tracker filtering; clients are pointed at it
  either by DHCP option or per-device. See [`software/pihole.md`](../software/pihole.md).
* The 8-port unmanaged switch ([`hardware/tp_link_tl_sg108s.md`](../hardware/tp_link_tl_sg108s.md))
  is the wired core. Because it's unmanaged there are **no VLANs**: the two segments
  share one L2 broadcast domain, and the separation is only logical - different subnets,
  and each node using a specific NIC for storage/corosync. True isolation (a managed
  switch + VLANs, or a direct node-to-node corosync link) is a roadmap item.

## Corosync - the known weak spot

Corosync currently runs a **single ring** on the storage segment. That is a
simplification worth calling out:

* If that link flaps, or NFS saturates it badly enough to delay heartbeats, corosync
  sees a membership change even though both nodes are healthy.
* **Roadmap:** add a second `knet` link on the LAN segment so corosync has a fallback
  path, and ideally make a dedicated NIC the primary ring.

Until then the QDevice is what keeps a spurious membership blip from turning into a
loss of quorum - see [high availability](high-availability.md).

## Firewall posture

The Proxmox firewall is being rolled out in stages - datacenter default-deny inbound,
management ports restricted to one subnet, per-guest app-port rules - described in
[security](security.md). Perimeter filtering is handled by the Eero in the meantime.
