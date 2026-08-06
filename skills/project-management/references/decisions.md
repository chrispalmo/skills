# Key decisions

Design choices that govern the project-management skills.

| ID | Date | Decision |
|----|------|----------|
| D-001 | 2026-07-09 | `IMPLEMENTATION_STATUS.md` is the mandatory core artifact |
| D-002 | 2026-07-09 | Decision log embedded in STATUS (not separate ADR directory) for solo greenfield |
| D-003 | 2026-07-09 | VISION + PLAN + STATUS trio is the default greenfield stack |
| D-004 | 2026-07-09 | AGENTS.md + `.cursor/rules/` for agent handoff enforcement |
| D-005 | 2026-07-09 | Optional ADR-lite for consulting engagements |
| D-006 | 2026-07-09 | Three complementary skills: audit → bootstrap → ledger |
| D-007 | 2026-07-09 | Reject Memory Bank as primary pattern (fragmentation, no evidence column) |
| D-008 | 2026-07-09 | Reject full docflow ADR governance for solo (overhead > benefit) |
| D-009 | 2026-07-20 | `EXPLORATION_BACKLOG.md` icebox: non-canonical; agents surface only on status check or project closeout |
| D-010 | 2026-07-21 | Do not bootstrap `EXPLORATION_BACKLOG.md`; create and wire it into an existing project only when asked to park the first item |

## Skill roles

| Skill | When to use |
|-------|-------------|
| `project-audit` | Assess any repo before changes |
| `project-bootstrap` | Scaffold or retrofit PM docs (one-time) |
| `status-ledger` | Every work session — maintain STATUS |

## Install

Registered in this repo's `skills.manifest`. Install with:

```bash
./scripts/install.sh
```

Source of truth: `skills/project-management/` in this repository.
