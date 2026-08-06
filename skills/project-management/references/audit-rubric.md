# Audit rubric

Scoring standard for `project-audit`. Used to rate any repo's agent-continuity maturity.

## Checklist (weighted)

Weights are slices of a **100-point** total (not per-item grades).

| # | Artifact | Weight | Required? |
|---|----------|--------|-------------|
| A1 | README | 5 | Yes |
| A2 | VISION.md (or equivalent goals doc) | 10 | Recommended |
| A3 | IMPLEMENTATION_PLAN.md | 10 | Recommended |
| A4 | **IMPLEMENTATION_STATUS.md** | **25** | **Mandatory** |
| A5 | AGENTS.md | 10 | Recommended |
| A6 | `.cursor/rules` (project-context) | 10 | Recommended |
| A7 | `.cursor/rules` (agent-handoff) | 10 | Recommended |
| A8 | Decision log (in STATUS or separate) | 10 | Mandatory (embedded OK) |
| A9 | Research/docs directory | 5 | Optional |
| A10 | Cursor skill (workflow-specific) | 5 | Optional |
| | **Total** | **100** | |

## Conformance tiers

- **Full** (≥85): Greenfield production-ready for agents
- **Partial** (60–84): Usable but gaps cause agent confusion
- **Minimal** (<60): Fresh agents will struggle
- **Skip**: Intentional minimal (frozen, infra, fork, document delivery)

## Scoring model

| Symbol | Meaning | Points earned |
|--------|---------|---------------|
| ✓ / 🟢 | present and adequate | **full** weight |
| ~ / 🟡 | partial / acceptable equivalent | **~half** weight (round to nearest integer) |
| — / 🔴 | missing | **0** |

Always show both points and percent of total in Earned, e.g. `🟢 10 (10%)`, `🟡 15 (15%)`, `🔴 0 (0%)`.

## Acceptable equivalents

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

## Retrofit playbook

For each project scoring <85:

1. **Assess tier** — minimal / partial / skip?
2. **Pick variant** — greenfield / consulting / meta / tool (see `variants.md`)
3. **Create STATUS first** (mandatory artifact)
4. **Backfill VISION + PLAN** from existing docs or chat history
5. **Add AGENTS.md** with startup checklist
6. **Add cursor rules** pointing to STATUS
7. **Migrate decisions** from chat/plan into STATUS decision log
8. **Set fresh-agent one-liner** in STATUS header

## Implementation order

```
1. project-audit     → assess repo
2. project-bootstrap → scaffold gaps found
3. status-ledger     → maintain every session
```
