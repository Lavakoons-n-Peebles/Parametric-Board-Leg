# Parametric Board Leg Generator

A fully parametric OpenSCAD project designed for 3D printing custom legs and supports for desk shelf risers, monitor stands, and modular furniture utilizing standard wooden boards (e.g., 16mm / 18mm MDF or pine panels). Optimized for high-quality FDM printing with robust geometry handling and MakerWorld Customizer integration.

---

## Key Features

- **Parametric Board Fitting**: Customizable board thickness, insertion depth, and clearance tolerance for a precise friction or snug fit.
- **Robust 3D Edge Chamfering**: Features a stable, artifact-free 3D beveling helper along top and bottom Z-planes that avoids complex CSG rendering issues.
- **Reinforced Brackets**: 5 distinct structural bracket styles to maximize lateral stability under heavy loads (monitors, audio equipment).
- **Enclosed Board Sleeve**: Optional back-wall pocket sleeve to conceal board edges and prevent sliding.
- **Integrated Mounting Holes**: Configurable screw mount presets (bottom, top, back pocket, or leg-mounted) with built-in countersinks and screwdriver pass-through access.
- **MakerWorld Customizer Ready**: Organized parameters with standard section emoji indicators for simple customization via Web GUI.

---

## Parameter Reference

### 🪵 Board Specs
| Parameter | Default | Range | Description |
| :--- | :--- | :--- | :--- |
| `BAR_THICKNESS` | `16.0` | `5.0 - 50.0` | Nominal thickness of the wooden panel (mm). |
| `BAR_WIDTH` | `200` | `30 - 250` | Board width / pocket insertion depth (mm). |
| `CLEARANCE` | `0.3` | `0.0 - 3.0` | Fit tolerance gap around the board (mm). |

### 📐 Stand Dimensions
| Parameter | Default | Range | Description |
| :--- | :--- | :--- | :--- |
| `CLOSED_TOP` | `true` | `true / false` | Encloses the top rail above the board slot. |
| `HEIGHT` | `150` | `50 - 290` | Overall leg height from desk surface (mm). |
| `THICKNESS` | `35` | `15 - 100` | Profile depth / extrusion length along the Z-axis (mm). |
| `LEG_WIDTH` | `18.0` | `10.0 - 30.0` | Structural wall and leg thickness (mm). |

### 📥 Pocket Sleeve
| Parameter | Default | Range | Description |
| :--- | :--- | :--- | :--- |
| `POCKET_WIDTH` | `40.0` | `10.0 - 50.0` | Extension lip width for holding the board (mm). |
| `CLOSED_POCKET` | `true` | `true / false` | Closes the back face of the board pocket. |
| `CLOSED_POCKET_WALL` | `2.0` | `1.0 - 5.0` | Thickness of the back enclosure wall (mm). |

### 🏗️ Brackets & Support
| Parameter | Default | Range | Description |
| :--- | :--- | :--- | :--- |
| `BRACKET` | `3` | `0 - 4` | Bracket style: `0: None`, `1: Crossbar`, `2: Straight`, `3: Curved`, `4: Inverted Curved`. |
| `BRACKET_OFFSET_X` | `55` | `0 - 120` | Horizontal brace extension along the board (mm). |
| `BRACKET_OFFSET_Y` | `65` | `0 - 200` | Vertical brace extension down the leg (mm). |

### ✨ Rounding & Chamfers
| Parameter | Default | Range | Description |
| :--- | :--- | :--- | :--- |
| `ENABLE_ROUNDING` | `true` | `true / false` | Toggles outer corner radius. |
| `CORNER_RADIUS` | `8.0` | `1.0 - 20.0` | Outer top corner radius (mm). |
| `OUTER_CHAMFER` | `1.5` | `0.0 - 5.0` | Top and bottom edge 3D chamfer size (mm). |

### 🔩 Mounting Holes
| Parameter | Default | Range | Description |
| :--- | :--- | :--- | :--- |
| `MOUNT_MODE` | `"bottom"` | `none / top / bottom / back / legs` | Preset placement for mounting screw holes. |
| `MOUNT_HOLES_COUNT` | `2` | `1, 2` | Number of mounting holes along the placement axis. |
| `MOUNT_HOLE` | `4.0` | `2.0 - 10.0` | Screw shank hole diameter (mm). |
| `MOUNT_COUNTERSINK` | `true` | `true / false` | Adds a $90^\circ$ conical bevel for flush screw heads. |
| `MOUNT_BRACKETS_HOLES` | `true` | `true / false` | Cuts screwdriver access holes through reinforcement brackets. |

---

## Recommended Print Settings

- **Orient**: Print flat on side wall face.
- **Wall Loops / Lines**: 4 – 5 walls for solid structural stiffness.
- **Infill**: 25% – 30% Gyroid or 3D Honeycomb.
- **Supports**: Not required for default bracket geometries.