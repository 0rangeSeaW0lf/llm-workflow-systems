# Handoff Contract (Sanitized Example)

A handoff is a structured message from one skill to another. The contract below is the minimum surface that lets a downstream skill parse upstream intent without re-doing upstream work.

## Schema

```json
{
  "handoff": {
    "contract_version": "1.0",
    "upstream_skill": "producer-skill-name",
    "output_type": "bio | cv | memo | update | post | other",
    "audience": "role or descriptor of the recipient",
    "channel": "email | document | post | deck | form | other",
    "sensitivity": "LOW | MEDIUM | HIGH",
    "direction": "north | south | west | east | mixed",
    "quality_layers_applied": ["voice-calibration", "anti-ai-markers", "scqa-structure"],
    "draft_text": "the content, or omit to use most recent upstream output in context",
    "return_mode": "inline | annotated"
  }
}
```

## Field notes

- `upstream_skill` is the only required field. Everything else defaults from the producing skill's conventions.
- `audience` carries whoever the content is for. A downstream skill calibrates tone and register from this field.
- `sensitivity` drives the disclosure gate. HIGH sensitivity forces an additional review pass.
- `quality_layers_applied` lets the downstream skill skip checks that already ran upstream, avoiding redundant scanning.
- `direction` uses the North / South / West / East convention: up to power, down from power, lateral, inward.

## Why contract-based

Three practical benefits.

First, the downstream skill does not re-run upstream work. If the producer already ran a voice-calibration pass and tagged it, the downstream quality layer can spot-check instead of full scanning.

Second, conflict detection becomes possible. A public-content gate can see that an upstream draft exceeds the sensitivity level the audience warrants, and flag the conflict before shipping.

Third, the contract survives model upgrades and new skill additions. A sparse contract with clear defaults degrades gracefully; a verbose one becomes a maintenance burden.

## Example flow

Producer skill finishes a draft, emits handoff contract, downstream quality gate reads contract, applies only the layers not listed in `quality_layers_applied`, returns annotated output, producer integrates annotations, ships.

## Versioning

Contract version lives in `contract_version`. Minor version bumps are backward-compatible; major bumps require all registered consumers to update. New optional fields can be added under the same major version.

## Absent fields

If a field is missing, the downstream skill falls back to a documented default or flags the absence. "Missing audience" should not silently become "generic professional"; the default should be explicit, logged, and overridable.
