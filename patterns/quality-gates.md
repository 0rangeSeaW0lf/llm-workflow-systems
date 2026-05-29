# Quality Gates (Illustrative Sequence)

The companion essay describes three layers: skills as encapsulated behaviors, handoffs as audience-preserving contracts, and gates as quality layering. This file is the illustrative gate sequence the essay refers to. It is a sanitized abstraction of a working gate stack, not a copy of any production hook.

A gate is a check that fires between producing content and acting on it. The unit of design is one gate per failure mode. A gate that tries to own several failure modes becomes a place where each of them hides.

## Why gates are layered, not bolted on

The common mistake is to add quality assurance as a single pass at the end: one reviewer prompt that asks "is this good?" That pass fails silently, because "good" is not a failure mode. It is a feeling.

Layering inverts this. You name the specific ways the output can be wrong, and you give each one a gate that knows how to detect it and what to do when it fires. The sum is a quality floor that holds even when any single author (human or model) is having a bad day.

## A gate taxonomy

Four gate kinds cover most of what an analytical pipeline needs. Each owns exactly one failure mode.

| Gate | Failure mode it owns | Fires on |
|---|---|---|
| Format / voice | Output violates a load-bearing style rule (a punctuation convention, a date or currency format, a calibrated voice) | Every draft destined for a reader |
| Disclosure / public-content | Output leaks something it should not, or overreaches what the source supports | Anything crossing to an external audience |
| Persistent-storage integrity | A write encodes reasoning or facts whose wrongness would mislead a future reader | Every write to a durable store |
| Plan / exit integration | A multi-step plan is internally incoherent at the moment of commitment | The boundary where planning becomes action |

The taxonomy is not sacred. The discipline is: before adding a gate, name the one failure mode it owns. If you cannot, you do not yet understand the gate.

## Enforcement patterns

These are the mechanical shapes a gate takes. The snippets are pseudo-code for illustration, not runnable hooks.

### Block versus warn

A gate either refuses to let the action proceed, or it lets the action proceed and records a warning. Reserve blocking for failure modes where proceeding is genuinely worse than stopping.

```
# block: the action does not happen until the content is fixed
if violates(rule, staged_content):
    print("BLOCKED: <one line naming the rule>")
    exit(1)

# warn: the action happens, the operator is told
if smells_off(content):
    print("WARNING: <what looked wrong and why>")
    exit(0)
```

### Two-layer gate (advisory, then block)

The first violation in a session is often an honest mistake. The second is a pattern. A two-layer gate warns on the first occurrence and blocks on the next, which keeps the gate from being noise on a one-time slip while still stopping a habit.

```
count = seen_this_session(rule)
if count == 0:
    warn("first occurrence; this is your nudge")
    record(rule)
    exit(0)
else:
    block("second occurrence; fix it")
    exit(1)
```

### Auto-repair (non-blocking correction)

When the fix is unambiguous, the gate can repair the content instead of refusing it. A format normalization (a smart quote, a stray character, a date rewritten to the canonical form) is better corrected than rejected. Repair silently only when the correct output is not in question; if there is judgment involved, warn instead.

```
fixed = normalize(content)
if fixed != content:
    write(fixed)
    note("auto-repaired: <what changed>")
```

### Transcript and turn-boundary awareness

A gate that runs inside an interactive loop often needs to know what already happened this turn. A gate enforcing "you must run the integration check before exiting plan mode" reads the current turn for evidence that the check ran. Scoping to the current turn (rather than the whole session) keeps the gate from passing on stale evidence from an earlier, unrelated step.

### The logged-bypass principle

The essay states it: a gate that can be bypassed without logging the bypass is not a gate. If an operator can override (and sometimes they must, for a false positive), the override is allowed but written to an audit log. The log turns a silent escape hatch into a reviewable decision. The same line draws the other two boundaries: a gate that runs after the artifact has shipped is not a gate, and a gate that accepts "skip, it is a small change" as a default is not a gate.

```
if override_requested:
    append_audit_log(rule, who, why, timestamp)
    exit(0)   # allowed, but now it is on the record
```

## Where gates sit

Gates are not a stage at the end of the pipeline. They are interleaved with the two layers below them.

```
skill produces output
   -> format / voice gate          (before the output is shown)
handoff carries it downstream
   -> disclosure gate              (before it crosses to an external audience)
write to durable store
   -> integrity gate               (before the write lands)
plan becomes action
   -> plan-exit integration gate   (at the commitment boundary)
```

Each gate sits at the boundary it protects, not in a quality-assurance phase that runs once and hopes to catch everything.

---

**Notes on this pattern:**

- One gate, one failure mode. The clarity of a gate is inversely proportional to how many things it tries to catch.
- Block sparingly. Most gates should warn. Blocking is for failure modes where shipping the bad output is worse than halting.
- Make bypasses loud. An override that is not logged is a gate that is not there.
- Gates earn their keep at the boundary, fired by the event that risks the failure, not collected into a single pass at the end.
