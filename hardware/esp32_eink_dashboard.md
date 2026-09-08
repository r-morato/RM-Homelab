# ESP32 + e-ink Proxmox dashboard

A small battery-friendly wall display on the rack that shows cluster stats at a glance - node load, memory, guest count, backup age - without opening a browser.

## Build

| | |
|---|---|
| MCU | ESP32 (Wi-Fi) |
| Display | e-ink panel - near-zero power when static, readable in any light |
| Power | USB from the rack's 6-port charger |
| Mount | custom 3D-printed bracket sized to the panel (not yet published) |

## How it works

The ESP32 connects to Wi-Fi, calls the **Proxmox VE API** read-only (a dedicated token
user with view-only permissions), parses the JSON, and redraws the e-ink panel on an
interval. Between refreshes it deep-sleeps, so it sips power.

It is **outside the cluster** and purely a consumer of the API - nothing depends on it,
and it has no write access.
