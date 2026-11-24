# 02 — Architecture Constraints

## Technical Constraints

| ID   | Constraint | Rationale |
|------|------------|-----------|
| TC-1 | The application is implemented in Python. | Approved in ADR-001. Python provides readable syntax and is sufficient for the kata's scope. |
| TC-2 | The application uses the Python standard library and requires no third-party runtime dependencies or application frameworks. Development and testing tools may be used separately. | Consistent with ADR-001. The Mars Rover application does not require additional runtime libraries or frameworks. Development and testing tools can be used without introducing dependencies into the application itself. |
| TC-3 | All state is held in memory for the duration of a single run. No database or file-based persistence is used. | Approved in ADR-001. The kata requires no persistent storage between runs. |
| TC-4 | The application runs as a single local process. No network communication, background services, or distributed components are introduced. | Approved in ADR-001. The kata is a self-contained simulation and does not require remote access. |
| TC-5 | The application is structured as three logical components: Mission Controller, Rover, and Map. These are Python modules or classes within one runnable application, not separate processes or services. | Approved in ADR-001. The separation provides clear responsibilities without introducing deployment complexity. |

---

## Organisational Constraints

| ID   | Constraint | Rationale |
|------|------------|-----------|
| OC-1 | The architecture must follow the arc42 template, documented chapter by chapter with explicit review and approval at each step. | Required by the Module 2 exercise guidelines. |
| OC-2 | C4 architecture diagrams (Context, Container, Component) must use the C4 model and be written as PlantUML files using the C4-PlantUML library. Other diagram types, such as runtime sequence diagrams, must use the appropriate PlantUML notation. | Required by the architecture-agent configuration for this project. |
| OC-3 | Significant architectural decisions must be recorded as ADRs in `architecture/09-architecture-decisions.md`. | Required by the architecture-agent configuration. ADR-001 is already in place and must not be modified without explicit approval. |

---

## Domain Constraints

| ID   | Constraint | Rationale |
|------|------------|-----------|
| DC-1 | The rover moves on a grid of integer coordinates. Each move-forward command advances the rover exactly one step in the direction it currently faces. | Consistent with FR-3 in Chapter 1 and the grid-based movement model. |
| DC-2 | Valid orientations are North, East, South, and West. Turning left or right rotates the rover 90° and keeps it within these four directions. | Defined by the Mars Rover kata. |
| DC-3 | The map contains a set of obstacle positions. The rover must not occupy a position that coincides with an obstacle. | Defined by the Mars Rover kata and FR-5. |
| DC-4 | The application does not need to handle concurrent rovers, multiple missions, or rover communication. | The kata describes a single-rover simulation. These capabilities are out of scope unless explicitly added. |
