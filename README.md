# RM-Homelab

 <img width="583" height="892" alt="Screenshot 2025-07-17 at 16 37 44" src="https://github.com/user-attachments/assets/839070fc-07c0-4ad8-93b7-052136dc8fb8" /> 


## Overview

Welcome to my homelab. This project started with a pretty clear goal: build something that could host my infrastructure in a neat, self-contained unit — something practical, portable, and efficient. I didn’t want a tangle of wires across the room or a power-hungry tower that doubled as a space heater.

I aimed for a system that ran quietly, consumed low power, was physically mobile (hence, wheels), and required only two cables to get going: power and Ethernet. Despite that simplicity, I still wanted it to be capable enough to handle virtual machines, media streaming, and automation without breaking the bank. This homelab is my way of experimenting, learning, and staying sane — all in one rack.

<img width="378" alt="image" src="https://github.com/user-attachments/assets/b2fc90ac-63e8-43ac-b9bb-f2d8e1db8b5f" /> 

## Why Build This?

I needed a central place to learn, experiment, and host the services I use every day. Cloud services are great — until you want more control or get tired of paying for things you could run yourself. So this is part learning platform, part practical utility. 

More than anything, I wanted a setup that:

- Was efficient and low-noise (it lives near people).
- Could be moved around easily.
- Didn't involve spending thousands on enterprise hardware.
- Could handle a reasonable mix of storage, compute, and networking.

This was never about building the most powerful or flashy setup — it was about finding the sweet spot between capability, cost, and cleanliness.

<img width="536" height="898" alt="Screenshot 2025-07-17 at 16 38 14" src="https://github.com/user-attachments/assets/35756d36-ad88-4a62-8a9e-c93d74f3043a" />

## Highlights

Some of the standout features of this setup:

- **Single-point deployment**: Just plug in power and Ethernet, and the entire lab comes to life.
- **Proxmox-powered virtualization**: Most services run in either LXCs or lightweight VMs.
- **Compact and modular**: Rack-mounted, low-profile components to keep things neat and upgrade-friendly.
- **Power efficient**: All chosen with efficiency in mind — especially the ThinkCentre, which punches above its weight.

## Core Services

### Virtualization & Infrastructure
- **Proxmox VE** – My main hypervisor. Runs both VMs and LXCs.
- **Semaphore** – Manages Ansible playbooks and automations.
- **Portainer** – Used for managing Docker containers when needed.
- **VS Code Server** – For editing and maintaining everything remotely.

### Networking & Monitoring
- **Pi-hole** – Local DNS and ad-blocking.
- **UptimeKuma** – Uptime monitoring across all services.
- **ESP32 w/ eInk display** – Custom-built Proxmox dashboard.

### Storage & Media
- **QNAP NAS (4TB Mirrored)** – Handles all shared storage.
- **Plex** – Streams my media collection.
- **QBittorrent** – Lightweight torrenting via web UI.

### Home Automation
- **Home Assistant (Raspberry Pi 4)** – Ties everything in the house together.

## Hardware Breakdown

All parts were chosen for their balance of efficiency, performance, and affordability:

- **ThinkCentre M720q Tiny** – The main workhorse running Proxmox.
- **QNAP NAS** – Redundant storage for media and backups.
- **Mac Mini** – Acts as a jump box and quick access point.
- **Raspberry Pi 4** – Dedicated to Home Assistant.
- **ESP32 w/ eInk** – Monitors Proxmox stats in real time.
- **TP-Link TL-SG108S** – 8-Port gigabit switch.
- **Eero Mesh 6** – Simple and reliable mesh Wi-Fi.
- **Hive Hub** – Controls heating systems.
- **APC Back-UPS 300W** – Battery backup for unexpected outages.
- **Oimaster 4-slot SATA rack** – Quick-swap SATA access.
- **1x PCIe to 4-port SATA card** – For extending storage inside tight enclosures.

See [Rack Build Components](rack-build.md) for full build notes.

## Diagrams

Visualizing the layout and network always helps:
- [Network Diagram](diagrams/network-diagram.md)
- [Rack Diagram](diagrams/rack-diagram.pdf)

## Customizations & 3D Prints

To keep things neat, I've designed a few parts myself and printed them:
- [Custom 3D Prints](3d_prints/README.md)

These include brackets, cable guides, and mounts to keep the whole rack tidy and quiet.

## Lessons Learned

This homelab has been an ongoing experiment. A few takeaways so far:

- **Noise matters more than you think** — especially when your servers live near bedrooms.
- **Cheap gear can take you surprisingly far**, if you're willing to tinker.
- **Power and thermals aren't optional** — efficiency isn't just about cost, it's about long-term stability.
- **Having everything in one rack feels great** — way better than scattered gear across shelves and desks.
- **You will make mistakes** — but the great thing about infrastructure as code and Proxmox snapshots is how easy it is to start fresh.

## Future Plans

Where I want to go next:

- Add a proper firewall/router appliance (likely something x86-based).
- Experiment with Kubernetes (likely K3s).
- Automate more with Ansible, Terraform and GitHub Actions.
- Expand backup solutions, potentially offsite or cloud-integrated.
- Increase Home Assistant integrations — more sensors, more automations.

## Final Thoughts

This homelab isn't finished — and probably never will be. That’s kind of the point. It's a place to learn, test ideas, and gradually build toward the ideal personal infrastructure. It might not be flashy, but it’s mine — and that’s what makes it satisfying to keep evolving.
