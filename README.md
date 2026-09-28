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

## HELL BOOK & run records

Progress now leaves a permanent trail instead of disappearing between runs:

- first demon kills unlock permanent HELL BOOK entries
- first graft use unlocks permanent graft entries
- undiscovered entries stay hidden as ???
- discovered demons show their region and combat identity
- discovered grafts show slot and gameplay modifiers
- lifetime runs, kills, boss kills, best circle and discoveries persist
- every finished run shows a result card with kills, Souls, meals, grafts, deaths, discoveries and banked Demon DNA

The HELL BOOK can be opened from the in-game button at any time.

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
- three-stage THE BUTCHER boss fight
- Phase II minion summons + cross-cut attack
- Phase III FRENZY with faster movement and tighter attack cadence
- dramatic boss phase UI / visual rage state
- player dash with mobile button + Shift/Q
- Rusty Cleaver swing motion, blade trail and camera kick
- Bone Crawler hunger attacks
- graft and cooking screen feedback

## Mobile-first polish

The client now adapts to smaller screens instead of assuming a desktop viewport:

- responsive HUD, navigation, boss bar, HELL BOOK and results scaling
- mobile DASH placement above standard touch controls
- keyboard-only hints hidden on touch
- directional melee target assist
- subtle local target outline while the Rusty Cleaver is equipped
- short attack lunge to reduce frustrating mobile whiffs
- automatic low-FX mode on touch / small viewports
- reduced ash, death shards and Lost Soul update frequency on lower-power layouts

## Environmental polish

The generated world now has a stronger atmosphere without relying on custom art assets:

- Circle-specific color grading, haze and bloom
- HELL KITCHEN fire, smoke and local light
- glowing cooking stations
- pulsing Lost Soul highlights
- lightweight local ash motes
- demon death shard bursts
- Lost Soul capture effects

These effects are deliberately lightweight and keep combat telegraphs readable on mobile.

## Adaptive Hell Director

Normal-circle pacing is now controlled by a lightweight server-side Director instead of a fixed spawn timer.

It considers current Circle, run progress, living player count, health, hunger and graft power. Healthy upgraded groups gradually face more pressure, while badly hurt or starving players get breathing room. A player who reaches critical hunger with no carried Souls can receive a cooldown-limited emergency Lost Soul so a run is less likely to collapse into an unrecoverable food soft-lock.

The HUD exposes only the atmospheric state **QUIET / STALK / HUNT**, not the underlying assistance math.

## Release safety

Public-session safeguards now protect the parts most likely to create a bad first impression or progression loss:

- HELL KITCHEN is a real **SANCTUARY**: demons will not target protected players there and non-boss demons are pushed back outside its marked boundary
- weapons are sealed inside SANCTUARY so the safe zone cannot be used to attack enemies for free
- fresh runs return players to HELL KITCHEN
- joining / respawning grants a short arrival veil before demons can target the player
- falling below the map or leaving the arena automatically returns the player to HELL KITCHEN
- profile load failures switch permanent progression into read-only mode instead of saving default data over an unknown profile
- saves retry before reporting failure
- the HUD clearly shows **SAVE READ-ONLY** when permanent progression is unavailable

## Studio playtest tools

When running inside Roblox Studio, a **DEV PANEL** is available for rapid QA. It can restore health/hunger, grant Souls, equip grafts, spawn each demon, jump directly into THE BUTCHER, force boss phases, switch circles, teleport between key locations, and clear spawned entities.

The server independently rejects all debug commands outside Studio. A Studio-only startup diagnostic also checks configuration references, HELL BOOK entries, world folders, recipes and remotes.

See `PLAYTEST.md` for the fast test sequence.

## Next polish targets

The core PvE game is now coherent enough for full Studio playtesting. The next changes should be driven by observed playtest problems rather than feature count: balance, pacing, animation, bespoke audio/music, art quality, analytics, and optional Blood Night PvP.
