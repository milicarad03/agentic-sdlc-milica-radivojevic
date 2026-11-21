# 04 — Solution Strategy

## Overall Architectural Approach

The Mars Rover System is implemented as a single Python CLI application that runs locally without external services or infrastructure.

This approach is appropriate because the kata defines a self-contained simulation: one user, one rover, one grid, one command sequence, one result. There is no concurrent access, no shared data, and no integration with external systems. A microservice architecture would introduce deployment, networking, and coordination complexity that the problem does not require. A database would add persistence that the kata does not need. A web framework would impose structure suited to HTTP request handling, not sequential command processing.

The Python standard library provides all the primitives needed: data structures for the grid and obstacle set, control flow for command processing, and standard input/output for the CLI. Keeping the application dependency-free means it can be run anywhere Python is available, with no installation step beyond the language itself.

---

## Separation of Responsibilities

The application is divided into three logical components, consistent with ADR-001 and TC-5:

| Component | Responsibility |
|-----------|---------------|
| **Mission Controller** | Receives and parses user input. Coordinates the execution of the command sequence. For each move-forward command, consults the Map to check whether the target position is blocked before allowing the Rover to move. Returns the final result to the user. |
| **Rover** | Maintains the current position and orientation. Calculates the potential next position for a move-forward command without updating state. Performs the movement when the Mission Controller determines the target position is clear. Handles rotation commands directly, as they do not involve obstacle checking. The rover's position is never updated when the target position is blocked. |
| **Map** | Stores obstacle locations. Answers queries about whether a given position is occupied by an obstacle. |

Each component has a single, focused responsibility. The Mission Controller orchestrates but does not encode movement or grid rules. The Rover encodes movement and rotation but does not decide whether a move is safe. The Map encodes obstacle knowledge but does not drive execution.

This separation means each component can be read, tested, and modified without understanding the internals of the others. A change to how obstacles are stored affects only the Map. A change to how rotation is calculated affects only the Rover. A change to how input is parsed affects only the Mission Controller.

---

## State Management

All state is held in memory for the duration of a single run:

- The **Rover** holds the current position (x, y) and orientation as mutable state, updated after each successfully executed command.
- The **Map** holds the obstacle positions as an in-memory collection, populated once from user input and read-only thereafter.
- No state is written to disk or a database. When the process exits, all state is discarded.

This is sufficient because the kata requires no history, no persistence between runs, and no shared access from other processes. In-memory state is also the simplest model to reason about and test: the system's behavior at any point is fully determined by the inputs provided at startup and the commands processed so far.

---

## Quality Goals

The table below explains how the architecture supports each quality goal approved in Chapter 1.

| Quality Goal | How the Architecture Supports It |
|---|---|
| **Correctness** | Movement and rotation logic are isolated in the Rover component, where they can be tested exhaustively with unit tests. Obstacle checking is a separate, explicit step before any position update. |
| **Testability** | Each component exposes a clear interface and holds no hidden global state, making it straightforward to construct test scenarios without involving the CLI layer. |
| **Maintainability** | The three-component separation keeps responsibilities distinct. Changes to one component do not require changes to the others, provided the interfaces between them remain stable. |
| **Simplicity** | One process, three logical components, no external dependencies. The application can be run with a single Python command and requires no installation beyond Python itself. |
| **Usability** | The CLI accepts inputs and returns a human-readable result. The exact input mechanism will be determined during implementation. |

---

## Architectural Decisions and Trade-offs

The key architectural decision for this system is recorded in **ADR-001** (`architecture/09-architecture-decisions.md`): Python CLI, standard library only, in-memory state, single process, three logical components.

The main trade-offs that follow from this decision:

- **Simplicity over extensibility.** The architecture is optimized for the kata's scope. Adding persistent storage, a web interface, or multiple rovers would require new architectural decisions rather than straightforward extension.
- **In-memory state over durability.** Rover state is lost when the process exits. This is acceptable because the kata has no persistence requirement, and in-memory state is easier to test and reason about.
- **Single process over distribution.** There is no network boundary between components, which eliminates latency, serialization, and fault-tolerance concerns that would be irrelevant to the problem. The trade-off is that the components cannot be scaled or deployed independently, which is not a requirement here.
- **Obstacle-handling strategy.** When a forward movement is blocked, the rover's position and orientation remain unchanged, and subsequent commands continue to be processed. This is an explicit project decision based on our interpretation of the Mars Rover kata.
