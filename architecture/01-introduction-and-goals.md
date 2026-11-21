# 01 — Introduction and Goals

## Purpose

The Mars Rover System simulates the movement of a rover on a rectangular grid.
The user provides an initial position and orientation, a map of obstacles, and a sequence of commands.
The system executes those commands, enforces obstacle avoidance, and reports the rover's final position and orientation.

This document describes the architecture of the system as part of Module 2, GitHub Issue #3,
using the arc42 template and C4 model notation.

---

## Functional Requirements

| ID   | Requirement |
|------|-------------|
| FR-1 | Accept the rover's initial position as a grid coordinate (x, y) and an orientation (N, E, S, W). |
| FR-2 | Accept a map that defines the locations of obstacles on the grid. |
| FR-3 | Accept a sequence of commands: move forward one step, turn left 90°, and turn right 90°. |
| FR-4 | Execute each command in sequence, updating the rover's position or orientation accordingly. |
| FR-5 | When a move-forward command would place the rover on an obstacle, prevent the movement and leave the rover's position unchanged. |
| FR-6 | Report the rover's resulting position and orientation when command processing ends. |

---

## Quality Goals

The following quality attributes are most important for this system, listed in priority order.

| Priority | Quality Attribute | Scenario |
|----------|-------------------|----------|
| 1 | **Correctness** | The rover's position and orientation are always consistent with the commands given and the obstacle rules. |
| 2 | **Testability** | Domain logic (movement, rotation, obstacle detection) can be exercised with unit tests independent of CLI input/output. |
| 3 | **Maintainability** | Mission Controller, Rover, and Map have clearly defined responsibilities, so each component can be understood, tested, and modified independently of the others. |
| 4 | **Simplicity** | The application runs with a single command, requires no installation beyond Python, and has no external dependencies. |
| 5 | **Usability** | The CLI provides clear feedback on the final state and on any blocked movement. |

---

## Stakeholders

| Role | Concern |
|------|---------|
| **Developer** | Understands the component boundaries and logic well enough to implement, extend, and test the system. |
| **Architect** | Verifies that the design satisfies the requirements and quality goals, and that decisions are recorded. |
| **Reviewer / Assessor** | Evaluates the architecture documentation for Module 2 of the agentic SDLC exercise. |
| **User** | Runs the CLI, provides inputs, and reads the output. Expects correct and readable results. |
