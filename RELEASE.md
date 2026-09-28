# HELL FEAST Release Gate

Release candidate build:

`HF-RC-20260929-01`

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
- DEV PANEL shows build **HF-RC-20260929-01**
- DEV PANEL shows **QA PASS** with zero failed checks

If the Build ID is different, stop. Studio is not running the intended source.

## 2. Two-minute failure-path test

Open DEV PANEL and run:

1. **Restore HP + Hunger**
2. **Set Hunger → 10**
   - hunger warning should appear
3. **+3 Lost Souls**
   - cook one recipe in HELL KITCHEN
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

## 4. Boss gate

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

## 5. Phone gate

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

## 6. One normal run

After the debug smoke tests, restart Play mode and do one normal Circle without DEV shortcuts.

Judge only these questions:

- Is the first minute understandable?
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
