// ============================================================================
// VELI FOREVER SPRAY-CAN ACTUATOR
// Parametric 3-Legged Snap-On Bridge + 3D-Printed Thumbscrew
// Supports both Standard Outer Can Rim (~65.5 mm) and Inner Valve Cup Rim (~32.7 mm)
// ============================================================================

/* [Render & Layout Selection] */
// Which part(s) to generate
part_to_render = "all_parts"; // [all_parts:All Parts (Print Layout), assembled_outer:Assembled Preview (Outer Rim), assembled_inner:Assembled Preview (Inner Valve Cup), outer_bridge:Outer Rim Bridge Only, inner_bridge:Inner Valve Cup Bridge Only, thumbscrew_long:Thumbscrew (Outer Bridge), thumbscrew_short:Thumbscrew (Inner Bridge)]

// Number of snap legs (3 = self-centering tripod, wide spray clearance)
num_legs = 3; // [2:2 Legs (U-Bridge), 3:3 Legs (Tripod - Recommended), 4:4 Legs]

// Angular width of each snap foot on the rim (degrees) - wider = much stronger!
foot_arc_angle = 52; // [35:1:75]

/* [Outer Can Rim Dimensions (Standard 400ml Aerosol Can)] */
// Outer diameter of the rolled top rim (chime) of the spray can
outer_rim_od = 65.5;
// Inner diameter of the rolled top rim where the top shoulder rests
outer_rim_id = 57.0;
// Height of the rolled metal rim bead
outer_rim_bead_h = 3.3;
// Undercut hook depth (how far the clip snaps inward under the rim bead)
outer_snap_undercut = 1.1;
// Clearance height from top of outer rim to bottom of central hub (must clear nozzle cap)
outer_arch_clearance_h = 40.0;
// Radial wall thickness of the foot & leg base (mm)
outer_leg_thickness = 6.0;
// Extra radial depth of the T-beam reinforcement spine on the back of each leg (mm)
outer_spine_depth = 4.0;
// Width of the legs where they meet the top hub (mm)
outer_leg_top_width = 15.0;

/* [Inner Valve Cup Rim Dimensions (Standard 1-inch Aerosol Valve Cup)] */
// Outer diameter of the small central metal valve cup ring around the nozzle
inner_rim_od = 32.7;
// Inner diameter of the valve cup ring
inner_rim_id = 25.0;
// Height of the valve cup rolled bead
inner_rim_bead_h = 3.0;
// Undercut hook depth for inner valve cup
inner_snap_undercut = 0.95;
// Clearance height from top of inner valve cup to bottom of central hub
inner_arch_clearance_h = 22.0;
// Radial wall thickness of the foot & leg base (mm)
inner_leg_thickness = 5.0;
// Extra radial depth of the T-beam reinforcement spine on the back of each leg (mm)
inner_spine_depth = 3.2;
// Width of the legs where they meet the top hub (mm)
inner_leg_top_width = 13.0;

/* [3D-Printed Thread & Thumbscrew Parameters] */
// Nominal outer diameter of the 3D-printed screw (mm) - M12 is strong & easy to print
screw_nominal_d = 12.0;
// Thread pitch (mm per revolution) - 3.0mm prints cleanly without supports
screw_pitch = 3.0;
// Radial depth of the thread tooth (mm)
thread_depth = 1.1;
// Radial clearance between external screw and internal nut threads (mm)
thread_radial_clearance = 0.35;
// Height of the threaded boss at the top of the bridge
hub_height = 12.0;
// Outer diameter of the central threaded hub
hub_od = 22.0;
// Diameter of the knurled thumbwheel head
knob_od = 28.0;
// Height of the knurled thumbwheel head
knob_h = 8.0;
// Number of grip flutes around the thumbwheel
knob_flutes = 12;
// Diameter of the bottom presser pad that pushes on the spray nozzle
presser_tip_d = 9.5;

/* [Resolution] */
$fn = 72;

// ============================================================================
// HELPER FUNCTIONS & THREAD GENERATOR
// ============================================================================

