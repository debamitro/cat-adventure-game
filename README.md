# 🐱 Cat Bridge Adventure

A fun 2D platformer game where you help a cute cat jump across increasingly wider bridges to get home!

## 🎮 How to Play

### Controls
- **A / D** or **Left / Right Arrow**: Move the cat left and right
- **W** / **Up Arrow** / **Space**: Jump
- **R**: Reset / Restart the level

### Objective
- Jump from bridge to bridge to cross the water
- Each subsequent bridge is wider than the last one
- Cross all 21 bridges to help the cat reach home!
- Don't fall in the water! 😿

## 🎯 Game Features

### Progressive Difficulty
- **20 main bridges** plus a final home platform
- Bridge width starts at **120 pixels** and increases by **40 pixels** per bridge
- Final bridge is **920 pixels** wide!

### Gameplay Mechanics
- Smooth movement with acceleration and friction
- Jump buffering: Jump slightly before landing for responsive feel
- Coyote time: Jump shortly after leaving a platform
- Camera smoothly follows the cat

### Visual Features
- Cute pixel-style cat character (made from colored rectangles)
- Each bridge has unique colors based on rainbow hue
- Detailed bridges with:
  - Wood planks
  - Railing posts and rope
  - Bridge numbers
- Animated water with waves and splash effects
- Sky blue background with underwater tint

## 📁 Project Structure

```
cat_bridge_adventure/
├── icon.svg                # Project icon
├── project.godot           # Godot project configuration
├── scenes/
│   └── main.tscn          # Main game scene
├── scripts/
│   ├── main.gd            # Main game controller
│   ├── cat.gd             # Cat player controller
│   └── hud.gd             # HUD and UI management
└── assets/                # (empty - all assets are procedural)
```

## 🔧 Customization

### Adjust Difficulty

Edit `scripts/main.gd` to change these variables:

```gdscript
var total_bridges: int = 20          # Number of bridges
var base_bridge_width: float = 120.0  # Starting width
var width_increment: float = 40.0     # Width increase per bridge
var bridge_gap: float = 200.0        # Gap between bridges
```

### Adjust Cat Physics

Edit `scripts/cat.gd` to change these constants:

```gdscript
const GRAVITY: float = 800.0       # Gravity strength
const JUMP_FORCE: float = -480.0   # Jump height
const MOVE_SPEED: float = 200.0    # Movement speed
const ACCELERATION: float = 2000.0 # Movement acceleration
```

## 🚀 Requirements

- **Godot Engine 4.7.2** or compatible 4.x version

## 📝 How to Run

1. Open Godot Engine
2. Click "Import" and select the `cat_bridge_adventure` folder
3. Open the project
4. Click "Play" or press F5 to start the game

## 🎨 Credits

All assets are created procedurally using Godot's built-in ColorRect nodes - no external sprites required!

---

Made with ❤️ and Godot 4.7.2
