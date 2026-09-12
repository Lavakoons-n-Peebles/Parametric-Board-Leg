
// ==========================================
// MODULE START: D:\Projects\_Scripts\_SCAD\Parametric Board Leg\src\main.scad
// ==========================================

/* [🪵 Board and Stand] */
// Nominal board thickness (mm)
BAR_THICKNESS       = 16.0; // [5:0.5:50]
// Board width / Insertion depth (mm)
BAR_WIDTH           = 200;  // [30:1:250]
// Tightness clearance tolerance (mm)
CLEARANCE           = 0.3;  // [0:0.05:3]
// Construction mode
CLOSED_TOP          = true;
// Overall stand height (mm)
HEIGHT              = 160;  // [30:1:290]
// Print extrusion thickness (mm)
THICKNESS           = 35;   // [5:1:100]
// Leg and wall width (mm)
LEG_WIDTH           = 18;   // [5:0.5:30]

/* [📥 Pocket Sleeve] */
// Lip width (mm)
POCKET_WIDTH        = 40.0; // [10:0.5:50]
// Close side of the board pocket
CLOSED_POCKET      = true;
// Back wall thickness (mm)
CLOSED_POCKET_WALL = 2.0;  // [1:0.5:5]

/* [🏗️ Brackets & Support] */
// Reinforcement bracket type
BRACKET             = 3;    // [0: None, 1: Crossbar, 2: Straight Bracket, 3: Curved Bracket, 4: Inverted Curved Bracket]
// Horizontal offset for bracket (mm)
BRACKET_OFFSET_X    = 55;   // [0:1:120]
// Vertical offset for bracket (mm)
BRACKET_OFFSET_Y    = 65;   // [0:1:200]

/* [✨ Rounding & Chamfers] */
// Enable top corners rounding
ENABLE_ROUNDING     = true;
// Top outer corner radius (mm)
CORNER_RADIUS       = 8;    // [1:0.5:20]
// Edge chamfer size (mm)
OUTER_CHAMFER       = 1.5;  // [0:0.5:5]

/* [🔩 Mounting Holes] */
// Mounting holes preset
MOUNT_MODE          = "bottom"; // [none: None, top: Top, bottom: Bottom, back: Pocket, legs: Legs]
// Number of holes
MOUNT_HOLES_COUNT   = 2;        // [1, 2]
// Hole diameter (mm)
MOUNT_HOLE          = 4.0;      // [2:0.5:10]
// Countersink for screw head
MOUNT_COUNTERSINK   = true;
// Screwdriver pass-through holes in brackets
MOUNT_BRACKETS_HOLES = true;


/* [Hidden Calculations] */
$fn = 32;
_color = "#F5D77A";

// --- Begin Import: common.scad ---

// ==========================================
// MODULE START: D:\Projects\_Scripts\_SCAD\Parametric Board Leg\src\common.scad
// ==========================================

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


// ==========================================
// MODULE END: common.scad
// ==========================================

// --- End Import: common.scad ---

// --- Begin Import: geometry.scad ---

// ==========================================
// MODULE START: D:\Projects\_Scripts\_SCAD\Parametric Board Leg\src\geometry.scad
// ==========================================

// --- Begin Import: common.scad ---

// --- End Import: common.scad ---


module main_profile(object) {
    isClosed            = get("isClosed", object);
    barThickness        = get("barThickness", object);
    barWidth            = get("barWidth", object);
    height              = get("height", object);
    legWidth            = get("legWidth", object);

    enableOuterFillet   = get("enableRounding", object);
    outerFillet         = get("outerFillet", object);

    difference() {
        union() {
            rail([0,                   0], legWidth, height);                               // Leg 1
            rail([barWidth + legWidth, 0], legWidth, height);                               // Leg 2
            if (isClosed) rail([legWidth, 0], barWidth, legWidth);                          // Top
            rail([legWidth, (isClosed ? legWidth : 0) + barThickness], barWidth, legWidth); // Support

            brackets(object);
        }

        top_fillet_mask(object);
    }
}

