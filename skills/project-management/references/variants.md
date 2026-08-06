# Project type variants

Used by `project-bootstrap` to pick the right scaffolding set.

## Detection signals

| Signals                                 | Variant               |
| --------------------------------------- | --------------------- |
| Empty repo or idea only                 | greenfield            |
| `backlog/`, `audit-`, client contracts  | consulting            |
| Multiple git subrepos, workspace README | container             |
| `PLAN.md`, content pipeline, scoring    | meta                  |
| README says frozen/minimal              | minimal — README only |

---

## Greenfield product (default)

Full stack:

```
project/
├── README.md
├── VISION.md
├── IMPLEMENTATION_PLAN.md
├── IMPLEMENTATION_STATUS.md    ← MANDATORY
├── AGENTS.md
└── .cursor/rules/
    ├── project-context.mdc
    └── agent-handoff.mdc
```

Add as needed: `docs/`, `TESTING_STRATEGY.md`, domain specs.

Do not bootstrap `EXPLORATION_BACKLOG.md`. If asked to park a speculative item,
`status-ledger` creates it in the existing project and wires its conditional
handoff guidance.

---

## Consulting / engagement

```
engagement/
├── README.md
├── AGENTS.md
├── audit-charter.md          # replaces VISION
├── audit-status.md           # replaces IMPLEMENTATION_STATUS
├── backlog/items.jsonl       # machine-readable work queue
└── evidence/                 # dated snapshots
```

---

## Workspace container (multi-repo)

```
container/
├── README.md                 # layout, nested-git rules
├── AGENTS.md                 # startup checklist, cross-repo sync
└── .vscode/settings.json     # git.autoRepositoryDetection: subFolders
```

Child repos get their own PM stack. Container does NOT track child code.

---

## Real-world deadline workflow

Add to greenfield stack:

```
state/handoff.md              # session handoff
log/session-log.md            # append-only session log
```

---

## Meta / content pipeline

```
meta-project/
├── README.md
├── PLAN.md                   # can serve PLAN + partial STATUS
├── FRAMEWORK-LOG.md          # process iteration log
└── .cursor/skills/           # pipeline automation
```

---

## Minimal / frozen

```
project/
└── README.md                 # explicit "frozen" or "minimal" note
```

---

## Completed tool / utility

```
tool/
├── README.md                 # usage + phase completion table
├── docs/IMPLEMENTATION-PLAN.md
└── .cursor/skills/           # if agents use it
```

Add lightweight STATUS only if ongoing maintenance expected.

---

## What NOT to include by default

- Formal ADR directories
- Memory Bank 6-file structure
- docflow CONVENTIONS + audit CI
- Separate ROADMAP.md (merge into PLAN)

Optional ADRs only when: regulated compliance, multi-agent team, or decisions need formal acceptance criteria.
