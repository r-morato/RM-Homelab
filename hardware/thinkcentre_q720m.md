# ThinkCentre M720q Tiny

## Overview

The Lenovo ThinkCentre M720q Tiny serves as the main host server in the homelab, running Proxmox Virtual Environment and supporting various virtual machines and containers.

## Specifications

* **Model:** ThinkCentre M720q Tiny (or Q720m as initially stated, though M720q is a more common designation for this series).
* **Form Factor:** Ultra-compact desktop PC (Tiny/Mini PC).
* **Processor:** Features modern Intel Core processors (e.g., 8th/9th Gen Intel Core, depending on configuration).
* **Memory:** Supports DDR4 SODIMM RAM, allowing for significant memory upgrades (e.g., up to 32GB or 64GB depending on the specific CPU and motherboard revision).

## Role in the Homelab

* **Primary Hypervisor:** Hosts Proxmox VE, which virtualizes the majority of homelab services.
* **Compute Core:** Provides the necessary processing power and memory for running multiple VMs and LXCs concurrently.

## Suitability for Homelab Use

* **Size:** Its compact "Tiny" form factor is advantageous for fitting into a space-constrained homelab rack.
* **Expansion Capabilities:** Despite its small size, it typically offers:
    * **M.2 NVMe Slot:** For a fast boot drive or primary storage.
    * **2.5-inch SATA Bay:** For an additional internal SSD/HDD.
    * **PCIe Slot (often M.2 E-key or M.2 B-key):** Can be adapted for various purposes, including the PCIe SATA expansion card used to connect the Oimaster drive rack. Some models may have a full PCIe x16 slot for half-height cards.
* **Processor & Memory:** The available processor options provide sufficient performance for virtualization workloads. The ability to upgrade RAM significantly supports running multiple resource-intensive services.

## Mounting

The ThinkCentre M720q is integrated into the custom-built rack using a 3D printed mount. (Refer to [ThinkCentre M720q/M920q Rack Mount](3d_prints/README.md) for details).
