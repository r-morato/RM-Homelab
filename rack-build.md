# Rack Build Components

This section outlines the custom-built enclosure and mounting setup that forms the physical foundation of my homelab.

Originally, I had planned to buy the **GeekPi 8U Rack**, but it wasn’t available locally. Rather than overpay for shipping or compromise, I decided to build my own version — with a focus on modularity, affordability, and clean design.

<img width="300" alt="image" src="https://github.com/user-attachments/assets/c838a7d2-b6ab-43d4-aebb-ba36a7a60ff8" />

---

## Initial 3D Renders

These early mockups helped plan the layout and dimensions before committing to cutting and drilling.

<img width="616" alt="image" src="https://github.com/user-attachments/assets/f481e324-415e-4707-a65e-6ea06317e182" />
<img width="550" alt="image" src="https://github.com/user-attachments/assets/2379e38c-b208-4b4e-971b-3876f66c33f2" />

---

## Build Progress

Here’s how things came together during the build process:

<img width="418" alt="image" src="https://github.com/user-attachments/assets/e6fa72c9-3254-439b-ac3b-530a314c1241" />
<img width="426" alt="image" src="https://github.com/user-attachments/assets/5e81913e-e11e-4161-b8c8-94687ab118e5" />
<img width="466" alt="image" src="https://github.com/user-attachments/assets/f93d114e-7681-438f-84ee-db0ac5e2156b" />
<img width="460" alt="image" src="https://github.com/user-attachments/assets/19988fa2-2e88-4998-9a24-4950a8a08b20" />
<img width="356" alt="image" src="https://github.com/user-attachments/assets/7f82542f-f7e4-44d9-9e92-540f3b61dbbc" />
<img width="384" alt="image" src="https://github.com/user-attachments/assets/ae049537-af08-4b88-b6a7-9d310f2d8af9" />

---

## Rack Frame & Enclosure Materials

Everything is based on a modular aluminum profile system, with side panels and internal mounts added using a mix of off-the-shelf and custom components.

### Structural Frame

- **Extruded Aluminum Profiles (20x20mm)**  
  The core of the frame — lightweight, strong, and modular. 
  [ebay](https://www.ebay.co.uk/itm/305826763149?var=604998211152)  
 
  
- **Corner Connectors**  
  For rigid 90° joints between profiles.  
  [Amazon UK Link](https://www.amazon.co.uk/dp/B0CPL6DDYH?ref=ppx_yo2ov_dt_b_fed_asin_title)  
  

- **M5 T-Slot Bolts & Nuts**  
  Used throughout for adjustable, tool-free component mounting.  
  [Amazon UK Link](https://www.amazon.co.uk/dp/B0CDBY3PHR?ref=ppx_yo2ov_dt_b_fed_asin_title)  


### Panels & Seals

- **Acrylic Side Panels (Clear, Custom Cut)**
  Keeps the rack enclosed but visible for aesthetics and protection.  
  [plasticsheets.com](https://www.plasticsheets.com/clear-acrylic-sheet-cut-to-size/)  


- **Flat Seal Panel Holders**
  Slotted into aluminum rails to hold acrylic securely and help reduce dust ingress.  
  [AliExpress](https://www.aliexpress.com/item/1005003222704634.html?spm=a2g0o.order_list.order_list_main.25.270b1802RzCqnd)


### Mobility & Handling

- **Top-Mounted Aluminum Handles**
  Makes it easy to move the rack when needed.  
  [AliExpress](https://www.aliexpress.com/item/1005006105161997.html?spm=a2g0o.order_list.order_list_main.15.270b1802RzCqnd)


- **1” Low-Profile Caster Wheels**
  For smooth repositioning on floors — no heavy lifting required.  
  [AliExpress](https://www.aliexpress.com/item/1005007219086138.html?spm=a2g0o.order_list.order_list_main.5.270b1802RzCqnd)  
---

## Rack Mounting Components

While it's a 10-inch rack footprint, many mounts are custom-made or adapted to fit non-standard devices.

- **10” Rack Ears**
  Standard rack brackets used in combination with custom prints. They required to be perforated to properly fit into the aluminium profiles.
  [Amazon UK Link](https://www.amazon.co.uk/dp/B00LFSC3K6?ref=ppx_yo2ov_dt_b_fed_asin_title)  


- **Perforated Aluminum Sheets**
  3mm thick, 10mm holes. Used to create shelves, blanks, or airflow panels.
  [ebay](https://www.ebay.co.uk/itm/305840202662?var=605028245526)

---

## Power Distribution

Internal power is handled by compact 10” PDUs designed for SOHO setups.

- **4-Way 10” Horizontal PDU (UK Sockets)**
  Simple and compact, ideal for powering basic gear.  
  [ebay](https://www.ebay.co.uk/itm/163710047824)

- **10” SOHO PDU with IEC Input (UPS-Ready)**
  Designed to connect directly to a UPS. Features 3x UK sockets and a detachable cable.  
  [ebay](https://www.ebay.co.uk/itm/186307877455)

- **12V＋5V HDD POWER SUPPLY AC 2A FOR HARD DRIVE MOLEX**
  This is to provide 12v+5v to the disk enclosure  
  [ebay](https://www.ebay.co.uk/itm/186307877455)


---

## Patching and cable management

- **GeekPi RackMate Patch Panel**   
  [Amazon UK Link](https://amzn.eu/d/7NtIrBL)

- **DIGITUS Cable Entry Panel**  
  [Amazon UK Link](https://amzn.eu/d/53MpwSx)

- **Digitus cable management panel - 10-inch - 1U**  
  [Amazon UK Link](https://amzn.eu/d/9G6zwlS)
  
- **DIGITUS shelf - 1U - 10-inch**  
  This tray is what I use as a mount for my mac mini  
  [Amazon UK Link](https://amzn.eu/d/fQygdA7)


---

## 3D Printed Mounts

A key part of the build — these mounts allow non-rack devices to fit securely and efficiently.

All files and links are documented in the [Custom 3D Prints](../3d_prints/README.md) section.

- **Raspberry Pi 3B/4B/5B Rack Mount**  
  [Printables.com](https://www.printables.com/model/1185545-raspberry-pi-3b4b5b-10-inch-rack-mount/files)

- **TP-Link TL-SG108 Switch Mount**  
  [Printables.com](https://www.printables.com/model/967188-sturdy-10-inch-rack-mount-for-the-tl-sg108-consume/files)

- **5.25" Drive Adapter Mount**  
  [Thingiverse](https://www.thingiverse.com/thing:6859441)

- **ThinkCentre M720q/M920q Mount**  
  [Printables.com](https://www.printables.com/model/1040412-lenovo-thinkcentre-tiny-m720qm715qm920q-10-rack-mo)

- **eInk Display Mount**  
  Custom-designed to match the screen dimensions. Not publicly uploaded (yet), but might share it later.

---

## Summary

This rack was built to be practical, minimal, and tailored to my needs — not just a clone of something from Amazon. Using a mix of aluminum framing, custom-cut panels, and 3D prints, I was able to keep the size down while still allowing for proper rack-mounting and cable management.

Everything is modular and easy to adapt. Whether I’m swapping hardware, expanding storage, or moving the setup to a new room, the enclosure keeps up without needing a full rebuild.