module brackets(object) {
    isClosed        = get("isClosed",       object);
    barThickness    = get("barThickness",   object);
    barWidth        = get("barWidth",       object);
    legWidth        = get("legWidth",       object);
    bracket         = get("bracket",        object);
    bracketOffsetX  = get("bracketOffsetX", object);
    bracketOffsetY  = get("bracketOffsetY", object);

    yBase = legWidth + barThickness + (isClosed ? legWidth : 0);
    if (bracket == 1) {
        translate([legWidth, yBase + bracketOffsetY]) square([barWidth, legWidth]);
    }
    if (bracket == 2) {
        bracket(legWidth, yBase, bracketOffsetX, bracketOffsetY, legWidth, 1);
        bracket(barWidth + legWidth, yBase, bracketOffsetX, bracketOffsetY, legWidth, -1);
    }
    if (bracket == 3) {
        curved_bracket(legWidth, yBase, bracketOffsetX + legWidth, bracketOffsetY + legWidth, legWidth, 1);
        curved_bracket(barWidth + legWidth, yBase, bracketOffsetX + legWidth, bracketOffsetY + legWidth, legWidth, -1);
    }
    if (bracket == 4) {
        inverted_curved_bracket(legWidth,            yBase, bracketOffsetX, bracketOffsetY, legWidth, 1);
        inverted_curved_bracket(barWidth + legWidth, yBase, bracketOffsetX, bracketOffsetY, legWidth, -1);
    }
}

module bracket(xBase, yBase, xOffset, yOffset, width, dir = -1) {
    // Угол наклона рейки в радианах
    alpha = atan2(yOffset, xOffset);
    eps = 1e-6;

    // Длина спила вдоль горизонтальной и вертикальной граней для сохранения ширины width
    cutX = (abs(sin(alpha)) < eps) ? 0 : width / sin(alpha);
    cutY = (abs(cos(alpha)) < eps) ? 0 : width / cos(alpha);

    polygon([
        [xBase + dir * xOffset, yBase],
        [xBase + dir * (xOffset + cutX), yBase],
        [xBase, yBase + yOffset + cutY],
        [xBase, yBase + yOffset]
    ]);
}

module single_arc(rx, ry, width, dir = 1) {
    spanX = rx + width;
    spanY = ry + width;

    intersection() {
        translate([dir == -1 ? -spanX : 0, 0]) square([spanX, spanY]);

        scale([dir, 1]) difference() {
            scale([1, spanY / spanX]) circle(r = spanX);
            scale([1, ry / rx]) circle(r = rx);
        }
    }
}

module inverted_curved_bracket(xBase, yBase, xOffset, yOffset, width, dir = -1) {
    translate([xBase, yBase])
        single_arc(xOffset, yOffset, width, dir);
}

module curved_bracket(xBase, yBase, xOffset, yOffset, width, dir = -1) {
    translate([xBase + dir * xOffset, yBase + yOffset]) scale([-1, -1])
        single_arc(xOffset, yOffset, width, dir);
}

//

module top_fillet_mask(object) {
    enableRounding  = get("enableRounding", object);
    cornerRadius    = get("cornerRadius", object);
    height          = get("height", object);
    barWidth        = get("barWidth", object);
    legWidth        = get("legWidth", object);

    totalWidth = barWidth + 2 * legWidth;

    if (enableRounding) {
        // Upper left corner cutout
        difference() {
            square([cornerRadius, cornerRadius]);
            translate([cornerRadius, cornerRadius]) circle(cornerRadius);
        }

        // Upper right corner cutout
        translate([totalWidth - cornerRadius, 0])
            difference() {
                square([cornerRadius, cornerRadius]);
                translate([0, cornerRadius]) circle(cornerRadius);
            }
    }
}

//

