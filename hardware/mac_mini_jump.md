# Mac Mini — jump box / workstation

A Mac Mini in the rack that doubles as the admin jump host and a general-purpose
machine.

## Role

* **Jump host** — the trusted starting point for SSH into the cluster and the web UIs.
  Its key is the personal admin key authorised on the Proxmox nodes.
* **Workstation** — day-to-day use, with the accounts and password manager that hold the
  lab's credentials.

## Notes

* When the [firewall](../docs/security.md) lands, management access (SSH, the Proxmox UI,
  Semaphore) is intended to be restricted to this machine and the cluster subnet.
* It has no role in cluster operation — nothing fails if it's off.
