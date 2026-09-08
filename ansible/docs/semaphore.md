# Semaphore setup

[Semaphore](https://github.com/semaphoreui/semaphore) is a single Go binary that gives
Ansible a web UI: task templates, cron schedules, run history with full logs, and
failure alerts. It runs in the control container alongside Ansible.

Deployed here as **Community Edition v2.19.12** (Apache-2.0). Adjust versions/paths when
rebuilding.

## 1. Install

```bash
pct enter 109
VER=2.19.12
cd /tmp
curl -fsSLO "https://github.com/semaphoreui/semaphore/releases/download/v${VER}/semaphore_community_${VER}_linux_amd64.deb"
# verify against the published checksums file BEFORE installing:
curl -fsSL "https://github.com/semaphoreui/semaphore/releases/download/v${VER}/semaphore_community_${VER}_checksums.txt" \
  | grep linux_amd64.deb | sha256sum -c -
apt-get install -y "./semaphore_community_${VER}_linux_amd64.deb"
```

> The `semaphore_community_*` build is the Apache-2.0 edition. The plain `semaphore_*`
> build is the commercial one — don't use it here.

## 2. Service account + directories

```bash
useradd --system --home-dir /var/lib/semaphore --create-home --shell /usr/sbin/nologin semaphore
install -d -o semaphore -g semaphore -m 0750 /var/lib/semaphore /var/lib/semaphore/tmp /etc/semaphore
```

## 3. Config

Semaphore 2.19 **dropped BoltDB** — the embedded option is now **SQLite**. Write
`/etc/semaphore/config.json` (mode 0600, owned by `semaphore`) with fresh random keys:

```jsonc
{
  "dialect": "sqlite",
  "sqlite":  { "host": "/var/lib/semaphore/database.sqlite" },
  "tmp_path": "/var/lib/semaphore/tmp",
  "cookie_hash":            "<head -c32 /dev/urandom | base64>",
  "cookie_encryption":      "<head -c32 /dev/urandom | base64>",
  "access_key_encryption":  "<head -c32 /dev/urandom | base64>",
  "port": ":3000",
  "web_host": "http://<control IP>:3000",
  "email_alert": false,
  "max_parallel_tasks": 1
}
```

`access_key_encryption` is what encrypts stored SSH keys and the static inventory at
rest in the SQLite file — keep the config file and the DB backed up together (the
control container is on the nightly vzdump job).

## 4. Initialise + admin user + service

```bash
runuser -u semaphore -- semaphore migrate --config /etc/semaphore/config.json
runuser -u semaphore -- semaphore user add --admin \
  --login admin --name Admin --email you@example.com \
  --password '<CHANGE THIS>' --config /etc/semaphore/config.json
```

systemd unit `/etc/systemd/system/semaphore.service`:

```ini
[Unit]
Description=Semaphore Ansible UI
After=network.target

[Service]
Type=simple
User=semaphore
Group=semaphore
ExecStart=/usr/bin/semaphore service --config /etc/semaphore/config.json
Restart=always
RestartSec=3
WorkingDirectory=/var/lib/semaphore

[Install]
WantedBy=multi-user.target
```

```bash
systemctl enable --now semaphore
curl -fsS http://127.0.0.1:3000/api/ping        # -> pong
```

> **Change the admin password** in the UI → top-right → Profile. The one set on the CLI
> during the build is a placeholder.

## 5. Git safe.directory

Semaphore runs as `semaphore` and clones the repo from `file:///opt/ansible`, which root
owns. Without this, the clone fails with "detected dubious ownership":

```bash
git config --system --add safe.directory /opt/ansible
git config --system --add safe.directory /opt/ansible/.git
```

## 6. Project objects

Built via the API during setup — the scripts in
[`../bootstrap/semaphore/`](../bootstrap/semaphore/) are kept as a record. Equivalent
clicks in the UI:

**Key Store**

| Name | Type | Contents |
|---|---|---|
| `none` | None | — |
| `ansible-ssh` | SSH Key | the private half of `/root/.ssh/id_ed25519_ansible`, login `root` |

**Repositories** — `homelab-ansible`, URL `file:///opt/ansible`, branch `main`, key `none`.

**Inventory** — `production`, type **static YAML**, body = the full contents of
`inventory/hosts.yml` (real addresses; encrypted at rest by Semaphore). SSH key
`ansible-ssh`, become key `none`.

> Static inventory is used because `inventory/hosts.yml` is gitignored and so is not in
> the clone. Because Semaphore then runs the play with its own inventory path, the
> variable files live in **`playbooks/group_vars/`** (adjacent to the playbooks), not
> `inventory/group_vars/`.

**Environment** — `default`, JSON `{}`.

**Task Templates**

| Name | Playbook | CLI args | Schedule |
|---|---|---|---|
| Ping fleet | `playbooks/ping.yml` | — | none |
| Patch - containers (dry run) | `playbooks/patch-guests.yml` | `["--check"]` | none |
| Patch - containers | `playbooks/patch-guests.yml` | — | `0 2 * * 6` (Sat 02:00) |
| Patch - hypervisors | `playbooks/patch-hosts.yml` | — | `0 3 1-7 * 0` (1st Sunday 03:00) |
| Reboot - hypervisors | `playbooks/reboot-hosts.yml` | — | none — **manual only** |

## 7. Alerting

The playbooks POST their own summary to the webhook on every run. For Semaphore-level
alerts (playbook errored before the notify play), enable **Project Settings → Alerts**
or per-template "Alert on failure".

## 8. Collections

There is **no `requirements.yml` at the repo root** on purpose. `community.general` and
`ansible.posix` ship with the Debian `ansible` package; a root `requirements.yml` would
make Semaphore pull newer major versions from Galaxy on every run, and
`community.general` ≥ 12 removed the `yaml` stdout callback the config used to use
(`ansible.cfg` now uses the built-in `default` callback with `result_format = yaml`).
`docs/requirements.reference.yml` is kept for the case of a non-Debian control box.

## 9. Hardening TODO

* Scope `:3000` to the management subnet as part of the Proxmox firewall rollout, or put
  a TLS reverse proxy in front.
* Consider enabling Semaphore's own TOTP 2FA for the admin account.
