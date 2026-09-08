# Media acquisition stack

Kept intentionally generic. Four containers handle getting content into the media
library that [Plex](plex.md) and [Jellyfin](jellyfin.md) then serve:

| Container | VMID | Function |
|---|---|---|
| `ct-torrent` | 101 | download client with a web UI |
| `ct-indexer-a` | 106 | media indexer / automation |
| `ct-indexer-b` | 107 | media indexer / automation |
| `ct-indexer-c` | 108 | media indexer / automation |

## How they relate

The indexer/automation containers watch for wanted items, hand download jobs to the
download client, and file the results into the library on the media NAS. Standard
self-hosted media-automation pattern.

## Notes

* **None are on the backup job.** Their state is re-creatable and their libraries live
  on the media NAS. They're also the largest and slowest containers to archive.
* All HA-managed.
* The download client's web UI requires a login from every address, and its credentials
  live in a password manager, not in the guest Notes - see
  [security](../docs/security.md).
* Config is hand-managed inside each container.
