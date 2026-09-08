# APC Back-UPS (300 W / 0.5 kVA)

Line-interactive UPS on the critical leg of the rack: the two cluster nodes, the switch,
the router, and the NAS. It rides out brownouts and short outages and gives everything
time for a clean shutdown on a long one.

## Current state

* **Battery backup and surge protection: working.** A brief power blip is invisible to
  the lab.
* **Automatic graceful shutdown: not wired up yet.** It used to be driven over USB from
  the (now offline) media NAS acting as a master and signalling Proxmox. With that box
  down, there is no automatic "power's been out for N minutes, shut down now" path.

The nodes' SSDs show a high unclean-shutdown count, so restoring this is a priority.

## Plan

Connect the UPS's USB to one cluster node, run **NUT** (`nut-server` there,
`nut-client` on the other node and the NAS), and configure a shutdown policy: on
"battery low" or after a set time on battery, HA guests stop, then the nodes power off.
Everything comes back on its own when mains returns and the nodes `onboot` their guests.

## Powered by the UPS

ThinkCentre (`pve-node-1`), HP EliteDesk (`pve-node-2`), TP-Link switch, Eero router,
NAS. The Raspberry Pi and low-power accessories are on the non-UPS leg.