module mounting_holes(object) {
    isClosed    = get("isClosed", object);
    barT        = get("barThickness", object);
    barW        = get("barWidth", object);
    legW        = get("legWidth", object);
    h           = get("height", object);
    thick       = get("thickness", object);
    bracketsHoles = get("mountBracketsHoles", object);

    mode        = get("mountMode", object);
    count       = get("mountHolesCount", object);
    r           = get("mountHoleRadius", object);
    cs          = get("mountCountersink", object);

    // Базовая Y-координата паза для доски
    pocketY = (isClosed ? legW : 0) + barT;

    if (mode != "none") {
        zPos = (thick / 2 + r / 2);

        if (mode == "bottom" || mode == "top") {
            yPos = (mode == "bottom" || mode == "top" && !isClosed) ? pocketY : 0;

            cs_dir = (mode == "bottom") ? -1 : 1;

            hole_mask([legW + barW * (count == 2 ? 0.25 : 0.5), -1 + yPos, zPos], [-90, 0, 0], r, legW + 2, cs, cs_dir);
            if (count == 2) hole_mask([legW + barW * 0.75, -1 + yPos, zPos], [-90, 0, 0], r, legW + 2, cs, cs_dir);

            if (mode == "bottom" && bracketsHoles) { // holes in brackets for installation
                yPos = yPos + legW;
                hole_mask([legW + barW * (count == 2 ? 0.25 : 0.5), yPos, zPos], [-90, 0, 0], (thick > 9) ? 3.6 : r, h, cs);
                if (count == 2) hole_mask([legW + barW * 0.75, yPos, zPos], [-90, 0, 0], (thick > 9) ? 3.6 : r, h, cs);
            }
        }

        if (mode == "back")  {// pocket box
            yPos = ((isClosed) ? legW : 0) + barW/2 + r/2;
            hole_mask([legW + barW * (count == 2 ? 0.25 : 0.5), -1 + ((!isClosed) ? legW : 2*legW), -1], [0, 0, 0], r, legW + 2, cs);
            if (count == 2) hole_mask([legW + barW * 0.75, -1 + ((!isClosed) ? legW : 2*legW), -1], [0, 0, 0], r, legW + 2, cs);
        }

        if (mode == "legs") {
            yPos = pocketY - (barT / 2);
            hole_mask([-1, yPos, zPos], [0, 90, 0], r, legW + 2, cs);
            if (count == 2) hole_mask([legW + barW - 1, yPos, zPos], [0, 90, 0], r, legW + 2, cs, -1);
        }

    }
}

//

module bar_pocket(object) {
    isClosed     = get("isClosed", object);
    barThickness = get("barThickness", object);
    barWidth     = get("barWidth", object);
    legWidth     = get("legWidth", object);

    totalWidth  = barWidth + 2 * legWidth;

    pocketH     = barThickness + (isClosed ? 2 * legWidth : legWidth);

    intersection() {
        main_profile(object);

        // Маска-ограничитель по высоте зоны кармана
        translate([0, 0])
            square([totalWidth, pocketH]);
    }
}

module bar_pocket_wall(object) {
    isClosed     = get("isClosed", object);
    barThickness = get("barThickness", object);
    barWidth     = get("barWidth", object);
    legWidth     = get("legWidth", object);
    closedPocket = get("closedPocket", object);

    pocketH     = barThickness + (isClosed ? 2 * legWidth : legWidth);

    if (closedPocket) translate([legWidth, (isClosed ? legWidth : 0), 0]) square([barWidth, barThickness]);
}


//

module outer_corners_mask(object) {
    enableRounding = get("enableRounding", object);
    r              = get("cornerRadius", object);
    height         = get("height", object);
    barWidth       = get("barWidth", object);
    legWidth       = get("legWidth", object);

    totalWidth = barWidth + 2 * legWidth;

