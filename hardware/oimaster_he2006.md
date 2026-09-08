# Oimaster HE-2006 - 4-slot hot-swap SATA cage

A 4-bay internal hot-swap drive cage (3.5" slots, 2.5" SSDs via adapters, individual
power indicators) fitted to [`pve-node-1`](thinkcentre_m720q.md).

## Role

Gives the ThinkCentre - which has almost no internal drive room - accessible,
tool-less SATA bays for 2.5" SSDs, connected through the
[PCIe SATA card](pcie_sata_card.md).

## Notes

The cluster's live guest disks are on **NFS from the [NAS](nas.md)**, and each node
boots from its internal NVMe, so these bays are spare capacity / local scratch rather
than primary storage. They're the obvious place to land guest disks if the design moves
stateful containers onto local storage (see [`docs/storage.md`](../docs/storage.md)).
