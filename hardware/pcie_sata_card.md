# PCIe → 4-port SATA card

A PCIe x1 expansion card adding four SATA 3.0 ports to
[`pve-node-1`](thinkcentre_m720q.md), which has next to no native SATA.

## Role

Connects the [Oimaster HE-2006](oimaster_he2006.md) hot-swap cage to the node so its
2.5" SSD bays are usable.

## Notes

Cards like this are usually a JMicron/ASMedia HBA — fine for SSDs in AHCI mode. It is
not used for the cluster's primary storage (that's NVMe boot + NFS guest disks); it's
there for expansion headroom.
