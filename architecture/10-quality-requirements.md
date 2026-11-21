# 10 — Quality Requirements

## Quality Goals

The five quality goals below are carried forward from Chapter 1, in the same priority order. Each is explained in the specific context of the Mars Rover System.

| Priority | Quality Attribute | In Context |
|----------|-------------------|------------|
| 1 | **Correctness** | The rover's position and orientation after a command sequence must exactly match the expected result given the initial state, the obstacle map, and the commands. Obstacle avoidance must be enforced without exception, and the rover's state must not change when a move is blocked. |
| 2 | **Testability** | Movement, rotation, and obstacle detection must be testable at the component level without a running CLI. Each component must have a clear interface and hold no hidden global state. |
| 3 | **Maintainability** | Mission Controller, Rover, and Map each have one clearly defined responsibility. A change to one component's internal implementation must not require changes to the others, provided interfaces remain stable. |
| 4 | **Simplicity** | The application runs with a single Python command, has no external runtime dependencies, and requires no installation beyond Python itself. |
| 5 | **Usability** | The CLI accepts inputs and returns a human-readable result. The user receives clear feedback when a movement is blocked. |

---

## Quality Tree

The tree below organises the five quality goals and their principal concerns.

```
Mars Rover System Quality
│
├── 1. Correctness
│   ├── Accurate movement and rotation results
│   ├── Obstacle avoidance enforced
│   ├── No state change on blocked movement
│   └── Continued processing after a blocked movement
│
├── 2. Testability
│   ├── Rover movement and rotation testable in isolation
│   ├── Map obstacle queries testable in isolation
│   └── Mission Controller coordination testable without CLI
│
├── 3. Maintainability
│   ├── Single responsibility per component
│   └── Internal changes do not propagate across components
│
├── 4. Simplicity
│   ├── Single local process, no external services
│   └── No third-party runtime dependencies
│
└── 5. Usability
    ├── Human-readable output
    └── Clear feedback on blocked movements
```

---

## Quality Scenarios

### Correctness

| ID | QS-C1 |
|----|-------|
| **Quality attribute** | Correctness |
| **Scenario** | The rover starts at (0, 0) facing North and receives a move-forward command with no obstacle at (0, 1). |
| **Expected response** | The rover is at (0, 1) facing North. |
| **Verification** | Unit test: initialise Rover at (0, 0) North, confirm Map reports (0, 1) clear, instruct Rover to move, assert position is (0, 1) and orientation is North. |

| ID | QS-C2 |
|----|-------|
| **Quality attribute** | Correctness |
| **Scenario** | The rover faces North and receives a turn-left command. |
| **Expected response** | The rover now faces West. Position is unchanged. |
| **Verification** | Unit test: initialise Rover facing North, apply rotate-left, assert orientation is West and position is unchanged. |

| ID | QS-C3 |
|----|-------|
| **Quality attribute** | Correctness |
| **Scenario** | The rover faces North and receives a turn-right command. |
| **Expected response** | The rover now faces East. Position is unchanged. |
| **Verification** | Unit test: initialise Rover facing North, apply rotate-right, assert orientation is East and position is unchanged. |

| ID | QS-C4 |
|----|-------|
| **Quality attribute** | Correctness |
| **Scenario** | The rover attempts to move forward into a position occupied by an obstacle. |
| **Expected response** | The Map correctly identifies the target position as blocked. |
| **Verification** | Unit test: initialise Map with an obstacle at a known position, query that position, assert the result indicates an obstacle is present. |

| ID | QS-C5 |
|----|-------|
| **Quality attribute** | Correctness |
| **Scenario** | A move-forward command would place the rover on an obstacle. |
| **Expected response** | The rover's position and orientation remain unchanged after the command is processed. |
| **Verification** | Unit or integration test: record rover state before the blocked command, process the command, assert position and orientation are identical afterwards. |

| ID | QS-C6 |
|----|-------|
| **Quality attribute** | Correctness |
| **Scenario** | The rover starts at (0, 0) facing North with an obstacle at (0, 1). The command sequence is: Forward, Right, Forward. |
| **Expected response** | The first Forward is blocked by the obstacle at (0, 1); the rover remains at (0, 0) facing North. Right changes orientation to East. The second Forward moves the rover to (1, 0). Final state: position (1, 0), orientation East. |
| **Verification** | Integration test: initialise rover at (0, 0) North with obstacle at (0, 1), process the sequence [Forward, Right, Forward], assert final position is (1, 0) and orientation is East. Explicitly verifies ADR-002. |

