# Pause and menus

> **Status**: Designed 2026-11-21 (`/design-system`, lean, standard, guided, balanced density); awaiting a first `/design-review` in a fresh session
> **Creative Director Review (CD-GDD-ALIGN)**: skipped, Lean mode
> **Author**: project owner + Claude
> **Last Updated**: 2026-11-21
> **Last Verified**: 2026-11-21
> **Implements Pillar**: none defined (the brief has no pillars; the art bible's "calm clarity: stepping out of the world to think" is the state this system serves)

## Summary

Pause and menus is the set of screens outside the world: the title screen, the pause menu, the options screen and control remapping. It lets the player start from a save, stop the world, set the game up for their machine, controller and comfort (window, audio volumes, screen shake, flash reduction, the Atmosphere setting) and rebind every action for keyboard and gamepad, then leave without losing what they did. It exists because a metroidvania of long sessions needs a way to stop and to be set up, and because Save points, World state, Grid map and Parallax each already hand it a screen, a freeze or an option to own.

> **Quick reference** — Layer: `Presentation` · Priority: `Vertical Slice` · Key deps: `Player controller (input), Save points, World state, Rooms and transitions`

## Overview

Pause and menus is everything the player sees and touches outside the world itself: the **title screen**, the **pause menu**, the **options screen** and **control remapping**. The player meets the title screen first, where they continue a save or start a new game; during play they open the pause menu to stop the world; and from either place they reach options, where they change how the game looks, sounds and plays and rebind every action for keyboard and gamepad. Nothing in it is played. It exists so the player can stop, set the game up for their machine, controller and comfort, and leave, without losing what they did. Without it the game could not be started from a save, paused, tuned or quit.

The player operates it directly and only when they choose to: it never opens by itself. It should feel like the art bible's "calm clarity: stepping out of the world to think": flat, ungraded and orderly, with the frozen world dimmed behind it. The system owns the screens, their layout and the **settings file**, where settings and key bindings live apart from the save record (World state). It does not own what its choices do: Continue and New game belong to Save points, the freeze it adopts belongs to the grid map, and each setting's effect belongs to the system it changes (the Atmosphere setting to Parallax, volumes to Audio, the actions to the Player controller).

**Scope.** The first scope is the four screens above. The options hold Atmosphere, audio volumes, display and comfort settings, and remapping rebinds keyboard and gamepad separately, action by action. **[Owner, 2026-11-21]** A collection view (Collectible upgrades) and the grid map as a tab of the pause screen stay later options. The audio volumes are provisional until an Audio GDD exists, and there is no project-wide accessibility standard yet (`design/accessibility-requirements.md` does not exist), so the comfort settings are this system's own and must be reconciled when it does. The systems index sizes this system at S; four screens and a settings file are larger, and the producer should re-estimate it.

## Detailed Design

### Core Rules

Tags: **[Owner]** = the owner's stated rule; **[Rec]** = recommendation, change freely; **[Code]** = how the code works today. `game-designer`, `ux-designer`, `ui-programmer`, `art-director` and `technical-artist` not consulted for this section: Lean mode. Review manually before production. Numbers that other GDDs own are cited by name, never restated.

**Screens**

1. **Four screens.** The **title screen**, the **pause menu**, the **options screen** and, as one of its pages, **controls** (remapping). The options screen has four pages: **Display**, **Audio**, **Comfort** and **Controls**. No screen is ever opened by the game on its own, except the title at launch and after a quit to the title. **[Owner, 2026-11-21: first scope]**
2. **The title screen.** Its items, in order: Continue, New game, Options, Quit. Continue is offered, shown unavailable with World state's message and not selectable, or not shown at all, as Save points rule 10 decides. New game over an existing save asks first, with No selected (Save points rule 12), or shows World state's warning for a newer or unreadable save. Focus starts on Continue when it is offered, else on New game. Continue and New game wait, with the loading mark, until World state's commit chain is idle (World state rule 8). Once one is accepted, the title ignores all input until the arrival's stand-up ends (Save points Edge Cases). Quit leaves the game. **[Rec; the choices' effects are Save points']**
3. **The pause menu.** Its items, in order: Resume, Options, Quit to title, Quit to desktop. Focus starts on Resume. It has no save item (Save points rule 5) and no way back to the last rest. **[Owner, 2026-11-21: no return to rest]** A line under the items reads that progress is kept and the player returns to their last rest, so a quit never looks like a loss. **[Rec]**
4. **Quitting.** Quit to desktop and Quit to title make one last write attempt first (World state quit flow). If a commit is failing, or fails during that attempt, a prompt with No selected shows World state's message and asks to quit anyway; otherwise the quit goes ahead at once with no prompt. Quit to title drops the record and resets `PlayerState` (World state States) and shows the title at once, with Continue and New game waiting for the commit chain (rule 2). **[Rec; the quit flow is World state's]**

**Opening and the freeze**

