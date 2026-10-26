# Early Prototypes & Design Iterations

Before arriving at the minimal 1-piece inner-rim **FOREVAA CAP** ([`../forever_inner_ring_cap.scad`](../forever_inner_ring_cap.scad)), we explored taller bridge-style actuators that snap onto the outer or inner rim of the spray can:

- **[`forever_spray_can.scad`](forever_spray_can.scad)** / **[`forever_spray_can_screw.stl`](forever_spray_can_screw.stl)**:  
  *Iteration 1* — A 3-legged tripod arch that clips onto the spray can rim with a 3D-printed M12 thumbscrew at the top to screw down onto the nozzle cap.
- **[`forever_spray_can.stl`](forever_spray_can.stl)**:  
  *Iteration 2* — A 3-legged bridge with a central one-way zip-tie ratchet plunger ("click-click").

Testing these early prints revealed that tall upright legs experience high bending stress across horizontal 3D-printing layer lines, and that the entire mechanism could instead be collapsed into a single, low-profile `X-Y`-flexing ring directly around the inner metal valve cup ([`../forever_inner_ring_cap.scad`](../forever_inner_ring_cap.scad)).
