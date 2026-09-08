# Eero Mesh 6 — router / gateway

The perimeter router and Wi-Fi for the whole house, including the lab. `10.0.0.1` on the
LAN segment.

## Role

* **Gateway / NAT** — the only path to the internet.
* **DHCP** for dynamic clients; static infra addresses sit outside the pool.
* **Perimeter firewall** — the only packet filtering currently in effect (the Proxmox
  firewall is designed but not enabled — see [`docs/security.md`](../docs/security.md)).
* **Wi-Fi 6 mesh** for phones, laptops, smart-home gear, and the ESP32 display.

## Notes

* No ports are forwarded to the lab. Remote access is via
  [Guacamole](../software/guacamole.md) or a VPN.
* Its presence is picked up by Home Assistant for device presence detection.
* A dedicated x86 firewall/router appliance (OPNsense-class) is a long-standing "maybe"
  — it would also give real VLAN support.
