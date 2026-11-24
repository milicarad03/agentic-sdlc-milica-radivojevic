# 12 — Glossary

This glossary defines the key terms used throughout the Mars Rover architecture documentation. Terms are grouped by category for readability. Where a term appears in multiple categories, it is defined once in the most relevant category and cross-referenced elsewhere.

---

## Domain Terminology

| Term | Definition |
|------|------------|
| **Mars Rover System** | The software system being designed and documented. It simulates the movement of a single rover on a grid containing obstacles. It accepts an initial position, orientation, obstacle map, and command sequence, and returns the rover's resulting position and orientation. |
| **Rover** | The simulated vehicle whose movement is controlled by the system. The Rover has a position and an orientation at all times. It moves one step forward or rotates 90° in response to commands. |
| **Position** | A pair of integer coordinates (x, y) identifying a cell on the grid. The rover occupies exactly one position at any point in time. Obstacle locations are also expressed as positions. |
| **Orientation** | The cardinal direction the rover is currently facing: North, East, South, or West. Orientation determines which grid cell a forward movement would reach. |
| **Grid** | The two-dimensional space of integer coordinate cells on which the rover moves. The kata illustrates finite grids. How movement beyond grid boundaries should be handled has not yet been decided (see OD-001). |
| **Obstacle** | An object occupying a grid position. The rover cannot move into a position occupied by an obstacle. Obstacles are fixed for the duration of a run. |
| **Obstacle Map** | The complete set of obstacle positions provided as input at the start of a run. Also referred to as the map. The Map component holds this data in memory and answers occupancy queries during command processing. |
| **Command** | A single instruction given to the rover. Three command types are defined: move forward one step, turn left 90°, and turn right 90°. The exact representation of commands in the CLI has not yet been decided (see OD-002). |
| **Command Sequence** | An ordered list of commands provided as input. Commands are processed one at a time, in the order given, from first to last. |
| **Forward Movement** | A command that advances the rover one step in the direction it currently faces. Before the move is applied, the Mission Controller checks the candidate position for obstacles. See also: Candidate Position, Blocked Movement. |
| **Rotation** | A command that changes the rover's orientation by 90° without changing its position. A left rotation from North yields West; a right rotation from North yields East. Rotation does not require an obstacle check. |
| **Candidate Position** | The grid position the rover would occupy if a forward movement were applied, calculated from its current position and orientation before any state is updated. The Mission Controller uses the candidate position to query the Map before deciding whether to allow the move. |
| **Blocked Movement** | A forward movement command whose candidate position is occupied by an obstacle. The movement is skipped: the rover's position and orientation remain unchanged. Command processing continues with the next command in the sequence. This behavior is defined in ADR-002. |

---

## Architectural Terminology

| Term | Definition |
|------|------------|
| **Software Architecture** | The set of significant structural decisions about a system: its components, their responsibilities, the relationships between them, and the principles guiding those decisions. In this project, the architecture is documented using the arc42 template and C4 model. |
| **Component** | A logical unit of responsibility within an application. In this system, the three components are Mission Controller, Rover, and Map. Components are not independently deployable processes or services; they are distinct units of responsibility within the single Mars Rover CLI application. In C4 terminology, a component is an element within a container (see C4 Model). |
| **Mission Controller** | The component responsible for receiving and parsing user input, coordinating command execution, and returning the final result. For each forward movement command, it queries the Map for the candidate position before instructing the Rover to move. It is the sole decision-maker for obstacle avoidance. |
| **Rover Component** | The component responsible for maintaining the rover's current position and orientation, calculating candidate positions for forward movements, applying permitted moves, and applying rotations. It does not make obstacle-avoidance decisions. |
| **Map Component** | The component responsible for storing obstacle locations and answering occupancy queries. Its obstacle set is populated once at startup from user input and is read-only during command processing. |
| **Separation of Concerns** | The principle that each component should have one clearly defined responsibility, so that changes to one component do not require changes to others. In this system: Mission Controller coordinates, Rover manages movement and orientation, Map manages obstacle knowledge. |
| **In-Memory State** | Application state that exists only within the running process and is discarded when the process exits. The rover's position, orientation, and obstacle locations are all held in memory. No database or file-based persistence is used. |
| **Deterministic Processing** | A property of the system whereby the same initial rover position and orientation, obstacle map, and command sequence always produce the same result, regardless of when or how many times the application is run. |
| **Runtime** | The period during which the application is executing. All command processing, state updates, and obstacle checks occur at runtime within a single process. |
| **Deployment** | The act of making the application available for execution. The Mars Rover System has a single deployment unit: the Mars Rover CLI application running as a local Python process on the user's machine. No server, cloud infrastructure, or containerization technology is required. |
| **Command-Line Interface (CLI)** | The interface through which the user interacts with the Mars Rover System. The user provides inputs and receives the result via a terminal. The exact input format and output format remain implementation decisions. |

