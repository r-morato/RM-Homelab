# UptimeKuma

## Overview

UptimeKuma is a self-hosted monitoring tool that provides status pages and uptime monitoring for various services and devices.

## Type

* Self-hosted Monitoring Tool
* Status Page Generator

## Role in the Homelab

* **Service Monitoring:** Continuously checks the availability and responsiveness of all key homelab services (e.g., Proxmox, Plex, Home Assistant, Pi-hole).
* **Alerting:** Configured to send notifications if a monitored service goes offline or becomes unresponsive.
* **Status Dashboard:** Provides a centralized, real-time dashboard displaying the current status of all monitored components, offering a quick overview of the homelab's health.

## Hosting

UptimeKuma runs as a service within the homelab environment, commonly deployed as a Docker container or an LXC on Proxmox.
