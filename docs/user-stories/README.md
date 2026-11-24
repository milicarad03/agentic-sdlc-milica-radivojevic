# Mars Rover — User Story Inventory

## Project Overview

The Mars Rover System simulates the movement of a single rover on a grid containing obstacles.
The user provides an initial position, orientation, obstacle map, and command sequence.
The system executes the commands, enforces obstacle avoidance, and reports the rover's final state.

The system is a single local Python CLI application with no external dependencies, no persistent
storage, and no network communication. All state is held in memory for the duration of one run.

**Architecture documentation:** `architecture/` (arc42 template, C4 model)
**Primary ADRs:** ADR-001 (Python CLI, in-memory state), ADR-002 (continue after blocked movement)

---

## Domains

The architecture defines three logical components (TC-5, ADR-001). These are not formal DDD bounded
contexts, but each has a distinct responsibility and forms a natural story domain.

| Domain | Architectural component | Responsibility |
|--------|------------------------|----------------|
| **ROVER** | Rover | Position, orientation, forward movement, rotation |
| **MAP** | Map | Obstacle storage and occupancy queries |
| **MISSION** | Mission Controller | Input acceptance, command coordination, obstacle avoidance, result reporting |

The CLI is the cross-cutting user interface of the application, not a separate architectural
component or deployable service. CLI interactions surface as FE sub-stories within the MISSION
domain bundles.

Stories in the ROVER and MAP domains cover component-level capabilities.
Stories in the MISSION domain cover end-to-end user interactions through the CLI.

*Reference: `../../architecture/05-building-block-view.md` — Level 2: Component View*

---

## Story Inventory

### Summary

| Metric | Count | Percentage |
|--------|-------|------------|
| Total original stories | 8 | 100% |
| Core (Module 3) | 2 | 25% |
| Supporting (deferred — Final Project) | 6 | 75% |
| Core bundles documented | 2 | 100% of Core |
| Core bundles remaining | 0 | — |
| Supporting bundles deferred to Final Project | 6 | — |

The 25% Core figure is the closest sensible approximation of the 20% Pareto heuristic for an
8-story inventory (20% of 8 = 1.6). Selecting 2 Core stories satisfies the Module 3 goal of
documenting two Core bundles, both now complete.

---

### All 8 Original Stories

#### ROVER Domain

| ID | Title | Architecture source | Priority | Class |
|----|-------|---------------------|----------|-------|
| ROVER-STORY-001 | Move Rover Forward | FR-3, FR-4; Ch. 6 Scenario 1; QS-C1 | 3 | Supporting — Deferred |
| ROVER-STORY-002 | Rotate Rover 90 Degrees | FR-3, FR-4; Ch. 6 Scenario 3; QS-C2, QS-C3 | 4 | Supporting — Deferred |

#### MISSION Domain

| ID | Title | Architecture source | Priority | Class |
|----|-------|---------------------|----------|-------|
| MISSION-STORY-001 | Set Initial Rover Position and Orientation | FR-1; Ch. 3; Ch. 5 Mission Controller | 6 | Supporting — Deferred |
| MISSION-STORY-002 | Execute Command Sequence and Receive Final State | FR-4, FR-6; Ch. 6 Scenario 4; QS-C6, QS-C7 | 1 | **Core** |
| MISSION-STORY-003 | Define Obstacle Positions | FR-2; Ch. 3; Ch. 5 Map (storage), Ch. 5 Mission Controller (input) | 5 | Supporting — Deferred |
| MISSION-STORY-004 | Avoid Obstacles and Continue Processing | FR-4, FR-5; ADR-002; Ch. 6 Scenario 2 | 2 | **Core** *(authored)* |
| MISSION-STORY-005 | Receive Feedback for Invalid Input | OD-005; RISK-002; Ch. 8 Input Validation | 8 | Supporting — Deferred |
| MISSION-STORY-006 | Provide a Command Sequence | FR-3; Ch. 3; Ch. 5 Mission Controller; OD-002 | 7 | Supporting — Deferred |

---

### Priority Ranking and Rationale

| Rank | Story ID | Rationale |
|------|----------|-----------|
| 1 | MISSION-STORY-002 | Delivers the system's end-to-end user value. Only story covering FR-4 and FR-6 together. Exercises the full component chain (Mission Controller → Rover → Map). Quality scenarios QS-C6 and QS-C7 are both integration-level and require this story. Highest MVP criticality. |
| 2 | MISSION-STORY-004 | The kata's defining constraint. ADR-002 makes obstacle avoidance and continued processing architecturally central. All three components interact. Already fully authored. |
| 3 | ROVER-STORY-001 | Foundational movement capability. Required by every integration scenario. Surfaces as BE sub-stories within MISSION-STORY-002. |
| 4 | ROVER-STORY-002 | Rotation is required for directional navigation and all multi-step scenarios. Surfaces as BE sub-stories within MISSION-STORY-002. |
| 5 | MISSION-STORY-003 | Supporting story deferred to the Final Project. Obstacle-map functionality is currently referenced through Core story preconditions and existing obstacle-occupancy requirements in MISSION-STORY-004 and MISSION-STORY-002, but MISSION-STORY-003 does not yet have its own detailed bundle. |
| 6 | MISSION-STORY-001 | Initial rover state is the entry point for every run. Surfaces as a precondition in MISSION-STORY-002 scenarios. OD-002 affects input format. |
| 7 | MISSION-STORY-006 | Command sequence acceptance is a prerequisite for execution. Deferred because OD-002 (command representation) is unresolved and the capability is established through MISSION-STORY-002 preconditions. |
| 8 | MISSION-STORY-005 | Valid error handling requires OD-005 to be resolved before full specification is possible. Lowest MVP priority. |

