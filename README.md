SB46-03 Sparklebug
=================

This is a fictional transport spacecraft; any similarity with real or fictional
aircraft or spacecraft is accidental and completely unintentional.

![Sparklebug hovering](Splash/hover-departure.jpg)

Characteristics
---------------

The Sparklebug is a single-stage-to-orbit (SSTO), vertical takeoff/landing
(VTOL) transport spacecraft.

It is equipped with the following propulsion systems:

- Air-breathing main engines (4, though only 2 currently simulated), mounted in
  two rotating nacelles on the wing tips.
- Rocket engine (3, though only 1 currently simulated), mounted in the tail.
- 12 RCS thrusters.

A typical mission would involve the following flight phases:

- Vertical takeoff
- Accelerate to subsonic climb speed, main engines provide lift and thrust
- At a suitable altitude, engage afterburners, tilt main engines forward,
  and go supersonic. Wings now provide sufficient lift for sustained
  aerodynamic flight.
- Supersonic climb to upper atmosphere.
- Engage rocket engine to continue climb and acceleration
- Main engine shutoff around 100k ft
- Orbital insertion using rocket engine and RCS
- Deorbit burn using rocket engine
- Ballistic descent to upper atmosphere; pitch up ~40 degrees for optimal drag
- Main engines started once air density is sufficient, pointed down to further
  decrease speed
- Transition to aerodynamic flight, glide down to a suitable atmospheric cruise
  altitude and speed
- Approach destination in aerodynamic flight
- Vertical landing

Flying the Sparklebug
---------------------

### General Considerations

Fundamentally, the Sparklebug will fly in 3 very distinct regimes: hovering,
aerodynamic, and orbital.

In the **hovering** regimen, the main engines point fully or partially up and
provide the majority of lift. When hovering, the Sparklebug flies similar to a
helicopter: engine thrust is used to control vertical speed, and pitch, bank
and yaw axes control lateral movement. (It is possible to also use engine
pitch for forward speed control, but making fine-grained adjustments this way
is difficult). When hovering, keep in mind that any control inputs may alter
the effective amount of lift from the engines, and especially when banking and
turning the aircraft, you may need to compensate with the throttle.

In the **aerodynamic** regimen, the Sparklebug flies much like a conventional
fixed-wing aircraft. The engines generate forward thrust, and are pointed fully
or partially forward; vertical speed is controlled with pitch (and thrust), the
yaw axis is typically configured to provide coordinated flight via yaw damping,
and the bank axis is used for turning. Note however that the turn rate you can
achieve is rather disappointing, due to the tiny wings. At high altitude, the
stardrive can be enabled to provide additional thrust; the stardrive however
cannot be tilted, so it always points forward.

In the **orbital** regimen, the Sparklebug flies outside the atmosphere, and
thus aerodynamic forces are not relevant. Orbital maneuvering is performed by
turning the spacecraft with the RCS system, and applying thrust using the
stardrive.

### The FBW System

Each axis (pitch, bank, yaw) has its own separate FBW law; laws can be cycled
with the q, w, and e keys (q = pitch, w = bank, e = yaw). The FBW automatically
maps bank and yaw to the RCS and main engine pitch difference: when the engines
are pitched full-forward, the bank axis controls engine pitch, when they are
pointing up in a hover position, the yaw axis controls engine pitch, and for
in-between positions, *both* axes influence engine pitch. In all cases, the RCS
system is used to compensate for missing rotational momentum on either axis.

The **available FBW laws** are:

- **Direct Law (0)**. Control inputs (stick / pedals) control engine pitch and
  RCS thrusters directly.
- **Rate Law (1)**. Control inputs command target rotation rate. Neutral
  controls will attempt to hold current attitude; stick or pedal deflections
  command a constant rate of rotation.
- **Attitude Law (2)** (pitch and bank axes only). Control inputs command
  target attitude. Neutral controls will attempt to put the aircraft in a
  neutral position relative to the ground (zero pitch / zero bank).
- **Yaw Damper Law (2)** (yaw axis only). Control inputs command side slip.
  Neutral rudder will attempt to eliminate sideslip; this means that the
  aircraft will fly much like a conventional fixed-wing craft, and respond to
  banking by turning.

**Engine Pitch** is controlled by the propeller pitch input. As a shortcut,
pressing *Shift-H* will command a straight-up pitch. The engine pitch commanded
this way (prop pitch / Shift-H) is only the *base* pitch; yaw and or bank
commands may add *differential* engine pitch to that.

### The Autothrottle System (A/T)

The autothrottle controls main engine thrust. Currently, the following modes
are working:

- **ALT HOLD**: Holds indicated barometric altitude.
- **AGL HOLD**: Holds altitude above ground. Useful for hover-taxiing.
- **V/S HOLD**: Holds vertical speed. This can be used for all sorts of things,
  but the main use case is smooth vertical landings: maneuver into position in
  AGL HOLD mode, then switch the V/S HOLD, set target V/S to -100 FPM, and
  maintain your position until touchdown.

Future modes to be implemented:

- **IAS HOLD** and **MACH HOLD**: Holds airspeed.
- **CLB** and **DES**: Set climb thrust / idle thrust respectively, for
  operational climbs and descents in aerodynamic flight.

### Propulsion

Engine startup is currently best done via the Autostart menu item. This will
start the main engines; it's best to put them into a straight-up position
before starting (*Shift-H*), to avoid toppling the aircraft over.

About 50% thrust should be enough to achieve a gentle vertical climb. At 95%
thrust, the afterburners kick in; you will probably need these to achieve
supersonic speeds.

The rocket engine ("stardrive") can be turned on and off using the *S* key.
This engine produces a massive amount of thrust, however realistically (for
what that means for a fictional spacecraft like this) you would not use it
below 60,000 ft.

