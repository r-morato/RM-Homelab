# Patching automation (Ansible + Semaphore)

Automated OS patching for the Proxmox VE cluster and its LXC guests, driven from a
dedicated control container and a [Semaphore](https://github.com/semaphoreui/semaphore)
web UI.

It replaces an earlier weekly cron on a hypervisor that did
`bash -c "$(curl -fsSL https://.../update-lxcs-cron.sh)"` as root - an unpinned
`curl | bash` from a third-party repo, with no pre-backup and no report. See
[`../docs/automation.md`](../docs/automation.md) and
[`../docs/patching.md`](../docs/patching.md) for the design write-up; this README is the
operator reference.

---

## 1. Architecture

```
                        ┌─────────────────────────────┐
                        │  control container          │
                        │  Debian 13, 1 vCPU / 512 MB  │
                        │  on local-lvm (not NFS)      │
                        │                              │
                        │  ├─ ansible-core             │
                        │  ├─ this repo → /opt/ansible  │
                        │  └─ Semaphore (web UI :3000)  │
                        └──────────────┬───────────────┘
                                       │  SSH as root, key-only,
                                       │  key locked from="<control IP>"
                ┌──────────────────────┼───────────────────────┐
                │                      │                       │
       ┌────────▼─────────┐   ┌────────▼─────────┐    ┌─────────▼────────┐
       │  pve-node-1      │   │  pve-node-2      │    │  LXC guests      │
       │  (pve_nodes)     │   │  (pve_nodes)     │    │  (lxc_guests)    │
       └──────────────────┘   └──────────────────┘    └──────────────────┘
```

* The control container reaches every target over the **LAN segment**, never the
  storage/cluster segment - corosync runs there as a single ring and management
  traffic is kept off it.
* The control container holds root SSH access to the entire cluster, so it is the most
  sensitive guest: unprivileged, `nesting=0,keyctl=0`, key-only SSH, per-guest firewall
  enabled, and every authorised key is `from="<control IP>"`-restricted.
* It sits on `local-lvm`, so it still runs (and can still patch the guests) during an
  NFS outage.

## 2. What runs when

| Job | Playbook | Schedule (Semaphore) | Disruptive? |
|---|---|---|---|
| Patch containers | `playbooks/patch-guests.yml` | weekly, Sat 02:00 | pre-backup + `dist-upgrade` in place; no reboot (opt-in `-e allow_reboot=true`) |
| Patch hypervisors | `playbooks/patch-hosts.yml` | monthly, 1st Sun 03:00 | `dist-upgrade` **in place** - no reboot, no HA drain, guests untouched; reports "reboot required" |
| Reboot hypervisors | `playbooks/reboot-hosts.yml` | **manual only** | drains HA + reboots, one node at a time; won't touch the node hosting the control container |
| Connectivity check | `playbooks/ping.yml` | on demand | none |

This is the **"patch on schedule, notify-to-reboot"** model: package updates land
automatically and non-disruptively; a hypervisor reboot is always a deliberate,
hands-on action.

## 3. Repository layout

```
ansible/
├── ansible.cfg                 # inventory path, ssh tuning, stdout callback
│                               # (no requirements.yml at root - collections come
│                               #  from the Debian `ansible` package; see docs/)
├── inventory/
│   ├── hosts.example.yml       # committed, placeholder addresses
│   └── hosts.yml               # gitignored - the real inventory
├── roles/
│   ├── apt_upgrade/            # idempotent update+upgrade, records facts for the summary
│   ├── pve_node_patch/         # dist-upgrade a node in place, flag if a reboot is due
│   ├── pve_node_reboot/        # drain HA → reboot → wait quorum+pveproxy → un-drain
│   └── notify_webhook/         # POST a short {title,message} to the webhook, never fails
├── playbooks/
│   ├── group_vars/             # adjacent to the PLAYBOOKS so vars load whether the
│   │   ├── all.yml             #   run is from the CLI or from Semaphore (which uses
│   │   ├── pve_nodes.yml       #   its own inventory path). all.yml = apt + webhook +
│   │   └── lxc_guests.yml      #   backup defaults; the others tune per host class
│   ├── ping.yml
│   ├── patch-guests.yml        # pre-backup + patch all guests + notify
│   ├── patch-hosts.yml         # patch both nodes, serial 1, no reboot, notify
│   └── reboot-hosts.yml        # rolling reboot, manual
├── bootstrap/
│   ├── 01-create-control-node.sh    # run on a PVE node - builds the control container
│   ├── 02-deploy-control-node-key.sh # run on a PVE node - authorises it everywhere
│   └── semaphore/              # API scripts that recreate the Semaphore project objects
└── docs/
    ├── control-node.md         # build + harden the control container
    ├── semaphore.md            # install + configure Semaphore, projects, schedules
    └── requirements.reference.yml   # collections list (only needed on a non-Debian box)
```

## 4. How the tricky bits work

### Pre-patch backup (`patch-guests.yml`)

The first play runs once on the first node and calls `vzdump` for exactly the containers
in the `backup_protected` inventory group (the ones already on the nightly job), in
snapshot mode. A bad upgrade is then one `pct rollback` away. Skip it with
`-e pre_patch_backup=false`.

### A dead third-party repo doesn't wedge the run

`apt-get update` returns `100` when *some* repositories fail but others succeed. The
`apt_upgrade` role tolerates rc `100`, patches everything the working repos provide, and
carries the failing lines into the run summary as `[repo warnings]`. Any other rc
(network down, dpkg lock) is still fatal.

### Patching a hypervisor (`pve_node_patch`)

`serial: 1`, and per node just `apt dist-upgrade` **in place**. No reboot, no HA drain - installing packages doesn't disturb running guests, and draining every guest to the
other node (and back) merely to install packages is both disruptive and self-defeating
here: the control container is itself an HA guest and would be migrated out from under
the running playbook. If a node ends up needing a reboot, the run says so.

### Rebooting a hypervisor (`pve_node_reboot`, manual only)

`serial: 1`, `any_errors_fatal`. Per node:

1. **Guard:** find where the control container is (`ha-manager status`); if it's on
   *this* node, fail immediately with instructions (rebooting it would kill the run).
   Bypass only with `-e control_node_relocated=true` after you've moved it yourself.
2. Reboot only if `/var/run/reboot-required` exists **or** the running kernel is older
   than the newest `/boot/vmlinuz-*` (override: `-e reboot_only_if_required=false`).
3. `ha-manager crm-command node-maintenance enable <node>` → poll until no
   `service … (<node>, …)` line remains.
4. `reboot`, wait for the node, then poll `pvecm status` for `Quorate: Yes` and
   `wait_for` port 8006.
5. `node-maintenance disable`; on the affinity-preferred node, poll until guests return.

This is the exact by-hand sequence from a kernel upgrade, codified - minus the part
where you have to remember not to strand yourself.

### Notifications

`notify_webhook` POSTs `{"title": …, "message": …}` to the URL in the real inventory (a
phone-push endpoint). Messages are hard-truncated to ~3.5 KB because that endpoint
returns HTTP 500 for bodies over ~5-7 KB. A failed notification is logged, never fatal.

## 5. First-time setup

See [`docs/control-node.md`](docs/control-node.md) then
[`docs/semaphore.md`](docs/semaphore.md). In short:

```bash
# on pve-node-1, as root
./bootstrap/01-create-control-node.sh           # build the control container
./bootstrap/02-deploy-control-node-key.sh        # authorise it everywhere

# copy this tree into the container (id 109 in the bootstrap script)
pct exec 109 -- install -d /opt/ansible
tar -C .. -cf - ansible | pct exec 109 -- tar -C /opt -xf -

# inside the container (collections ship with the Debian `ansible` package - no galaxy step)
cd /opt/ansible
cp inventory/hosts.example.yml inventory/hosts.yml   # then edit with real values
ansible-playbook playbooks/ping.yml                  # verify reachability
ansible-playbook playbooks/patch-guests.yml --check  # dry run
```

Then install Semaphore ([`docs/semaphore.md`](docs/semaphore.md)).

## 6. Day-to-day

```bash
ansible-playbook playbooks/patch-guests.yml                     # patch all containers
ansible-playbook playbooks/patch-guests.yml --limit ct-media-a  # just one
ansible-playbook playbooks/patch-hosts.yml                      # patch both nodes (no reboot)
ansible-playbook playbooks/reboot-hosts.yml                     # when a reboot was flagged
```

…or click **Run** on the matching task template in Semaphore.

### Rebooting the nodes

`patch-hosts.yml` never reboots and never drains - it just installs packages one node
at a time. When it reports a node needs a reboot, `reboot-hosts.yml` does the
drain → reboot → wait-for-quorum → un-drain cycle, **but it will not reboot the node
currently hosting the control container** (that would kill the run). On this 2-node
cluster:

```bash
ha-manager status | grep ct:109                             # find the control container
ansible-playbook playbooks/reboot-hosts.yml --limit <other> # reboot the other node
ha-manager migrate ct:109 <other>                           # move the control container
ansible-playbook playbooks/reboot-hosts.yml --limit <first> -e control_node_relocated=true
```

## 7. Adding a new container or node

For a new guest that should be patched:

1. **Inventory** - add it under `lxc_guests` in `inventory/hosts.yml` (and
   `backup_protected` if it's on the vzdump job). The playbooks iterate the group, so
   nothing else changes.
2. **Semaphore** uses a *static* copy of that inventory - update it too:
   Semaphore → project → Inventory → `production` → edit, or re-paste `hosts.yml`.
3. **SSH access** - `bootstrap/02-deploy-control-node-key.sh` (add the new id to
   `GUEST_IDS`) or a one-off `pct exec <id> -- ...` to drop the `from="<control IP>"`
   key into `root@`'s `authorized_keys`. If the guest has `AllowUsers` in sshd, add the
   `20-ansible.conf` drop-in (see `docs/control-node.md` §3a).
4. **HA** (recommended for anything that matters) - `ha-manager add ct:<id>
   --state started` and add `ct:<id>` to the node-affinity rule's `resources`.

> The step-2 double entry is the price of keeping `hosts.yml` out of git. If you add
> guests often, switch Semaphore to the `community.general.proxmox` **dynamic
> inventory** (queries the PVE API, auto-discovers every guest); group membership then
> comes from PVE tags. Not set up here yet.

## 8. Security notes

* `inventory/hosts.yml` (real addresses + webhook URL) and any `vault.yml` /
  `.vault_pass` are gitignored. Only `hosts.example.yml` with `10.0.0.x` placeholders is
  committed.
* The control container is a single point of compromise for the whole cluster. Treat
  its backups and its `/root/.ssh/id_ed25519_ansible` accordingly. It is on the nightly
  vzdump job and under HA.
* Authorised keys on targets are `from="<control IP>"`-locked; the plan is to tighten
  further once the Proxmox firewall is enabled, restricting SSH to the control
  container and one workstation. See [`../docs/security.md`](../docs/security.md).
