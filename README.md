# HELL FEAST

Roblox prototype: survive a ten-minute HELL RUN by hunting demons for body grafts and capturing Lost Souls for food.

## Core loop

1. Equip the **Rusty Cleaver** and hunt demons.
2. Defeated demons drop graftable parts.
3. Grafts change your body and increase combat power, but stronger bodies burn hunger faster.
4. Capture **Lost Souls** around the arena.
5. Return to **HELL KITCHEN** and cook:
   - **HELL PIE**: +50 hunger
   - **SOUL BURGER**: +30 hunger, +40 HP
   - **SINNER STEW**: costs 2 Souls, slows hunger drain for 35 seconds
6. Survive the 10-minute HELL RUN.
7. Run completion grants **Demon DNA**. Equipped grafts dissolve between runs.

The prototype intentionally uses abstract Lost Souls and stylized transformations rather than gore.

## Current demons

- **Imp** → Imp Legs
- **Horned Brute** → Brute Arm
- **Watcher** → Watcher Eye
- Rare drops → Demon Horn / Demon Wings / Claw Arm

## Rojo setup

This repository is structured for Rojo.

```powershell
git clone https://github.com/ferrarissound-design/HELL-FEAST.git
cd HELL-FEAST
rojo serve
```

Then open Roblox Studio and connect the Rojo plugin to the running server.

Project file: `default.project.json`

## Main files

- `src/shared/Config.lua` - tuning values, demons, grafts, recipes
- `src/server/World.lua` - procedural prototype arena and HELL KITCHEN
- `src/server/Game.server.lua` - run loop, hunger, combat, demons, Souls, cooking, grafts and Demon DNA
- `src/client/HUD.client.lua` - mobile-friendly HUD

## Prototype notes

The arena and NPC visuals are generated in code so a fresh Roblox place can become playable immediately after Rojo sync. Art, animation, audio, boss encounters, PvP, circle descent, permanent upgrade UI and a richer map are future layers rather than blockers for the first playtest.
