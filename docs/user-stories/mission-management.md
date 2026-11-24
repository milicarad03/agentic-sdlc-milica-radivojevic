# Mission Management — User Stories

## MISSION-STORY-004: Avoid Obstacles and Continue Processing

**Domain:** MISSION
**Priority:** Core — Pareto 20%
**Status:** Draft — Manual Exercise
**Architecture Components:** Mission Controller, Rover, Map

### Original User Story

**AS A** rover operator
**I WANT** the rover to avoid obstacles and continue processing subsequent commands
**SO THAT** I can navigate safely without terminating the entire command sequence when a movement is blocked.

### Architecture References

- `architecture/01-introduction-and-goals.md` — FR-4, FR-5, FR-6
- `architecture/05-building-block-view.md` — Component Interactions
- `architecture/06-runtime-view.md` — Scenarios 2, 3, 4
- `architecture/09-architecture-decisions.md` — ADR-002

### Acceptance Criteria

#### SCENARIO 1: Prevent Movement into an Obstacle

**Scenario ID:** `MISSION-STORY-004-S1`

**GIVEN**
- The rover is at a valid position P, facing North.
- The cell immediately north of P contains an obstacle.
- P is not on the grid boundary.

**WHEN**
- The Mission Controller processes a move-forward command.

**THEN**
- The Mission Controller detects that the target cell is occupied.
- The rover does not enter the occupied cell.
- The rover's position remains P.
- The rover's orientation remains North.

**Architecture Reference:** Chapter 6 — Scenario 2: Blocked Forward Movement.

#### SCENARIO 2: Continue Executing Commands After a Blocked Movement

**Scenario ID:** `MISSION-STORY-004-S2`

**GIVEN**
- The rover starts at a valid position P, facing North.
- The cell immediately north of P contains an obstacle.
- The cell immediately east of P is unoccupied.
- The command sequence consists of move-forward, turn-right, and move-forward.

**WHEN**
- The Mission Controller processes the complete command sequence.

**THEN**
- The first move-forward command is blocked.
- The rover remains at P after the blocked movement.
- The turn-right command changes the rover's orientation to East.
- The final move-forward command moves the rover one cell east of P.
- The rover's final orientation is East.
- All three commands are processed in their original order.

**Architecture References:** Chapter 6 — Scenarios 2, 3, 4; ADR-002.

---

## Frontend Sub-Stories

### MISSION-FE-004.1: Display Blocked Movement Feedback

**Parent Story:** `MISSION-STORY-004`
**Layer:** Frontend — CLI
**Architecture Reference:** Chapter 1 — Quality Goal 5: Usability

**AS A** rover operator
**I WANT** the CLI to indicate when a movement is blocked
**SO THAT** I can understand why the rover did not change its position.

#### SCENARIO 1: Blocked Movement Is Communicated

**Scenario ID:** `MISSION-FE-004.1-S1`

**GIVEN**
- The rover attempts to move into an occupied cell.
- The Mission Controller prevents the movement.

**WHEN**
- The CLI communicates the outcome of command processing.

**THEN**
- The user can identify that a movement was blocked by an obstacle.
- The CLI does not incorrectly indicate that the blocked movement succeeded.

**Open Decision:** OD-004 — The exact feedback format and timing remain undefined.

---

## Backend Sub-Stories

### MISSION-BE-004.1: Check Obstacle Occupancy Before Movement

**Parent Story:** `MISSION-STORY-004`
**Layer:** Backend — Domain Logic
**Architecture Reference:** Chapter 5 — Component Interactions

**AS A** rover operator
**I WANT** the system to check whether a target cell is occupied before moving
**SO THAT** the rover never enters a cell containing an obstacle.

#### SCENARIO 1: Target Cell Is Occupied

**Scenario ID:** `MISSION-BE-004.1-S1`

**GIVEN**
- The rover has a valid current position and orientation.
- The next cell in its current direction is occupied by an obstacle.

**WHEN**
- The Mission Controller receives a move-forward command.

**THEN**
- The Rover calculates the candidate position without changing its state.
- The Mission Controller queries the Map for that position.
- The Map reports that the position is occupied.
- The Mission Controller does not instruct the Rover to move.
- The Rover's position and orientation remain unchanged.

**Architecture Reference:** Chapter 6 — Runtime Invariants: Position Integrity and No Direct Rover–Map Dependency.

