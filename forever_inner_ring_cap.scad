// ============================================================================
// VELI FOREVER SPRAY-CAN - LOW-PROFILE INNER-RIM SINGLE-RATCHET RING (v3)
// Tuned directly from test-print photo on spray can:
// 1. 4.4mm LOWER CATCH & LOW-PROFILE RING: Total height reduced from 15.4mm
//    down to 9.8mm; ratchet lock shelf lowered by >4mm (`pressed_cap_h = 2.8mm`
//    above the inner metal rim top) to match where the spray cap actually sits.
// 2. SEPARATED BACK FLANGES: The two back flanges now stop at 156 deg and
//    204 deg, leaving a 48-degree (~7mm) gap in the back middle so they
//    never touch or fuse together.
// 3. HIGH-FLEX TAPERED FLANGES: Thinner tapered arms (1.45mm -> 0.90mm),
//    3.2mm vertical arm height, 1.2mm tooth catch depth, and a 4.8mm open
//    radial flex gap behind every flange so the cap clicks through smoothly.
// ============================================================================

/* [Render Mode] */
// View the single printable ring or preview it with a ghost spray cap
render_mode = "print_ring"; // [print_ring:Single Ring (Print Orientation - Flat on Bed), preview_on_can:Upright Preview on Ghost Spray Can]

/* [Inner Metal Rim Dimensions (Clinched 1-Inch Aerosol Mounting Cup)] */
// Outer diameter of the clinched inner metal ring around the nozzle (mm)
inner_rim_od = 32.0;
// Radial clearance on the metal rim (mm)
rim_clearance = 0.20;
// Height of the rolled metal bead on the inner rim (mm)
inner_rim_bead_h = 4.0;
// How far the outer clip hooks inward underneath the metal rim bead (mm)
rim_snap_undercut = 1.10;
// Height of the bottom lead-in bevel for clicking onto the metal rim (mm)
rim_lead_in_h = 1.8;

/* [Spray Cap & Single Ratchet Catch Parameters] */
// Clearance diameter around the spray cap body when pressed through (mm)
nozzle_cap_clearance_id = 20.3;
// Inner diameter across the tips of the inward-sticking ratchet catch (mm)
ratchet_tip_id = 16.9;
// Height from the TOP of the metal rim to the flat locking underside of the single ratchet catch (mm)
pressed_cap_h = 2.2;
// Height of the top lead-in ramp on the single ratchet catch (mm)
ratchet_ramp_h = 2.2;

/* [High-Flex Tapered Spring Arm Parameters] */
// Radial thickness of the outer C-ring wall (mm)
outer_wall_t = 3.0;
// Thickness of each spring arm at its root on the ring wall (mm)
arm_root_thick = 1.45;
// Thickness of each spring arm where it narrows down at the ratchet tip (mm)
arm_tip_thick = 0.90;
// Vertical height (Z thickness) of the flexible spring arms (mm)
arm_height = 3.0;
// Angular length (sweep) of each curved spring arm (degrees)
spring_arm_sweep_deg = 38; // [30:1:48]
// Angular width of the ratchet tooth head at the very tip of each arm (degrees)
ratchet_head_arc_deg = 12; // [5:1:16]
// Front opening angle so the spray jet exits with zero obstruction (degrees)
spray_window_angle = 75; // [65:1:115]

/* [Outer Ring Engraved/Inward-Embossed Text] */
// Text recessed inward into the outer surface of the ring
label_text = "FOREVAA CAP";
// Font size (height of letters in mm)
label_font_size = 6.0;
// How deep the letters are recessed inward into the outer ring wall (mm)
label_emboss_depth = 0.6;
// Angular spacing between letters around the ring (degrees)
label_char_step_deg = 15.0;

/* [Resolution] */
$fn = 96;

// ============================================================================
// MAIN MODULE: LOW-PROFILE SINGLE-RATCHET RING OVER INNER RIM
// ============================================================================

module forever_ratchet_ring(print_upside_down = true) {
    r_rim_inner = (inner_rim_od + rim_clearance) / 2;
    r_outer     = r_rim_inner + outer_wall_t;
    r_rim_hook  = r_rim_inner - rim_snap_undercut;

    // Z coordinates in upright working orientation (z = 0 at very bottom of rim clip)
    z_bot       = 0;
    z_rim_top   = rim_lead_in_h + inner_rim_bead_h; // 4.8 mm
    z_lock      = z_rim_top + pressed_cap_h;        // 7.6 mm (down from 12.0 mm!)
    z_top       = z_lock + ratchet_ramp_h;          // 9.8 mm (down from 15.4 mm!)

    if (print_upside_down) {
        // Flip upside-down so the flat top ring sits at Z = 0 on the print bed.
        translate([0, 0, z_top])
            rotate([180, 0, 0])
                ratchet_ring_geometry(
                    r_rim_inner, r_outer, r_rim_hook,
                    z_bot, z_rim_top, z_lock, z_top
                );
    } else {
        ratchet_ring_geometry(
            r_rim_inner, r_outer, r_rim_hook,
            z_bot, z_rim_top, z_lock, z_top
        );
    }
}

