# 08 — Crosscutting Concepts

This chapter documents the concepts, principles, and rules that apply across the entire Mars Rover System rather than to a single component. These are the shared foundations that keep the architecture consistent, testable, and maintainable.

---

## Domain Concepts

The following concepts form the shared vocabulary of the system. All components use these concepts consistently.

**Position**
A position is a pair of integer coordinates (x, y) identifying a cell on the grid. Obstacle locations are also expressed as positions. The original kata illustrates finite grid maps but does not explicitly define how movement beyond the map boundaries should be handled. Grid boundary behavior has not yet been decided and should not be assumed to be unlimited or restricted without an explicit decision.

**Orientation**
The rover faces one of four cardinal directions: North, East, South, or West. Orientation determines which grid cell a forward movement would reach.

**Forward movement**
A move-forward command advances the rover exactly one step in the direction it currently faces. The target cell is determined by the current position and orientation before any state is updated.

**Rotation**
A rotation command changes the rover's orientation by 90° without changing its position. Turning left from North yields West; turning right from North yields East. Rotation cycles through the four cardinal directions in both directions.

**Obstacle**
An obstacle occupies a grid position. The rover cannot move into a position occupied by an obstacle. Obstacles are fixed for the duration of a run.

**Command sequence**
A command sequence is an ordered list of move-forward and rotation commands. Commands are processed one at a time, in order, from first to last.

---

## Command Processing

Command processing follows a consistent, deterministic sequence for every command in the list.

**Move-forward commands:**

1. The Mission Controller asks the Rover to calculate the potential next position from its current position and orientation. The Rover returns the candidate position without updating its state.
2. The Mission Controller queries the Map with the candidate position.
3. If the Map reports the position is clear, the Mission Controller instructs the Rover to move. The Rover updates its position.
4. If the Map reports the position is blocked, the movement is skipped. The Rover's position and orientation remain unchanged.
5. In both cases, the Mission Controller continues to the next command in the sequence.

**Rotation commands:**

1. The Mission Controller instructs the Rover to rotate in the specified direction.
2. The Rover updates its orientation by 90°.
3. No Map query is required. Rotation does not change the rover's position and cannot result in a collision.

This model is consistent with Chapter 6 (Runtime View). The Mission Controller is the sole decision-maker for obstacle avoidance. The Rover and Map have no direct dependency on each other.

---

## State Management

All state is held in memory within the single process for the duration of one run.

| State | Owner | Lifecycle |
|-------|-------|-----------|
| Rover position (x, y) | Rover | Set at initialisation. Updated after each permitted move-forward. Discarded on process exit. |
| Rover orientation | Rover | Set at initialisation. Updated after each rotation. Discarded on process exit. |
| Obstacle locations | Map | Set at initialisation from user input. Read-only during command processing. Discarded on process exit. |

The Mission Controller holds no persistent state of its own. The Mission Controller initializes the Rover and Map from user input. During command processing, it queries the Map and instructs the Rover to update its state.

No state is written to disk. There is no persistence between runs, and no history of past positions or commands is retained.

---

## Input Validation and Error Handling

The Mars Rover kata does not specify detailed rules for invalid input. The following distinguishes what is established from what remains open.

**Established by the kata and approved decisions:**
- The application accepts an initial position, orientation, obstacle map, and command sequence as inputs.
- A move-forward command that would place the rover on an obstacle is skipped, and command processing continues. The blocked movement does not change the rover's position or orientation. The CLI should provide clear feedback about blocked movements, consistent with the Usability quality goal in Chapter 1. The exact format and timing of this feedback remain undecided.

**Reasonable architectural principles (not yet fully specified):**
- Invalid or unrecognised inputs (such as an unrecognised command or a malformed position) should be reported clearly to the user rather than causing silent failures or unhandled exceptions.
- The application should not crash on invalid input if that can be avoided with straightforward validation at the input boundary (the Mission Controller).

**Not yet decided:**
- The exact format of error messages.
- Whether the application exits immediately on invalid input or attempts to continue.
- Whether the initial rover position coinciding with an obstacle position is treated as an error.

These details are implementation decisions to be made during development. They do not affect the core architecture.

---

## Testability

The architecture is designed to support testing at the component level without requiring a running CLI or end-to-end harness.

**Rover**
Movement and rotation logic are self-contained. Given a position, orientation, and command, the outcome is fully deterministic. Rover behavior can be tested by constructing a Rover with known state and asserting the resulting position or orientation.

**Map**
Obstacle detection is a pure query: given a position and a set of obstacles, the result is deterministic. Map behavior can be tested by constructing a Map with known obstacle locations and querying specific positions.

**Mission Controller**
Coordination logic can be tested by supplying a known initial state and command sequence and asserting the final rover position and orientation. Both the successful-move and blocked-move paths, as well as continued processing after a blocked move, can be exercised as distinct test cases.

Development and testing tools, such as pytest, may be used to implement and run these tests. Such tools are development dependencies and do not introduce runtime dependencies into the application itself, consistent with TC-2.

---

## Architectural Principles

The following principles shaped the design decisions documented across Chapters 1–7 and ADR-001.

**Separation of concerns**
Each component has one clear responsibility. The Mission Controller coordinates, the Rover manages movement and orientation, and the Map manages obstacle knowledge. No component takes on the responsibility of another.

**Clear component responsibilities**
The boundaries between components are defined by what each one owns: the Rover owns position and orientation, the Map owns obstacle locations, and the Mission Controller owns the execution flow. Changes to one component's internals do not require changes to the others, provided their interfaces remain stable.

**Deterministic command processing**
Given the same initial rover position and orientation, obstacle map, and command sequence, the system always produces the same result. There is no randomness, concurrency, or external input during command processing. This makes the system straightforward to reason about and test.

**Simplicity**
The architecture uses the minimum structure needed to satisfy the kata's requirements. No frameworks, databases, services, or infrastructure are introduced without justification. The application runs with a single Python command and has no external runtime dependencies.

**Maintainability**
The three-component structure keeps the codebase navigable. Each component can be understood, modified, and tested independently. The separation also makes it possible to change one aspect of the system — such as how the Map stores obstacles, or how the Rover calculates movement — without touching the other components.

**Testability**
Domain logic is kept separate from CLI input/output. Components expose clear interfaces and hold no hidden global state. This allows unit tests to exercise each component in isolation and integration-style tests to verify the full command-processing flow without requiring a running terminal session.
