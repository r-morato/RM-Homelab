# Plex Media Server

Client–server media system. Runs in `ct-media-b` (VMID 103).

## Role

* Organises and streams the film/TV library (on the media NAS, bind-mounted in) to smart
  TVs, phones, tablets, and browsers, on the LAN and remotely.
* Runs alongside [Jellyfin](jellyfin.md) — Plex for polish and client support, Jellyfin
  as the no-strings fallback.

## Notes

* **Hardware transcoding** via the host iGPU, shared with the Jellyfin container.
* **Not on the backup job.** Media is on the NAS; the Plex database is a metadata cache
  that rebuilds from a library scan.
* HA-managed; needs the media bind-mount on whichever node runs it.