    if (enableRounding && r > 0) {
        // 1. Верхний левый внешний угол
        translate([0, height - r])
            difference() {
                square([r, r]);
                translate([r, 0]) circle(r = r);
            }

        // 2. Верхний правый внешний угол
        translate([totalWidth - r, height - r])
            difference() {
                square([r, r]);
                translate([0, 0]) circle(r = r);
            }

        // 3. Нижний левый внешний угол
        translate([0, 0])
            difference() {
                square([r, r]);
                translate([r, r]) circle(r = r);
            }

        // 4. Нижний правый внешний угол
        translate([totalWidth - r, 0])
            difference() {
                square([r, r]);
                translate([0, r]) circle(r = r);
            }
    }
}

//

module outer_wall_texture(object) {
    texType  = get("textureType", object);
    texSize  = get("textureSize", object);
    texDepth = get("textureDepth", object);
    height   = get("height", object);
    legWidth = get("legWidth", object);

    if (texType == 1) {
        // === ТИП 1: Organic Ribs / Колбаски ===
        // Набираем вертикальную стенку из дуг/кругов без нависаний
        count = floor(height / texSize);
        step  = height / count;

        for (i = [0 : count - 1]) {
            y = i * step + step / 2;
            translate([0, y]) {
                // Выпуклая «колбаска» вдоль края
                intersection() {
                    square([texDepth * 2, step], center = true);
                    scale([texDepth / (step / 2), 1])
                        circle(r = step / 2, $fn = 16);
                }
            }
        }
    }
    else if (texType == 2) {
        // === ТИП 2: Linear Strips (Заготовка под будущее) ===
    }
    else if (texType == 3) {
        // === ТИП 3: Panel Slots (Заготовка под будущее) ===
    }
}

// ==========================================
// MODULE END: geometry.scad
// ==========================================

// --- End Import: geometry.scad ---


object = let (
    isClosed    = CLOSED_TOP,
    barT        = BAR_THICKNESS    + 2 * CLEARANCE,
    barW        = BAR_WIDTH        + 2 * CLEARANCE,
    minH        = barT + (isClosed ? 2 * LEG_WIDTH : LEG_WIDTH),
    h           = max(minH, HEIGHT),
) [
    ["isClosed",            isClosed    ],
    ["legWidth",            LEG_WIDTH   ],
    ["thickness",           THICKNESS   ],
    ["barThickness",        barT        ],
    ["barWidth",            barW        ],
    ["height",              h           ],

    ["closedPocket",        CLOSED_POCKET],
    ["closedPocketWall",    CLOSED_POCKET_WALL],
    ["pocketWidth",         max(POCKET_WIDTH, barT)],

    ["bracket",             BRACKET     ],
    ["bracketOffsetX",      min(BRACKET_OFFSET_X, barW / 2)],
    ["bracketOffsetY",      min(BRACKET_OFFSET_Y, h - minH)],

    ["enableRounding",      ENABLE_ROUNDING],
    ["cornerRadius",        min(CORNER_RADIUS, LEG_WIDTH)],
    ["outerChamfer",         min(OUTER_CHAMFER, LEG_WIDTH / 3)],

    ["mountMode",           MOUNT_MODE],
    ["mountHolesCount",     MOUNT_HOLES_COUNT],
    ["mountHoleRadius",     MOUNT_HOLE / 2],
    ["mountCountersink",    MOUNT_COUNTERSINK],
    ["mountBracketsHoles",  MOUNT_BRACKETS_HOLES]
];

color(_color) {
    build(object);
}


module build(object) {
    thickness           = get("thickness", object);
    pocketWidth         = get("pocketWidth", object);
    closedPocketWall    = get("closedPocketWall", object);

    enableRounding      = get("enableRounding", object);
    outerChamfer        = get("outerChamfer", object);

    difference() {
        union() {
            chamfered_body(thickness, (enableRounding ? outerChamfer : 0)) main_profile(object);

            // pocket
            linear_extrude(pocketWidth) bar_pocket(object);
            linear_extrude(closedPocketWall) bar_pocket_wall(object);
        }

        mounting_holes(object);
    }
}

// ==========================================
// MODULE END: main.scad
// ==========================================