---

### MISSION-BE-004.2: Continue Processing After Blocked Movement

**Parent Story:** `MISSION-STORY-004`
**Layer:** Backend — Command Coordination
**Architecture Reference:** Chapter 9 — ADR-002

**AS A** rover operator
**I WANT** the system to continue processing subsequent commands after a blocked movement
**SO THAT** one obstacle does not cancel the remaining command sequence.

#### SCENARIO 1: Skip Only the Blocked Command

**Scenario ID:** `MISSION-BE-004.2-S1`

**GIVEN**
- The current command is move-forward.
- The target cell contains an obstacle.
- Additional valid commands remain in the sequence.

**WHEN**
- The Mission Controller processes the blocked movement.

**THEN**
- The blocked movement is skipped.
- The Rover's state remains unchanged for that movement.
- The Mission Controller proceeds to the next command.
- The remaining valid commands are processed in their original order.

**Architecture Reference:** Chapter 6 — Scenario 2; ADR-002.

---

## Infrastructure Sub-Stories

### MISSION-INFRA-004.1: Execute the System Locally

**Parent Story:** `MISSION-STORY-004`
**Layer:** Infrastructure — Execution
**Architecture Reference:** Chapter 9 — ADR-001

**AS A** developer
**I WANT** the obstacle-avoidance functionality to run as part of the existing Python CLI application
**SO THAT** the system can operate locally without external services.

#### SCENARIO 1: Local Application Execution

**Scenario ID:** `MISSION-INFRA-004.1-S1`

**GIVEN**
- Python is installed locally.
- The Mars Rover application has been implemented.

**WHEN**
- The application is started using its documented execution command.

**THEN**
- The application can execute the obstacle-avoidance workflow locally.
- No database server is required.
- No external network service is required.
- No additional application framework is required.

---

### MISSION-INFRA-004.2: Store Obstacle Data in Memory

**Parent Story:** `MISSION-STORY-004`
**Layer:** Infrastructure — Data Storage
**Architecture References:** Chapter 5 — Map; Chapter 9 — ADR-001

**AS A** developer
**I WANT** the system to store obstacle positions in memory during execution
**SO THAT** obstacle detection does not require persistent storage.

#### SCENARIO 1: Query In-Memory Obstacle Data

**Scenario ID:** `MISSION-INFRA-004.2-S1`

**GIVEN**
- The Map contains an in-memory collection of obstacle positions.

**WHEN**
- The Mission Controller queries whether a position is occupied.

**THEN**
- The Map returns the correct occupancy result.
- No database access is performed.
- The obstacle collection remains unchanged.

**Architecture Reference:** Chapter 6 — Runtime Invariant: Obstacle Immutability.

---

### MISSION-INFRA-004.3: Provide Local Observability

**Parent Story:** `MISSION-STORY-004`
**Layer:** Infrastructure — Monitoring and Observability
**Architecture Reference:** Chapter 1 — Quality Goal 5: Usability

**AS A** developer
**I WANT** the application's CLI output to make obstacle avoidance observable
**SO THAT** I can inspect its behavior during local execution.

#### SCENARIO 1: Observe the Result of a Blocked Movement

**Scenario ID:** `MISSION-INFRA-004.3-S1`

**GIVEN**
- The command sequence contains a blocked movement.
- The application is running locally.

**WHEN**
- The command sequence finishes processing.

**THEN**
- The application's output provides the final rover position and orientation.
- The available CLI feedback makes it possible to identify that a movement was blocked.
- No centralized monitoring service is required.

**Open Decision:** OD-004 — The exact blocked-movement feedback format and timing remain undefined.

### Infrastructure Scope

| Concern | Approach |
|---|---|
| Deployment | Local Python CLI |
| Data Store | In-memory obstacle collection |
| Event Handling | Not applicable — synchronous command processing |
| Monitoring | Local CLI feedback |
| External Services | None |

---

## Traceability Summary