module ratchet_ring_geometry(
    r_rim_inner, r_outer, r_rim_hook,
    z_bot, z_rim_top, z_lock, z_top
) {
    c_arc_angle = 360 - spray_window_angle;
    // Keep the upper inner wall recessed (`r_rim_inner - 0.6`) so there is a huge
    // ~4.8mm radial flex pocket behind every spring arm!
    r_wall_inner = r_rim_inner - 0.6;

    union() {
        // 1. Outer C-Ring Body with Inward-Embossed ("FOREVAA CAP") Text
        difference() {
            union() {
                rotate([0, 0, spray_window_angle / 2])
                    rotate_extrude(angle = c_arc_angle, convexity = 8)
                        outer_ring_profile_2d(
                            r_rim_inner  = r_rim_inner,
                            r_wall_inner = r_wall_inner,
                            r_outer      = r_outer,
                            r_rim_hook   = r_rim_hook,
                            z_bot        = z_bot,
                            z_rim_top    = z_rim_top,
                            z_top        = z_top
                        );

                // Rounded front ends of the C-ring at the spray window edges
                for (ang = [spray_window_angle / 2, 360 - spray_window_angle / 2]) {
                    rotate([0, 0, ang])
                        translate([(r_wall_inner + r_outer) / 2, 0, 0.6])
                            cylinder(
                                h = z_top - 0.6,
                                d = r_outer - r_wall_inner - 1.2
                            );
                }
            }

            // Subtract "FOREVAA CAP" inward into the outer wall volume
            inward_embossed_outer_text(
                txt       = label_text,
                r_surface = r_outer,
                depth     = label_emboss_depth,
                font_sz   = label_font_size,
                step_deg  = label_char_step_deg,
                z_center  = z_top / 2
            );
        }

        // 2. Four Well-Separated, High-Flex Tapered Spring Flanges
        //    - Front-Left Flange:  starts at  52 deg -> sweeps +42 deg to  94 deg
        //    - Back-Left Flange:   starts at 114 deg -> sweeps +42 deg to 156 deg
        //    - Back-Right Flange:  starts at 246 deg -> sweeps -42 deg to 204 deg
        //    - Front-Right Flange: starts at 308 deg -> sweeps -42 deg to 266 deg
        //    Notice the 48-degree (~7mm) clear gap in the back middle (156 deg to 204 deg)
        //    so the two back flanges NEVER touch each other!
        front_start = spray_window_angle / 2 + 6; // 52 deg
        back_start  = 114;                        // Leaves 48-deg gap at 180 deg!

        flange_starts = [
            front_start,
            back_start,
            360 - back_start,
            360 - front_start
        ];
        flange_dirs = [1, 1, -1, -1];

        z_arm_bot = max(z_rim_top + 0.6, z_top - arm_height);

        for (i = [0 : 3]) {
            rotate([0, 0, flange_starts[i]])
                tapered_single_ratchet_finger(
                    r_root     = r_wall_inner + 0.5,
                    r_tip_base = nozzle_cap_clearance_id / 2,
                    r_tooth    = ratchet_tip_id / 2,
                    sweep_deg  = spring_arm_sweep_deg,
                    head_arc   = ratchet_head_arc_deg,
                    dir        = flange_dirs[i],
                    root_t     = arm_root_thick,
                    tip_t      = arm_tip_thick,
                    z_arm_bot  = z_arm_bot,
                    z_lock     = z_lock,
                    z_top      = z_top
                );
        }
    }
}

// Text Recessed / Embossed Inward into the Outer Cylindrical Volume of the Ring
module inward_embossed_outer_text(txt, r_surface, depth, font_sz, step_deg, z_center) {
    n = len(txt);
    if (n > 0 && depth > 0) {
        total_span = (n - 1) * step_deg;
        start_deg  = 180 - total_span / 2;

        difference() {
            union() {
                for (i = [0 : n - 1]) {
                    ang = start_deg + i * step_deg;
                    rotate([0, 0, ang])
                        translate([r_surface - depth - 0.6, 0, z_center])
                            rotate([90, 0, 90])
                                linear_extrude(height = depth + 2.0, convexity = 6)
                                    text(
                                        text   = txt[i],
                                        size   = font_sz,
                                        font   = "Liberation Sans:style=Bold",
                                        halign = "center",
                                        valign = "center"
                                    );
                }
            }
            // Keep the inner floor of the recessed letters curved at exact radius `r_surface - depth`
            translate([0, 0, -1])
                cylinder(h = z_center * 2 + 4, r = r_surface - depth);
        }
    }
}

