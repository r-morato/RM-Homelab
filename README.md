# RM-Homelab

<img width="498" alt="image" src="https://github.com/user-attachments/assets/a7dc7f18-4fe8-4a68-8b61-1007618fe399" /><img width="495" alt="image" src="https://github.com/user-attachments/assets/d08e69e3-6dc8-47ff-aa78-d862f3ee14bc" />
<img width="378" alt="image" src="https://github.com/user-attachments/assets/b2fc90ac-63e8-43ac-b9bb-f2d8e1db8b5f" />





## Overview

This repository documents the components, services, and setup of my personal home lab. Designed for a mix of virtualization, media serving, and home automation, it's a continuously evolving platform for learning and hosting various services. I focused this project on good processing power whilst using low power usage, which is why I decided to go with the hardware below. 

## Key Features

* **Virtualization:** Proxmox VE for running VMs and LXCs.
* **Media & Storage:** Dedicated NAS and Plex for media consumption and backups.
* **Home Automation:** Home Assistant on a Raspberry Pi for smart home control.
* **Custom Monitoring:** ESP32 with an eInk display for real-time Proxmox status.
* **Network Services:** Pi-hole for network-wide ad-blocking and DNS.
* **Management:** Semaphore for Ansible automation and Portainer for Docker management.

## Components

A detailed breakdown of the hardware and software making up the homelab:

* **Hardware:**
    * [Rack Build Components](components/hardware/rack_components.md)
    * [ESP32 with eInk Screen (Proxmox Status)](components/hardware/esp32_eink.md)
    * [APC Back-UPS 0.5 KVA 300W](components/hardware/apc_ups.md)
    * [MSI Spatium S270 240GB SSDs](components/hardware/msi_spatium_ssd.md)
    * [Oimaster HE-2006 4-Slot SATA Rack](components/hardware/oimaster_he2006.md)
    * [PCIe 1x Express to 4-Port SATA Card](components/hardware/pcie_sata_card.md)
    * [Raspberry Pi 4 (Home Assistant)](components/hardware/raspberry_pi4.md)
    * [Eero Mesh 6 Wi-Fi (Router)](components/hardware/eero_mesh_6.md)
    * [Hive Hub (Heating Management)](components/hardware/hive_hub.md)
    * [TP-Link TL-SG108S 8-Port Gigabit Switch](components/hardware/tp_link_tl_sg108s.md)
    * [ThinkCentre M720q Tiny](components/hardware/thinkcentre_q720m.md)
    * [Mac Mini (Jump Server)](components/hardware/mac_mini_jump.md)
    * [QNAP NAS (4TB Mirrored Drives)](components/hardware/qnap_nas.md)
    * [6-Port USB Charger](components/hardware/usb_charger.md)

* **Software & Services:**
    * [Proxmox Virtual Environment](components/software/proxmox.md)
    * [Semaphore](components/software/semaphore.md)
    * [QNAP NAS Software](components/software/qnap_software.md)
    * [Pi-hole](components/software/pihole.md)
    * [UptimeKuma](components/software/uptimekuma.md)
    * [Portainer](components/software/portainer.md)
    * [VS Code Server](components/software/vscode_server.md)
    * [Plex Media Server](components/software/plex.md)
    * [QBittorrent](components/software/qbittorrent.md)
    * [Home Assistant](components/software/homeassistant.md)

## Homelab Services

Here are the primary services running, categorized by their function:

### Servers
* **Proxmox**: Virtualization environment for hosting VMs and LXCs.
* **Semaphore**: Manages Ansible automation.
* **QNAP**: Network-attached storage for data.
* **Pi-hole**: Network-wide ad-blocking and DNS.
* **UptimeKuma**: Status monitoring for all services.
* **Portainer**: Manages Docker containers.
* **VS Code Server**: Remote VS Code instance for development.

### Entertainment
* **Plex**: Media server for films and TV shows.
* **QBittorrent**: Torrent client for media acquisition.

### Home Automation
* **HomeAssistant**: Central hub for home automation.

## Diagrams

Visual representations of the homelab's structure and connectivity:
* [Network Diagram](diagrams/network_diagram.drawio)
* [Rack Elevation](diagrams/rack_elevation.drawio)
* [Logical Flow Diagram](diagrams/logical_flow.drawio)

## Customizations & 3D Prints

Details on custom solutions and 3D printed components used in the build:
* [Custom 3D Prints](3d_prints/README.md)

## Automation

Scripts and configurations for automating various aspects of the homelab:
* [Ansible Playbooks](automation/ansible/)
* [Utility Scripts](automation/scripts/)
* [Home Assistant Automations](automation/home_assistant_automations/)

## Issues & Lessons Learned

Documentation of common challenges encountered and their resolutions:
* [Common Issues](issues/common_issues.md)
* [Troubleshooting Guides](issues/troubleshooting_guides.md)

## Future Plans

Ongoing developments and planned enhancements for the homelab:
* Integration of a dedicated firewall/router appliance.
* Exploration of Kubernetes for container orchestration.
* Further expansion of storage and backup solutions.
* Deepening Home Assistant integrations.
