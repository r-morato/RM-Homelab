# Control container - build & harden

The container that runs Ansible and Semaphore. It holds root SSH access to every node
and guest, so it is treated as the most sensitive box in the lab.

## 1. Create it

Run [`bootstrap/01-create-control-node.sh`](../bootstrap/01-create-control-node.sh) on
`pve-node-1` as root. It:

* downloads the Debian 13 template if missing;
* creates the container - **unprivileged**, 1 vCPU / 512 MB / 512 MB swap / 4 GB on
  `local-lvm` (deliberately **not** NFS, so it survives a storage outage), `net0` on the
  LAN bridge, `firewall=1`, `onboot=1`, `nesting=0,keyctl=0`;
* `apt dist-upgrade`s it and installs `ansible`, `git`, `openssh-client`, `jq`,
  `unattended-upgrades`;
* generates `/root/.ssh/id_ed25519_ansible` (no passphrase - it has to run unattended)
  and an `~/.ssh/config` that always uses it;
* prints the public key.

Adjust `TEMPLATE_NAME` in the script to whatever
`pveam available --section system | grep debian-13` currently lists.

## 2. Make it managed infrastructure

It now holds the keys to the kingdom, so treat it like the other protected guests:

```bash
ha-manager add ct:109 --state started
#   then add ct:109 to the resources list of the existing node-affinity rule
#   and add it to the nightly vzdump job (Datacenter → Backup → <job> → Edit)
```

## 3. Authorise it everywhere

Run [`bootstrap/02-deploy-control-node-key.sh`](../bootstrap/02-deploy-control-node-key.sh)
on `pve-node-1`. It appends the `from="<control IP>"`-restricted key to:

* `/root/.ssh/authorized_keys` inside every guest (via `pct exec`);
* `/etc/pve/priv/authorized_keys` (cluster-synced, so both nodes get it).

It backs up the node's `authorized_keys` file first.

### 3a. Containers with `AllowUsers`

Some guests ship an `AllowUsers ssh-user` line in `sshd_config`, which blocks root SSH
**before** the key is checked - `ping.yml` reports them `unreachable` with
`User root ... not allowed because not listed in AllowUsers`.

Fix: a drop-in on each affected container (back up the original `sshd_config` first):

```
# /etc/ssh/sshd_config.d/20-ansible.conf
AllowUsers ssh-user root@<control IP>
```

`AllowUsers` directives accumulate across the config, and `sshd -t` +
`systemctl reload ssh` applies it with no dropped connections.

## 4. Install this repo into the container

```bash
# from a checkout on the host:
pct exec 109 -- install -d -m 0755 /opt/ansible
tar -C .. -cf - ansible | pct exec 109 -- tar -C /opt -xf -
```

Or `git clone` it. Keep `/opt/ansible/inventory/hosts.yml` out of any public remote (it
is gitignored here).

## 5. Configure Ansible inside the container

```bash
pct enter 109
cd /opt/ansible
cp inventory/hosts.example.yml inventory/hosts.yml     # edit: real IPs, webhook URL
ansible-playbook playbooks/ping.yml                    # all hosts must answer
```

If `ping.yml` fails for a container, its `/root/.ssh/authorized_keys` or the `from=`
address is wrong - re-check step 3.

## 6. Harden the container's own SSH

```bash
pct exec 109 -- bash -c '
  cat > /etc/ssh/sshd_config.d/10-hardening.conf <<EOF
PermitRootLogin prohibit-password
PasswordAuthentication no
KbdInteractiveAuthentication no
EOF
  systemctl reload ssh'
```

Add your workstation key to the container's `/root/.ssh/authorized_keys` first so you
keep access. `fail2ban` here too, mirroring the hosts.

## 7. Locale

The stock Debian 13 template has no locale generated, and Ansible aborts with "could not
initialize the preferred locale":

```bash
pct exec 109 -- bash -c '
  sed -i "s/^# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen && locale-gen
  printf "LANG=C.UTF-8\nLC_ALL=C.UTF-8\n" > /etc/default/locale && update-locale LANG=C.UTF-8'
```

## 8. Logging

Run logs live in **Semaphore's task history** (full per-run stdout, kept indefinitely).
`ansible.cfg` deliberately sets **no `log_path`** - a root-owned logfile is not writable
by the `semaphore` service user and just produces warnings.

## 9. Scheduling without Semaphore (fallback)

A plain systemd timer works if you skip Semaphore:

```ini
# /etc/systemd/system/patch-guests.service
[Service]
Type=oneshot
WorkingDirectory=/opt/ansible
ExecStart=/usr/bin/ansible-playbook playbooks/patch-guests.yml
```

```ini
# /etc/systemd/system/patch-guests.timer
[Timer]
OnCalendar=Sat *-*-* 02:00:00
Persistent=true
[Install]
WantedBy=timers.target
```

`systemctl enable --now patch-guests.timer`. The playbook still posts its own webhook
summary. Semaphore ([`semaphore.md`](semaphore.md)) is nicer for history and ad-hoc runs.
