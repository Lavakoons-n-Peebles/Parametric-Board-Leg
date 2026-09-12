use <common.scad>

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
