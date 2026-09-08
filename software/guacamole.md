# Apache Guacamole (remote-access gateway)

Clientless remote desktop gateway - RDP / VNC / SSH in a browser tab, no client install.
Runs in `ct-gateway` (VMID 105).

## Role

* The way I reach the lab's consoles and a couple of desktops from outside, over one
  HTTPS endpoint, without exposing RDP/SSH directly.
* Backed by a small MariaDB database (connection list, users) and the `guacd` proxy
  daemon, both bound to localhost inside the container.

## Why it's treated as sensitive

A remote-access gateway holds the credentials for every system it can reach, so it's
handled as one of the more important guests to keep locked down and current:

* It's **on the nightly backup job**, with a **pre-backup transaction-consistent
  database dump** so every archive has a clean copy (see [backups](../docs/backups.md)).
* It's near the front of the line for patching and for the firewall rules
  ([security](../docs/security.md)).
* Any key it uses to reach another host is `from=`-locked to this container's address.

## Notes

* MariaDB root auth inside the container is `unix_socket` (no password).
* The database was moved from a short-term-support release onto the **LTS** line to stop
  the annual repo-churn that once broke a patch run - see [patching](../docs/patching.md).
* HA-managed. The SSH connection needs username `root` (lowercase) and the guacd
  host/port fields left blank.
