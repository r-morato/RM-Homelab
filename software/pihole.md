# Pi-hole

Network-wide DNS sinkhole — LAN DNS resolver plus ad/tracker blocking for every device
that uses it.

<!-- TODO(@r-morato): confirm where Pi-hole actually runs before publishing — this
     page assumes a container on the Docker host. If it's its own LXC or on the Pi,
     update this and docs/networking.md. -->

## Role

* **LAN DNS** — clients resolve through it (set by DHCP option on the router, or
  per-device). Upstream is a public resolver.
* **Filtering** — blocks ad/tracker/malware domains from common block-lists.
* **Visibility** — query log and per-client stats in its web UI.

## Hosting

Runs as a container on the [Docker host](docker-host.md) (`ct-docker`), so it inherits
that container's HA coverage and backup.

## Notes

* DNS is a dependency for most of the lab, so it matters that its host is HA-managed —
  a node failure shouldn't take name resolution with it.
* Block-lists and local DNS records are lightweight config; they're captured in the
  `ct-docker` backup.