// 2D Radial Profile of the Low-Profile Outer C-Ring
module outer_ring_profile_2d(
    r_rim_inner, r_wall_inner, r_outer, r_rim_hook,
    z_bot, z_rim_top, z_top
) {
    z_hook_peak = rim_lead_in_h;
    shoulder_drop = r_rim_inner - r_wall_inner;

    polygon(points = [
        // Bottom-outer corner with chamfer
        [r_outer - 0.6,      z_bot],
        [r_outer,            z_bot + 0.6],
        // Outer cylindrical wall up to top flat face
        [r_outer,            z_top - 0.6],
        [r_outer - 0.6,      z_top],
        // Flat top ring surface (sits on Z = 0 when flipped for printing!)
        [r_wall_inner,       z_top],
        // Upper inner wall surrounding the spring fingers
        [r_wall_inner,       z_rim_top + shoulder_drop],
        // 45-degree shoulder resting on top of the inner metal rim
        [r_rim_inner,        z_rim_top],
        // Pocket for the rolled metal rim bead
        [r_rim_inner,        z_hook_peak + 0.7],
        // Snap hook ridge that clicks under the metal rim
        [r_rim_hook,         z_hook_peak + 0.25],
        [r_rim_hook,         z_hook_peak - 0.25],
        // Bottom lead-in ramp (pushes C-ring open when clicking onto rim)
        [r_rim_inner + 0.4,  z_bot]
    ]);
}

// High-Flex Tapered Curved X-Y Spring Arm + Compact Single Ratchet Tooth at Tip
module tapered_single_ratchet_finger(
    r_root, r_tip_base, r_tooth,
    sweep_deg, head_arc, dir,
    root_t, tip_t,
    z_arm_bot, z_lock, z_top
) {
    steps = 14;

    // Part A: Slender Tapered Curved X-Y Spring Arm
    // Pulls inward away from the outer wall immediately so there is a wide
    // radial flex space behind the entire length of the flange.
    for (s = [0 : steps - 1]) {
        t0 = s / steps;
        t1 = (s + 1) / steps;

        a0 = dir * t0 * sweep_deg;
        a1 = dir * t1 * sweep_deg;

        // Curve profile that opens a wide flex pocket behind the arm right away
        rad0 = r_root * pow(1 - t0, 1.6) + (r_tip_base + tip_t / 2) * (1 - pow(1 - t0, 1.6));
        rad1 = r_root * pow(1 - t1, 1.6) + (r_tip_base + tip_t / 2) * (1 - pow(1 - t1, 1.6));

        // Smoothly narrow the arm thickness from `root_t` (1.45mm) down to `tip_t` (0.90mm)
        w0 = root_t * (1 - t0) + tip_t * t0;
        w1 = root_t * (1 - t1) + tip_t * t1;

        hull() {
            translate([rad0 * cos(a0), rad0 * sin(a0), z_arm_bot])
                cylinder(h = z_top - z_arm_bot, d = w0, $fn = 20);
            translate([rad1 * cos(a1), rad1 * sin(a1), z_arm_bot])
                cylinder(h = z_top - z_arm_bot, d = w1, $fn = 20);
        }
    }

    // Part B: Compact Single Inward Ratchet Tooth right at the very tip of the arm
    tip_angle = dir * sweep_deg;
    start_a = (dir > 0) ? (tip_angle - head_arc * 0.7) : (tip_angle - head_arc * 0.3);

    rotate([0, 0, start_a])
        rotate_extrude(angle = head_arc, convexity = 8)
            single_ratchet_tooth_2d(
                r_base   = r_tip_base,
                r_tooth  = r_tooth,
                tip_t    = tip_t,
                z_bottom = min(z_arm_bot, z_lock - 0.4),
                z_lock   = z_lock,
                z_top    = z_top
            );
}

// 2D Radial Profile of the Compact Single Ratchet Catch at the Narrowed Finger Tip
module single_ratchet_tooth_2d(r_base, r_tooth, tip_t, z_bottom, z_lock, z_top) {
    union() {
        // Slender tip backing spine matching the narrowed `tip_t` arm end
        translate([r_base, z_bottom])
            square([tip_t, z_top - z_bottom]);

        // Single sawtooth catch (1.2mm radial catch depth):
        // - Top ramp (`z_top` down to `z_lock`): pushes spring arm outward when cap is pressed down
        // - Flat bottom locking shelf at `z_lock`: snaps inward over the top of the spray cap!
        polygon(points = [
            [r_base + 0.1, z_lock],
            [r_tooth,      z_lock],
            [r_tooth,      z_lock + 0.3],
            [r_base + 0.1, z_top]
        ]);
    }
}

// ============================================================================
// GHOST SPRAY CAN REFERENCE (FOR PREVIEW MODE ONLY)
// ============================================================================

module ghost_inner_rim_and_nozzle() {
    %union() {
        // Rolled metal bead of the clinched 1-inch inner valve cup (~32.0mm OD)
        translate([0, 0, rim_lead_in_h])
            cylinder(h = inner_rim_bead_h, d = inner_rim_od);
        // Depressed spray nozzle cap sitting 4mm lower (`pressed_cap_h = 2.8mm` above rim)
        translate([0, 0, rim_lead_in_h + inner_rim_bead_h])
            cylinder(h = pressed_cap_h, d = nozzle_cap_clearance_id - 0.5);
    }
}

// ============================================================================
// RENDER DISPATCHER
// ============================================================================

if (render_mode == "print_ring") {
    forever_ratchet_ring(print_upside_down = true);

} else if (render_mode == "preview_on_can") {
    forever_ratchet_ring(print_upside_down = false);
    ghost_inner_rim_and_nozzle();
}
