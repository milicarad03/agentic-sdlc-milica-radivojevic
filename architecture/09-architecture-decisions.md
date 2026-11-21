# 09 — Architecture Decisions

## ADR-001: Use Python CLI with In-Memory State

**Status:** Accepted

**Context:**

The Mars Rover kata requires an application that simulates the movement of a rover on a grid containing obstacles.

The application must accept an initial position, orientation, map, and sequence of movement commands. It must process these commands, prevent the rover from moving into obstacles, and return its final position and orientation.

We need to choose a programming language, application interface, framework, and data storage approach.

The solution should be simple, maintainable, and suitable for demonstrating software architecture principles.

**Decision:**

Use Python to implement the Mars Rover system as a single command-line application.

- **Language:** Python
- **Interface:** Command-Line Interface (CLI)
- **Framework:** Python standard library, without additional frameworks
- **Data storage:** In-memory state, without a database
- **Architecture:** Three logical components: Mission Controller, Rover, and Map

The application will run locally without requiring external services.

**Rationale:**

- Python provides readable syntax, allowing us to focus on the application's logic and architecture.
- A CLI is sufficient for entering rover commands and displaying the final result.
- An additional framework is unnecessary for a small application without a web interface.
- In-memory state is sufficient because the kata does not require persistent storage.
- Separating the application into Mission Controller, Rover, and Map provides clear responsibilities and makes the code easier to test and maintain.
- A single application avoids unnecessary deployment and infrastructure complexity.

**Consequences:**

- The application can run locally without external services.
- The architecture is simple to understand, maintain, and test.
- Rover state is lost when the application terminates.
- The application does not provide a graphical user interface.
- The system is intended for local execution rather than remote access.
- Adding persistent storage or a web interface in the future would require additional architectural decisions.

---

## ADR-002: Continue Command Processing After a Blocked Movement

**Status:** Accepted

**Context:**

The Mars Rover kata requires the system to prevent the rover from moving into a position occupied by an obstacle. When a move-forward command would place the rover on an obstacle, that movement must be blocked and the rover's position and orientation must remain unchanged.

The kata does not explicitly define what should happen to the remaining commands in the sequence after a movement is blocked. Two alternatives were considered:

- **Option A — Continue processing:** skip only the blocked movement and continue executing the remaining commands in sequence.
- **Option B — Stop processing:** treat a blocked movement as a terminal condition and halt the entire command sequence at that point.

**Decision:**

When a move-forward command is blocked by an obstacle, skip only that movement and continue processing the remaining commands in their original order. The rover's position and orientation are preserved unchanged, and subsequent commands are executed as normal.

**Rationale:**

- This is a reasonable interpretation of the original Mars Rover kata, which does not prescribe halting behavior on a blocked move.
- Continuing after a blocked move avoids introducing an additional rule that terminates the sequence, keeping the system's behavior simpler and more predictable.
- Command processing remains deterministic: given the same initial rover position and orientation, obstacle map, and command sequence, the system always produces the same result.
- This behavior is consistent with the Mission Controller coordinating command execution, the Rover preserving its state when a move is blocked, and the Map answering obstacle queries — the three-component architecture approved in ADR-001 requires no structural change to support this decision.

**Consequences:**

- The Mission Controller must continue iterating over the command sequence after a blocked movement rather than terminating early.
- The Rover must not update its position or orientation when the Mission Controller determines that a movement is blocked.
- Unit and integration tests must include cases that verify continued command processing after encountering one or more obstacles.
- A blocked movement does not terminate the command sequence.
- The exact format of user-facing feedback for blocked movements remains an implementation detail and is not decided here.