| Scenario ID | Architecture Reference |
|---|---|
| MISSION-STORY-004-S1 | Chapter 6 — Blocked Forward Movement |
| MISSION-STORY-004-S2 | Chapter 6 — Command Sequence Completion; ADR-002 |
| MISSION-FE-004.1-S1 | Chapter 1 — Quality Goal 5 |
| MISSION-BE-004.1-S1 | Chapter 5 — Component Interactions; Chapter 6 — Runtime Invariants |
| MISSION-BE-004.2-S1 | Chapter 6 — Blocked Forward Movement; ADR-002 |
| MISSION-INFRA-004.1-S1 | ADR-001 |
| MISSION-INFRA-004.2-S1 | Chapter 5 — Map; ADR-001 |
| MISSION-INFRA-004.3-S1 | Chapter 1 — Quality Goal 5 |

---

## Open Decisions and Constraints

The following architecture decisions remain open and must not be resolved implicitly through these stories:

- OD-001 — Grid boundary behavior
- OD-002 — CLI input format and command representation
- OD-003 — Initial position validation
- OD-004 — Blocked-movement feedback format and timing
- OD-005 — Invalid-input handling

Scenarios use descriptive command names rather than defining specific command characters.

The application must remain consistent with ADR-001 and ADR-002.

## Implementation Status

**Requirements only — not implemented.**

Implementation and automated testing will be handled in later modules.

This is one of the two core stories selected for Module 3. The remaining supporting stories are deferred to the final project.

---

## MISSION-STORY-002: Execute Command Sequence and Receive Final State

**Domain:** MISSION
**Priority:** Core — Pareto 25%
**Status:** Draft — Module 3
**Architecture Components:** Mission Controller, Rover, Map

### Original User Story

**AS A** rover operator
**I WANT** to submit a sequence of movement and rotation commands and receive the rover's final
position and orientation
**SO THAT** I can determine where the rover ends up after a complete mission run.

### Architecture References

- [`../../architecture/01-introduction-and-goals.md`](../../architecture/01-introduction-and-goals.md) — FR-4, FR-6
- [`../../architecture/05-building-block-view.md`](../../architecture/05-building-block-view.md) — Mission Controller, Component Interactions
- [`../../architecture/06-runtime-view.md`](../../architecture/06-runtime-view.md) — Scenario 1 (Successful Forward Movement), Scenario 3 (Rotation), Scenario 4 (Command Sequence Completion)
- [`../../architecture/08-cross-cutting-concepts.md`](../../architecture/08-cross-cutting-concepts.md) — Command Processing, State Management
- [`../../architecture/09-architecture-decisions.md`](../../architecture/09-architecture-decisions.md) — ADR-001, ADR-002
- [`../../architecture/10-quality-requirements.md`](../../architecture/10-quality-requirements.md) — QS-C1, QS-C2, QS-C3, QS-C6, QS-C7, QS-T3, QS-U1

### Acceptance Criteria

#### SCENARIO 1: All Commands Execute Successfully With No Obstacles

**Scenario ID:** `MISSION-STORY-002-S1`

**GIVEN**
- The rover is initialised at a known position and orientation.
- No obstacles are present at any position the rover will visit.
- A command sequence containing at least one move-forward and one rotation command is provided.

**WHEN**
- The Mission Controller processes the complete command sequence.

**THEN**
- Each command is executed in the order it was provided.
- The rover's position is updated after each unblocked move-forward command.
- The rover's orientation is updated after each rotation command.
- The final position and orientation are returned to the user.

*Architecture reference: Ch. 6 Scenario 4 — Command Sequence Completion; Ch. 6 Scenario 1 —
Successful Forward Movement; Ch. 6 Scenario 3 — Rotation.*

---

#### SCENARIO 2: Command Sequence Containing a Blocked Move Completes Fully

**Scenario ID:** `MISSION-STORY-002-S2`

**GIVEN**
- The rover is initialised at a starting position P facing North, with an obstacle at the
  cell immediately north of P (test fixture from Ch. 10 QS-C6: P = (0, 0), obstacle at (0, 1)).
- The command sequence is: Forward, Right, Forward.

**WHEN**
- The Mission Controller processes the complete command sequence.

**THEN**
- The first Forward command is blocked; the rover remains at P facing North.
- The Right command changes the rover's orientation to East.
- The second Forward command moves the rover one step east of P.
- The final state returned reflects that outcome.
- All three commands are processed; the sequence does not terminate early.

*Architecture reference: Ch. 10 QS-C6; ADR-002 — Continue Command Processing After a Blocked
Movement. The specific coordinate values in QS-C6 are used as the stated test fixture; no
general coordinate convention beyond those scenarios is assumed.*

