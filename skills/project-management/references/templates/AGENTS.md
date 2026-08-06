# Agent guide — [project name]

## Startup checklist

1. Read `IMPLEMENTATION_STATUS.md` first — **Current focus**, **Next work item**, blockers
2. Skim `VISION.md` if scope is unclear
3. Use `IMPLEMENTATION_PLAN.md` for phase deliverables
4. [Project-specific: read domain docs, run tests, etc.]

## Documentation authority

| Question | Source of truth |
|----------|-----------------|
| What are we building? | `VISION.md` |
| What's the roadmap? | `IMPLEMENTATION_PLAN.md` |
| What's done/blocked/next? | `IMPLEMENTATION_STATUS.md` |
| Why was X decided? | `IMPLEMENTATION_STATUS.md` decision log |

## Session workflow

### At session start

- Read STATUS header and fresh-agent one-liner
- Do not redo work marked `done` unless evidence is missing

### Before ending session

Update `IMPLEMENTATION_STATUS.md` per `.cursor/rules/agent-handoff.mdc`.

## Build / test commands

```bash
# [Add project-specific commands]
```

## Safety

- [Project-specific constraints: no prod deploys, no secrets in commits, etc.]
