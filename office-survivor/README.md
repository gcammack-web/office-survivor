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

1. Open Godot → **Import** → select `office-survivor/project.godot`
2. Press **F5** (or click Play)

Headless smoke test:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path "/Users/garrettcammack/simple-game/office-survivor" --quit-after 2
```

## Controls

| Input | Action |
|-------|--------|
| WASD / Arrow keys | Move |
| — | Weapons fire automatically |

On level-up, the game briefly slow-mos, then pauses and offers **3 random upgrades**. Pick one to continue.

## Vertical slice scope

**Included (playable now):**

- Title screen → survival run → death → retry
- Auto-attacking **Stapler** starter weapon
- Unlockable **Coffee Mug** (damage aura), **Passive-Aggressive Email** (homing), and **Printer Jam** (screen-wide freeze + burst damage)
- Passive upgrades: speed, max HP, global damage, **Office Magnet** (XP pickup radius)
- Enemies: **Deadlines**, **Meetings**, **Slack pings**, plus tier unlocks — **Overdue Reports** (Lv5+), **Micromanagers** (Lv10+), **Crunch Time** (Lv15+), **Executives** (Lv20+)
- **Level milestone bosses** at levels 10, 20, 30+ (Quarterly Review, etc.) — angry manager sprites, high HP/damage, big XP drops
- **Timed escalation events** (once per run):
  - **5:00** — Stand-up Meeting (tighter spawn ring)
  - **10:00** — Performance Review (mini-boss)
  - **15:00** — All-Hands (swarm + stronger boss)
- Spawn pressure ramps **monotonically** with player level and run time (no difficulty dips at 20+)
- Code-generated pixel sprites with outlines (office worker player, enemies, boss managers, weapon icons, XP orbs)
- Procedural chiptune background music + SFX (weapon fire, boss spawn, level-up, hits)
- Juice: hit flash, XP orb pulse, enemy death burst, level-up camera shake, upgrade slow-mo
- **Death recap** on game over: time survived, level reached, enemies/bosses cleared, best weapon
- **Milestone HUD** label showing the next timed event or level boss (whichever is estimated sooner)
- **Floating combat feedback**: green heal numbers on donut pickup, red/orange damage numbers on hits (pooled, rate-limited)
- XP orbs with magnet pickup (upgradeable via Office Magnet)
- Escalating spawn rate over time and with player level

**Not yet (next milestones):**

- Meta-progression between runs (unlockables, permanent upgrades)
- Steam page, demo, wishlist campaign
- Balance pass and content expansion

## Project structure

```
office-survivor/
├── project.godot
├── scenes/
│   ├── main.tscn              # Entry point
│   ├── player/
│   ├── enemies/
│   ├── weapons/
│   ├── projectiles/
│   ├── pickups/
│   └── ui/
└── scripts/
    ├── main.gd
    ├── autoload/              # GameEvents, GameAudio, RunStats
    ├── player/
    ├── weapons/
    ├── enemies/
    ├── systems/               # Spawner, upgrades, run events
    ├── visual/                # SpriteFactory (pixel art)
    ├── audio/
    ├── ui/
    └── world/
```

## Steam path (when ready)

1. **Validate the loop** — if surviving 10+ minutes isn't fun, iterate on upgrades/enemies first
2. **Replace placeholder art** — simple pixel office worker + paper enemies read well on stream
3. **Add one streamable moment** — Printer Jam hits every enemy on screen with a dramatic freeze
4. **Create Steamworks app** + export presets in Godot (Export → Add Windows/macOS/Linux)
5. **Steam page early** + demo for **Steam Next Fest**
6. **Launch at $7–9** with a small launch discount

## Design notes

| Weapon | Fantasy | Behavior |
|--------|---------|----------|
| Stapler | Ranged staple bursts | Fires at nearest enemy; more staples + faster fire at higher levels |
| Coffee Mug | Caffeinated aura | Burns enemies in a radius around you |
| Passive-Aggressive Email | "Per my last message..." | Homing projectiles |
| Printer Jam | Office equipment meltdown | ~28s cooldown; slows everyone, damages all on-screen enemies |

| Enemy | Fantasy | Behavior |
|-------|---------|----------|
| Slack ping | Teal notification | Swarm fodder — **1 XP** (Lv1+) |
| Deadline | Red rush job | Fast, fragile — **3 XP** (Lv1+) |
| Meeting | Purple calendar block | Slow, tanky — **6 XP** (Lv3+) |
| Overdue Report | Orange urgent doc | Fast, medium HP — **5 XP** (Lv5+) |
| Micromanager | Purple clipboard boss | Tough, more damage — **10 XP** (Lv10+) |
| Crunch Time | Red stress bruiser | High HP, slow — **14 XP** (Lv15+) |
| Executive | Dark suit elite | Fast, high XP — **20 XP** (Lv20+) |
| Performance Review | Angry manager boss | High HP, slow — **80 XP** |
| All-Hands Chair | Executive escalation | Stronger boss at 15:00 — **140 XP** |
| Quarterly / Mid-Year / Annual Review | Level milestone bosses | Spawn at levels 10, 20, 30+ with scaled stats and XP |

---

The original **Simple Quest** web RPG remains in the repo root as a separate portfolio piece.
