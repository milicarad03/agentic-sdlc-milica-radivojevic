# 11 — Risks and Technical Debt

## Overview

This chapter documents the architectural risks, open decisions, and technical debt relevant to the Mars Rover System at its current stage of documentation.

- **Architectural risks** are uncertainties or conditions that could negatively affect the correctness, maintainability, or testability of the system if not addressed before or during implementation.
- **Open decisions** are behavioral or implementation details that have been identified but not yet resolved. They are not automatically technical debt; they are questions that must be answered before the affected code is written.
- **Technical debt** is a known compromise or shortcut that has been accepted and may require additional work in the future. The absence of a database, frameworks, or external services is not technical debt — it is an intentional and approved design choice.

The application has not yet been implemented. No technical debt has been introduced through implementation shortcuts at this stage.

---

## Architectural Risks

### RISK-001: Grid Boundary Behavior Undefined

| Field | Detail |
|-------|--------|
| **Description** | The kata illustrates finite grids but does not define what should happen when a move-forward command would take the rover beyond the map boundary. The architecture does not currently specify boundary behavior. |
| **Potential impact** | Movement logic in the Rover and obstacle-checking logic in the Mission Controller may need to be extended or modified once a boundary behavior is chosen. Test cases for boundary conditions cannot be written until the behavior is defined. |
| **Likelihood** | High — boundary behavior must be decided before the move-forward logic can be fully implemented. |
| **Mitigation** | Decide boundary behavior before implementing move-forward logic. Document the decision in Chapter 8 or as an ADR if the choice has significant architectural consequences (see OD-001). |
| **Status** | Open. Boundary behavior has not yet been decided. |

---

### RISK-002: CLI Input Format and Command Representation Undefined

| Field | Detail |
|-------|--------|
| **Description** | The exact format for providing inputs at the command line — including how positions, orientations, obstacles, and commands are represented — has not been specified. The architecture has deliberately avoided prescribing specific command characters or input structures. |
| **Potential impact** | Without a defined input format, the Mission Controller's input-parsing logic cannot be implemented. Inconsistent or incomplete parsing could cause invalid state to be passed to Rover or Map, leading to incorrect behavior. |
| **Likelihood** | High — input format must be decided before any CLI code can be written. |
| **Mitigation** | Define the input format before implementing the Mission Controller. Validate inputs at the CLI boundary and report unrecognised inputs clearly, consistent with the principle in Chapter 8. The format decision does not require an ADR unless it introduces new architectural concerns. |
| **Status** | Open. See OD-002. |

---

### RISK-003: Initial Rover Position Coinciding With an Obstacle

| Field | Detail |
|-------|--------|
| **Description** | It is not yet decided whether placing the rover's initial position on an obstacle position should be treated as an error or silently accepted. The kata does not address this case. |
| **Potential impact** | If not handled, an initialisation on an obstacle position could result in an invalid starting state. Inconsistent handling could mislead the user or cause unexpected behavior during command processing. |
| **Likelihood** | Low in normal use, but the case is easy to trigger with malformed input. The impact of leaving it unhandled is moderate. |
| **Mitigation** | Decide the initialisation validation rule before implementing the Mission Controller. A simple guard at startup is sufficient; no structural change to the architecture is required. |
| **Status** | Open. See OD-003. |

---

### RISK-004: Incorrect Coordination Between Mission Controller, Rover, and Map

| Field | Detail |
|-------|--------|
| **Description** | The correctness of the system depends on the Mission Controller querying the Map before allowing a move, and on the Rover not updating its state when a move is blocked. An implementation error in this coordination — such as applying a move before checking the Map, or updating the Rover's state on a blocked move — would violate the invariants in Chapter 6 and ADR-002. |
| **Potential impact** | The rover could move into obstacle positions or report an incorrect final state, directly failing the Correctness quality goal. |
| **Likelihood** | Low if the architecture is followed carefully, but the coordination sequence has multiple steps and is easy to implement incorrectly without adequate tests. |
| **Mitigation** | Implement the quality scenarios QS-C4, QS-C5, QS-C6, and QS-C7 from Chapter 10 as tests before or alongside the Mission Controller implementation. The sequence diagram in Chapter 6 provides an unambiguous reference for the correct interaction order. |
| **Status** | Open — mitigation planned. The architecture and Chapter 10 quality scenarios provide a testing strategy, but implementation and tests have not yet been completed. |

---

### RISK-005: Insufficient Test Coverage

