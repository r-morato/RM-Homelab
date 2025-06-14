# Proxmox Virtual Environment

## Overview

Proxmox Virtual Environment (VE) is an open-source server virtualization management solution. It is the core hypervisor running on the ThinkCentre M720q.

## Type

* Hypervisor (Type-1)
* Container (LXC) and Virtual Machine (KVM) platform.

## Role in the Homelab

* **Virtualization Platform:** Hosts various virtual machines (VMs) and Linux Containers (LXCs) that run different homelab services.
* **Centralized Management:** Provides a web-based interface for creating, managing, and monitoring all virtualized resources.
* **Resource Allocation:** Manages the allocation of CPU, RAM, and storage resources to individual VMs and LXCs.
* **Storage Integration:** Utilizes ZFS on the MSI Spatium SSDs for VM/LXC storage.

## Hosting Hardware

* **Host:** ThinkCentre M720q Tiny
* **Storage:** MSI Spatium S270 SSDs via Oimaster HE-2006 and PCIe SATA card.
