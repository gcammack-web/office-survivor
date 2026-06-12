# Office Survivor

**One-sentence hook:** Office worker survivor — staplers, coffee, passive-aggressive emails as upgrades.

A Vampire Survivors–style roguelite built in **Godot 4** for a future Steam release. This repo contains a playable **vertical slice**: one survival loop, four weapons, timed escalation events, pixel-art placeholders, and juice.

## Why Godot (not Unity)

For a 2D survivor-like with simple art, Godot 4 is the better fit:

- Free and open source (no revenue share)
- Excellent 2D workflow and export to Steam (Windows, macOS, Linux)
- Lighter than Unity for a solo/small team scope
- Megabonk used Unity, but your game is 2D top-down — Godot matches the genre

## Requirements

- [Godot 4.3+](https://godotengine.org/download) (Standard build)

On macOS with Homebrew:

```bash
brew install --cask godot
```

## Run the game

1. Open Godot → **Import** → select `project.godot` in this repo
2. Press **F5** (or click Play)

Or from terminal:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path "/path/to/office-survivor"
```

Headless smoke test:

```bash
godot --headless --path . --quit-after 2
```

## Controls

| Input | Action |
|-------|--------|
| WASD / Arrow keys | Move |
| Esc | Pause menu (during a run) |
| — | Weapons fire automatically |

On level-up, the game briefly slow-mos, then pauses and offers **3 random upgrades**. Pick one to continue.

## Vertical slice scope

**Included (playable now):**

- Title screen → survival run → death → retry
- Auto-attacking **Stapler** starter weapon
- Unlockable **Coffee Mug** (damage aura), **Passive-Aggressive Email** (homing), and **Printer Jam** (screen-wide freeze + burst damage)
- Passive upgrades: speed, max HP, global damage, **Office Magnet** (XP pickup radius)
- Enemies: **Deadlines**, **Meetings**, **Slack pings**, plus tier unlocks — **Overdue Reports** (Lv5+), **Micromanagers** (Lv10+), **Crunch Time** (Lv15+), **Executives** (Lv20+)
- **Level milestone bosses** at levels 10, 20, 30+ (Quarterly Review, etc.)
- **Timed escalation events** (once per run): Stand-up Meeting (5:00), Performance Review (10:00), All-Hands (15:00)
- Random **donut pickups** restore 30 HP
- Death recap, milestone HUD, floating damage/heal numbers
- Procedural elevator-style music + SFX

**Not yet (next milestones):**

- Meta-progression between runs
- Steam page, demo, wishlist campaign

## Project structure

```
├── project.godot
├── scenes/
│   ├── main.tscn
│   ├── player/
│   ├── enemies/
│   ├── weapons/
│   ├── projectiles/
│   ├── pickups/
│   └── ui/
└── scripts/
    ├── main.gd
    ├── autoload/
    ├── player/
    ├── weapons/
    ├── enemies/
    ├── systems/
    ├── visual/
    ├── audio/
    └── ui/
```

## Steam path (when ready)

1. Validate the loop — survive 10+ minutes and want another run
2. Replace placeholder art with consistent pixel office theme
3. Steam page early + demo for **Steam Next Fest**
4. Launch at **$7–9** with a small launch discount
