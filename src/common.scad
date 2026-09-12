function get(key, dict) = dict[search([key], dict)[0]][1];

module rail(v, width, height) {
    translate(v) square([width, height]);
}

module hole_mask(v, rv, r, h, countersink = false, dir = 1, cs_r = 0) {
    cs_radius = (cs_r > 0) ? cs_r : r * 2;
    cs_depth  = cs_radius - r;

    translate(v) rotate(rv) {
        cylinder(r=r, h=h);
        if (countersink) {
            if (dir >= 0) {
                cylinder(r1 = cs_radius, r2 = r, h = cs_depth);
            } else {
                translate([0, 0, h - cs_depth])  cylinder(r1 = r, r2 = cs_radius, h = cs_depth);
            }
        }
    }
}

module chamfered_body(height, chamfer = 1.0) {
    eps = 0.05;

    if (chamfer <= 0) {
        linear_extrude(height) children();
    } else {
        difference() {
            linear_extrude(height) children();

            // НИЖНИЙ ЧАМФЕР (Z = 0)
            // Заглубляем клинок чуть ниже нуля (z = -chamfer)
            translate([0, 0, chamfer])
                render()
                minkowski() {
                    linear_extrude(eps)
                        difference() {
                            offset(r = chamfer) children();
                            children();
                        }
                    // Перевернутый конус для нижнего среза
                    rotate([180, 0, 0])
                        cylinder(r1 = 0, r2 = chamfer, h = chamfer + eps, $fn = 4);
                }

            // ВЕРХНИЙ ЧАМФЕР (Z = height)
            translate([0, 0, height - chamfer])
                render()
                minkowski() {
                    linear_extrude(eps)
                        difference() {
                            offset(r = chamfer) children();
                            children();
                        }
                    // Прямой конус для верхнего среза
                    cylinder(r1 = 0, r2 = chamfer, h = chamfer + eps, $fn = 4);
                }
        }
    }
}

