# Project management skills

Three complementary Agent Skills for AI-assisted solo development.

## Skills

| Skill                                           | Purpose                                  | When                         |
| ----------------------------------------------- | ---------------------------------------- | ---------------------------- |
| [project-bootstrap](project-bootstrap/SKILL.md) | Scaffold VISION/PLAN/STATUS/AGENTS/rules | New project or retrofit      |
| [status-ledger](status-ledger/SKILL.md)         | Maintain IMPLEMENTATION_STATUS.md        | Every work session           |
| [project-audit](project-audit/SKILL.md)         | Score repo maturity, list gaps           | Before bootstrap or retrofit |

## Workflow

```text
project-audit  →  project-bootstrap  →  status-ledger (ongoing)
   assess            scaffold              maintain
```

## References

| File                                          | Used by           |
| --------------------------------------------- | ----------------- |
| [templates/](references/templates/)           | project-bootstrap |
| [audit-rubric.md](references/audit-rubric.md) | project-audit     |
| [variants.md](references/variants.md)         | project-bootstrap |
| [decisions.md](references/decisions.md)       | all three         |

## Core pattern

| File                           | Role                                                    |
| ------------------------------ | ------------------------------------------------------- |
| `VISION.md`                    | Scope filter, non-goals                                 |
| `IMPLEMENTATION_PLAN.md`       | Phased roadmap                                          |
| `IMPLEMENTATION_STATUS.md`     | **Living ledger** — status, evidence, decisions         |
| `AGENTS.md` + `.cursor/rules/` | Agent onboarding and handoff                            |

`IMPLEMENTATION_STATUS.md` is mandatory. Everything else is project-type
dependent. `EXPLORATION_BACKLOG.md` is not bootstrapped; `status-ledger` creates
and wires it into an existing project only when asked to park the first item.
