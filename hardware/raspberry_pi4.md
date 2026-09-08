# Raspberry Pi 4 — Home Assistant

A Raspberry Pi 4 (8 GB) running **Home Assistant OS on bare metal**, powered from the
rack's 6-port USB charger and mounted in a custom 3D-printed 10-inch bracket.

## Why bare metal, outside the cluster

Home automation should keep working while the Proxmox cluster is being patched, rebooted,
or rebuilt — and it needs a stable USB path to the Zigbee coordinator. Running it on its
own dedicated board keeps it independent of everything else in the rack. It has its own
backup routine (HAOS snapshots) separate from the cluster's `vzdump` job.

## Role

* **Home automation hub** — the single control point for the house's smart devices.
* **Zigbee coordinator** — via a Sonoff Zigbee 3.0 USB Dongle Plus, for local
  (cloud-free) control of sensors, lights, and switches.

## Integrations

Zigbee (Sonoff dongle), Hive heating ([`hive_hub.md`](hive_hub.md)), Ecovacs, Ring,
Octopus Energy, LG webOS TV, Spotify, Tuya, the Eero router (presence detection), and
the Home Assistant mobile apps. Plus the usual core integrations (`sun`, `met` weather,
`cast`, Supervisor, `backup`).

See [`software/homeassistant.md`](../software/homeassistant.md) for the platform side.
