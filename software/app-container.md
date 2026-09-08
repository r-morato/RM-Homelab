# App container (`ct-app`)

A small self-hosted **Laravel** web application, running in its own container - VMID 112.

## Role

* A personal project / utility app. Kept in its own LXC rather than on the shared
  [Docker host](docker-host.md) so its dependencies and lifecycle are isolated.

## Notes

* **On the nightly backup job** - it holds application data that isn't reproducible.
* HA-managed like the rest.
* Patched by the weekly container job. Config is hand-managed inside the container.