// Trapezoidal wave over [0, 360) degrees for ISO/Acme-like 3D-printable thread profile
// Returns a value in [0, 1]: flat root -> linear flank -> flat crest -> linear flank
function trap_wave(deg) =
    let(a = ((deg % 360) + 360) % 360)
    (a < 35)  ? 0.0 :
    (a < 145) ? (a - 35) / 110.0 :
    (a < 215) ? 1.0 :
    (a < 325) ? 1.0 - (a - 215) / 110.0 :
                0.0;

// 2D cross-section that produces an exact helical trapezoidal thread when linear_extruded with twist
module thread_2d_profile(root_r, depth, steps = 96) {
     pts = [
        for (i = [0 : steps - 1])
            let(
                ang = i * 360 / steps,
                r = root_r + depth * trap_wave(ang)
            )
            [r * cos(ang), r * sin(ang)]
    ];
    polygon(pts);
}

// Helical thread rod (used for both bolt and internal nut cutout)
module helical_thread(length, major_d, pitch, depth, internal = false) {
    root_r = (major_d / 2) - depth;
    slices = max(36, ceil(length / pitch * 24));
    twist_deg = -360 * (length / pitch); // Right-hand thread

    intersection() {
        linear_extrude(height = length, twist = twist_deg, slices = slices, convexity = 10)
            thread_2d_profile(root_r, depth);

        // Lead-in / lead-out 45-degree chamfer cones on external bolts
        if (!internal) {
            union() {
                cylinder(h = length, d1 = major_d - 1.5, d2 = major_d + length * 2);
            }
        } else {
            cylinder(h = length + 1, d = major_d + 2, center = false);
        }
    }
}

// ============================================================================
// 3-LEGGED SNAP-ON BRIDGE MODULE
// ============================================================================

module snap_bridge(
    rim_od,
    rim_id,
    rim_bead_h,
    snap_undercut,
    arch_clearance_h,
    leg_thickness,
    leg_top_width,
    spine_depth = 3.6
) {
    rim_r = rim_od / 2;
    hub_r = hub_od / 2;
    
    // Extra thick top shoulder above the rim to prevent horizontal layer cracking
    foot_top_shoulder_h = 4.5;
    foot_lead_in_h = 2.6;
    
    // Z coordinate where the top of the can rim sits (z = 0 is bottom of clip feet)
    rim_top_z = foot_lead_in_h + rim_bead_h;
    // Z coordinate of the bottom of the central threaded hub
    hub_bottom_z = rim_top_z + arch_clearance_h;
    // Conical self-supporting base height under the hub (45-deg printable without supports)
    hub_cone_h = (hub_od - screw_nominal_d) / 2;

    difference() {
        union() {
            // 1. Central Top Threaded Hub + Flared Upper Arch Collar
            translate([0, 0, hub_bottom_z])
                cylinder(h = hub_height, d = hub_od);
            
            translate([0, 0, hub_bottom_z - hub_cone_h])
                cylinder(h = hub_cone_h + 3.0, d1 = screw_nominal_d + 2.0, d2 = hub_od + 3.0);

            // 2. Heavy-Duty Snap Feet + Full-Height T-Beam Legs (Starting at Z = 0!)
            for (i = [0 : num_legs - 1]) {
                rotate([0, 0, i * (360 / num_legs)]) {
                    // Wide Circumferential Snap-Fit Foot
                    rotate([0, 0, -foot_arc_angle / 2])
                        rotate_extrude(angle = foot_arc_angle, convexity = 6)
                            snap_foot_profile_2d(
                                rim_r = rim_r,
                                rim_id_r = max(rim_id / 2, rim_r - 3.6),
                                bead_h = rim_bead_h,
                                undercut = snap_undercut,
                                shoulder_h = foot_top_shoulder_h,
                                lead_in_h = foot_lead_in_h,
                                wall_t = leg_thickness
                            );

                    // Full-Height T-Beam Gusseted Leg starting at Z = 0 on the bed!
                    leg_strut(
                        rim_r = rim_r,
                        rim_top_z = rim_top_z,
                        shoulder_h = foot_top_shoulder_h,
                        hub_r = hub_r,
                        hub_bottom_z = hub_bottom_z - hub_cone_h,
                        hub_h = hub_height + hub_cone_h,
                        wall_t = leg_thickness,
                        spine_d = spine_depth,
                        top_w = leg_top_width,
                        foot_arc = foot_arc_angle
                    );
                }
            }
        }

        // 3. Internal Female Thread through the Top Hub
        internal_major_d = screw_nominal_d + 2 * thread_radial_clearance;
        translate([0, 0, hub_bottom_z - hub_cone_h - 1.0])
            helical_thread(
                length = hub_height + hub_cone_h + 2.0,
                major_d = internal_major_d,
                pitch = screw_pitch,
                depth = thread_depth + 0.1,
                internal = true
            );

        // Top & bottom 45-degree thread entry chamfers inside the hub
        translate([0, 0, hub_bottom_z + hub_height - 1.4])
            cylinder(h = 1.5, d1 = internal_major_d - 2 * thread_depth, d2 = internal_major_d + 1.0);
        translate([0, 0, hub_bottom_z - hub_cone_h - 0.1])
            cylinder(h = 1.6, d1 = internal_major_d + 1.0, d2 = internal_major_d - 2 * thread_depth);
    }
}

