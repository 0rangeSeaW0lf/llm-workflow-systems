# Skill Template (Sanitized Example)

A structural example of a domain skill. Replace the section contents with your own domain logic; keep the structural elements.

---

# [Skill Name]

## Purpose

One paragraph: what domain problem this skill solves, what inputs it expects, what output it produces. Written for the next practitioner (or the next version of you) to decide whether this skill is what they need.

## Trigger

Under what conditions should this skill fire? Two lists:

- **Direct triggers:** user phrases or explicit invocations that should activate this skill.
- **Handoff triggers:** upstream skill outputs matching specific patterns.

## Mode Detection

If the skill has multiple modes (Execute versus Coach, Light versus Standard versus Full), list the signals that route between them.

| Signal | Mode |
|---|---|
| User says "just draft it" | Execute |
| User says "help me think through" | Coach |

Default mode when ambiguous: [name and rationale].

## References

On-demand reference files this skill loads. Load only the file the current invocation needs, not everything upfront.

```
[reference-name-1].md -> [one-line description of what this file contains]
[reference-name-2].json -> [one-line description]
```

## Steps

Numbered steps, each with one sentence describing the action and one sentence describing what success looks like. Keep it short enough that the skill is auditable.

1. [Action]. Success: [observable outcome].
2. [Action]. Success: [observable outcome].
3. [Action]. Success: [observable outcome].

## Output Format

Explicit template for the skill's output. If the output is a handoff to another skill, include the handoff contract schema here.

## Failure Modes

Known failure modes and their guardrails. Example: "If the audience profile is missing, default to low-context assumption and flag."

## Review Cadence

When this skill should be revisited. Link to the evaluation gate that monitors for regressions.

---

**Notes on this template:**

- Keep skill files under 300 lines when possible. Above 300, consider splitting into sub-files loaded on demand.
- Sparse is better than verbose. If a section is not applicable, delete it rather than leave an empty heading.
- Reference files should be lazy-loaded so skill invocation cost stays proportional to the work needed.
- The trigger list is the contract with the runtime. Keep it specific enough that the runtime can route without heuristics.