*Note: The obstacle-blocking mechanism is defined in MISSION-STORY-004. This scenario focuses
on full sequence completion and correct final state reporting.*

---

#### SCENARIO 3: Multi-Step Sequence With Mixed Commands Produces Correct Final State

**Scenario ID:** `MISSION-STORY-002-S3`

**GIVEN**
- The rover is initialised at a starting position P facing North, with an obstacle at the
  cell immediately north of P (test fixture from Ch. 10 QS-C7: P = (0, 0), obstacle at (0, 1)).
- The command sequence is: Forward, Right, Forward, Left, Forward.

**WHEN**
- The Mission Controller processes the complete command sequence.

**THEN**
- The first Forward is blocked; the rover remains at P facing North.
- Right changes orientation to East.
- The second Forward moves the rover one step east of P.
- Left changes orientation to North.
- The third Forward moves the rover one step north from that position.
- The final state returned reflects that outcome.

*Architecture reference: Ch. 10 QS-C7. Coordinate values are from the QS-C7 test fixture.*

---

## Frontend Sub-Stories

### MISSION-FE-002.1: Receive the Rover's Final Position and Orientation

**Parent Story:** `MISSION-STORY-002`
**Layer:** Frontend — CLI
**Architecture Reference:** [`../../architecture/01-introduction-and-goals.md`](../../architecture/01-introduction-and-goals.md) — FR-6, Quality Goal 5 (Usability); [`../../architecture/10-quality-requirements.md`](../../architecture/10-quality-requirements.md) — QS-U1

**AS A** rover operator
**I WANT** the CLI to display the rover's final position and orientation after the command
sequence completes
**SO THAT** I can read the result of the mission run directly from the terminal.

#### SCENARIO 1: Final State Is Displayed After a Completed Sequence

**Scenario ID:** `MISSION-FE-002.1-S1`

**GIVEN**
- The Mission Controller has finished processing all commands in the sequence.
- The rover has a definite final position and orientation.

**WHEN**
- The application completes execution.

**THEN**
- The final position and orientation are printed to standard output in a human-readable format.
- The output correctly represents the rover's actual final state.
- The output is produced before the process exits.

**Open Decision:** OD-002 — The exact output format remains unspecified until the CLI
input/output format is decided.

*Architecture reference: Ch. 10 QS-U1 — human-readable output; Ch. 3 — Output direction:
Mars Rover System → User via CLI (stdout); FR-6 (Ch. 1) — report resulting position and
orientation when command processing ends.*

---

## Backend Sub-Stories

### MISSION-BE-002.1: Process Each Command in Sequence Order

**Parent Story:** `MISSION-STORY-002`
**Layer:** Backend — Command Coordination
**Architecture Reference:** [`../../architecture/05-building-block-view.md`](../../architecture/05-building-block-view.md) — Mission Controller; [`../../architecture/06-runtime-view.md`](../../architecture/06-runtime-view.md) — Scenario 4; [`../../architecture/08-cross-cutting-concepts.md`](../../architecture/08-cross-cutting-concepts.md) — Command Processing

**AS A** rover operator
**I WANT** the Mission Controller to execute each command in the order it was provided
**SO THAT** the rover's final state reflects the intended command sequence without reordering
or skipping valid commands.

#### SCENARIO 1: Commands Are Dispatched in Submission Order

**Scenario ID:** `MISSION-BE-002.1-S1`

**GIVEN**
- The Mission Controller holds a command sequence of two or more commands.
- The rover is in a known initial state.
- No command in the sequence is blocked by an obstacle.

**WHEN**
- The Mission Controller iterates over the command sequence.

**THEN**
- Each command is dispatched exactly once, in the order it appears in the sequence.
- No command is skipped, repeated, or reordered.
- After the final command, the rover's state reflects all commands having been applied in order.

*Architecture reference: Ch. 6 Scenario 4 step 1 — "processes each command in sequence in
order"; Ch. 8 — "Commands are processed one at a time, in order, from first to last."*

---

### MISSION-BE-002.2: Apply a Move-Forward Command to the Rover

**Parent Story:** `MISSION-STORY-002`
**Layer:** Backend — Domain Logic
**Architecture Reference:** [`../../architecture/05-building-block-view.md`](../../architecture/05-building-block-view.md) — Component Interactions; [`../../architecture/06-runtime-view.md`](../../architecture/06-runtime-view.md) — Scenario 1; [`../../architecture/10-quality-requirements.md`](../../architecture/10-quality-requirements.md) — QS-C1