// Heavy-Duty 2D Radial Cross-Section of Snap-On Rim Clip (Thickened + Filleted)
module snap_foot_profile_2d(rim_r, rim_id_r, bead_h, undercut, shoulder_h, lead_in_h, wall_t) {
    r_inner_wall = rim_r + 0.15;
    r_outer_wall = r_inner_wall + wall_t;
    r_hook_tip   = r_inner_wall - undercut;
    r_shoulder   = rim_id_r;
    
    z_bot        = 0;
    z_hook_peak  = lead_in_h;
    z_hook_top   = lead_in_h + 1.0;
    z_rim_top    = lead_in_h + bead_h;
    z_top        = z_rim_top + shoulder_h;

    polygon(points = [
        [r_outer_wall,           z_bot],
        [r_outer_wall,           z_top],
        [r_shoulder + 1.2,       z_top + 1.5],
        [r_shoulder,             z_top - 0.4],
        [r_shoulder,             z_rim_top + 0.4],
        [r_shoulder + 0.5,       z_rim_top],
        [r_inner_wall - 0.4,     z_rim_top],
        [r_inner_wall,           z_rim_top - 0.4],
        [r_inner_wall,           z_hook_top],
        [r_hook_tip,             z_hook_peak],
        [r_hook_tip,             z_hook_peak - 0.6],
        [r_inner_wall + 0.8,     z_bot]
    ]);
}

// Full-Height T-Beam Gusseted Leg starting at Z = 0 on the build plate
module leg_strut(rim_r, rim_top_z, shoulder_h, hub_r, hub_bottom_z, hub_h, wall_t, spine_d, top_w, foot_arc) {
    z_foot_top = rim_top_z + shoulder_h;
    z_end      = hub_bottom_z + hub_h - 1.0;
    r_start    = rim_r + 0.15 + wall_t / 2;
    r_end      = hub_r - wall_t / 2 + 1.5;
    
    w_base  = max(top_w + 5.0, 2 * r_start * sin(min(foot_arc - 6, 36) / 2));
    w_spine = max(6.5, top_w * 0.52);

    // Part A: Bottom Root Buttress from Z = 0 to Z = z_foot_top (eliminates weak neck joint!)
    hull() {
        translate([r_start + spine_d / 2, 0, 0.25])
            cube([wall_t + spine_d, w_spine + 3.0, 0.5], center = true);
        translate([r_start + spine_d / 2, 0, z_foot_top])
            cube([wall_t + spine_d, w_spine + 2.0, 0.5], center = true);
    }
    hull() {
        translate([r_start, 0, 0.25])
            cube([wall_t, w_base, 0.5], center = true);
        translate([r_start, 0, z_foot_top])
            cube([wall_t, w_base, 0.5], center = true);
    }

