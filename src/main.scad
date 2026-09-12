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

use <common.scad>
use <geometry.scad>

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