**AS A** rover operator
**I WANT** a move-forward command to advance the rover one step in its current direction when
the target position is clear
**SO THAT** the rover moves through the grid as commanded.

#### SCENARIO 1: Rover Advances One Step on an Unblocked Move-Forward

**Scenario ID:** `MISSION-BE-002.2-S1`

**GIVEN**
- The rover is at a known position P with a known orientation.
- The Mission Controller receives a move-forward command.
- The Map reports that the candidate position is not occupied by an obstacle.

**WHEN**
- The Mission Controller instructs the Rover to apply the movement.

**THEN**
- The Rover updates its position to the candidate position.
- The Rover's orientation remains unchanged.
- The Mission Controller proceeds to the next command.

*Architecture reference: Ch. 6 Scenario 1 steps 4–6; Ch. 6 Runtime Invariant — Position
Integrity; Ch. 10 QS-C1.*

---

### MISSION-BE-002.3: Apply a Rotation Command to the Rover

**Parent Story:** `MISSION-STORY-002`
**Layer:** Backend — Domain Logic
**Architecture Reference:** [`../../architecture/05-building-block-view.md`](../../architecture/05-building-block-view.md) — Component Interactions; [`../../architecture/06-runtime-view.md`](../../architecture/06-runtime-view.md) — Scenario 3; [`../../architecture/10-quality-requirements.md`](../../architecture/10-quality-requirements.md) — QS-C2, QS-C3

**AS A** rover operator
**I WANT** a rotation command to change the rover's orientation by 90 degrees without moving it
**SO THAT** the rover faces the intended direction for subsequent move-forward commands.

#### SCENARIO 1: Left Rotation Updates Orientation Without Changing Position

**Scenario ID:** `MISSION-BE-002.3-S1`

**GIVEN**
- The rover is at a known position with a known orientation.
- The Mission Controller receives a rotate-left command.

**WHEN**
- The Mission Controller instructs the Rover to rotate left.

**THEN**
- The Rover's orientation changes 90 degrees to the left (e.g. North → West).
- The Rover's position remains unchanged.
- No Map query is made.
- The Mission Controller proceeds to the next command.

*Architecture reference: Ch. 6 Scenario 3; Ch. 8 — "No Map query is required. Rotation does
not change the rover's position"; Ch. 10 QS-C2.*

#### SCENARIO 2: Right Rotation Updates Orientation Without Changing Position

**Scenario ID:** `MISSION-BE-002.3-S2`

**GIVEN**
- The rover is at a known position with a known orientation.
- The Mission Controller receives a rotate-right command.

**WHEN**
- The Mission Controller instructs the Rover to rotate right.

**THEN**
- The Rover's orientation changes 90 degrees to the right (e.g. North → East).
- The Rover's position remains unchanged.
- No Map query is made.
- The Mission Controller proceeds to the next command.

*Architecture reference: Ch. 6 Scenario 3; Ch. 10 QS-C3.*

---

### MISSION-BE-002.4: Retrieve Final Rover State After All Commands Are Processed

**Parent Story:** `MISSION-STORY-002`
**Layer:** Backend — Domain Logic
**Architecture Reference:** [`../../architecture/06-runtime-view.md`](../../architecture/06-runtime-view.md) — Scenario 4; [`../../architecture/01-introduction-and-goals.md`](../../architecture/01-introduction-and-goals.md) — FR-6

**AS A** rover operator
**I WANT** the Mission Controller to retrieve and return the rover's position and orientation
once all commands have been processed
**SO THAT** the final state of the mission is available to report to the user.

#### SCENARIO 1: Final State Is Retrieved After Full Sequence Execution

**Scenario ID:** `MISSION-BE-002.4-S1`

**GIVEN**
- The Mission Controller has dispatched and processed every command in the sequence.
- The Rover holds the definitive final position and orientation in memory.

**WHEN**
- The Mission Controller retrieves the rover's current state.

**THEN**
- The returned position and orientation reflect all commands that were applied.
- The state is consistent with the runtime invariants: position updated only on permitted
  moves, orientation updated on each rotation.
- The retrieved state is passed to the output layer for reporting.

