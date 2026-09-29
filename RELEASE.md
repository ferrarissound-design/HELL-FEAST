# HELL FEAST Release Gate

Release candidate build:

`HF-RC-20260929-06`

This checklist is intentionally short. If a step fails, fix that failure before publishing.

## 1. Get the exact release candidate

From the local HELL-FEAST folder:

```powershell
git pull origin main
git status
rojo serve
```

Expected after the release-gate PR is merged:

- `git status` is clean
- Roblox Studio connects through Rojo
- Play mode shows **DEV PANEL**
- DEV PANEL shows build **HF-RC-20260929-06**
- DEV PANEL shows **QA PASS** with zero failed checks
- DEV PANEL runtime line shows plausible FPS / demon / Soul counts and updates while playing

If the Build ID is different, stop. Studio is not running the intended source.

## 2. Two-minute failure-path test

Open DEV PANEL and run:

1. **Restore HP + Hunger**
2. **Set Hunger → 10**
   - hunger warning should appear
3. **+3 Lost Souls**
   - confirm each kitchen station visibly shows Soul cost + effect
   - cook one recipe in HELL KITCHEN
   - confirm upgrade shrines show effect + starting DNA cost
4. **Kill Player**
   - death overlay should explain the losses
   - respawn should receive the short VEIL
5. **Test OOB Recovery**
   - the player should return to HELL KITCHEN automatically
6. **Save Profile Now**
   - should report success when Studio DataStore access is enabled
   - should fail safely / read-only when it is unavailable

## 3. Combat smoke test

Spawn:

- Imp
- Horned Brute
- Watcher
- Furnace Hound
- Bone Crawler

Confirm:

- each can approach the player
- major obstacles are steered around rather than crossed directly
- telegraphed attacks remain visible
- melee target outline selects sensible targets
- DASH can escape telegraphed attacks
- demon bodies do not physically trap or fling the player

## 4. RC-06 regression gate

Before the boss test, verify the bugs fixed by the deep audit:

1. **Death / respawn**
   - die during an active run
   - death overlay appears
   - Humanoid stays dead until Roblox respawns it
   - controls and one Rusty Cleaver return after respawn
2. **Cover / targeting**
   - place a tree, pillar, cage bar, or kitchen wall between player and demon
   - melee outline must not select through solid cover
   - player melee must not damage through solid cover
   - Brute / Watcher / Furnace Hound must not begin an attack through solid cover
   - hide behind cover during a Brute windup and confirm the delayed slam does not hit through it
3. **Attack sequencing**
   - during a telegraphed enemy attack, confirm an instant melee hit is not stacked into the same windup
   - kill THE BUTCHER while adds remain and confirm combat stops immediately
4. **Interaction validation**
   - cooking, upgrades, Lost Soul capture and graft pickup work normally at prompt range
   - no interaction succeeds from clearly outside prompt range
5. **Vote lock**
   - cast ESCAPE or DESCEND once
   - buttons disable after server confirmation
   - a second choice does not replace the first vote
6. **DASH**
   - DASH works in HELL RUN / BOSS
   - DASH shows WAIT outside active combat
   - cooldown begins only after successful server confirmation
   - on phone emulation, DASH returns to its responsive size after the pulse
7. **UI races**
   - force Phase II then Phase III quickly; the Phase III banner must not be hidden by the older timer
   - begin a new combat run with the result screen still open; it must close automatically
8. **Persistence**
   - trigger Save Profile Now several times around autosave / upgrade activity
   - latest DNA / upgrades / HELL BOOK state must remain after rejoin
   - no stale save should overwrite a newer snapshot

## 5. Boss gate

1. Teleport to **SLAUGHTER PIT**
2. **Spawn THE BUTCHER Now**
3. **Force Butcher Phase II**
4. **Force Butcher Phase III**
5. **Set Butcher → 1 HP**
6. land one real hit

Confirm:

- boss can die
- ESCAPE / DESCEND UI opens
- solo vote resolves quickly
- DESCEND returns the player to HELL KITCHEN with grafts preserved
- the next Circle starts normally

## 6. Watchdog / remote-guard gate

Use the DEV PANEL watchdog/security section:

1. Start THE BUTCHER, then press **WD: Remove Active Boss**.
   - after the configured grace, THE BUTCHER should respawn
   - WD recovery count should increase
2. During normal HELL RUN, press **WD: Empty Active Hunt** while outside SANCTUARY.
   - a demon should be restored after the empty-run grace
   - WD count should increase again
3. Open ESCAPE / DESCEND and press **WD: Expire Open Decision** before voting.
   - overdue missing votes should resolve toward ESCAPE
4. Press **SEC: Send Invalid Dash** and **SEC: Send Invalid Vote**.
   - SEC rejected-request count should increase
   - no movement, vote, or server error should occur

Normal play should leave WD at 0 and SEC at 0 unless you deliberately run these tests or double-fire a guarded control extremely quickly.

## 7. Phone gate

Use Studio device emulation.

Confirm:

- HEALTH and HUNGER remain readable
- navigation does not overlap the HUD
- DASH is reachable
- HELL BOOK opens and closes
- SETTINGS opens and closes
- decision UI fits
- boss HP bar fits
- LOW FX reduces ambient clutter
- attack telegraphs remain readable
- runtime FPS does not collapse under normal Circle 1 combat density

## 8. One normal run

After the debug smoke tests, restart Play mode and do one normal Circle without DEV shortcuts.

Judge only these questions:

- Is the first minute understandable?
- Does the OBJECTIVE line always suggest a sensible next action?
- Does combat feel responsive?
- Do you naturally return to HELL KITCHEN before starving?
- Does the middle of the run stay active without becoming noisy?
- Is THE BUTCHER readable and fair?
- Does the end-of-circle choice make sense?

Write down anything irritating, confusing, unfair, visually broken, or slow. Those findings should drive the next fixes.

## Stop publish immediately if

- DEV PANEL does not show the expected Build ID
- QA status is FAIL
- Output contains a repeating red error
- boss cannot die
- run transition hangs
- controls break after death
- SANCTUARY can be exploited for free attacks
- player can become stranded outside the arena
- progression load failure can overwrite stored data
- critical UI is unusable on phone
- Watchdog recovery loops repeatedly during normal play
- invalid remote payloads can change gameplay state
- death leaves the Humanoid stuck alive / dead in an inconsistent state
- attacks or prompts work through solid cover / clearly invalid distance
- a locked ESCAPE / DESCEND vote can be changed
- a stale profile save overwrites newer progression
