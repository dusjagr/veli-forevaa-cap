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
// View the single printable ring or preview it on a 3D spray can model
render_mode = "print_ring"; // [print_ring:Single Ring (Print Orientation - Flat on Bed), preview_on_can:Locked on Spray Can (Spraying Forever!), preview_standby:Standby on Spray Can (Before Pressing Cap)]

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
pressed_cap_h = 0.6; // [0.0:0.1:2.5]
// Height of the top lead-in ramp on the single ratchet catch (mm)
ratchet_ramp_h = 2.2;

/* [High-Flex Tapered Spring Arm Parameters] */
// Radial thickness of the outer C-ring wall (mm)
outer_wall_t = 3.0;
// Thickness of each spring arm at its root on the ring wall (mm)
arm_root_thick = 1.45;
// Thickness of each spring arm where it narrows down at the ratchet tip (mm)
arm_tip_thick = 0.90;
// Vertical thickness of the spring arms at the root on the wall (mm)
arm_height = 2.0;
// Angular length (sweep) of each curved spring arm (degrees)
spring_arm_sweep_deg = 38; // [30:1:48]
// Angular width of the ratchet tooth head at the very tip of each arm (degrees)
ratchet_head_arc_deg = 12; // [5:1:16]
// Inward draft angle of the spring arms toward the center as they descend (degrees)
arm_inward_angle_deg = 4.0; // [0.0:0.5:10.0]
// Vertical slope / rise angle on the underside of the arms (mm height difference from root to tip)
arm_downward_drop = 1.0; // [0.0:0.1:2.5]
// Positive undercut hook angle on the locking shelf to bite and trap the cap (degrees)
tooth_hook_angle_deg = 5.0; // [0.0:1.0:10.0]
// Front opening angle so the spray jet exits with zero obstruction (degrees)
spray_window_angle = 75; // [65:1:115]