*Architecture reference: Ch. 6 Scenario 4 steps 2–3; Ch. 6 Runtime Invariants — Position
Integrity; FR-6 (Ch. 1) — report resulting position and orientation when command processing
ends.*

---

## Infrastructure Sub-Stories

### MISSION-INFRA-002.1: Deploy and Execute Within the Local Python Process

**Parent Story:** `MISSION-STORY-002`
**Layer:** Infrastructure — Deployment / Execution
**Architecture Reference:** [`../../architecture/07-deployment-view.md`](../../architecture/07-deployment-view.md) — Runtime Environment; [`../../architecture/09-architecture-decisions.md`](../../architecture/09-architecture-decisions.md) — ADR-001

**Shared infrastructure reference — not an independent sub-story.**

This entry records that the deployment and execution concern for MISSION-STORY-002 is covered
by `MISSION-INFRA-004.1`, the canonical infrastructure sub-story defined in the
MISSION-STORY-004 bundle. The execution environment is identical: a single local Python
process, no external services, no additional packages beyond the standard library.

The canonical acceptance scenario is `MISSION-INFRA-004.1-S1`. No separate scenario is
defined here; doing so would duplicate requirements already specified and traceable in that
sub-story.

---

### MISSION-INFRA-002.2: Maintain Rover State in Memory During Command Processing

**Parent Story:** `MISSION-STORY-002`
**Layer:** Infrastructure — Data Storage / State
**Architecture Reference:** [`../../architecture/08-cross-cutting-concepts.md`](../../architecture/08-cross-cutting-concepts.md) — State Management; [`../../architecture/09-architecture-decisions.md`](../../architecture/09-architecture-decisions.md) — ADR-001; [`../../architecture/02-constraints.md`](../../architecture/02-constraints.md) — TC-3

**AS A** developer
**I WANT** the rover's position and orientation to be held in memory throughout command
sequence execution
**SO THAT** each command operates on the current accumulated state without requiring any
external storage.

#### SCENARIO 1: Rover State Is Updated and Readable In-Memory Throughout Execution

**Scenario ID:** `MISSION-INFRA-002.2-S1`

**GIVEN**
- The application is running as a single local Python process.
- The Rover has been initialised with a known position and orientation.
- The Mission Controller is processing a command sequence.

**WHEN**
- One or more commands are applied to the Rover.

**THEN**
- The Rover's updated position and orientation are immediately available in memory for the
  next command.
- No file system write, database write, or network call is performed at any point during
  execution.
- When the process exits, all state is discarded.

*Architecture reference: Ch. 8 State Management table — "Rover position: updated after each
permitted move-forward, discarded on process exit"; ADR-001 — in-memory state; TC-3 — no
database or file-based persistence.*

---

### MISSION-INFRA-002.3: Event Handling

**Parent Story:** `MISSION-STORY-002`
**Layer:** Infrastructure — Event Handling

**Not applicable.** The Mars Rover System processes commands synchronously within a single
process using direct in-memory calls. There is no event bus, message broker, asynchronous
dispatch, or inter-process communication. Command processing is a sequential loop inside
the Mission Controller.

*Architecture reference: Ch. 6 — "All behavior occurs within a single process... through
direct in-memory calls with no network communication or asynchronous messaging"; ADR-001 —
single local process.*

---

### MISSION-INFRA-002.4: Local Observability of Command Sequence Execution

**Parent Story:** `MISSION-STORY-002`
**Layer:** Infrastructure — Monitoring / Observability
**Architecture Reference:** [`../../architecture/10-quality-requirements.md`](../../architecture/10-quality-requirements.md) — QS-U1; [`../../architecture/01-introduction-and-goals.md`](../../architecture/01-introduction-and-goals.md) — Quality Goal 5 (Usability)

**AS A** developer
**I WANT** the application's standard output to make the result of a command sequence run
observable
**SO THAT** I can verify correct execution during local development and testing without a
monitoring service.

#### SCENARIO 1: Final State Is Observable From Standard Output

**Scenario ID:** `MISSION-INFRA-002.4-S1`

**GIVEN**
- The application has completed processing a command sequence.
- The application is running locally with standard output visible in the terminal.

**WHEN**
- The application prints its result and exits.

**THEN**
- The final rover position and orientation appear on standard output.
- No external monitoring service, log aggregator, or telemetry system is required.
- The output is sufficient to verify the result of the run.

