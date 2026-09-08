# Home Assistant

Open-source, local-first home automation platform — the central brain for the house's
smart devices. Runs on **Home Assistant OS, bare metal, on a dedicated
[Raspberry Pi 4](../hardware/raspberry_pi4.md)** — deliberately **outside** the Proxmox
cluster.

## Why it's not a cluster guest

* Home automation should keep working while the cluster is being patched or rebuilt.
* It needs a stable, exclusive USB path to the Zigbee coordinator — cleaner on dedicated
  hardware than passed through to a container.
* It has its own backup story (HAOS snapshots), independent of the cluster's `vzdump`.

## Role

* **Single control surface** for every smart device, regardless of brand.
* **Local Zigbee network** via a Sonoff Zigbee 3.0 USB Dongle Plus — sensors, lights,
  switches, no cloud round-trip.
* **Automation engine** — presence- and sensor-driven routines (heating, lighting,
  notifications).
* **Dashboards & history** for sensor data and energy use.

## Integrations

Zigbee, Hive heating, Ecovacs, Ring, Octopus Energy, LG webOS TV, Spotify, Tuya, the
Eero router (presence), and the Home Assistant mobile apps.

## Relationship to the lab

Monitored by [Uptime Kuma](uptimekuma.md); resolves DNS through [Pi-hole](pihole.md).
Otherwise self-contained.
