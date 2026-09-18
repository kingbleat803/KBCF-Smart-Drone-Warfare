# KBCF Welcome Back Notes

---

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

Truth hierarchy:

Runtime Evidence
↓
Repository Implementation
↓
Repository Documentation
↓
Historical Records
↓
Memory

Current repository and runtime evidence define project reality.

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

Do not mix document responsibilities.

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

Doctrine describes desired behavior.

Implementation describes current code.

Runtime determines reality.

---

## Investigation Board Rule

Once a conclusion becomes:

IMPLEMENTED
+
RUNTIME VERIFIED

treat it as current board state.

Do not repeatedly re-open verified conclusions unless:

- new runtime evidence appears
- implementation changes
- repository documentation conflicts with implementation
- regression evidence appears

Previously verified conclusions remain active until superseded by newer evidence.

Do not repeatedly re-litigate settled results.

Ask:

"What changed?"

before reopening a verified conclusion.

---

## Controller Development Rule

Controllers are built one verified behavior at a time.

Do not ask:

"Is the controller complete?"

Instead ask:

"What behavior are we building next?"

Controller completion is achieved through accumulation of verified behaviors.

---

## Current Project Phase

Framework architecture largely established.

Current development focus:

Controller doctrine implementation through runtime-verified behaviors.

Current controller:

SCOUT

Current profile goal:

Complete SCOUT doctrine implementation and runtime verification.

Current increment:

(To be determined from repository evidence when milestone status changes.)

Increment selection should be based on the remaining gap between:
- Doctrine.md
- Current implementation
- VERIFIED.md
---

## Documentation Update Rule

After significant work:

1. What changed?
2. What did runtime prove?
3. Did ownership change?
4. Did doctrine change?
5. Did milestone status change?

Update only the appropriate documents.

Examples:

Runtime proof changed
→ VERIFIED.md

Current active work changed
→ Development_State.md

Ownership changed
→ Architecture.md

Desired behavior changed
→ Doctrine.md

Future milestones changed
→ ROADMAP.md

Historical record changed
→ CHANGELOG.md

Avoid mixing:

- doctrine
- implementation status
- architecture
- roadmap items
- runtime facts

into the same document.

---

## Session Audit Rule

Before making project conclusions:

1. What does runtime prove?
2. What does implementation prove?
3. What does documentation claim?
4. Do all three agree?

If they disagree:

Runtime evidence wins.

Implementation is second authority.

Documentation should be corrected.

---

## Recovery Question

When returning to the project, ask:

"What behavior are we building next?"

If work already occurred during the current session, first ask:

"What changed since the last verified checkpoint?"

before reassessing project status.