| Field | Detail |
|-------|--------|
| **Description** | The Testability quality goal requires that movement, rotation, and obstacle detection be exercisable independently. If components are implemented with hidden dependencies or global state, the isolation required for unit testing will be lost. |
| **Potential impact** | Errors in movement, rotation, or obstacle-handling logic may go undetected. Regressions introduced by later changes would be harder to identify. |
| **Likelihood** | Low if the three-component separation is respected during implementation. The risk increases if implementation shortcuts blur the boundaries between components. |
| **Mitigation** | Use the quality scenarios in Chapter 10 (QS-T1, QS-T2, QS-T3) as the basis for the test suite. Each component should be testable without constructing the others. Development testing tools such as pytest may be used without introducing runtime dependencies, consistent with TC-2. |
| **Status** | Open — mitigation planned. The architecture supports independent component testing, but actual test coverage has not yet been established. |

---

## Open Decisions

The following questions must be resolved before implementing the affected behavior. None of these is currently classified as technical debt because no implementation commitment has been made.

| ID | Decision Required | Affects | Notes |
|----|-------------------|---------|-------|
| OD-001 | Grid boundary behavior: what happens when a move-forward command would take the rover off the grid? | Rover movement logic, Mission Controller coordination, Map responsibilities, test cases | Noted in Chapter 8 as undecided. Requires a decision before move-forward can be fully implemented. |
| OD-002 | CLI input format and command representation: how are position, orientation, obstacles, and commands provided? | Mission Controller input parsing, user documentation, usability | Noted in Chapters 4 and 8. Must be decided before CLI implementation. |
| OD-003 | Initial position validation: should the application report an error if the rover's initial position coincides with an obstacle? | Mission Controller initialisation logic | Not addressed by the kata. A simple validation rule is sufficient; no structural change required. |
| OD-004 | Blocked-movement feedback format and timing: when and how does the CLI notify the user that a movement was blocked? | Mission Controller output, Usability quality goal (QS-U2) | Noted in Chapters 8 and 10. The requirement for clear feedback is established; the format remains open. |
| OD-005 | Invalid-input handling: when the application receives malformed input or an unrecognised command, should it terminate processing with an error or attempt to continue? | CLI input validation, Mission Controller coordination, error reporting, usability and correctness | Chapter 8 identifies invalid-input handling as undecided. The behavior should be explicitly defined before implementing input validation. |

---

## Technical Debt

No technical debt has been introduced at this stage. The application has not yet been implemented.

The following are deliberate design choices, not technical debt:

- In-memory state with no persistence (approved in ADR-001, TC-3).
- No third-party runtime dependencies (approved in ADR-001, TC-2).
- No database, web framework, or external services (approved in ADR-001, Chapter 4).
- Three logical components rather than a more granular decomposition (approved in ADR-001, TC-5).

**Potential future technical debt** may arise in the following areas if not addressed during implementation:

- If input parsing logic is embedded in the Mission Controller without a clear separation, it may become harder to change the input format later without touching coordination logic.
- If the Rover's movement calculations are implemented without clear interfaces, adding support for new command types or grid geometries in a later module would require more invasive changes.

These are risks to watch during implementation, not debt that exists today.

---

## Mitigation and Follow-up

The table below maps the identified risks and open decisions to the quality scenarios in Chapter 10 that provide concrete verification.

| Risk / Open Decision | Related Quality Scenarios | Follow-up Action |
|----------------------|--------------------------|------------------|
| RISK-001 (boundary behavior) | QS-C1 (movement), future boundary scenarios | Decide OD-001 before implementing move-forward. |
| RISK-002 (input format) | QS-S1, QS-S2, QS-U1 | Decide OD-002 before implementing Mission Controller parsing. |
| RISK-003 (initial position on obstacle) | Future initial-position validation scenario (to be defined after OD-003 is resolved). | Decide OD-003 before implementing initialisation, then add a corresponding validation test. |
| RISK-004 (coordination correctness) | QS-C4, QS-C5, QS-C6, QS-C7 | Implement these as tests alongside Mission Controller development. |
| RISK-005 (test coverage) | QS-T1, QS-T2, QS-T3 | Implement component-level tests before or alongside each component. |
| OD-004 (blocked-movement feedback) | QS-U2 | Decide format before implementing Mission Controller output. |

Open decisions OD-001 through OD-005 should be resolved and documented before implementation of the affected component begins. If any resolution has significant architectural consequences, a new ADR should be created.