*Architecture reference: Ch. 10 QS-U1; Ch. 3 — Output: Mars Rover System → User via CLI
(stdout); Ch. 7 — "The User runs the application from a terminal... prints the result, and
exits."*

### Infrastructure Scope

| Concern | Approach |
|---------|----------|
| Deployment / execution | Shared with MISSION-INFRA-004.1 — local Python CLI process, no external services |
| Data store / state | In-memory rover position and orientation — MISSION-INFRA-002.2 |
| Event handling | Not applicable — synchronous, single-process execution |
| Monitoring / observability | Local standard output — MISSION-INFRA-002.4 |
| External services | None |

---

## Traceability Table

| Scenario ID | Parent story | Architecture reference |
|-------------|--------------|------------------------|
| MISSION-STORY-002-S1 | MISSION-STORY-002 | Ch. 6 Scenarios 1, 3, 4; FR-4, FR-6 (Ch. 1) |
| MISSION-STORY-002-S2 | MISSION-STORY-002 | Ch. 10 QS-C6; ADR-002; Ch. 6 Scenario 2 |
| MISSION-STORY-002-S3 | MISSION-STORY-002 | Ch. 10 QS-C7 |
| MISSION-FE-002.1-S1 | MISSION-FE-002.1 | Ch. 10 QS-U1; FR-6 (Ch. 1); Ch. 3 output direction |
| MISSION-BE-002.1-S1 | MISSION-BE-002.1 | Ch. 6 Scenario 4 step 1; Ch. 8 Command Processing |
| MISSION-BE-002.2-S1 | MISSION-BE-002.2 | Ch. 6 Scenario 1 steps 4–6; Ch. 10 QS-C1 |
| MISSION-BE-002.3-S1 | MISSION-BE-002.3 | Ch. 6 Scenario 3; Ch. 10 QS-C2 |
| MISSION-BE-002.3-S2 | MISSION-BE-002.3 | Ch. 6 Scenario 3; Ch. 10 QS-C3 |
| MISSION-BE-002.4-S1 | MISSION-BE-002.4 | Ch. 6 Scenario 4 steps 2–3; FR-6 (Ch. 1) |
| MISSION-INFRA-002.1 | MISSION-INFRA-002.1 | Shared reference to MISSION-INFRA-004.1-S1 — no independent scenario; ADR-001; Ch. 7 |
| MISSION-INFRA-002.2-S1 | MISSION-INFRA-002.2 | Ch. 8 State Management; ADR-001; TC-3 (Ch. 2) |
| MISSION-INFRA-002.4-S1 | MISSION-INFRA-002.4 | Ch. 10 QS-U1; Ch. 3; Ch. 7 |

---

## Open Decisions and Assumptions

The following open decisions from
[`../../architecture/11-risks-and-technical-debts.md`](../../architecture/11-risks-and-technical-debts.md)
affect this story and must not be resolved implicitly through its scenarios.

| OD | Affects this story | Treatment |
|----|-------------------|-----------|
| OD-001 | MISSION-BE-002.2: grid boundary behavior when a move-forward would leave the grid | Scenarios use positions that do not reach a grid boundary; boundary behavior is not specified here |
| OD-002 | MISSION-FE-002.1: exact CLI output format for final state | Output described as "human-readable" without prescribing specific symbols or structure |
| OD-004 | Blocked-movement feedback during sequence execution | Specified in MISSION-FE-004.1 (MISSION-STORY-004); not re-specified here |
| OD-005 | Error handling for invalid commands in the sequence | Out of scope; deferred to MISSION-STORY-005 |

**Assumptions:**
- The command sequence is non-empty and all commands are valid. Invalid-command handling is
  out of scope here (OD-005, MISSION-STORY-005).
- The rover's initial position and obstacle map have been provided and accepted before
  execution begins. Input acceptance is out of scope here (MISSION-STORY-001, MISSION-STORY-006).
- Obstacle-avoidance mechanics (Map query, blocked-move skip, continued processing) are
  defined in MISSION-STORY-004 and referenced but not re-specified in this bundle.

---

## Implementation Status

**Requirements only — not implemented.**

Implementation and automated testing will be handled in later modules.

This is the second of two Core story bundles for Module 3. With this bundle, the Module 3
Core documentation is complete.
