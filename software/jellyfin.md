# Jellyfin

Open-source media server. Runs in `ct-media-a` (VMID 102).

## Role

* Streams the media library (stored on the media NAS, bind-mounted into the container)
  to clients on the LAN and remotely.
* The free/self-hosted counterpart to [Plex](plex.md) - both run so I'm not tied to one.

## Notes

* **Hardware transcoding** via the host's integrated GPU - the render device is
  bind-mounted into the container. [`ct-media-b`](plex.md) shares the same GPU.
* **Not on the backup job.** The library lives on the media NAS; Jellyfin's own metadata
  DB is re-buildable by a library scan. Nothing here is worth an archive.
* HA-managed. If it moves to `pve-node-2`, that node needs the media bind-mount too -   see [provisioning](../docs/provisioning.md).
