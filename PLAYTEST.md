# HELL FEAST Studio Playtest

Use the **DEV PANEL** in Roblox Studio to test systems without waiting through a full run. The panel and debug commands are disabled outside Studio.

## Fast smoke test

1. Start Play mode.
2. Open **DEV PANEL**.
3. Press **Restore HP + Hunger**.
4. Spawn each demon and verify:
   - Imp chases and attacks.
   - Horned Brute shows its attack warning before the slam.
   - Watcher shows a ranged strike zone.
   - Furnace Hound shows a charge lane.
   - Bone Crawler reduces hunger when it hits.
5. Graft at least three different parts and verify the avatar changes and stats update.
6. Add **+3 Lost Souls**, return to HELL KITCHEN, and test all three recipes.
7. Set Hunger low naturally or continue playing long enough to verify hunger warnings and starvation behavior.

## Boss test in under two minutes

1. Press **Teleport → SLAUGHTER PIT**.
2. Press **Spawn THE BUTCHER Now**.
3. Fight Phase I briefly.
4. Press **Force Butcher Phase II**.
5. Verify:
   - phase banner appears
   - Imps spawn
   - cross-cut telegraphs appear
6. Press **Force Butcher Phase III**.
7. Verify:
   - FRENZY banner appears
   - Brute spawns
   - boss moves faster
   - slam and cross-cut cadence increases
8. Kill the boss and verify ESCAPE / DESCEND appears.

## Circle scaling test

Repeat the boss test after selecting Circle 1, 2, and 3.

Check that deeper circles visibly change atmosphere and that enemies become harder.


## Hell Director pacing test

Run one normal Circle without using debug spawns.

Watch the HUD value after `HELL:`:

- **QUIET** should appear when the player is badly hurt or low on food.
- **STALK** should cover normal exploration.
- **HUNT** should appear later in a healthy / upgraded run.

Verify:

- enemy density grows when the player is healthy and grafted
- enemy spawning eases when health and hunger collapse
- multiplayer increases the enemy cap
- a starving player with zero carried Souls can receive an emergency nearby Lost Soul
- the emergency Soul does not repeat constantly
- THE BUTCHER phase is not polluted by normal Director demon spawns

## Progression test

During a run:

- kill a demon you have not recorded before
- graft a part you have not used before
- open **HELL BOOK**
- verify the new entries are revealed
- finish or escape the run
- verify the result screen shows kills, Souls, meals, grafts, deaths, discoveries and banked DNA

Rejoin Play mode and verify persistent records when Studio DataStore access is enabled.

## Visual atmosphere check

Verify in each Circle:

- Circle 1 feels dim and smoky but readable.
- Circle 2 shifts warmer and more oppressive.
- Circle 3 shifts colder / stranger with stronger bloom and haze.
- HELL KITCHEN beacon has visible flame and smoke.
- cooking stations glow without obscuring prompts.
- Lost Souls visibly pulse.
- demon deaths produce a brief local shard burst.
- Lost Soul capture produces a rising soul-orb effect.
- ash motes remain lightweight and do not obscure combat telegraphs.

## Mobile check

Use Roblox Studio device emulation in at least one phone landscape size and one tablet size.

Verify:

- HUD automatically shrinks on short / narrow viewports
- top navigation moves below the compact HUD instead of overlapping it
- DASH sits above the standard mobile controls and remains reachable
- keyboard-only dash hint is hidden on touch devices
- HELL BOOK button and book pages remain reachable
- result screen fits without hiding its return button
- ESCAPE / DESCEND buttons fit
- equip the Rusty Cleaver and confirm the intended nearby demon gets an outline
- attack near two demons and verify facing direction influences the selected target
- short melee lunge helps connect attacks without pulling the player a large distance
- ash / death effects are visibly lighter on touch devices
- DEV PANEL is usable during Studio testing
- interaction prompts are readable

## Stop-ship bugs

Do not publish a new build if any of these occur:

- run cannot reach THE BUTCHER
- boss cannot die
- ESCAPE / DESCEND gets stuck
- Hunger cannot be restored
- Lost Souls cannot be cooked
- demon graft cannot be equipped
- death permanently breaks controls
- a client can trigger debug commands outside Studio
- save errors destroy existing progression