5. **Opening the pause menu.** The `pause` action, Escape on a keyboard and Start on a gamepad, opens it. It opens in normal play and also during a rest, the death clip, a death's hold and an arrival's stand-up, and in a boss or mini-boss fight (Save points rules 3, 8). It never opens over the title. A press during a transition is held and the menu opens on the first frame after the fade-in ends (Rooms and transitions Edge Cases). **[Rec; the timing is Rooms'; Escape and Start are fixed]**
6. **Pause and the map never stack.** While the map is open, a `pause` press is not a pause: Escape closes the map as `cancel` and Start does nothing. While the pause menu is open, `map` does nothing. This settles Grid map Open Question 7: Escape and Start can be both. **[Rec; Grid map Edge Cases]**
7. **Losing the window's focus.** When the game window loses focus in any state where rule 5 opens the menu, the menu opens as for a `pause` press, including the wait for a fade-in. On the title screen nothing happens. Regaining focus does not close it. **[Owner, 2026-11-21: pause on focus loss]**
8. **The freeze.** Opening the pause menu freezes the game exactly as the map does (Grid map rule 11, Rooms and transitions rule 9): physics, enemies, hazards, projectiles, timers and the Seeker stop, and so do animations, particles, the camera and its shake, and the world's clock (Parallax rule 16). The freeze does not set or depend on `Engine.time_scale`, which a hit-pause resets on its own, and a hit-pause is not held: it runs on real time. Save points' timers stop, and control returns later by the time spent paused. This system adopts the freeze; Grid map owns it. **[Rec; Grid map rule 11]**
9. **Closing.** `pause` again, `cancel` or Resume closes the pause menu, and play resumes on the next frame. Presses made while the menu was open, the closing press included, are discarded, so closing it never jumps, attacks or dashes. A button released while the menu was open reads as not held on the first frame after closing; one still held reads as held, and a direction still held carries on as a run (Grid map rule 12, Rooms and transitions rule 9). **[Rec]**

**Looking and moving through a menu**

10. **Menu input.** Menus use their own fixed actions: up, down, left and right (arrows, WASD, D-pad, left stick), `accept` (Enter, gamepad A) and `cancel` (Escape, gamepad B). They are never remappable, so a bad rebind can never lock the player out of the menus. Cancel goes back one level; at the top of the pause menu it is a resume; at the top of the title it does nothing. Every control also works with the mouse: hovering moves the highlight and a click activates, and the mouse highlight and the keyboard or gamepad focus are shown apart (Godot 4.6 keeps them separate). **[Owner, 2026-11-21: mouse works too; Rec for the keys]**
11. **Look.** Menus draw above the grade, ungraded and flat, and the frozen world sits under a dark scrim (art bible, state table; Parallax Interactions). The UI is rectilinear with 45-degree chamfers, selection is a bracket and brightness, never a hue, no circle appears (the grapple ring is reserved) and text is Bone Pale on Void Black (art bible sections 3, 4). The look is the art bible's, not this GDD's.

**Options and settings**

12. **Options.** Reached from the title and from the pause menu. Each page lists its controls with their current value. A change applies at once: there is no Apply button. Cancel goes back one level, and each page has a Reset to defaults item that asks first, with No selected. **[Rec]**
13. **The settings.** The first scope is this table. The defaults are recommendations; each setting's effect belongs to the system named.

    | Page | Setting | Values | Default | Effect owned by |
    |---|---|---|---|---|
    | Display | Window mode | Windowed, Fullscreen | Windowed | This system |
    | Display | Window size (windowed only) | 1x to `max_scale` (F1), whole numbers | 3x | This system |
    | Display | Atmosphere | Full, Reduced | Full | Parallax rule 14 (its one-line text is Parallax's) |
    | Audio | Master, Music and Effects volume | 0 to 100% in steps of `volume_step` (F2) | Master `master_default`, Music and Effects `group_default` | Audio (no GDD yet: provisional) |
    | Comfort | Screen shake | 0 to 100% in steps of `shake_step` (F3) | 100% | Camera (no GDD yet) |
    | Comfort | Flash reduction | Off, On | Off | Hit feedback and effects, Combat (no GDDs yet) |

    **[Owner, 2026-11-21: audio volumes, display and comfort in the options; Rec: values and defaults]**
14. **Flash reduction.** On, no light effect in the game flashes more than `flash_limit` times in any second (F4: a flash is a rise and a fall in brightness; the general flash threshold of WCAG 2.3.1). The charged heavy's strobing charge glow (its glow steps run as fast as `glow_step_time_fast`, 0.05 s, 20 a second, `attack_data.tres`) becomes a steady glow that brightens as it charges, and hit, finisher and guard-break flashes are shortened to stay inside the limit. This system owns the setting; it places the requirement on Hit feedback and effects and on Combat. **[Rec]**
15. **Screen shake.** The setting scales every camera shake by its percentage; at 0% nothing shakes. The shake of an attack is owned by Combat (`shake_size`, `shake_time`) and the camera applies the scale. **[Rec]**
16. **The settings file.** Every setting and every binding lives in one file of its own, apart from the save record (World state). It is read at startup, before the title screen is shown, and written when a value changes (a slider writes when it is released, not on each step), never on a timer. It holds a format version, a whole number; a value outside its range is replaced by its default, and a key the game does not know is kept and written back unchanged. A missing file gives every default and is written on the first change; an unreadable one gives every default and is kept aside as a copy before the first write. **[Rec]**

**Control remapping**

17. **The controls page.** It lists one row per control that does something, in the order of the controls (move left, move right, up, down, jump, attack, dash, grapple, interact and, when their GDDs exist, map, bow, cast and rapid fire; a later action shows only once its system exists). Each row has two keyboard slots and two gamepad slots. The **Up** row drives `move_up` and `interact`, and the **Down** row drives `move_down` and `crouch`, as the default bindings already share those keys (`PlayerInputBindings`, Code). A gamepad slot holds a button or a trigger pull. The left stick is always movement and is not shown. A mouse button is not a binding. **[Owner, 2026-11-21: keyboard and gamepad separately; Rec: slots and rows]**
18. **Rebinding.** Selecting a slot starts a capture: the next key, button or trigger pull on that device is the new binding, and the capturing press does nothing else. Cancel ends the capture with nothing changed. The new binding applies at once. Each row always keeps at least one keyboard and one gamepad binding, so only a second slot can be cleared. **[Rec]**
19. **Conflicts swap.** If the new binding is already held by another row, the two slots swap: the other row receives the binding the edited slot held, and the screen says so by naming that row. Conflicts are compared between rows, never between the two actions of one row. **[Owner, 2026-11-21: swap]** Escape and Start are reserved for `pause`: they cannot be captured, and the screen says why. **[Rec]**
20. **Reset and labels.** Reset to defaults on the controls page restores every binding after a prompt with No selected. Any prompt or hint elsewhere in the game that names a control reads its current binding from this system, never a fixed key (the rest-area glyph is B or D-pad up today, Save points UI Requirements). **[Rec]**

### States and Transitions

| State | What the player sees | Entered by | Left by |
|-------|----------------------|------------|---------|
| Closed | The game, running | Continue or New game accepted on the title, once the arrival ends (rule 2); the pause menu or the map closes | `pause` or window focus loss (rules 5, 7): to Pause; `map` (Grid map): to the map |
| Title | The title screen | Launch; Quit to title (rule 4) | Continue or New game accepted: to Closed (through the arrival); Options: to Options; Quit |
| Pause | The pause menu over the frozen, dimmed world | Rules 5, 7 | Resume, `pause` or `cancel`: to Closed (rule 9); Options: to Options; Quit to title: to Title; Quit to desktop: the game ends |
| Options | One of four pages | Options chosen from the title or the pause menu | `cancel`: back to the title or the pause menu; a binding slot chosen: to Capture; a Reset: to Prompt |
| Capture | The slot waiting for a press | A binding slot chosen (rule 18) | A press is captured, or `cancel`: back to Options |
| Prompt | A question with No selected | The replace prompt, a quit while a commit is failing, a Reset | Yes or No (or `cancel`, which is No): back to where it was opened |

Only one of these is active at a time; Closed is the state with the world running. **[Rec]**

### Interactions with Other Systems

Of these, only Save points, World state, Rooms and transitions, Grid map, Parallax and Collectible upgrades have GDDs; the rest have code or are not designed, and each interface is **provisional** until its owner is designed.

| System | Direction | Data flowing | Owner of the interface |
|--------|-----------|--------------|------------------------|
| Save points and save/load | Both | Out: Continue, New game and the replace prompt, as the title screen's choices. In: whether Continue is offered, unavailable or hidden and the messages (rules 10-12); pause during a rest, a death or an arrival (rules 3, 8) | Save points owns what each choice does; this system owns the screens |
| World state | Both | Out: quit chosen; quit to the title. In: whether a commit is failing, whether the commit chain is idle, the messages. Settings and bindings are kept apart, in this system's own file | World state owns the record and the quit flow; this system owns the settings file |
| Rooms and transitions | In | The transition's end, so a held pause opens on the first frame after the fade-in (rule 5); the freeze it shares (R3, rule 9) | Rooms and transitions |
| Grid map | Both | The shared freeze and the never-stack rule (rules 6, 8); `cancel` closes the map | Grid map owns the freeze and `map` |
| Parallax, lighting and atmosphere | Both | Out: the Atmosphere value, applied at once. In: the world clock stops while frozen (rule 8); menus draw above the grade | Parallax owns what each value does |
| Player controller (input) | Both | Out: the rebound input map, applied at once. In: the action list and the default bindings | Player controller owns the actions; this system owns changing their bindings |
| Camera | Out | The screen-shake scale (rule 15) | Camera |
| Hit feedback and effects, Combat | Out | The flash-reduction setting and its limit (rule 14) | Those systems apply it |
| Audio | Out | Master, Music and Effects volumes (rule 13) | Audio |
| HUD | Out | The current binding of an action, as a label or glyph (rule 20) | HUD |
| Collectible upgrades | In (later) | `held` and the steps per kind, for an optional collection view | Collectible upgrades |

## Formulas

Four formulas: the largest window scale (F1), the volume to bus gain (F2), the shake scale (F3) and the flash limit (F4). Every `data file` value lives in the settings configuration, never as a constant in code. The `systems-designer` lens was applied in-session for the boundaries (lean mode: no agent); each variable was worked at its minimum, its maximum and 0.

### F1. Largest window scale

The max_scale formula is defined as:

`max_scale = max(1, floor(min(usable_w / base_w, (usable_h - decoration_h) / base_h)))`, and `window_scale = min(saved_scale, max_scale)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base_w, base_h | int (px) | 480, 270 | project display settings (viewport size; owned by the terrain pipeline, rules 1-2) | The game's screen size. Read, never copied |
| usable_w, usable_h | int (px) | 0 or more | calculated (the screen the window is on, minus the taskbar or dock) | The area a window may fill |
| decoration_h | int (px) | 0-80 | calculated (the window system's title bar and borders; 0 when unknown) | Height the window frame takes beyond its content |
| saved_scale | int | 1 or more | settings file | The window size last chosen; the default is 3, the project's 1440 x 810 window |

**Output Range:** 1 to about 16 (a 7680 x 4320 screen). The Window size setting offers every whole number from 1 to `max_scale`. In Fullscreen the same formula is applied to the whole display, with `decoration_h` 0 and the leftover as even letterbox bars: `bar_w = (display_w - base_w x scale) / 2`.
**Boundaries:** a screen smaller than the base (`usable` under 480 x 270) gives a floor of 0, which the `max(1, ...)` raises to 1: the window is then larger than the screen, and the player can still reach Fullscreen. `usable_w` or `usable_h` at 0 (a display that reports nothing) gives 1 and is logged. A saved scale larger than `max_scale` (the player moved to a smaller monitor) is clamped when the window opens, and the file keeps the larger value until the player changes it, so moving back restores it.
**Example:** a 1920 x 1080 screen with a 40 px taskbar and a 31 px title bar: `min(1920 / 480, (1040 - 31) / 270)` = `min(4.0, 3.74)` = 3.74, so `max_scale` 3 (1440 x 810). A 1366 x 768 laptop gives 2 (the default of 3 is clamped to 2). Fullscreen at 2560 x 1440 gives `floor(min(5.33, 5.33))` = 5, a 2400 x 1350 image with bars of 80 px at the sides and 45 px above and below.

### F2. Volume to bus gain

The volume_db formula is defined as:

`volume_db(p) = 20 x log10(p / 100)` for `p > 0`; at `p = 0` the bus is muted

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| p | int (%) | 0-100, a multiple of `volume_step` | settings file | A volume setting: Master, Music or Effects |
| volume_step | int (%) | 5, 10, 20 or 25 (a divisor of 100), starts at 10 | data file | The slider's step. Must divide 100 so that 100% can be reached |
| master_default | int (%) | 0-100, a multiple of `volume_step`, starts at 100 | data file | The Master default |
| group_default | int (%) | 0-100, a multiple of `volume_step`, starts at 80 | data file | The Music and Effects default |

**Output Range:** 0 dB at 100%, down to about -26.0 dB at 5%, and muted at 0%. The Master and a group multiply, which in decibels is a sum.
**Boundaries:** `p` 0 would give minus infinity, so it is a mute and never a number. A `volume_step` of 0 never ends and one that does not divide 100 (30, say) cannot reach 100%: the configuration check rejects both at load, and a default that is not a multiple of the step is rounded to the nearest one.
**Example:** Music 80% is `20 x log10(0.8)` = -1.94 dB; with Master 100% a music sound is attenuated by 1.94 dB. 50% is -6.02 dB and 10% is -20.0 dB. At the defaults Effects play at -1.94 dB, leaving room to raise them above the music.

### F3. Shake scale

The shake_scale formula is defined as:

`applied_shake = shake_size x shake_pct / 100`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| shake_size | float (px) | 0 or more | data file (`attack_data.tres` and the enemy and boss configs; owned by Combat) | One shake's amplitude before the setting |
| shake_pct | int (%) | 0-100, a multiple of `shake_step` | settings file | The Screen shake setting; starts at 100 |
| shake_step | int (%) | 5, 10, 20 or 25 (a divisor of 100), starts at 25 | data file | The setting's step; must divide 100 |

**Output Range:** 0 to `shake_size`. The setting only lowers a shake, never raises one.
**Boundaries:** `shake_pct` 0 removes every shake, so no information may be carried by shake alone: Combat and Hit feedback must also show a hit by the hit-stop, the flash or the animation (requirement on them). `shake_size` 0 stays 0.
**Example:** the third attack's `shake_size` of 3.0 px at 50% is 1.5 px; at 0% it is 0.

### F4. Flash limit

The flash_rate formula is defined as:

`flash_rate(effect) = 1 / (2 x step_time)` for an effect that alternates bright and dim every `step_time`, and with Flash reduction On every effect must satisfy `flash_rate <= flash_limit`, counted together for effects on the same screen area

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| step_time | float (s) | above 0 | data file (the effect's own config, e.g. `glow_step_time_fast` in `attack_data.tres`; owned by Combat and Hit feedback) | How long a bright or dim step lasts |
| flash_limit | int (flashes per second) | 0-3 | constant (WCAG 2.3.1's general flash threshold) | The most flashes in any one second. Never raised above 3 |
| flash_delta | float | 0.10 | constant (WCAG 2.3.1) | The least change in relative luminance that counts as a rise or a fall |

**Output Range:** 0 to `flash_limit` flashes a second with the setting On; with it Off, today's effects reach 10 a second. A flash is a rise and a fall of at least `flash_delta`.
**Boundaries:** `step_time` at 0 is an infinite rate and is rejected by the effect's own check. `flash_limit` 0 allows no flash at all, so steady glows only. A single effect inside the limit can still break it together with another on the same area (a finisher flash during a charge glow), so the count is of the sum.
**Example:** the charge glow at its fastest step, `glow_step_time_fast` 0.05 s, is `1 / (2 x 0.05)` = 10 flashes a second, over the limit of 3, so with Flash reduction On it becomes a steady glow that brightens as it charges. The slow step, 0.22 s, is 2.3 a second and may stay. The shortest alternating step allowed is `1 / (2 x 3)` = 0.167 s.

**Feedback loops:** none. No setting feeds back into another or into the world's state.

## Edge Cases

`systems-designer` not consulted for this section: Lean mode. Review manually before production.

**Opening, closing and the freeze**

- **If `pause` is pressed on the frame a hit brings health to zero**: the hit is resolved first, then the menu opens over the death clip, frozen on its first frame (rule 5 allows a pause during the death clip). **[Rec]**
- **If `pause` and `map` are pressed on the same frame**: the pause is read first and the menu opens; the `map` press is discarded (rule 6). **[Rec]**
- **If the window loses focus during a transition, or the pause is pressed during one**: the request is kept and the menu opens on the first frame after the fade-in ends, even if the focus is back by then (rule 5, Rooms and transitions Edge Cases). **[Rec]**
- **If the window loses focus while the map is open, the title is showing or the pause menu is open**: nothing happens: the map and the menu are already freezes, and the title has nothing to pause (rule 7). **[Rec]**
- **If the pause opens during a hit-pause** (`Engine.time_scale` below 1): the freeze holds on its own, and the hit-pause runs out on real time while the menu is open, so closing the menu starts at normal speed (rule 8, Grid map Edge Cases). **[Rec]**
- **If the pause opens while the Seeker is charging a heavy**: the charge is held by the freeze. If X is still held when the menu closes, the charge goes on; if it was released while the menu was open, the heavy is released on the first frame after closing, as for the map (rule 9). A heavy cannot be charged while frozen. **[Rec]**
- **If the pause opens during a rest, a death's hold or an arrival's stand-up**: every timer stops and control returns later by the time spent paused (Save points Edge Cases). Code that waits on a real-time timer, such as the boss arena's reload stand-in `RELOAD_DELAY` (`create_timer`, which keeps running while the tree is paused by default, Code), must be stopped by the freeze too; this is a requirement on the freeze's mechanism, not a menu rule (Open Questions). **[Rec]**
- **If the window is closed (the close button, Alt+F4) while the game is running**: it is a Quit to desktop, with the same last write attempt and the same prompt when a commit is failing (rule 4). From the title, it closes at once once the commit chain is idle. **[Rec]**
- **If Quit to desktop is chosen from the title while the commit chain is not idle** (just after a quit to the title): the game waits for the in-flight commit and its last attempt, with the loading mark, then closes (World state Edge Cases). **[Rec]**

**Title screen**

- **If Escape (`cancel`) is pressed on the title's top level**: nothing happens (rule 10). **[Rec]**
- **If Continue or New game is pressed again after one was accepted**: the second press is ignored (Save points Edge Cases; rule 2).

**Navigation and the mouse**

- **If the mouse hovers over one item while the keyboard or gamepad has focus on another**: both are shown, each in its own style; Enter or A activates the focused item and a click activates the clicked one. Moving the mouse does not take the focus from the keyboard, and keyboard moves do not move the hover (rule 10). **[Rec]**
- **If a direction is held in a menu**: the highlight repeats after a delay and then at a steady rate, and stops at the first or last item without wrapping. **[Rec]**
- **If the player holds a volume slider with the mouse and drags**: the value applies live as it moves and the file is written once, when the button is released (rule 16).

**Options and settings**

- **If fullscreen is refused by the system, or a window size cannot be set**: the setting returns to its previous value and the page shows one line naming it. **[Rec]**
- **If the window size is changed while in Fullscreen**: the value is kept and applies on returning to Windowed. If the screen changes (a smaller monitor), a saved scale above `max_scale` is clamped, and the file keeps the larger value (F1).
- **If the settings file cannot be written** (disk full, no permission): every change still applies in memory, the options page shows a one-line "settings not saved" mark, and the write is retried on the next change and when the game quits. **[Rec]**
- **If the settings file is missing, unreadable or holds an out-of-range value**: every default is used, or the one value is replaced by its default (rule 16). A file of a newer format keeps its version number when written back, with every key it holds, so an older build never damages a newer build's file. **[Rec; as World state rule 10]**
- **If a saved binding names an action the game no longer has, or one that does not exist yet** (the bow before its GDD): it is kept in the file and ignored (rule 16).
- **If a saved binding breaks a rule** (a hand-edited file: Escape or Start on a game action, one input on two rows, a row left with no keyboard or no gamepad binding): that row takes its default bindings for that device; the other rows are untouched. **[Rec]**

**Remapping**

- **If the captured input is already held by another row**: the slots swap and the screen names that row (rule 19). If the edited slot was empty (a second slot) and the other slot was that row's only binding for that device, the rebind is refused instead and the screen says that row would be left with none. **[Owner for the swap; Rec for the refusal]**
- **If the captured input is already on the row being edited** (the other slot): nothing changes and the screen says so. **[Rec]**
- **If the captured input is Escape or Start**: it is refused and the screen says they open the pause menu. An Escape press while capturing is `cancel` and ends the capture (rules 18, 19).
- **If the captured input is a mouse button, the wheel or a stick movement**: it is ignored and the capture goes on; the screen says only keyboard keys and gamepad buttons and triggers can be bound (rule 17). **[Rec]**
- **If a trigger is captured**: a pull past the dead zone every action uses (`DEADZONE`, `PlayerInputBindings`, Code) counts. **[Rec]**
- **If the window loses focus, or the gamepad disconnects, during a capture**: the capture keeps waiting, and a press delivered to another window is not captured. **[Rec]**
- **If two gamepads are connected**: a binding is for any gamepad, as in the code today (`device` -1). **[Code]**
- **If the player swaps the Up and Down rows**: the swap is between rows, so `move_up` and `interact` move together and `move_down` and `crouch` move together (rule 17).
- **If the player resets the controls while a binding screen's capture is open**: the capture ends first, then the prompt shows (rule 20). **[Rec]**

**Gaps this section does not close** are open questions: what happens to the menus if the only gamepad disconnects in play; whether the Seeker is protected during the fade-in while a pause waits for it (the world runs then, Rooms and transitions rule 9); and how many presses a menu buffers during a load (Open Questions).

## Dependencies

**Upstream (this system needs them):**

| System | Hard / soft | What this system needs | GDD exists |
|--------|-------------|------------------------|------------|
| Player controller (input) | Hard | The action list and default bindings (`PlayerInputBindings.BINDINGS`), and a way to replace an action's bindings at run time and at startup (`register()` leaves an action that already exists untouched, so saved bindings must be applied after it or in its place); input withheld from the Seeker while frozen | No (code exists: `src/player/player_input_bindings.gd`, `player.gd`) |
| Save points and save/load | Hard | What Continue, New game and the replace prompt do, when each is offered, and the messages to show (rules 10-12); pause during a rest, a death or an arrival (rules 3, 8); no save action in the menus (rule 5) | Yes (`design/gdd/save-points-and-save-load.md`, Approved) |
| World state | Hard | Whether a commit is failing, whether the commit chain is idle, the quit flow (a last write attempt, then a prompt while a commit is failing), the record dropped on a quit to the title, and the messages for a newer or unreadable save | Yes (`design/gdd/world-state.md`, Approved) |
| Rooms and transitions | Hard | The freeze (rule 9) and the end of a transition, so a pause waits for the fade-in (Edge Cases); held input carries on across a freeze | Yes (`design/gdd/rooms-and-transitions.md`, Approved per the systems index) |
| Grid map | Soft | The shared freeze and the never-stack rule (Grid map rule 11, Edge Cases); `cancel` closes the map; the `map` action | Yes (`design/gdd/grid-map.md`, Approved) |
| Parallax, lighting and atmosphere | Soft | What Full and Reduced do, applied at once (rule 14); the world's clock stops while frozen (rule 16); menus drawn above the grade | Yes (`design/gdd/parallax-lighting-and-atmosphere.md`, In Review) |
| Camera | Soft | A shake scale it applies to every shake (F3) | No (code exists: `player_camera.gd`) |
| Audio | Soft | Master, Music and Effects buses the volumes set (F2), and what keeps playing while paused | No |
| Hit feedback and effects, Combat | Soft | An effect that obeys the flash limit when Flash reduction is On (F4), and a shake that is never the only sign of a hit (F3) | No (code exists: `attack_data.tres`, `enemy_base.gd`) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Save points and save/load | Hard | The title screen: Continue (offered, unavailable or hidden), New game and the replace prompt, laid out here |
| World state | Soft | The quit flow's prompt and the title's Continue and New game messages |
| Grid map | Soft | Pause that never stacks with the map; later, the map as a tab of the pause screen |
| Parallax, lighting and atmosphere | Soft | The Atmosphere option, Full or Reduced, on the Display page |
| Collectible upgrades | Soft | An optional collection view (later) |
| HUD | Soft | The current binding of an action, to label a prompt or glyph (rule 20) |
| Audio, Camera, Hit feedback and effects, Combat | Soft | The settings' values: volumes, the shake scale and the flash-reduction setting |

**Bidirectional check (2026-11-21):**
- **Save points** lists Pause and menus as a hard dependency for the title screen and its choices. This matches.
- **World state** lists it as soft for the quit flow and the title's messages. This matches.
- **Grid map** lists it as soft for the freeze and the never-stack rule. Its Open Question 7 asked for the Escape and Start binding to be settled; rule 6 here settles it, and Grid map's Edge Cases, criterion and Open Question 7 were updated to match on 2026-11-21 (`/consistency-check`).
- **Parallax** lists it as soft for the Atmosphere option and menus above the grade. This matches.
- **Collectible upgrades** lists it as soft for a collection view. This matches.
- **Rooms and transitions** mentions pause only in its Edge Cases and does not list this system in its Dependencies table; it should, as soft (the freeze's end and a pause waiting for the fade-in).
- **The systems index** row 22 lists only the Player controller (input) and Save points; it should list the five above and the rest as soft.
- **Player controller, Camera, Audio, HUD, Hit feedback and effects, Combat** have no GDD yet. Each needs a matching entry when designed.

## Visual/Audio Requirements

The `art-director` lens was applied in-session; `audio-director` and `sound-designer` not consulted: Lean mode. Review manually before production. The art bible (`design/art/art-bible.md`, sections 1-4) owns the look; its state table gives menus "calm clarity: stepping out of the world to think", flat, ungraded, quiet, animation intensity 1 of 5, still. This section lists what this system needs from it.

- **Opening and closing are cuts.** The scrim and the panel appear on the next rendered frame and vanish on the frame after the close; nothing fades, slides or eases. The world stops at once underneath. **[Rec]**
- **The world under the pause menu** sits under a dark scrim, still and ungraded around the menu; the menu itself has no gradient, vignette, bloom or light direction (art bible, Map, pause and menus). **[Sourced]**
- **Shape grammar.** Panels and controls are rectilinear with 45-degree chamfers, never rounded. A slider is a segmented bar of cells, one per step, like the guard meter. No control is a circle: no round knob, radio button, spinner or loading wheel, because circles are reserved for the grapple (art bible, UI shape grammar). **[Sourced]**
- **Selection** is a bracket and brightness, never a hue: the focused item is the one drawn in Flash White, and the mouse's hover is drawn apart, dimmer and without the bracket (rule 10). **[Sourced; Rec for the hover]**
- **What can be touched reads hard and light, what cannot reads soft and dark** (the art bible's rule): a live item is bright with hard edges; the unavailable Continue is dark and soft-edged and not selectable. **[Sourced]**
- **Colour.** Panels are Void Black and text is Bone Pale, at least 7:1 (the art bible says about 8:1). No key colour (orange, chalk-yellow, copper-green, violet) and no key's reserved shape (the bisque pane, the grooves, the kiln shelf, the ring and cord) appears in menu chrome, and nothing relies on red against green. **[Sourced]**
- **Gamepad glyphs** on the controls page and in the hint line are chamfered tiles carrying the button's letter or name (A, B, X, Y, LB, RB, LT, RT, Start, D-pad), never a drawn circle. **[Rec]**
- **Menus never flash.** No menu animation changes brightness by 10% or more more than `flash_limit` times in a second, whatever Flash reduction says (F4), so the loading mark advances in segments no faster than `1 / (2 x flash_limit)` s and is not a spinner. **[Rec]**
- **The swap notice, the "settings not saved" mark and the loading mark** are text and segmented marks on the panel, in Bone Pale, with no hue.
- **Sound:** a quiet cue for each of moving the highlight, accepting, going back, a refused or swapped rebind and opening or closing the pause menu, each distinct from the others and all quieter than a key pickup's cue. UI cues play on the Effects bus. A volume slider plays a short tick on the bus being changed, as feedback. **[Rec]**
- **While paused**, the world's own sounds stop with the world; whether the music and ambient loops continue, duck or stop is not decided (Open Questions). **[Rec: world sounds stop]**

📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:pause-and-menus` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## Game Feel

These are design targets, not acceptance criteria: they guide the build and become playtest questions.

- **The world stops with the press.** The world never moves on after the pause press, and the menu shows on the next frame, so pausing feels like a hard stop, never a slow one. **[Rec]**
- **Closing hands the Seeker back as left.** After closing, the Seeker is where it was, with no jump, attack or dash from the closing press (rule 9). A playtester asked afterwards never describes a pause as having "cost" them a move.
- **A menu answers the press it is given.** The highlight moves on the frame of the press. A held direction repeats after about 0.4 s and then about every 0.08 s, starting values to confirm in playtest. **[Rec]**
- **Remapping is quick and safe.** A tester asked to move Dash to another key does it in under 30 seconds without help and can say afterwards which other action, if any, was swapped. No tester is left with a control they cannot undo.
- **Menus are quiet.** Opening the pause menu adds no sound louder than the world's own quietest cue, and nothing in a menu moves unless the player moves it (art bible, Map, pause and menus: 1 of 5, still).
- **Comfort settings are found.** A playtester asked "what would you change if the screen flashing or shaking bothered you?" finds Flash reduction and Screen shake in the options without help.

## UI Requirements

- **Screens:** the title screen (three states of Continue), the pause menu, the options screen (Display, Audio, Comfort, Controls), the capture overlay on the controls page, and a prompt (replace a save, quit while a commit is failing, Reset to defaults). Plus three marks: the loading mark, the "settings not saved" mark and the swap notice.
- **Every function works from a keyboard alone and from a gamepad alone;** the mouse is an addition, never the only way (rule 10). **[Rec]**
- **A hint line** on every screen shows the current accept and cancel inputs, read from the bindings or the fixed menu keys, never typed in. **[Rec]**
- **Nothing by colour alone:** state is shown by shape, position, brightness and text (the bracket, the dark unavailable Continue, the swap notice's words).
- **Text:** every visible string goes through the translation function and is localizable, and text fields leave room for strings about 40% longer. The core build ships one language (brief, Out of scope), so the room is cheap insurance. **[Rec]**
- **Text size and legibility** at the 480 x 270 base are not decided: the art bible's UI/HUD section (7) is not authored (Open Questions).
- **Screen readers:** the menus are built from `Control` nodes that can carry accessible names and live regions (Godot 4.5 AccessKit, `Control.accessibility_live` typed in 4.7). Whether the first scope supports a screen reader is an open question, since the engine reference marks these as post-cutoff features.

> **📌 UX Flag — Pause and menus**: This system has UI requirements. In Phase 4 (Pre-Production), run `/ux-design` to create a UX spec for each screen or HUD element this system contributes to (the title screen, the pause menu, the four options pages, the capture overlay, the prompts) **before** writing epics. Stories that reference UI should cite `design/ux/[screen].md`, not the GDD directly.

## Cross-References

| This GDD uses | Owner (system) | Status |
|---------------|----------------|--------|
| Title items, Continue offered, unavailable or hidden, New game and the replace prompt with No selected, no save action, pause during a rest, a death and an arrival, input ignored after an accepted choice (rules 3, 5, 8, 10-12; Edge Cases) | Save points and save/load | `design/gdd/save-points-and-save-load.md`, Approved |
| The commit chain being idle, the quit flow and its prompt, the record dropped on a quit to the title, the messages, settings and bindings kept apart from the record, unknown entries kept (rules 8, 10; Edge Cases; States) | World state | `design/gdd/world-state.md`, Approved |
| The freeze, held input that carries on, a pause waiting for the fade-in (rule 9; Edge Cases) | Rooms and transitions | `design/gdd/rooms-and-transitions.md`, Approved per the systems index; its Dependencies table does not list this system yet |
| The shared freeze (rule 11), the closing rule (rule 12), the never-stack rule (Edge Cases), `map` and `cancel`, Open Question 7 | Grid map | `design/gdd/grid-map.md`, Approved |
| The Atmosphere option and what Full and Reduced do (rule 14), the world's clock stopping (rule 16), menus above the grade | Parallax, lighting and atmosphere | `design/gdd/parallax-lighting-and-atmosphere.md`, In Review |
| `held` and the steps per kind, for an optional collection view | Collectible upgrades | `design/gdd/collectible-upgrades.md`, Approved |
| `PlayerInputBindings.BINDINGS`, `register()` leaving existing actions untouched, `DEADZONE` 0.5, `device` -1 for any gamepad | Player controller | Code (`src/player/player_input_bindings.gd`); no GDD |
| `glow_step_time_fast` 0.05 s, the shake of an attack (`shake_size`, `shake_time`) | Combat | Code (`src/player/attack_data.tres`); no GDD |
| The 480 x 270 screen (viewport size) | Terrain pipeline (rules 1-2) | `design/gdd/terrain-pipeline.md`, In Review |
| The state table (Map, pause and menus), the shape grammar, the UI palette and contrast, the reserved key shapes and colours (sections 1, 3, 4) | Art bible | `design/art/art-bible.md`, sections 1-4 (Draft) |
| Mouse and keyboard focus kept apart (4.6), event device ids (4.7), SDL3 gamepads, AccessKit (4.5) | Engine reference | `docs/engine-reference/godot/modules/ui.md`, `input.md` |

## Acceptance Criteria

Types: **[Auto]** automated test (unit test, or a check on the settings and room data); **[Auto, engine]** an automated test that runs the game; **[Shot]** retained screenshot in `production/qa/evidence/`; **[Play]** playtest record. At standard rigor, Logic and Integration need a test or a playtest record; Visual and UI need a screenshot. The `qa-lead` lens was applied in-session (lean mode: no agent).

**Screens and flow (rules 1-4)**
- **GIVEN** the game launched, **THEN** the title screen is the first thing shown and no other menu is open. **GIVEN** 10 minutes of play with a focused window and no `pause` press, **THEN** no menu opened. **GIVEN** the options screen, **THEN** it has four pages, Display, Audio, Comfort and Controls. **[Auto, engine]** (rule 1)
- **GIVEN** a save World state can load, **THEN** the title lists Continue, New game, Options and Quit in that order with focus on Continue; **GIVEN** no save, **THEN** Continue is absent and focus is on New game; **GIVEN** a save that needs a newer version, **THEN** Continue is shown unavailable with World state's message and activating it does nothing. **[Auto, engine]** for the order, focus and the inert item; **[Shot]** of each of the three title states (rule 2)
- **GIVEN** a commit in flight after a quit to the title, **THEN** Continue and New game are not activatable and the loading mark shows until the commit chain is idle; **GIVEN** Continue accepted, **WHEN** a second press arrives before the arrival's stand-up ends, **THEN** it is ignored. **[Auto, engine]** (rule 2; World state rule 8, Save points Edge Cases)
- **GIVEN** the pause menu, **THEN** its items are Resume, Options, Quit to title and Quit to desktop in that order, focus is on Resume, the input map and the menu hold no save action and no return to the last rest, and the line that progress is kept is shown. **[Auto]** for the items and the absent actions; **[Shot]** of the line (rule 3)
- **GIVEN** a commit failing (test hook), **WHEN** Quit to desktop is chosen, **THEN** one write attempt ran first and a prompt with No selected shows World state's message; **GIVEN** no failing commit, **THEN** Quit to desktop ends the game with no prompt. **GIVEN** Quit to title, **THEN** the title shows at once and the record is dropped. **[Auto, engine]** (rule 4)

**Opening and the freeze (rules 5-9)**
- **GIVEN** the Seeker in play, in a rest, in the death clip, in a death hold, in an arrival's stand-up and in a boss fight, **WHEN** `pause` is pressed, **THEN** the menu opens on that frame in each; **GIVEN** the title, **THEN** a `pause` press does nothing. **GIVEN** a transition, **WHEN** `pause` is pressed during it, **THEN** the menu opens on the first frame after the fade-in ends. **[Auto, engine]** (rule 5)
- **GIVEN** the map open, **WHEN** Escape is pressed, **THEN** the map closes and no pause opens; **WHEN** Start is pressed, **THEN** nothing happens. **GIVEN** the pause menu open, **WHEN** `map` is pressed, **THEN** nothing happens. **GIVEN** `pause` and `map` pressed on one frame, **THEN** the menu opens and the map does not. **[Auto, engine]** (rule 6)
- **GIVEN** a focused window in play, **WHEN** it loses focus, **THEN** the menu opens that frame; **GIVEN** the loss during a transition, **THEN** it opens on the first frame after the fade-in even if focus is back; **GIVEN** the loss with the map open, the title showing or the menu open, **THEN** nothing happens. **[Auto, engine]** (rule 7)
- **GIVEN** an enemy moving, particles drifting and a camera shake running, **WHEN** the menu opens and stays open 5 s, **THEN** every position, timer, animation frame, particle position, the camera and its shake offset and the world's clock are unchanged on the frame it closes. **GIVEN** a hit-pause (`Engine.time_scale` 0.05) running when the menu opens, **THEN** the world is still frozen when the time scale returns to 1.0 and the first frame after closing runs at normal speed. **[Auto, engine]** (rule 8; Grid map rule 11)
- **GIVEN** the pause held 3 s during a rest, **THEN** control returns 3 s later than without it; **GIVEN** 3 s in the death clip, **THEN** `died` and the respawn request come 3 s later (the Save points criteria, run with this menu). **[Auto, engine]** (rule 8; cross-system: Save points Edge Cases)
- **GIVEN** the menu open, **WHEN** jump is pressed and released and then the closing press is made, **THEN** no jump, attack or dash happens after closing; **GIVEN** X released while the menu was open, **THEN** X reads not held on the first frame after closing; **GIVEN** X or a direction still held, **THEN** it reads held and the direction carries on as a run. **[Auto, engine]** (rule 9)

**Navigation and look (rules 10, 11)**
- **GIVEN** any screen, **WHEN** up, down, accept and cancel are pressed from a keyboard and from a gamepad, **THEN** the highlight moves, the item activates and the screen goes back one level; **GIVEN** the top of the pause menu, **THEN** cancel resumes; **GIVEN** the title's top level, **THEN** cancel does nothing. **GIVEN** the controls page, **THEN** none of the menu actions is listed or rebindable. **[Auto, engine]** (rule 10)
- **GIVEN** the mouse over item A and the keyboard focus on item B, **THEN** both are drawn in their own style, Enter activates B and a click on A activates A, and moving the mouse leaves the keyboard focus where it was. **GIVEN** a held direction, **THEN** the highlight repeats and stops at the last item without wrapping. **[Play]** on a keyboard, a gamepad and a mouse (rule 10, Edge Cases; Godot 4.6 keeps mouse and keyboard focus apart)
- **GIVEN** each screen (the title in its three states, the pause menu, the four options pages, a capture and a prompt), **THEN** it is drawn above the grade with no gradient, vignette or bloom, the world under the pause menu sits under a dark scrim, selection is a bracket and brightness, no circle appears, and body text on its panel has a contrast ratio of at least 7:1. **[Shot]** of each in `production/qa/evidence/`, with art director sign-off (rule 11; art bible sections 3, 4)

**Options and settings (rules 12-16)**
- **GIVEN** the options screen, **WHEN** a value is changed, **THEN** it applies on that frame with no Apply step; **WHEN** Reset to defaults is chosen, **THEN** a prompt with No selected shows first and the page's values return to the table's defaults only after Yes. **[Auto, engine]** (rule 12)
- **GIVEN** no settings file, **THEN** Window mode is Windowed, Window size is 3x or `max_scale` if lower, Atmosphere is Full, Master is `master_default`, Music and Effects are `group_default`, Screen shake is 100% and Flash reduction is Off. **[Auto]** (rule 13)
- **GIVEN** Atmosphere changed from Full to Reduced, **THEN** the room's atmosphere changes on that frame with no restart (Parallax rule 14). **GIVEN** the menu open 3 s, **WHEN** it closes, **THEN** every particle, fog offset and glow phase is where it was (Parallax's own criterion, run with this menu). **[Auto, engine]** (rule 13; cross-system: Parallax)
- **GIVEN** Flash reduction On and a full charge of the heavy, a 3-hit combo and a finisher played back to back, **WHEN** the screen's luminance is captured at the game's frame rate, **THEN** no 1-second window holds more than `flash_limit` (3) rises and falls of 10% or more; **GIVEN** the setting Off, **THEN** the charge glow still steps at `glow_step_time_fast`. **[Auto]** for every effect config's `step_time` against F4; **[Play]** with a luminance capture for the played sequence (rule 14, F4)
- **GIVEN** Screen shake at 100%, 50% and 0% and the third attack's shake of 3.0 px, **THEN** the camera's peak shake offset is 3.0, 1.5 and 0 px; **GIVEN** 0%, **THEN** a hit still shows its hit-stop, flash or animation. **[Auto, engine]** (rule 15, F3)
- **GIVEN** a change to any setting or binding, **THEN** the settings file holds it and the save record holds neither; **GIVEN** a slider dragged through 10 values and released, **THEN** one write happened, on release. **GIVEN** a missing file, **THEN** every default is used; **GIVEN** an unreadable file, **THEN** every default is used and a copy is kept before the first write; **GIVEN** a value out of range, **THEN** only that value is replaced; **GIVEN** a file with an unknown key and one of a newer version, **THEN** a write keeps the key and the newer version number. **GIVEN** the file unwritable, **THEN** the change applies, the "settings not saved" mark shows and a write is retried on the next change and on quit. **[Auto]** (rule 16, Edge Cases)

**Control remapping (rules 17-20)**
- **GIVEN** the controls page, **THEN** it lists a row for every action that does something today, each with two keyboard and two gamepad slots, no row for bow, cast or rapid fire until their systems exist, and no mouse-button option; **GIVEN** the Up row rebound, **THEN** `move_up` and `interact` both follow it, and the Down row drives `move_down` and `crouch` the same way. **[Auto, engine]** (rule 17)
- **GIVEN** a slot selected, **WHEN** a key is pressed, **THEN** it becomes the binding on that frame, that press does nothing else, and cancel instead leaves everything unchanged. **GIVEN** a row, **THEN** it cannot lose its last keyboard or its last gamepad binding. **[Auto, engine]** (rule 18)
- **GIVEN** a captured input held by another row, **THEN** the slots swap, the other row now holds the edited slot's old binding and the screen names it; **GIVEN** an empty second slot and an input that is the other row's only binding for that device, **THEN** the rebind is refused and the screen says why. **GIVEN** Escape or Start captured, **THEN** it is refused and the screen says they open the pause menu; **GIVEN** a mouse click or a stick movement, **THEN** it is ignored and the capture goes on. **GIVEN** the input already in the other slot of the same row, **THEN** nothing changes. **[Auto, engine]** (rule 19, Edge Cases)
- **GIVEN** a trigger pulled to 0.4 and then to 0.6 during a capture, **THEN** only the 0.6 pull is captured (the dead zone is 0.5). **[Auto, engine]** (Edge Cases)
- **GIVEN** every control rebound, **WHEN** Reset to defaults is chosen on the controls page and Yes is answered, **THEN** every binding equals `PlayerInputBindings.BINDINGS`; **GIVEN** a rebound Jump, **THEN** a stub label provider reads the new binding for `jump`, never the default (HUD has no GDD, so a stub stands in). **[Auto]** (rule 20)
- **GIVEN** a settings file whose bindings break a rule (Escape on a game action, one input on two rows, a row with no gamepad binding), **WHEN** it loads, **THEN** only those rows take their default bindings for that device. **[Auto]** (Edge Cases)

**Formulas (F1-F4)**
- **GIVEN** `base` 480 x 270, **WHEN** F1 runs for usable 1920 x 1040 with a 31 px frame, 1366 x 768 with 31, 400 x 200 with 0, 0 x 0 and 7680 x 4320 with 0, **THEN** `max_scale` is 3, 2, 1, 1 (logged) and 16. **GIVEN** a saved scale of 3 and `max_scale` 2, **THEN** the window opens at 2 and the file still holds 3. **GIVEN** Fullscreen on 2560 x 1440, **THEN** the scale is 5 with bars of 80 px at the sides and 45 px above and below. **[Auto]** (F1, boundary)
- **GIVEN** `volume_db`, **WHEN** p is 100, 80, 50, 10, 5 and 0, **THEN** the result is 0, -1.94, -6.02, -20.0 and -26.02 dB (to 0.01) and a mute for 0, never an infinity. **GIVEN** a configuration with `volume_step` 0, 15 or 30, **THEN** it is rejected by name; with 5, 10, 20 or 25 it passes; **GIVEN** a default of 84 at step 10, **THEN** it becomes 80, and 86 becomes 90. **[Auto]** (F2, boundary)
- **GIVEN** `shake_size` 3.0, **WHEN** `shake_pct` is 100, 50 and 0, **THEN** `applied_shake` is 3.0, 1.5 and 0; **GIVEN** `shake_size` 0, **THEN** 0 at any setting; **GIVEN** a `shake_step` of 30, **THEN** the configuration is rejected. **[Auto]** (F3, boundary)
- **GIVEN** `step_time` 0.05, 0.16, 0.167 and 0.22, **WHEN** F4 runs, **THEN** the rates are 10, 3.125, 2.99 and 2.27 flashes a second and only 0.167 and 0.22 pass; **GIVEN** `step_time` 0, **THEN** the effect's config is rejected; **GIVEN** two effects each at 2 on the same area, **THEN** the sum of 4 fails. **[Auto]** (F4, boundary)

**Performance**
- **GIVEN** `pause` pressed in play, **THEN** the menu is drawn on the next rendered frame; **GIVEN** the menu closed, **THEN** no menu node is processing a frame (zero menu `_process` calls over 60 frames). **[Auto, engine]**

**Gaps found by the QA lens:**
- The flash limit needs a luminance capture to be proven on screen; Hit feedback and effects has no GDD, so the automatable part is each effect's `step_time` against F4 and the rest is a **[Play]** record.
- The mouse-and-keyboard focus criterion needs real hardware and cannot be fully automated. It is a **[Play]** record.
- The look criteria use art bible sections 3 and 4; section 7 (UI/HUD direction) is not authored, so type size and legibility at the 480 x 270 base are not yet testable (Open Questions).
- The freeze criteria state behaviour only. How the freeze is built (the tree's pause or the game's own freeze) is an ADR, and the real-time timers it must also stop (`RELOAD_DELAY`) have no criterion until then.
- The Audio criteria test the gain only. What keeps playing while paused is not decided, so it is untested.
- Nothing tests a gamepad disconnecting in play, a menu's buffering during a load, or a protected fade-in while a pause waits (Open Questions).

## Open Questions

Owner is the project owner unless stated. Each has a target step instead of a date.

1. **How the freeze is built.** Rule 8 states the behaviour. The tree's pause or the game's own freeze is a technical choice, and two facts bear on it: the hit-pause sets `Engine.time_scale` and restores it on a real-time timer, and `create_timer` keeps running while the tree is paused by default, so the boss arena's `RELOAD_DELAY` would fire during a pause. Owner: technical director with Grid map and Rooms and transitions. Target: an ADR before the first pause story.
2. **UI resolution and text size.** The project renders at a 480 x 270 viewport with integer scaling, and the brief mentions 1920 x 1080 for the world. Whether the UI draws in the viewport or on its own layer decides how crisp text is and how large it must be. Owner: art director and technical artist. Target: the art bible's section 7, before the UX specs.
3. **What plays while paused.** Whether music and ambient loops continue, duck or stop. Owner: Audio GDD. Target: before Audio is designed.
4. **A gamepad that disconnects in play.** Whether the pause opens with a line naming the missing pad (the keyboard still works). Owner: UX. Target: the options and pause UX specs.
5. **A pause waiting for the fade-in.** Rooms and transitions rule 9 resumes the world as the fade-in begins, and rule 5 here opens a held pause only after it ends, so the Seeker can be hit during the fade-in with a pause pending. Whether the pause opens at the start of the fade-in instead. Owner: Rooms and transitions with this system. Target: the next review of either.
6. **Menu input during a load.** How many presses a menu buffers while the loading mark shows, if any. Owner: UX. Target: the title-screen UX spec.
7. **The title screen's look and name.** A still, a region scene or a flat field with the working title, and the final title. Owner: art director. Target: the art bible's section 7.
8. **The accessibility standard.** `design/accessibility-requirements.md` does not exist, so the Comfort settings, the 7:1 contrast, the glyph rule and screen-reader support are this system's own and must be reconciled with it. Owner: UX with the producer. Target: before Vertical Slice.
9. **The flash limit's reach.** F4 counts flashes, and the WCAG area clause and the sum across effects need measuring on captures. Hit feedback and effects and Combat must adopt `flash_limit` and a steady alternative to the charge glow. Owner: art director with Combat. Target: their GDDs.
10. **Starting values to confirm in playtest.** The default volumes (100, 80, 80) and steps, the shake step of 25%, the default window of 3x, and the key repeat (about 0.4 s then 0.08 s). Owner: game designer. Target: the first playable title and options.
11. **Later options.** The collection view (Collectible upgrades), the map as a tab of the pause screen (Grid map Open Question 7), a toggle-to-charge option for the heavy, and mouse bindings. Owner: the producer. Target: after the first scope plays.
12. **Owed changes in other GDDs.**
    - Rooms and transitions: list this system in its Dependencies table, as soft.
    - Grid map: done 2026-11-21 (its Edge Cases, criterion and Open Question 7 now follow rule 6).
    - Parallax: the Atmosphere option sits on the Display page.
    - The systems index: row 22's dependencies.
    - The registry: `flash_limit` and the Escape and Start reservation, once Hit feedback and effects and Combat adopt them.

    Target: the next revision of each.
13. **Scope.** The systems index sizes this system at S. Four screens, a settings file, remapping and four settings groups are larger. Owner: producer. Target: before sprint planning.
