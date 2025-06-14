# VS Code Server

## Overview

VS Code Server is a backend service that allows you to run Visual Studio Code remotely on a server and access it through a web browser.

## Type

* Remote Development Environment
* Cloud-based IDE

## Role in the Homelab

* **Web-based Development:** Provides a powerful, browser-accessible VS Code instance for development and script editing directly on the homelab's server.
* **Centralized Codebase:** Allows for managing and editing configuration files, automation scripts (e.g., Ansible, Terraform), and other code related to the homelab without needing a local VS Code installation connected via SSH.
* **Resource Efficiency:** Leverages the server's resources for demanding tasks, potentially freeing up local machine resources.

## Hosting

VS Code Server runs as a service within the homelab, likely as a Docker container or an LXC on Proxmox, accessible via a web browser.