/* [Outer Ring Engraved/Inward-Embossed Text] */
// Text recessed inward into the outer surface of the ring
label_text = "FOREVAA CAP";
// Font size (height of letters in mm)
label_font_size = 5.0;
// How deep the letters are recessed inward into the outer ring wall (mm)
label_emboss_depth = 0.5;
// Angular spacing between letters around the ring (degrees)
label_char_step_deg = 13.0;

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
    z_rim_top   = rim_lead_in_h + inner_rim_bead_h; // 5.8 mm
    z_lock      = z_rim_top + pressed_cap_h;        // 6.4 mm
    // Total ring height: flat print-bed side stays 100% planar at z_top for effortless printing!
    z_top       = z_lock + ratchet_ramp_h;          // ~8.6 mm (completely flat on print bed!)

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

        // The underside starts at `z_top - arm_height` at the root and angles downward towards the tip
        z_arm_bot = z_top - arm_height;

        for (i = [0 : 3]) {
            rotate([0, 0, flange_starts[i]])
                tapered_single_ratchet_finger(
                    r_root        = r_wall_inner + 0.5,
                    r_tip_base    = nozzle_cap_clearance_id / 2,
                    r_tooth       = ratchet_tip_id / 2,
                    sweep_deg     = spring_arm_sweep_deg,
                    head_arc      = ratchet_head_arc_deg,
                    dir           = flange_dirs[i],
                    root_t        = arm_root_thick,
                    tip_t         = arm_tip_thick,
                    z_arm_bot     = z_arm_bot,
                    z_lock        = z_lock,
                    z_top         = z_top,
                    inward_angle  = arm_inward_angle_deg,
                    downward_drop = arm_downward_drop,
                    hook_angle    = tooth_hook_angle_deg
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
    z_arm_bot, z_lock, z_top,
    inward_angle  = 4.0,
    downward_drop = 1.0,
    hook_angle    = 5.0
) {
    steps  = 14;
    arm_h  = max(0.1, z_top - z_arm_bot);
    max_dr = (arm_h + downward_drop) * tan(inward_angle);

    // Part A: Slender Tapered Curved Spring Arm
    // - The print-bed side stays 100% FLAT at z_top for effortless printing!
    // - The OTHER side (underside facing into the spray can) angles DOWNWARDS!
    for (s = [0 : steps - 1]) {
        t0 = s / steps;
        t1 = (s + 1) / steps;

        a0 = dir * t0 * sweep_deg;
        a1 = dir * t1 * sweep_deg;

        // Print-bed side stays 100% planar and flat on z_top
        z0_top = z_top;
        z1_top = z_top;

        // Underside angles downwards from root (t=0) down towards the rim at the tip (t=1)
        z0_bot = z_arm_bot - downward_drop * t0;
        z1_bot = z_arm_bot - downward_drop * t1;

        // Base curve profile at flat top
        rad0_top = r_root * pow(1 - t0, 1.6) + (r_tip_base + tip_t / 2) * (1 - pow(1 - t0, 1.6));
        rad1_top = r_root * pow(1 - t1, 1.6) + (r_tip_base + tip_t / 2) * (1 - pow(1 - t1, 1.6));

        // Inward conical tilt on the underside increases towards the tip
        rad0_bot = rad0_top - max_dr * t0;
        rad1_bot = rad1_top - max_dr * t1;

        // Smoothly narrow the arm thickness from `root_t` down to `tip_t`
        w0 = root_t * (1 - t0) + tip_t * t0;
        w1 = root_t * (1 - t1) + tip_t * t1;

        hull() {
            translate([rad0_top * cos(a0), rad0_top * sin(a0), z0_top - 0.05])
                cylinder(h = 0.1, d = w0, center = true, $fn = 20);
            translate([rad0_bot * cos(a0), rad0_bot * sin(a0), z0_bot + 0.05])
                cylinder(h = 0.1, d = w0, center = true, $fn = 20);
            translate([rad1_top * cos(a1), rad1_top * sin(a1), z1_top - 0.05])
                cylinder(h = 0.1, d = w1, center = true, $fn = 20);
            translate([rad1_bot * cos(a1), rad1_bot * sin(a1), z1_bot + 0.05])
                cylinder(h = 0.1, d = w1, center = true, $fn = 20);
        }
    }

    // Part B: Compact Single Inward Ratchet Tooth at the arm tip
    // Flat on top (z_top), while underside reaches deep down into the mounting cup
    tip_angle = dir * sweep_deg;
    start_a   = (dir > 0) ? (tip_angle - head_arc * 0.7) : (tip_angle - head_arc * 0.3);

    z_tip_top = z_top;
    z_tip_bot = z_arm_bot - downward_drop;

    rotate([0, 0, start_a])
        rotate_extrude(angle = head_arc, convexity = 8)
            single_ratchet_tooth_2d(
                r_base     = r_tip_base,
                r_tooth    = r_tooth,
                tip_t      = tip_t,
                z_bottom   = z_tip_bot,
                z_lock     = z_lock,
                z_top      = z_tip_top,
                inward_dr  = max_dr,
                hook_angle = hook_angle
            );
}

// 2D Radial Profile of the Ratchet Catch with Inward Cant & Undercut Hook Angle
module single_ratchet_tooth_2d(
    r_base, r_tooth, tip_t, z_bottom, z_lock, z_top,
    inward_dr = 0.2, hook_angle = 5.0
) {
    h_total    = max(0.1, z_top - z_bottom);
    ratio_lock = (z_top - z_lock) / h_total;

    r_base_top = r_base;
    r_base_bot = r_base - inward_dr;

    shelf_r_base = r_base - inward_dr * ratio_lock;
    shelf_r_tip  = r_tooth - inward_dr;

    // Positive hook angle: inner tip rises slightly above `z_lock` to firmly trap the cap rim
    z_hook_tip = z_lock + (shelf_r_base - shelf_r_tip) * tan(hook_angle);

    union() {
        // Tapered backing spine matching the arm's inward tilt
        polygon(points = [
            [r_base_bot,         z_bottom],
            [r_base_bot + tip_t, z_bottom],
            [r_base_top + tip_t, z_top],
            [r_base_top,         z_top]
        ]);

        // Single sawtooth catch with positive undercut hook angle:
        // - Top ramp: pushes spring arm outward when cap is pressed down
        // - Inward-angled bottom locking shelf: snaps over cap and bites inward when pressed!
        polygon(points = [
            [shelf_r_base + 0.1, z_lock],
            [shelf_r_tip,        z_hook_tip],
            [shelf_r_tip,        z_hook_tip + 0.3],
            [shelf_r_base + 0.1, z_top]
        ]);
    }
}

// ============================================================================
// DETAILED 3D MODEL OF SPRAY CAN, 1-INCH VALVE CUP & SPRAY CAP (FOR PREVIEW)
// ============================================================================

module spray_can_and_cap_3d(pressed = true) {
    z_rim_top = rim_lead_in_h + inner_rim_bead_h;
    // The 4 inward ratchet teeth grab the LOWER RIM SHOULDER of the spray cap!
    // - When pressed = true: lower rim shoulder sits at `z_rim_top + pressed_cap_h - 0.1`
    //   (trapped underneath the 4 inward ratchet teeth!).
    // - When pressed = false (standby): lower rim shoulder sits 3.0mm higher (above the teeth).
    lower_rim_top_z = z_rim_top + (pressed ? (pressed_cap_h - 0.1) : (pressed_cap_h + 2.9));
    lower_rim_od    = nozzle_cap_clearance_id - 0.8; // ~19.5 mm lower flange (held by ratchet)
    
    // Tall central cylinder rising up through the center between the 4 ratchet teeth
    center_cyl_od   = ratchet_tip_id - 1.6;          // ~15.3 mm (clears the 16.9mm ratchet tips!)
    center_cyl_h    = 7.8;                           // Rises high so the nozzle jet clears the ring
    cap_top_z       = lower_rim_top_z + center_cyl_h;
    cap_bot_z       = lower_rim_top_z - 5.5;

    // 1. High-Contrast Aerosol Can Body (Deep Slate + Hot-Pink Color Donut + Bright Silver Dome)
    color("#14181f")
        translate([0, 0, -58])
            cylinder(h = 38, d = 65.0);

    // Hot-pink spray-paint color indicator band below the outer chime
    color("#ff1e8a")
        translate([0, 0, -20.5])
            cylinder(h = 2.6, d = 65.1);

    // Bright polished silver outer chime rim (65.5 mm OD)
    color("#e4e9ef") {
        translate([0, 0, -18])
            rotate_extrude()
                translate([32.75 - 1.6, 0, 0])
                    circle(r = 1.6, $fn = 24);
        translate([0, 0, -18])
            difference() {
                cylinder(h = 1.6, d = 64.5);
                translate([0, 0, 0.4])
                    cylinder(h = 1.5, d = 59.0);
            }
    }

    // Brushed steel dome rising from outer rim to the 1-inch valve cup
    color("#9ba4b0")
        translate([0, 0, -16.8])
            cylinder(h = 16.8 + rim_lead_in_h - 0.5, d1 = 59.5, d2 = inner_rim_od - 1.4);

    // Dark gasket ring at base of valve cup for crisp visual separation
    color("#181a1d")
        translate([0, 0, rim_lead_in_h - 0.6])
            cylinder(h = 0.7, d = inner_rim_od + 1.0);

    // 2. Clinched 1-Inch Metal Valve Mounting Cup (~32.0 mm OD bright chrome curl)
    color("#eef2f6") {
        translate([0, 0, rim_lead_in_h + inner_rim_bead_h / 2])
            rotate_extrude()
                hull() {
                    translate([inner_rim_od / 2 - 1.3,  inner_rim_bead_h / 2 - 1.2, 0])
                        circle(r = 1.2, $fn = 24);
                    translate([inner_rim_od / 2 - 1.3, -inner_rim_bead_h / 2 + 1.2, 0])
                        circle(r = 1.2, $fn = 24);
                }
        translate([0, 0, -3.5])
            difference() {
                cylinder(h = z_rim_top + 3.0, d = inner_rim_od - 2.2);
                translate([0, 0, 1.5])
                    cylinder(h = z_rim_top + 3.0, d = 23.6);
            }
    }

    // 3. Stepped Spray Nozzle Cap (Dark Charcoal with High-Contrast Rim & Arrow)
    nozzle_z = cap_top_z - 3.0;
    color("#23272e")
        difference() {
            union() {
                // Lower wide skirt & shoulder rim (what the ratchet teeth lock onto!)
                translate([0, 0, cap_bot_z])
                    cylinder(h = lower_rim_top_z - cap_bot_z - 0.3, d = lower_rim_od);
                translate([0, 0, lower_rim_top_z - 0.35])
                    cylinder(h = 0.35, d1 = lower_rim_od, d2 = lower_rim_od - 0.5);

                // Fillet between lower shoulder and tall central cylinder
                translate([0, 0, lower_rim_top_z - 0.1])
                    cylinder(h = 0.9, d1 = center_cyl_od + 1.0, d2 = center_cyl_od);

                // Tall central cylinder rising above the lower rim
                translate([0, 0, lower_rim_top_z])
                    cylinder(h = center_cyl_h - 0.6, d = center_cyl_od);
                translate([0, 0, cap_top_z - 0.65])
                    cylinder(h = 0.65, d1 = center_cyl_od, d2 = center_cyl_od - 0.7);
            }
            // Recessed finger-pad dish on top of the central cylinder
            translate([0, 0, cap_top_z - 0.3])
                cylinder(h = 0.45, d = center_cyl_od - 2.0);
            // Front pocket on the tall central cylinder for the pink nozzle insert
            translate([center_cyl_od / 2 - 1.1, 0, nozzle_z])
                rotate([0, 90, 0])
                    cylinder(h = 2.5, d = 4.6, $fn = 32);
        }

    // High-contrast top directional arrow & grip lines on the tall central cylinder
    color("#8c96a4") {
        translate([0.6, 0, cap_top_z - 0.31])
            linear_extrude(height = 0.35)
                polygon(points = [
                    [ 3.4,  0.0],
                    [-2.0,  2.4],
                    [-0.9,  0.0],
                    [-2.0, -2.4]
                ]);
        for (gx = [-4.4 : 1.2 : -2.0]) {
            translate([gx, 0, cap_top_z - 0.16])
                cube([0.5, center_cyl_od - 5.0, 0.3], center = true);
        }
    }

    // 4. Hot-Pink Spray Nozzle Orifice Insert high on the central cylinder
    color("#ff1493")
        translate([center_cyl_od / 2 - 0.8, 0, nozzle_z])
            rotate([0, 90, 0])
                difference() {
                    cylinder(h = 1.0, d = 4.2, $fn = 32);
                    translate([0, 0, 0.3])
                        cylinder(h = 1.0, d = 1.1, $fn = 20);
                }

    // 5. Vibrant Hot-Pink Translucent Paint Spray Mist Jet when Locked Down!
    if (pressed) {
        %color([1.0, 0.08, 0.58, 0.55])
            translate([center_cyl_od / 2, 0, nozzle_z])
                rotate([0, 90, 0])
                    cylinder(h = 38, d1 = 1.5, d2 = 19.0);
    }
}

// ============================================================================
// RENDER DISPATCHER
// ============================================================================

if (render_mode == "print_ring") {
    forever_ratchet_ring(print_upside_down = true);

} else if (render_mode == "preview_on_can") {
    color("#f2cf56")
        forever_ratchet_ring(print_upside_down = false);
    spray_can_and_cap_3d(pressed = true);

} else if (render_mode == "preview_standby") {
    color("#f2cf56")
        forever_ratchet_ring(print_upside_down = false);
    spray_can_and_cap_3d(pressed = false);
}
