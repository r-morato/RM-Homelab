# Pi-hole

## Overview

Pi-hole is a Linux network-level advertisement and Internet tracker blocking application. It acts as a DNS sinkhole, protecting all devices on the network.

## Type

* Network-wide Ad Blocker
* DNS Server

## Role in the Homelab

* **Ad Blocking:** Filters out advertisements and trackers for all devices configured to use it as their DNS server, enhancing privacy and Browse experience.
* **DNS Caching:** Caches DNS queries, which can lead to faster resolution times for frequently accessed domains.
* **Network Insight:** Provides detailed statistics and logs of DNS queries and blocked domains through its web interface.

## Hosting

Pi-hole runs as a service within the homelab environment, typically deployed as an LXC on Proxmox or as a Docker container.
