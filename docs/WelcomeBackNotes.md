# KBCF Welcome Back Notes

## Read These In Order

1. Development_State.md
2. VERIFIED.md
3. Architecture.md
4. Doctrine.md
5. ROADMAP.md
6. CHANGELOG.md

---

## Project Recovery Rules

Do not recover project state from memory.

Do not recover project state from previous chats.

Recover project state from:

1. Current repository implementation
2. VERIFIED.md
3. Development_State.md

Runtime evidence is final authority.

Repository implementation is second authority.

Documentation exists to explain repository reality, not replace it.

---

## Documentation Roles

Doctrine.md
=
Desired behavior

Architecture.md
=
Ownership and execution flow

Development_State.md
=
Current project board

VERIFIED.md
=
Runtime-proven facts

ROADMAP.md
=
Future milestones

CHANGELOG.md
=
Historical changes

---

## Current Project Phase

Framework architecture largely established.

Current development focus:

Controller doctrine implementation through runtime-verified behaviors.

Current controller:

SCOUT

Current milestone:

SCOUT Prototype V2

Replace temporary observe counter with first real SCOUT decision behavior.

---

## Important Distinction

Doctrine
≠
Implementation

Implementation
≠
Runtime Verification

A behavior is not considered complete because it appears in doctrine.

A behavior becomes project reality only after:

Controller Design
↓
Implementation
↓
Runtime Verification

---

## Recovery Question

When returning to the project, ask:

"What behavior are we building next?"

Do not ask:

"Is the controller complete?"

Controllers are built one verified behavior at a time.

---

## Documentation Update Rule

After significant work:

1. What changed?
2. What did runtime prove?
3. Did ownership change?
4. Did doctrine change?
5. Did milestone status change?

Update only the appropriate documents.

Avoid mixing doctrine, implementation status, architecture, and runtime facts into the same document.