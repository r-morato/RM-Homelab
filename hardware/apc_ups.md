# APC Back-UPS 0.5 KVA 300W

## Overview

The APC Back-UPS serves as an Uninterruptible Power Supply (UPS) for critical homelab components, providing a buffer against power outages and fluctuations.

## Specifications

* **Model:** APC Back-UPS (Specific model number, e.g., BX500CI or similar, if known).
* **Capacity:** 0.5 KVA / 300W
* **Type:** Line-interactive UPS

## How does it trigger?

I have configured the UPS on the QNAP via USB, and it works as a master sending commands to Proxmox when the power goes off so that all the containers and VMs are shutdown after a defined amount of time

## Purpose in the Homelab

* **Power Protection:** Shields connected devices from power surges, spikes, and brownouts.
* **Uninterrupted Operation:** Provides battery backup during power failures, allowing time for controlled shutdowns of servers (like Proxmox) or maintaining continuous operation for essential services (like the network switch and router).
* **Graceful Shutdowns:** Enables automated, safe shutdowns of systems to prevent data corruption during extended power outages.

## Integration

The UPS powers the most critical components of the homelab, including the ThinkCentre (Proxmox host), the TP-Link switch, the Eero router, and potentially the QNAP NAS, ensuring network connectivity and server uptime even during brief power interruptions.