    // Part B: Continuous Arched T-Beam (Wide Flange + Deep Radial Spine Web)
    z_arch_start = z_foot_top * 0.5;
    steps = 12;
    for (s = [0 : steps - 1]) {
        t0 = s / steps;
        t1 = (s + 1) / steps;
        
        curve0 = pow(t0, 1.25);
        curve1 = pow(t1, 1.25);
        
        r0 = r_start * (1 - curve0) + r_end * curve0;
        r1 = r_start * (1 - curve1) + r_end * curve1;
        
        z0 = z_arch_start + (z_end - z_arch_start) * t0;
        z1 = z_arch_start + (z_end - z_arch_start) * t1;
        
        w0 = w_base * (1 - t0) + top_w * t0;
        w1 = w_base * (1 - t1) + top_w * t1;

        thick0 = wall_t + 1.5 * sin(t0 * 180);
        thick1 = wall_t + 1.5 * sin(t1 * 180);
        spine0 = spine_d * (1 - 0.3 * t0);
        spine1 = spine_d * (1 - 0.3 * t1);
        
        hull() {
            translate([r0, 0, z0])
                cube([thick0, w0, 0.6], center = true);
            translate([r1, 0, z1])
                cube([thick1, w1, 0.6], center = true);
        }
        hull() {
            translate([r0 + spine0 / 2, 0, z0])
                cube([thick0 + spine0, w_spine, 0.6], center = true);
            translate([r1 + spine1 / 2, 0, z1])
                cube([thick1 + spine1, w_spine, 0.6], center = true);
        }
    }
}

// ============================================================================
// 3D-PRINTED THUMBSCREW MODULE
// ============================================================================
// Designed to print FLAT on the build plate (thumbwheel at z=0, shaft pointing UP)
// so zero supports are needed!

module thumbscrew(shaft_length) {
    union() {
        // 1. Knurled Thumbwheel Base (at z = 0 for support-free printing)
        difference() {
            // Chamfered cylinder body
            hull() {
                cylinder(h = 1.0, d = knob_od - 2.0);
                translate([0, 0, 1.0])
                    cylinder(h = knob_h - 2.0, d = knob_od);
                translate([0, 0, knob_h - 1.0])
                    cylinder(h = 1.0, d = knob_od - 2.0);
            }
            // Grip flutes around perimeter
            for (i = [0 : knob_flutes - 1]) {
                rotate([0, 0, i * (360 / knob_flutes)])
                    translate([knob_od / 2 + 1.2, 0, -0.5])
                        cylinder(h = knob_h + 1, d = 5.0, $fn = 24);
            }
            // Directional arrow / indicator recess on bottom face (top when installed)
            translate([0, 0, -0.01])
                cylinder(h = 0.6, d1 = 6.0, d2 = 4.0);
        }

        // 2. Strengthened Transition Shoulder
        translate([0, 0, knob_h - 0.1])
            cylinder(h = 2.0, d1 = screw_nominal_d + 2.5, d2 = screw_nominal_d - 2 * thread_depth);

        // 3. Helical Threaded Shaft
        translate([0, 0, knob_h + 1.5])
            helical_thread(
                length = shaft_length,
                major_d = screw_nominal_d,
                pitch = screw_pitch,
                depth = thread_depth,
                internal = false
            );

        // 4. Smooth Rounded Nozzle Presser Tip at the end of the screw
        tip_z = knob_h + 1.5 + shaft_length;
        translate([0, 0, tip_z - 0.2]) {
            cylinder(h = 1.8, d1 = screw_nominal_d - 2 * thread_depth, d2 = presser_tip_d);
            translate([0, 0, 1.8])
                hull() {
                    cylinder(h = 0.8, d = presser_tip_d);
                    translate([0, 0, 1.2])
                        cylinder(h = 0.2, d = presser_tip_d - 2.5);
                }
        }
    }
}

// ============================================================================
// GHOST SPRAY CAN REFERENCE (FOR ASSEMBLED PREVIEW ONLY)
// ============================================================================

module ghost_spray_can() {
    %union() {
        // Outer can body & chime rim
        translate([0, 0, -25])
            cylinder(h = 25, d = outer_rim_od - 1.0);
        cylinder(h = outer_rim_bead_h, d = outer_rim_od);
        // Dome going up to inner valve cup
        translate([0, 0, outer_rim_bead_h])
            cylinder(h = 15, d1 = outer_rim_id, d2 = inner_rim_od - 1.5);
        // Inner valve cup rim
        translate([0, 0, outer_rim_bead_h + 15])
            cylinder(h = inner_rim_bead_h, d = inner_rim_od);
        // Spray nozzle cap
        translate([0, 0, outer_rim_bead_h + 18])
            cylinder(h = 15, d = 20.0);
    }
}

