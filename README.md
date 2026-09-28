# HELL FEAST

A Roblox survival roguelite about feeding, grafting demon parts, and deciding how deep into Hell you are willing to go.

## Core loop

1. Hunt demons with the **Rusty Cleaver**.
2. Defeated demons drop graftable body parts.
3. Grafts change your avatar and increase combat power, but stronger bodies burn hunger faster.
4. Capture **Lost Souls** around the arena.
5. Return to **HELL KITCHEN** and cook food to stay alive.
6. Survive the circle and defeat **THE BUTCHER**.
7. Choose:
   - **ESCAPE** to bank your Demon DNA.
   - **DESCEND** to keep your grafts and enter a harder circle with larger rewards.
8. Spend banked Demon DNA on permanent upgrades.

The experience uses abstract Lost Souls and stylized transformations rather than gore.

## Current run structure

- Up to **3 circles** per run
- Each circle lasts up to **10 minutes**
- THE BUTCHER enters during the final 90 seconds
- Deeper circles:
  - increase demon health and damage
  - introduce new demon types
  - spawn faster
  - award more unbanked Demon DNA
- Death during a run removes current grafts and costs part of your unbanked DNA
- Escaping banks the haul
- Clearing the deepest circle gives a bonus

## Demons

- **Imp** → Imp Legs
- **Horned Brute** → Brute Arm
- **Watcher** → Watcher Eye
- **Furnace Hound** → Demon Horn
- **Bone Crawler** → Claw Arm
- **THE BUTCHER** → Butcher Arm
- Rare graft drops include Demon Wings

## Food

- **HELL PIE**: strong hunger recovery
- **SOUL BURGER**: hunger + health
- **SINNER STEW**: slows hunger drain temporarily

## Permanent upgrades

Use the upgrade shrine in HELL KITCHEN:

- **VITALITY** → more maximum health
- **METABOLISM** → larger hunger capacity
- **BUTCHERY** → more base damage

Progress and banked Demon DNA persist through DataStore.

## World

The place builds itself from code after Rojo sync.

### Regions

- **ASH FIELDS** — charred trees and mostly Imps
- **BONE YARD** — bone formations, Brutes and deeper-circle Crawlers
- **CINDER RUN** — Furnace Hounds and damaging lava cracks
- **SOUL PENS** — Watchers and the highest concentration of Lost Souls
- **HELL KITCHEN** — central safe landmark for food and permanent upgrades
- **THE SLAUGHTER PIT** — boss destination for THE BUTCHER

Glowing roads and beacons connect the central kitchen to each region. A mobile navigation HUD always points back to HELL KITCHEN, switches to THE BUTCHER during boss time, shows the current region, and warns when hunger becomes dangerous.

The generated world also includes:

- cooking stations
- permanent upgrade shrine
- bone pillars
- Soul Cages
- charred trees
- damaging lava cracks
- circle-specific lighting / atmosphere
- region-biased demon and Lost Soul spawning

## Rojo setup

```powershell
git clone https://github.com/ferrarissound-design/HELL-FEAST.git
cd HELL-FEAST
rojo serve
```

Open Roblox Studio and connect the Rojo plugin to the running server.

Project file: `default.project.json`

## Main files

- `src/shared/Config.lua` - balance, circles, demons, grafts, food and upgrades
- `src/server/World.lua` - generated arena, kitchen and atmosphere
- `src/server/Progression.lua` - persistent Demon DNA and permanent upgrades
- `src/server/Game.server.lua` - combat, hunger, spawning, bosses, runs and escape/descend logic
- `src/client/HUD.client.lua` - HUD and mobile-friendly escape/descend voting

## Current polish

The playable build now also includes:

- first-run objective onboarding
- hit markers and floating damage numbers
- local damage flashes
- lightweight hit / reward audio cues
- THE BUTCHER boss health bar
- distinct procedural silhouettes for each demon family
- telegraphed Brute attacks
- telegraphed Watcher strike zones
- telegraphed Furnace Hound charge lanes
- telegraphed THE BUTCHER slam
- player dash with mobile button + Shift/Q
- Rusty Cleaver swing motion, blade trail and camera kick
- Bone Crawler hunger attacks
- graft and cooking screen feedback

## Next polish targets

The core PvE game is now coherent enough for full Studio playtesting. The next work should be driven by playtest findings: combat animation, bespoke sound/music, better demon art, map landmarks, balance, analytics, and optional Blood Night PvP.
