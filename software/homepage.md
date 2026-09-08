# Homepage (dashboard)

[Homepage](https://gethomepage.dev/) - the lab's start page. Runs in `ct-dashboard`
(VMID 100).

## Role

* A single link-and-status page for every service, grouped by function.
* Live widgets: Proxmox cluster status, container/VM counts, and per-service health
  pulled from each app's API.
* The first thing that loads on a new browser / device.

## Notes

* Config is hand-written YAML inside the container (`services.yaml`, `widgets.yaml`,
  `bookmarks.yaml`). Fiddly to recreate, so `ct-dashboard` **is on the nightly backup
  job**.
* It only links to service web UIs - it stores no credentials of its own. API keys for
  the widgets live in its environment / config, referenced from the guest's Notes.
* HA-managed like the rest.
