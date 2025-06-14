# Raspberry Pi 4 (Home Assistant)

## Overview

A Raspberry Pi 4 serves as the dedicated host for Home Assistant OS, acting as the central hub for home automation within the homelab.

## Specifications

* **Model:** Raspberry Pi 4 (Specific RAM variant not specified, e.g., 4GB or 8GB).
* **Operating System:** Home Assistant OS (bare-metal installation).
* **Power:** Powered via the 6-Port USB Charger.

## Role in the Homelab

* **Home Automation Hub:** Manages and automates various smart home devices and services.
* **Zigbee Coordinator:** Connects to Zigbee devices via a USB dongle.
* **Integration Point:** Acts as a central point for integrating diverse smart home platforms and devices.

## Key Integrations & Connected Devices (as seen in configuration)

The Home Assistant instance on this Raspberry Pi manages a variety of smart home integrations, including:

* **Zigbee Devices:** Connected via a Sonoff Zigbee 3.0 USB Dongle Plus.
* **Eero Router:** For network presence and potentially status monitoring.
* **Hive Heating System:** Integration for managing home heating.
* **Ecovacs:** For robotic vacuum cleaner control.
* **Octopus Energy:** For energy consumption monitoring.
* **Ring:** For security camera and doorbell integration.
* **LG webOS Smart TV:** For TV control and media integration.
* **Spotify:** For media playback control.
* **Tuya:** For smart devices using the Tuya platform.
* **Mobile App:** Connectivity with Home Assistant mobile applications (iPad and iPhone).
* **Other Home Assistant Core Integrations:** Includes default integrations like `sun`, `shopping_list`, `met` (weather), `upnp`, `cast`, and system services like `hassio` (Supervisor) and `backup`.

## Mounting

This Raspberry Pi is housed in a custom 3D printed 10-inch rack mount, ensuring a tidy and secure installation within the homelab rack. (Refer to [Raspberry Pi 10-inch Rack Mount](3d_prints/README.md) for details).
