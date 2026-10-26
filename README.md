# FOREVAA CAP

**A 1-piece 3D-printable one-way ratchet ring for standard aerosol spray cans.**  
Click it onto the inner metal rim, push the spray cap down once, and it locks in place—spraying forever until the can is completely empty.

![FOREVAA CAP Prototype on Spray Can](docs/forevaa_cap_prototype.png)

---

## Concept & Credits

- **Invention & Concept:** [**Veli Silver**](https://www.instagram.com/veli_silver/)
- **Co-Prompting & Rapid Prototyping:** [**Veli Silver**](https://www.instagram.com/veli_silver/) & [**dusjagr** (Marc R. Dusseiller)](https://www.dusseiller.ch/), vibe-coded into parametric OpenSCAD with Gemini during an iterative test-printing session.

### Background: Veli Silver × dusjagr

The paths of [**Veli Silver**](https://www.instagram.com/veli_silver/) (artist working across graffiti, spatial interventions, action painting, and subversive urban objects between Zürich and Ljubljana) and [**dusjagr**](https://www.hackteria.org/wiki/Dusjagr) (transdisciplinary artist, researcher, hardware hacker, and co-founder of the [**Hackteria**](https://www.hackteria.org/) network and [**SGMK**](https://www.mechatronicart.ch/)) have crossed repeatedly across independent art, hacker, and DIWO (*Do-It-With-Others*) scenes from Europe to Southeast Asia:

- **Zürich ([Zentralwäscherei](https://zentralwaescherei.space/) / [Bitwäscherei](https://www.bitwaescherei.ch/)):** Overlapping in Zürich's self-organized cultural and hackerspace ecosystem around the *Alte Zentralwäscherei*—home to the [**Bitwäscherei**](https://www.bitwaescherei.ch/) collective and the [**Hackteria ZET – Open Science Lab**](https://www.hackteria.org/wiki/Hackteria_ZET_%E2%80%93_Open_Science_Lab_in_Z%C3%BCrich).
- **Ljubljana ([Kersnikova](https://kersnikova.org/) / [MobileLabs](https://www.hackteria.org/wiki/MobileLabs_Hackathon)):** Shared roots and long-standing connections in Ljubljana's alternative art, squat, and open laboratory scene.
- **Chiang Mai, Thailand ([*LLL CoLaboratory / CNX OpenLab*](https://www.hackteria.org/wiki/LLL_CoLaboratory)):** Crossing paths at the [**Laab Lu Lao (LLL) CoLaboratory**](https://www.hackteria.org/wiki/LLL_CoLaboratory) / *CNX OpenLab* in Chiang Mai's old town—an open laboratory gathering bringing together street interventions, DIY electronics, bio-art, and experimental fieldwork.

Out of these intersections came a deceptively simple question: *What is the minimal 3D-printed piece of plastic needed to turn any standard rattlecan into an unstoppable, autonomous "spray-forever" performance object?*

---

## How the FOREVAA CAP Works

Instead of complicated screws, moving parts, or tall fragile bridges, the final design ([`forever_inner_ring_cap.scad`](forever_inner_ring_cap.scad)) reduces the entire mechanism to a **single, low-profile open C-ring** (`10.2 mm` tall, ~10-minute print):

| 1. Standby Mode (`preview_standby`) | 2. Locked "FOREVAA" Mode (`preview_on_can`) |
| :---: | :---: |
| ![Standby Mode on Spray Can](docs/docs_render_standby.png) | ![Locked Forever Mode on Spray Can](docs/docs_render_locked.png) |
| *Ring clicked onto the 32 mm inner valve cup rim; spray cap lower rim sits above the 4 ratchet arms (safe to attach).* | *Spray cap pushed down once past the 4 spring arms—lower rim is trapped forever while the tall center nozzle sprays clear of the ring.* |

1. **Snap onto the Inner Metal Rim (`32.0 mm` Valve Cup):**  
   The outer C-collar clicks underneath the standard 1-inch (`~32.0 mm` clinched OD) rolled metal valve mounting cup around the nozzle. Because the front `75°` is open as a spray window, the C-ring flexes horizontally in the `X-Y` plane when snapping on—aligning all stress *along* the continuous 3D-printed filament perimeters so it never delaminates across layers.
2. **Standby Mode (Safe to Attach):**  
   Before triggering, the spray nozzle cap sticks up through the center of the ring above the inward-pointing spring flanges. You can clip the ring onto the can without accidentally spraying yourself.
3. **One-Way "Click" Forever Lock:**  
   Four tapered, curved `X-Y` spring flanges sweep inward from the ring wall with a single sawtooth ratchet catch (`pressed_cap_h = 2.2 mm` above the metal rim). When you press the spray nozzle cap down through the ring:
   - The cap's lower shoulder rim slides down the sloped top ramps, flexing the 4 spring arms outward in the `X-Y` plane.
   - As soon as the lower rim of the spray cap drops past the catch, all 4 arms **snap inward over the lower shoulder**, trapping it permanently in the depressed position while the tall central nozzle cylinder rises through the center.

![Print Orientation Render](docs/docs_render_ring.png)

---

## Repository Structure

| Path | Description |
| :--- | :--- |
| **[`forever_inner_ring_cap.scad`](forever_inner_ring_cap.scad)** | **Main "FOREVAA CAP" OpenSCAD Model:** 1-piece inner-rim C-ring with 4 tapered `X-Y` spring flanges, single ratchet catch, inward-embossed `"FOREVAA CAP"` text, and 3D spray can/cap preview (`render_mode`). |
| **[`forever_inner_ring_cap.stl`](forever_inner_ring_cap.stl)** | Ready-to-print STL exported with the tuned `"perfect"` preset. |
| **[`forever_inner_ring_cap.json`](forever_inner_ring_cap.json)** | OpenSCAD Customizer preset (`"perfect"`). |
| **[`docs/`](docs/)** | Documentation photos and OpenSCAD 3D renders (`forevaa_cap_prototype.png`, `docs_render_standby.png`, `docs_render_locked.png`, `docs_render_ring.png`). |
| **[`prototypes/`](prototypes/)** | Archived early iterations (3-legged screw bridge & one-way ratchet plunger prototypes). |

---

## 3D Printing Instructions

- **Orientation:** The model defaults to `render_mode = "print_ring"`, which places the flat top face of the ring directly on the build plate (`Z = 0`). **No supports or brim required.**
- **Material:** **PETG**, **ASA**, or **PLA+ / Tough PLA** (for snappy spring-arm recovery).
- **Slicer Settings:**
  - **Layer height:** `0.15 mm` or `0.20 mm`
  - **Perimeters / Walls:** `3–4` perimeters (so the tapered `1.45 mm → 0.90 mm` spring arms print as solid continuous filament loops)
  - **Infill:** `25–40%`

---

## Tuned Default Parameters (`"perfect"` Preset)

All parameters can be customized in OpenSCAD via the **Customizer** panel:

- `inner_rim_od = 32.0` mm *(standard clinched 1-inch aerosol valve cup)*
- `inner_rim_bead_h = 4.0` mm
- `nozzle_cap_clearance_id = 20.3` mm
- `ratchet_tip_id = 16.9` mm
- `pressed_cap_h = 2.2` mm
- `ratchet_ramp_h = 2.2` mm
- `outer_wall_t = 3.0` mm
- `arm_root_thick = 1.45` mm → `arm_tip_thick = 0.90` mm (`arm_height = 3.0` mm)
- `spring_arm_sweep_deg = 38`°, `ratchet_head_arc_deg = 12`°
- `spray_window_angle = 75`°
- `label_text = "FOREVAA CAP"` (`label_font_size = 6.0`, `label_emboss_depth = 0.6`, `label_char_step_deg = 15.0`)

---

## Links & Network

- **Veli Silver:** [@veli_silver](https://www.instagram.com/veli_silver/)
- **dusjagr (Marc R. Dusseiller):** [dusseiller.ch](https://www.dusseiller.ch/) · [Hackteria Wiki: Dusjagr](https://www.hackteria.org/wiki/Dusjagr)
- **Hackteria (Open Source Biological Art):** [hackteria.org](https://www.hackteria.org/)
- **LLL CoLaboratory (Chiang Mai):** [hackteria.org/wiki/LLL_CoLaboratory](https://www.hackteria.org/wiki/LLL_CoLaboratory)
- **Hackteria ZET (Zürich):** [Hackteria ZET – Open Science Lab in Zürich](https://www.hackteria.org/wiki/Hackteria_ZET_%E2%80%93_Open_Science_Lab_in_Z%C3%BCrich)
- **Bitwäscherei & Zentralwäscherei (Zürich):** [bitwaescherei.ch](https://www.bitwaescherei.ch/) · [zentralwaescherei.space](https://zentralwaescherei.space/)
- **SGMK (Swiss Mechatronic Art Society):** [mechatronicart.ch](https://www.mechatronicart.ch/)

---

## License

Open-source hardware / artistic intervention tool — share, remix, and spray responsibly.