| ID | QS-C7 |
|----|-------|
| **Quality attribute** | Correctness |
| **Scenario** | The rover starts at (0, 0) facing North with an obstacle at (0, 1). The command sequence is: Forward, Right, Forward, Left, Forward. |
| **Expected response** | First Forward is blocked; rover remains at (0, 0) North. Right changes orientation to East. Second Forward moves to (1, 0) East. Left changes orientation to North. Final Forward moves to (1, 1) North. Final state: position (1, 1), orientation North. |
| **Verification** | Integration test: initialise rover at (0, 0) North with obstacle at (0, 1), process the sequence [Forward, Right, Forward, Left, Forward], assert final position is (1, 1) and orientation is North. |

---

### Testability

| ID | QS-T1 |
|----|-------|
| **Quality attribute** | Testability |
| **Scenario** | A developer writes a unit test for Rover movement and rotation without constructing a Mission Controller or Map. |
| **Expected response** | The test can create a Rover with a known initial state, apply a command, and assert the result directly. |
| **Verification** | Confirmed if Rover tests can be written and executed without importing or instantiating Mission Controller or Map. |

| ID | QS-T2 |
|----|-------|
| **Quality attribute** | Testability |
| **Scenario** | A developer writes a unit test for Map obstacle detection without constructing a Mission Controller or Rover. |
| **Expected response** | The test can create a Map with known obstacle locations and assert query results directly. |
| **Verification** | Confirmed if Map tests can be written and executed without importing or instantiating Mission Controller or Rover. |

| ID | QS-T3 |
|----|-------|
| **Quality attribute** | Testability |
| **Scenario** | A developer tests Mission Controller coordination logic without invoking the CLI layer. |
| **Expected response** | The test can initialise a Mission Controller with known inputs, process a command sequence, and assert the resulting rover state without reading from stdin or writing to stdout. |
| **Verification** | Confirmed if Mission Controller can be constructed and exercised in a test without any CLI interaction. |

---

### Maintainability

| ID | QS-M1 |
|----|-------|
| **Quality attribute** | Maintainability |
| **Scenario** | A developer reviews the codebase to understand a single component's behavior. |
| **Expected response** | The responsibilities of Mission Controller, Rover, and Map are evident from their structure without requiring knowledge of the other components' internals. |
| **Verification** | Assessed during code review: each component's purpose is clear from its interface and internal logic alone. |

| ID | QS-M2 |
|----|-------|
| **Quality attribute** | Maintainability |
| **Scenario** | A developer changes the internal data structure used by Map to store obstacle locations. |
| **Expected response** | No changes are required to Rover or Mission Controller, provided the Map's query interface remains unchanged. |
| **Verification** | Confirmed if the change can be made and all existing tests pass without modifying Rover or Mission Controller source. |

---

### Simplicity

| ID | QS-S1 |
|----|-------|
| **Quality attribute** | Simplicity |
| **Scenario** | A developer clones the repository on a machine with Python installed and runs the application. |
| **Expected response** | The application runs successfully without installing any additional packages. |
| **Verification** | Confirmed by running the application in a clean Python environment with only the standard library available, consistent with TC-2. |

| ID | QS-S2 |
|----|-------|
| **Quality attribute** | Simplicity |
| **Scenario** | A developer inspects the application's dependencies. |
| **Expected response** | No third-party runtime packages are listed or required. |
| **Verification** | Confirmed by inspecting the project's dependency configuration and verifying only the Python standard library is used at runtime. |

---

### Usability

| ID | QS-U1 |
|----|-------|
| **Quality attribute** | Usability |
| **Scenario** | The application finishes processing a command sequence. |
| **Expected response** | The resulting rover position and orientation are printed in a human-readable format. |
| **Verification** | Manual or automated test: run the application with known inputs and assert the output is readable and correctly represents the final rover state. The exact output format remains an implementation decision. |

| ID | QS-U2 |
|----|-------|
| **Quality attribute** | Usability |
| **Scenario** | A move-forward command is blocked by an obstacle during command processing. |
| **Expected response** | The CLI provides clear feedback indicating that a movement was blocked, consistent with the Usability quality goal in Chapter 1. |
| **Verification** | Manual or automated test: run the application with a command sequence that includes a blocked move and confirm the output includes feedback about the blocked movement. The exact format and timing of the feedback remain implementation decisions. |
