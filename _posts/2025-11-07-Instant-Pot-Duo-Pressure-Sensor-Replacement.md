---
layout: post
title: "Instant Pot Duo Pressure Sensor Replacement and Calibration"
date: 2025-11-07
tags: [Instant Pot, Repair, Pressure Cooker, DIY, Calibration, Safety]
---

Replacing and calibrating the **high-pressure sensor** on an Instant Pot Duo can restore full pressure operation when the unit throws C6 errors or fails to maintain cooking pressure.  
This guide covers **diagnosis, part selection, disassembly, calibration**, and safety considerations — formatted for technical DIY users.

---

## 🧭 1. Overview

Instant Pot Duo models (6 Qt, 8 Qt, Duo 60, Duo 80, Duo V2, etc.) use **two separate internal sensors**:

| Sensor | Function | Typical Marking | Location |
|---------|-----------|-----------------|-----------|
| **High-Pressure Sensor** | Controls cooking pressure (≈ 10–12 psi). Sends feedback to control board. | KSD105, KSD105A, YCD3005, YCD3008 | Centered under inner pot, small disk with 2 wires |
| **Thermal / Overheat Cutoff** | Shuts down at over-temperature (> 115 °C). | KSD301 | Off to the side of heater ring |

If the cooker fails to pressurize, vents steam early, or displays **C6L / C6H**, the **pressure sensor** may be faulty or mis-calibrated.

---

## 🔧 2. Identifying the High-Pressure Sensor

Below is a labeled view of the **Instant Pot Duo base (upside-down)** with the bottom cover removed:

![Instant Pot Duo High-Pressure Sensor](/assets/images/instant-pot-duo-pressure-sensor.png)

> **High-Pressure Sensor (KSD105)** — small round metal puck mounted near the center with two insulated wires (often white or blue).  
>  
> **Thermal Safety Switch (KSD301)** — slightly larger disk near the heater edge, heavier wiring.

You can use this image in your repo by placing the file  
`instant-pot-duo-pressure-sensor.png` in your `/assets/images/` folder.

---

## 🧰 3. Tools & Parts Required

**Tools**
- Phillips & Torx (TT15) screwdrivers  
- Multimeter (for continuity)  
- Insulated gloves  
- Clean, non-metal surface for disassembly  

**Replacement Sensors**
- Genuine Instant Pot sensor — [eBay OEM Part](https://www.ebay.com/itm/393638207076) (~$11)  
- ZoneFly replacement — [Grill Parts America](https://www.grillpartsamerica.com/products/zonefly-original-pressure-sensor-for-instant-pot-pressure-sensor-or-switch-for-power-cooker-cuisinart-farberware-power-quick-pot-crock-pot-electric-pressure-cooker-pressure-sensor-or-switch) (~$28)  
- Universal KSD105A / YCD3005 sensors — [Walmart listing](https://www.walmart.com/ip/4-Pcs-Pressure-Cooker-Sensor-Switch-Replacement-KSD105-KSD105A-YCD3005-YCD3008-Instant-Pot-Duo-Power-Cooker-Cuisinart-Power-Quick-Pot-Farberware-Croc/5156031369)  

---

## ⚙️ 4. Replacement Procedure

1. **Unplug** the unit and allow it to cool completely.  
2. Remove lid and inner pot. Turn cooker upside down.  
3. **Remove bottom cover** (Torx or Phillips screws).  
4. Disconnect wiring harness carefully from the control board.  
5. Identify the **center sensor** (high pressure).  
6. Unscrew and remove the old sensor; note its wire orientation.  
7. Mount and reconnect the **new sensor**.  
8. Reassemble the base and test with a “water test” (3 cups water, 5 min high pressure).

---

## 🔩 5. Calibration Adjustment

If the pot builds too little or too much pressure after replacement:

1. Locate the **small screw** on top of the sensor (may have silicone or epoxy).  
2. Adjust in **¼-turn increments** while unplugged:
   - **Clockwise → decreases** pressure (earlier cutoff).  
   - **Counterclockwise → increases** pressure (later cutoff).  
3. Repeat the water test until pressure and timing feel correct.  
4. Once satisfied, seal the screw with a dab of heat-resistant silicone.

---

## 🧪 6. Verification & Safety

Perform at least two dry water tests before cooking food.

| Test | Result | Action |
|------|---------|--------|
| Steam vents early | Over-pressure; turn screw clockwise |
| Float valve never rises | Under-pressure; turn screw counter-clockwise |
| Strong quick release, normal timer countdown | ✅ Calibration good |

> ⚠️ **Warning:** Mis-calibrated sensors can lead to over-pressure and lid safety lock failure. Only small adjustments should be made.

---

## 📋 7. Maintenance Notes

- Replace the **silicone sealing ring** yearly.  
- Check float valve and venting assembly for mineral buildup.  
- Log repair date and part number (recommended for service tracking).  
- Keep photos of wiring orientation for reference.

---

## ✅ 8. Summary

| Step | Task | Notes |
|------|------|-------|
| 1 | Confirm issue via C6 code or test | Check sealing ring first |
| 2 | Identify high-pressure sensor | Center disk with two wires |
| 3 | Replace sensor | Use KSD105/KSD105A type |
| 4 | Calibrate screw | ¼-turn increments |
| 5 | Verify with water test | Steam behavior confirms fix |

---

**References:**  
- [iFixit Pressure Sensor Replacement Guide](https://www.ifixit.com/Guide/Instant+Pot+60+EPC+Pressure+Sensor+Replacement/179057)  
- [Instant Pot DUO80 V2 Troubleshooting Wiki](https://www.ifixit.com/Wiki/Instant_Pot_IP-DUO80_V2_Troubleshooting)  
- [C6 Error Calibration Guide](https://www.ifixit.com/Guide/How+to+Fix+the+C6+Error+for+an+Instant+Pot+DUO80/177018)

---

**File:** `2025-11-07-Instant-Pot-Duo-Pressure-Sensor-Replacement.md`  
**Image:** `assets/images/instant-pot-duo-pressure-sensor.png`  
**Author:** Preston Powell  
**License:** CC BY-SA 4.0  
