---
name: project-audit
description: >-
  Audits a repository's project management maturity against the agent continuity
  standard — scoring README, VISION, PLAN, STATUS, AGENTS, cursor rules, and
  decision tracking. Produces tier rating and retrofit recommendations. Use when
  assessing project docs, comparing repos, planning retrofits, or before
  bootstrapping a new project structure.
---

# Project Audit

Score repos against `skills/project-management/references/audit-rubric.md`
in this skills repository (resolve via the realpath of this skill's `SKILL.md`).

## Checklist (weighted)

Weights are slices of a **100-point** total (not per-item grades).

| # | Artifact | Weight |
|---|----------|--------|
| A1 | README | 5 |
| A2 | VISION or equivalent | 10 |
| A3 | IMPLEMENTATION_PLAN | 10 |
| A4 | **IMPLEMENTATION_STATUS** | **25** |
| A5 | AGENTS.md | 10 |
| A6 | project-context.mdc | 10 |
| A7 | agent-handoff.mdc | 10 |
| A8 | Decision log | 10 |
| A9 | Research/docs | 5 |
| A10 | Cursor skill | 5 |
| | **Total** | **100** |

## Scoring model

| Symbol | Meaning | Points earned |
|--------|---------|---------------|
| ✓ / 🟢 | present and adequate | **full** weight |
| ~ / 🟡 | partial / acceptable equivalent | **~half** weight (round to nearest integer) |
| — / 🔴 | missing | **0** |

Always show both points and percent of total in Earned, e.g. `🟢 10 (10%)`, `🟡 15 (15%)`, `🔴 0 (0%)`.

## Tiers

- **Full** ≥85 — agent-ready
- **Partial** 60–84 — retrofit recommended
- **Minimal** <60 — agent will struggle
- **Skip** — intentional minimal (frozen, infra, fork)

## Audit steps

1. List root + `.cursor/` files
2. Grep for VISION, PLAN, STATUS, AGENTS, handoff
3. Spot-read STATUS quality (evidence columns? decision log? one-liner?)
4. Score each artifact ✓ / ~ / —
5. Compute earned points (full / ~half / 0 of each weight); sum out of 100
6. Assign tier + variant recommendation
7. List gaps in priority order

## Equivalents (partial credit)

| Standard | Acceptable equivalent |
|----------|----------------------|
| VISION | `docs/vision.md`, `audit-charter.md` |
| STATUS | `state/STATUS.md`, `audit-status.md`, living plan current state |
| PLAN | `PLAN.md`, `docs/implementation-plan.md` |

## Output format

```markdown
# Audit: <project>
**Tier:** <Full|Partial|Minimal|Skip> (<earned> / 100)
**Variant:** <greenfield|consulting|container|meta|minimal|tool>

Scoring: each row’s **Weight** is its share of 100. **Earned** counts toward the total (🟢 ✓ = full, 🟡 ~ ≈ half, 🔴 — = 0).

| # | Artifact | Weight | Found | Earned |
|---|----------|--------|-------|--------|
| A1 | README | 5 | ✓|~|— <short note> | 🟢|🟡|🔴 <points> (<points>%) |
| A2 | VISION | 10 | ... | ... |
| A3 | IMPLEMENTATION_PLAN | 10 | ... | ... |
| A4 | IMPLEMENTATION_STATUS | 25 | ... | ... |
| A5 | AGENTS.md | 10 | ... | ... |
| A6 | project-context.mdc | 10 | ... | ... |
| A7 | agent-handoff.mdc | 10 | ... | ... |
| A8 | Decision log | 10 | ... | ... |
| A9 | Research/docs | 5 | ... | ... |
| A10 | Cursor skill | 5 | ... | ... |
| | **Total** | **100** | | **🟢|🟡|🔴 <earned> (<earned>%)** |

## Gaps (priority)
1. ...
2. ...

## Next
Invoke `project-bootstrap` to close gaps (omit if Skip / already Full).
```