---

## Dependencies

```
MISSION-STORY-001  (initial rover state)
MISSION-STORY-003  (obstacle positions)
MISSION-STORY-006  (command sequence)
        │
        └──► MISSION-STORY-002  (execute sequence, receive final state)  ← Core
                    │
                    ├── ROVER-STORY-001  (forward movement)      → BE sub-story
                    ├── ROVER-STORY-002  (rotation)              → BE sub-story
                    └── obstacle query                           → BE sub-story
                                │
                                └──► MISSION-STORY-004  (obstacle avoidance)  ← Core (authored)
```

MISSION-STORY-005 depends on MISSION-STORY-001 and MISSION-STORY-006 providing defined inputs
before invalid-input behavior can be fully specified.

---

## Open Architectural Decisions

The following open decisions from `../../architecture/11-risks-and-technical-debts.md` affect
story specification. None are resolved here.

| OD | Decision required | Affects |
|----|-------------------|---------|
| OD-001 | Grid boundary behavior: what happens when a move would cross the grid boundary? | ROVER-STORY-001 boundary scenarios |
| OD-002 | CLI input format and command representation: how are position, orientation, obstacles, and commands provided? | MISSION-STORY-001, MISSION-STORY-006 |
| OD-003 | Initial position validation: error if rover starts on an obstacle? | No current story — excluded until resolved |
| OD-004 | Blocked-movement feedback format and timing | MISSION-FE-004.1 in existing MISSION-STORY-004 bundle |
| OD-005 | Invalid-input handling: exit immediately or attempt to continue? | MISSION-STORY-005 — deferred until resolved |

Scenarios in all story bundles use technology-neutral wording and do not prescribe specific
command characters, symbols, or error message formats unless a decision has been approved.

---

## Module 3 Scope — Core Story Bundles

| Story ID | Title | Bundle file | Status |
|----------|-------|-------------|--------|
| MISSION-STORY-004 | Avoid Obstacles and Continue Processing | `mission-management.md` | **Complete — Authored** |
| MISSION-STORY-002 | Execute Command Sequence and Receive Final State | `mission-management.md` | **Complete — Module 3** |

Both bundles are in `docs/user-stories/mission-management.md`. Module 3 Core documentation
is complete.

---

## Final Project Scope — Supporting Story Backlog

The following stories are listed here for traceability. Full bundles will be generated during
the final project, after relevant open decisions are resolved.

| Story ID | Title | Blocked by |
|----------|-------|------------|
| ROVER-STORY-001 | Move Rover Forward | OD-001 (boundary scenarios) |
| ROVER-STORY-002 | Rotate Rover 90 Degrees | — |
| MISSION-STORY-001 | Set Initial Rover Position and Orientation | OD-002 (input format) |
| MISSION-STORY-003 | Define Obstacle Positions | OD-002 (input format) |
| MISSION-STORY-006 | Provide a Command Sequence | OD-002 (command representation) |
| MISSION-STORY-005 | Receive Feedback for Invalid Input | OD-005 (invalid-input handling) |

---

## Documentation Progress

| Phase | Stories | Bundles documented | Bundles remaining | Status |
|-------|---------|-------------------|-------------------|--------|
| Module 3 | 2 Core | 2 | 0 | **Complete** |
| Final Project | 6 Supporting | 0 | 6 | Deferred |
| **Total** | **8** | **2** | **6** | — |

> **Important:** Story bundle status tracks *documentation progress only*. It does not reflect
> implementation or test status. No application code has been written based on these stories.
> Implementation and automated testing are handled in later modules.

---

## File Map

| File | Contents | Status |
|------|----------|--------|
| `docs/user-stories/README.md` | This file — full inventory, Pareto analysis, progress tracking | Exists |
| `docs/user-stories/mission-management.md` | MISSION-STORY-004 (Core — authored), MISSION-STORY-002 (Core — Module 3); remaining MISSION-prefixed Supporting stories listed in backlog above, bundles deferred to Final Project | Exists |
| `docs/user-stories/rover.md` | ROVER-STORY-001, ROVER-STORY-002 — planned for Final Project | Does not exist yet |