// ============================================================================
// MAIN RENDER DISPATCHER
// ============================================================================

outer_screw_len = outer_arch_clearance_h + hub_height - 16;
inner_screw_len = inner_arch_clearance_h + hub_height - 6;

if (part_to_render == "all_parts") {
    // 1. Outer Rim Bridge (center)
    snap_bridge(
        rim_od = outer_rim_od,
        rim_id = outer_rim_id,
        rim_bead_h = outer_rim_bead_h,
        snap_undercut = outer_snap_undercut,
        arch_clearance_h = outer_arch_clearance_h,
        leg_thickness = outer_leg_thickness,
        leg_top_width = outer_leg_top_width
    );

    // 2. Inner Valve Cup Bridge (to the right)
    translate([68, 0, 0])
        snap_bridge(
            rim_od = inner_rim_od,
            rim_id = inner_rim_id,
            rim_bead_h = inner_rim_bead_h,
            snap_undercut = inner_snap_undercut,
            arch_clearance_h = inner_arch_clearance_h,
            leg_thickness = inner_leg_thickness,
            leg_top_width = inner_leg_top_width
        );

    // 3. Long Thumbscrew for Outer Bridge (front left, oriented for support-free printing)
    translate([-55, 25, 0])
        thumbscrew(shaft_length = outer_screw_len);

    // 4. Short Thumbscrew for Inner Bridge (back left, oriented for support-free printing)
    translate([-55, -25, 0])
        thumbscrew(shaft_length = inner_screw_len);

} else if (part_to_render == "assembled_outer") {
    snap_bridge(
        rim_od = outer_rim_od,
        rim_id = outer_rim_id,
        rim_bead_h = outer_rim_bead_h,
        snap_undercut = outer_snap_undercut,
        arch_clearance_h = outer_arch_clearance_h,
        leg_thickness = outer_leg_thickness,
        leg_top_width = outer_leg_top_width
    );
    // Thumbscrew inverted in its working position at the top
    translate([0, 0, 2.4 + outer_rim_bead_h + outer_arch_clearance_h + hub_height + knob_h + 10])
        rotate([180, 0, 0])
            thumbscrew(shaft_length = outer_screw_len);
    ghost_spray_can();

} else if (part_to_render == "assembled_inner") {
    snap_bridge(
        rim_od = inner_rim_od,
        rim_id = inner_rim_id,
        rim_bead_h = inner_rim_bead_h,
        snap_undercut = inner_snap_undercut,
        arch_clearance_h = inner_arch_clearance_h,
        leg_thickness = inner_leg_thickness,
        leg_top_width = inner_leg_top_width
    );
    translate([0, 0, 2.4 + inner_rim_bead_h + inner_arch_clearance_h + hub_height + knob_h + 6])
        rotate([180, 0, 0])
            thumbscrew(shaft_length = inner_screw_len);

} else if (part_to_render == "outer_bridge") {
    snap_bridge(
        rim_od = outer_rim_od,
        rim_id = outer_rim_id,
        rim_bead_h = outer_rim_bead_h,
        snap_undercut = outer_snap_undercut,
        arch_clearance_h = outer_arch_clearance_h,
        leg_thickness = outer_leg_thickness,
        leg_top_width = outer_leg_top_width
    );

} else if (part_to_render == "inner_bridge") {
    snap_bridge(
        rim_od = inner_rim_od,
        rim_id = inner_rim_id,
        rim_bead_h = inner_rim_bead_h,
        snap_undercut = inner_snap_undercut,
        arch_clearance_h = inner_arch_clearance_h,
        leg_thickness = inner_leg_thickness,
        leg_top_width = inner_leg_top_width
    );

} else if (part_to_render == "thumbscrew_long") {
    thumbscrew(shaft_length = outer_screw_len);

} else if (part_to_render == "thumbscrew_short") {
    thumbscrew(shaft_length = inner_screw_len);
}