---

## arc42 and C4 Terminology

| Term | Definition |
|------|------------|
| **arc42** | A template for documenting software architecture, structured as twelve chapters covering goals, constraints, context, strategy, building blocks, runtime, deployment, crosscutting concepts, decisions, quality, risks, and glossary. This documentation follows the arc42 template. |
| **C4 Model** | A hierarchical notation for visualising software architecture at four levels of abstraction: System Context (C1), Container (C2), Component (C3), and Code (C4). Diagrams in this documentation use the C4-PlantUML library. |
| **System Context Diagram** | A C4 Level 1 (C1) diagram showing the system as a whole, its users, and any external systems it interacts with. The Mars Rover System Context diagram shows the User and the Mars Rover System. |
| **Container Diagram** | A C4 Level 2 (C2) diagram showing the independently runnable or deployable units within a system boundary. For the Mars Rover System, the single container is the Mars Rover CLI application. In C4 terminology, a container is an application or deployable unit and is unrelated to containerization technologies such as Docker. |
| **Component Diagram** | A C4 Level 3 (C3) diagram showing the internal logical components of a selected container. The Mars Rover component diagram shows Mission Controller, Rover, and Map within the CLI application. |
| **Sequence Diagram** | A UML diagram showing the interactions between participants over time, used in this documentation to illustrate the runtime command-processing workflow. Sequence diagrams use standard PlantUML notation, not C4 notation. |
| **Deployment Diagram** | A UML diagram showing where and how software elements run at deployment time. The Mars Rover deployment diagram shows the local computer, Python runtime, and Mars Rover CLI. |
| **Architecture Decision Record (ADR)** | A document recording a significant architectural decision, including its context, the decision made, the rationale, and the consequences. ADRs in this project follow a Status / Context / Decision / Rationale / Consequences structure. ADR-001 records the Python CLI and in-memory state decisions; ADR-002 records the obstacle-handling behavior. |

---

## Documentation and Quality Terminology

| Term | Definition |
|------|------------|
| **Quality Goal** | A named quality attribute that the architecture aims to satisfy, with an associated priority and scenario. The five quality goals for this system are Correctness, Testability, Maintainability, Simplicity, and Usability (Chapter 1 and Chapter 10). |
| **Quality Scenario** | A concrete, observable description of a system interaction or condition that verifies a quality goal. Each scenario in Chapter 10 includes an ID, quality attribute, scenario description, expected response, and verification method. |
| **Functional Requirement (FR)** | A statement of a capability the system must provide. The functional requirements for the Mars Rover System are documented as FR-1 through FR-6 in Chapter 1. |
| **Technical Constraint (TC)** | A restriction on the technology or approach used to build the system. Technical constraints for this project are documented as TC-1 through TC-5 in Chapter 2. |
| **Architectural Risk (RISK)** | An uncertainty or condition that could negatively affect the system if not addressed before or during implementation. Risks are documented as RISK-001 through RISK-005 in Chapter 11. |
| **Open Decision (OD)** | A behavioral or implementation question that has been identified but not yet resolved. Open decisions must be answered before the affected component is implemented. OD-001 through OD-005 are documented in Chapter 11. |
| **Technical Debt** | A known compromise accepted during design or implementation that may require additional work in the future. No technical debt has been introduced in the current architecture. The simple, dependency-free design is an intentional choice, not a shortcut. |
| **Unit Test** | A test that verifies the behavior of a single component in isolation, without constructing or invoking other components. The architecture is designed to support unit tests for Rover movement, Rover rotation, and Map obstacle queries independently. |
| **Integration Test** | A test that verifies the interaction between multiple components. In this system, integration tests verify the full command-processing flow through Mission Controller, Rover, and Map, including blocked and unblocked movement scenarios. |
| **PlantUML** | An open-source tool for generating diagrams from plain text descriptions. All diagrams in this project are written as `.puml` files and rendered to SVG using the C4-PlantUML library (for C4 diagrams) or standard PlantUML sequence and deployment notation. |
| **SVG** | Scalable Vector Graphics. The output format used for all diagrams in this documentation. SVG files are generated from `.puml` source files and referenced from Markdown chapters. |
