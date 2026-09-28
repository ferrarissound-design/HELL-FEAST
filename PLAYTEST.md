# HELL FEAST Studio Playtest

Use the **DEV PANEL** in Roblox Studio to test systems without waiting through a full run. The panel and debug commands are disabled outside Studio.

Before testing anything else, confirm DEV PANEL reports build **HF-RC-20260929-05** and **QA PASS**. If not, treat the Studio session as invalid until the sync or failing check is fixed.

Also watch the DEV PANEL runtime line during tests. It reports FPS, active demons, active Lost Souls, Circle, run state, and the effective FX mode.

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
6. Add **+3 Lost Souls**, return to HELL KITCHEN, confirm recipe costs / effects are readable, and test all three recipes.
   - confirm VITALITY / METABOLISM / BUTCHERY shrines show their effect and starting DNA cost
7. Set Hunger low naturally or continue playing long enough to verify hunger warnings and starvation behavior.
8. Take damage and confirm the custom HEALTH bar updates immediately.
9. Raise VITALITY and confirm the HEALTH maximum updates.
10. Watch OBJECTIVE while changing state:
    - no graft → hunt a demon / graft
    - low hunger with Souls → return and cook
    - low hunger without Souls → capture a Lost Soul
    - boss active → defeat THE BUTCHER
    - decision open → choose ESCAPE or DESCEND

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
9. In solo play, vote once and confirm the decision resolves almost immediately instead of waiting the full timer.
10. In a 2-player test, confirm live ESCAPE / DESCEND tallies update.
11. Leave one eligible player unvoted and confirm the missing vote safely counts toward ESCAPE at timeout.
12. Join after the decision already opened and confirm the late joiner cannot alter that decision.
13. Choose DESCEND and confirm the player returns to HELL KITCHEN with grafts preserved before the next Circle begins.

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
- start another session with TotalRuns > 0 and confirm FIRST DESCENT tutorial does not repeat
- die during a run and confirm the death overlay clearly states graft / Soul / DNA loss

Rejoin Play mode and verify persistent records when Studio DataStore access is enabled.

## Demon movement / obstacle test

Use the DEV PANEL to spawn several enemy types near real map geometry.

Verify:

- demons steer around charred trees instead of moving straight through trunks
- Brutes steer around Bone Yard pillars
- enemies route around Soul Cage bars rather than clipping directly through them
- enemies do not treat their target player's character as a wall
- multiple demons can still converge on a player without freezing each other
- moving anchored demon bodies do not physically trap, shove, or fling the player
- demons that cannot find a clear left or right step pause / face the player instead of teleporting through an obstacle
- sanctuary pushback still works with obstacle steering enabled
- THE BUTCHER remains able to move normally inside the open SLAUGHTER PIT

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
- SETTINGS opens and closes without covering critical combat controls
- LOW / HIGH / AUTO FX settings visibly change ambient effect density
- Reduced flashes weakens full-screen flashes without hiding attack telegraphs
- Damage numbers can be disabled
- Camera motion can be disabled while attack and dash gameplay still works

## Watchdog / remote guard test

Use the DEV PANEL watchdog/security buttons.

Verify:

- removing an active THE BUTCHER causes exactly one watchdog boss recovery after the grace window
- emptying a normal active hunt outside SANCTUARY causes exactly one demon recovery
- marking an open decision overdue resolves missing votes toward ESCAPE
- each successful repair increments WD and updates the last recovery reason
- normal play does not continuously increment WD
- invalid dash payload increments SEC but does not move the player
- invalid vote payload increments SEC but does not alter vote tallies
- malformed / rapid remote calls do not produce repeating server errors

## Release safety test

Verify the failure cases that can ruin a public session:

- stand inside HELL KITCHEN and confirm demons stop outside the sanctuary boundary
- confirm the Rusty Cleaver cannot damage enemies from inside SANCTUARY
- step outside and confirm combat immediately works again
- walk a demon toward the sanctuary edge and confirm it cannot remain inside the protected radius
- fall below the map and confirm the player is returned to HELL KITCHEN
- cross the outer arena bounds and confirm recovery also works
- join an already-running server and confirm the arrival protection message / VEIL status appears
- confirm enemies ignore a newly joined or newly respawned player during the short arrival grace
- start a fresh run and confirm all players are returned to HELL KITCHEN
- with Studio DataStore access disabled or failing, confirm the HUD shows SAVE READ-ONLY
- confirm permanent upgrades refuse purchases while progression is read-only
- confirm a failed profile load cannot write default values over the profile
- restore DataStore access and confirm normal saves clear the failure state
- leave a session running for at least the configured autosave interval and confirm a save occurs without ending the run
- simulate a missing v2 profile with legacy DNA available and confirm migration succeeds
- simulate legacy DataStore read failure and confirm the session becomes read-only instead of writing a zero-value migration

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
- enemies can attack players inside SANCTUARY
- players can attack demons from inside SANCTUARY
- falling out of the map leaves a player stranded
- a failed profile load is allowed to overwrite stored progression
- watchdog enters a repeated recovery loop
- invalid custom remote payloads can mutate gameplay state
