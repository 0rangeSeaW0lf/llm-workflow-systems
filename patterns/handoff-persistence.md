# Handoff Persistence (Sanitized Example)

The handoff-contract pattern in this repo covers the message that one skill passes to another in flight. This file covers the other half: what happens when a handoff outlives the session that created it and becomes a durable record you can browse, query, and resolve later.

A live handoff is a message. A persisted handoff is a small unit of state with a lifecycle. The two need different designs, and conflating them is a common source of mess.

## Why persist a handoff at all

Some work does not finish in the session that starts it. A piece of analysis is paused on an external dependency; a decision is parked pending a date; a follow-up is owed but not yet due. If that context lives only in a chat transcript, it is gone the moment the session closes.

Persisting the handoff turns "I will remember to come back to this" into a record the next session can find without you. The design goal is a registry that is cheap to write, cheap to scan, and honest about state.

## A record schema

Keep the persisted record sparse. Each field earns its place by answering a question a future reader will actually ask.

```
handoff_record:
  id            # stable key; never reused, never re-keyed
  slug          # human-readable name, set once at creation
  priority      # P1..P4, so a scan can triage
  area          # which part of the system this belongs to
  status        # lifecycle state (see below)
  created_at    # when the record was opened
  fire_after    # when it becomes due, if it is time-gated
  body_ref      # pointer to the full prose (a file, a row, a doc)
```

The body, the long-form context, lives outside the indexed record. The index carries only what a triage scan needs. This keeps the registry fast to query and keeps the prose free to be as long as it needs to be.

## Lifecycle states

A persisted handoff moves through a small set of states. Model them explicitly; do not infer state from the presence or absence of a file.

```
active      -> the work is open and current
superseded  -> a later record replaces this one (cross-referenced both ways)
archived    -> closed and done; kept for the audit trail, not for action
stale       -> untouched past its review horizon; needs a human glance
```

Two rules keep the state machine honest:

- A record never silently disappears. When work is done, it moves to `archived`, it is not deleted. The closed record is the audit trail.
- Supersession is a two-way link. The new record points back to the one it replaces, and the old record points forward to its successor. A one-way link rots: you find the old record, follow nothing, and re-do work that was already redone.

## Creation-anchored naming

If a persisted handoff has a filename, anchor that name to the creation date and never mutate it.

```
handoff-<slug>-YYYY-MM-DD.md     # YYYY-MM-DD is the creation date, fixed
```

The temptation is to rename the file when the trigger date or the fire date changes, so the name reflects "when this matters." Resist it. The trigger, fire, and review dates belong in the body, where they can change freely. The filename is an identity, not a status.

Renaming on a date change is expensive in a way that is easy to miss. The name is the key. Re-keying deletes the old identity, breaks every cross-reference that pointed at it, and loses the pair of dates (when it was created, when it was meant to fire) that together form the audit record. A trivial slip, pushing a fire date out by a few days, becomes a body edit. A material change, the work being superseded, becomes a new record with a back-link. Neither is ever a rename.

## The parser and sync contract

The registry is built by a parser, not maintained by hand. The contract is small:

1. Parse the prose handoff. Pull the indexed fields (id, slug, priority, area, status, dates) from a known location in the document (a frontmatter block or a labeled table).
2. Upsert into the registry, keyed by id. Same id updates in place; new id inserts.
3. Expose query views over the registry: open items by priority, items in one area, items past their review horizon, items due to fire.

Keep the parser strict about the index fields and forgiving about everything else. The body can be free prose; the handful of fields the registry depends on must be in a shape the parser can read every time. When a field can be written two ways, the registry drifts, so pick one shape and validate it at write time.

---

**Notes on this pattern:**

- A live handoff is a message; a persisted handoff is state with a lifecycle. Design them separately.
- Index the few fields a triage scan needs; keep the long prose out of the index.
- Never delete, never re-key. Archive to close, supersede with a two-way link, and let the filename be a fixed identity.
- A strict, small set of machine-read fields plus free-form prose for everything else is what keeps the registry both queryable and pleasant to write.
