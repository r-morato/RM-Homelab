# My Ultimate Home Lab

![Homelab Rack](media/images/tempImagePQJTqr.jpg)

## Introduction

Welcome to my home lab repository! This space serves as a detailed documentation of the design, components, services, and ongoing evolution of my personal home lab. Built for a variety of purposes including virtualization, media serving, and home automation, it's a constantly evolving environment where I can learn, experiment, and host critical services.

## Key Features

* **Robust Virtualization:** Powered by Proxmox VE, offering flexibility for multiple VMs and LXCs.
* **Centralized Media & Storage:** Plex and QNAP provide a dedicated solution for films, TV shows, and backups.
* **Comprehensive Home Automation:** Home Assistant running on a dedicated Raspberry Pi integrates and manages smart home devices.
* **Custom Monitoring:** An ESP32 with an eInk screen provides real-time Proxmox status at a glance.
* **Network Control:** Pi-hole ensures ad-blocking and DNS management across the network.
* **Secure Access & Management:** A Mac Mini acts as a jump server, and Semaphore helps manage Ansible deployments.

## Architecture Overview

My homelab's architecture is built around a central Proxmox server, a dedicated NAS for bulk storage, and a robust network infrastructure. All critical components are housed within a compact, portable rack, powered by a UPS for resilience. For a detailed visual representation, please refer to the network and rack elevation diagrams in the `diagrams/` folder.

## Components

Dive deeper into the specific hardware and software that power my homelab:

* **Hardware:** Explore the physical components that make up the rack and its peripherals.
    * [Rack Build Components](components/hardware/rack_components.md)
    * [ESP32 with eInk Screen - Proxmox Status Monitor](components/hardware/esp32_eink.md)
    * [APC Back-UPS 0.5 KVA 300W](components/hardware/apc_ups.md)
    * [MSI Spatium S270 240GB SSDs (x3)](components/hardware/msi_spatium_ssd.md)
    * [Oimaster HE-2006 4-Slot SATA Internal Rack](components/hardware/oimaster_he2006.md)
    * [PCIe 1x Express to 4-Port SATA Card](components/hardware/pcie_sata_card.md)
    * [Raspberry Pi 4 - Home Assistant OS](components/hardware/raspberry_pi4.md)
    * [Eero Mesh 6 Wi-Fi System (Router)](components/hardware/eero_mesh_6.md)
    * [Hive Hub (Heating Management)](components/hardware/hive_hub.md)
    * [TP-Link TL-SG108S 8-Port Gigabit Switch](components/hardware/tp_link_tl_sg108s.md)
    * [ThinkCentre M720q Tiny](components/hardware/thinkcentre_q720m.md)
    * [Mac Mini (Jump Server)](components/hardware/mac_mini_jump.md)
    * [QNAP NAS with 4TB Mirrored Drives](components/hardware/qnap_nas.md)
    * [6-Port USB Charger](components/hardware/usb_charger.md)

* **Software:** Discover the services and applications running on the hardware.
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

## Services Running

Here's a quick overview of the key services and their access points. For security reasons, specific internal IP addresses are not listed, but you can infer typical port numbers for these services.

### Servers
* **Proxmox**: Access via web browser on the configured Proxmox port (e.g., `https://[Your-Proxmox-IP]:8006`) - Proxmox Virtual Environment
* **Semaphore**: Access via web browser on its configured port (e.g., `http://[Your-Semaphore-IP]:3000`) - Manage Ansible and other solutions
* **QNAP**: Access via web browser on its standard port (e.g., `http://[Your-QNAP-IP]:8080`) - NAS Storage
* **Pi-hole**: Access admin interface via web browser (e.g., `http://[Your-PiHole-IP]/admin`) - Ad-blocking DNS server
* **UptimeKuma**: Access status page via web browser on its configured port (e.g., `http://[Your-UptimeKuma-IP]:3001/status/home`) - Status Monitor
* **Portainer**: Access via web browser on its secure port (e.g., `https://[Your-Portainer-IP]:9443`) - Docker container Manager
* **VS Code Server**: Access via web browser on its configured port (e.g., `http://[Your-VSCodeServer-IP]:8680`) - VS Code instance running on the browser

### Entertainment
* **Plex**: Access via web browser (e.g., `http://[Your-Plex-IP]`) - Watch movies and TV shows
* **QBittorrent**: Access via web browser on its configured port (e.g., `http://[Your-QBittorrent-IP]:8080`) - Watch movies and TV shows

### Home Automation
* **HomeAssistant**: Access via web browser on its standard port (e.g., `http://[Your-HomeAssistant-IP]:8123/`) - Manage all home automation

## Challenges & Solutions

Building a homelab always comes with its share of challenges. In the `issues/` folder, I document common problems encountered during setup and operation, along with their solutions and troubleshooting guides. This helps in understanding potential pitfalls and how to navigate them.

## Future Plans

My homelab is an ongoing project. Future plans include:

* Implementing a dedicated firewall/router appliance (e.g., OPNsense/pfSense).
* Exploring Kubernetes for container orchestration.
* Expanding storage capacity for media and backups.
* Integrating more smart home devices with Home Assistant.

## Contribution

Suggestions and improvements are always welcome! Feel free to open an issue or pull request if you have ideas on how to enhance this documentation or the homelab itself.
