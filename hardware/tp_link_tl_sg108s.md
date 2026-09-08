# TP-Link TL-SG108S - 8-port gigabit switch

The wired core of the rack. Unmanaged, plug-and-play, gigabit on all 8 ports.

## Role

Connects everything wired: both cluster nodes (two cables each - one per segment), the
NAS (two cables), the Raspberry Pi, the Mac Mini, and the uplink to the
[Eero](eero_mesh_6.md).

## Consequence of it being unmanaged

No VLANs. The "LAN" and "storage/cluster" segments
([`docs/networking.md`](../docs/networking.md)) therefore share **one L2 broadcast
domain** - separation is logical (different subnets, and each node uses a specific NIC
for storage/corosync traffic), not true isolation. A managed switch with VLANs, or a
direct node-to-node link for corosync, is on the roadmap.

At 8 ports it is also nearly full - the next expansion needs a bigger switch anyway.

## Mounting

Custom 3D-printed 10-inch bracket - see [`3d_prints/`](../3d_prints/).