### Recommended procedures

#### Startup

- Pitch Law: ATTITUDE (2)
- Bank Law: ATTITUDE (2)
- Yaw Law: RATE (1)
- Main Engine Pitch: UP
- Throttles: IDLE
- Wind: CHECKED
- Autostart: SELECTED
- Left Engine N2: STABLE 35%
- Right Engine N2: STABLE 35%

#### Takeoff

- Pitch Law: ATTITUDE (2)
- Bank Law: ATTITUDE (2)
- Yaw Law: RATE (1)
- Main Engine Pitch: UP
- Thrust: ~40%
- Both Engines N1: STABLE
- Thrust: AS NEEDED
- Gear: UP AT STABLE POSITIVE CLIMB

#### Departure & Subsonic climb

- Altitude: >= 500 FT AGL
- Main Engine Pitch: GRADUALLY ADVANCE
- Vertical Speed: POSITIVE
- Thrust: AS NEEDED
- IAS: >= 100 KTS
- Yaw Law: DAMPER (2)
- IAS: >= 200 KTS
- Pitch Law: RATE (1)
- AOA: MAINTAIN 1-2 DEG
- IAS: MAINTAIN <250 KTS BELOW 10,000 FT

#### Supersonic climb

- Altitude: >= 30,000 FT
- Thrust: FULL FORWARD
- Main Engine Pitch: FULL FORWARD
- AOA: MAINTAIN 1-2 DEG

#### High-Altitude climb

- Altitude: >= 60,000 FT
- Stardrive: ENGAGE
- Pitch: AS NEEDED

#### Orbital Insertion

- Altitude: >= 100,000 FT
- Main Engines Cutoff: CUT OFF
- Pitch: AS NEEDED
- Thrust: AS NEEDED

#### Deorbit Burn

- Yaw Law: RATE (1)
- Orientation: NEGATIVE FPV
- Thrust: FULL UNTIL TARGET TRAJECTORY REACHED

#### Deorbit Descent

- Orientation: POSITIVE FPV
- Pitch Law: RATE (1)
- Bank Law: ATTITUDE (2)
- Yaw Law: DAMPER (2)
- Main Engine Pitch: UP
- Pitch: MAINTAIN 40 DEG UP
- Thrust: IDLE

#### Reentry

- Pitch: MAINTAIN 40 DEG UP
- Stardrive: OFF
- Autostart: SELECTED
- Altitude: <= 60,000 ft
- Mach: <= 5
- Pitch: AS NEEDED
- Thrust: AS NEEDED

#### Arrival

- IAS: < 250 KTS BELOW 10,000 FT
- AOA: 1-2 DEG
- Main Engine Pitch: AS NEEDED
- Thrust: AS NEEDED
- Gear: DOWN BELOW 200 KTS

#### Landing (straight down)

- Yaw Law: RATE (1)
- Altitude: <= 2000 FT
- Gear: DOWN AND LOCKED
- Main Engine Pitch: UP
- Thrust: AS NEEDED
- Pitch/Bank: AS NEEDED
- Sinkrate: 0 UNTIL ALIGNED; KEEP BELOW 500 FPM
- Wheels: WOW
- Thrust: IDLE

#### Approach (conventional ops)

- Altitude: AS PUBLISHED
- Airspeed: 150-200 KTS
- Main Engine Pitch: AS NEEDED
- Thrust: AS NEEDED
- Localizer: CAPTURE
- Glideslope: CAPTURE
- Gear: DOWN
- 5 miles out:
- Gear: DOWN AND LOCKED
- Airspeed: 120-180 KTS

#### Landing (conventional ops)

- Gear: DOWN AND LOCKED
- Altitude: 100 FT AGL
- Engine Pitch: FULL UP
- Yaw law: RATE (1)
- Thrust: AS NEEDED
- Runway Centerline: MAINTAIN
- Airspeed: <= 30 KTS
- Pitch / Bank: AS NEEDED FOR TAXIING

Development Status
------------------

- FDM:
    - aerodynamic: working.
    - fix contact points: done.
    - propulsion: working, but need to make it 4 main engines and 3 rocket
      thrusters instead of 2 + 1.
    - aerodynamic control surfaces: TODO
    - ground effect: TODO
    - mach drag: TODO
- 3D model:
    - hull somewhat complete, but needs detail work
    - landing gear: done
    - textures and UV mapping: TODO
    - cockpit & instruments: TODO
    - interior: TODO
    - doors, windows: TODO
    - particle animations for engines etc.: TODO
- Systems:
    - FBW:
        - DIRECT: done
        - HOLD: done
        - STAB: done
        - SPD (pitch and bank only): TODO
    - instruments:
        - PFD: in progress
        - MFD: TODO
        - Glareshield panel (A/P control): TODO
        - Center pedestal (engine controls): TODO
        - Various other controls (gear, pressurization, fuel systems, ...):
          TODO
    - autopilot:
        - A/T
            - ALT HOLD: done
            - AGL HOLD: done
            - V/S HOLD: done
            - IAS HOLD: done
            - Mach HOLD: TODO
        - Pitch
            - ALT HOLD: done
            - AGL HOLD: done
            - V/S HOLD: done
            - IAS HOLD: TODO
            - Mach HOLD: TODO
        - Lateral
            - HDG HOLD: done
            - LNAV: TODO
        - Control logic: TODO
            - Alt capture (switch to ALT HOLD when reaching target altitude)
            - Autoland (?)
    - fuel systems, reactor: TODO
    - automatic main engine shutdown at altitude: TODO
    - prohibit stardrive activation below 60,000 ft: TODO
