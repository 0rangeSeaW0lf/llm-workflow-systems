# Systems-level thinking for LLM skill ecosystems

*April 2026, ~800 words*

Most LLM workflows I see in the wild look like a prompt library and a vibe. They work until they don't, and the failure modes feel mysterious. This is a short essay about the three layers I've converged on after running an analytical pipeline across roughly 60 domain skills for about a year. The pipeline supports live investment, diligence, and advisory work, so quality is not optional and drift is a known adversary.

## Layer 1: Skills as encapsulated domain behaviors

A skill is not a prompt. It is an entry condition, a set of references loaded on demand, a protocol for producing an output, and a schema for the output itself. When I treat skills as libraries with interfaces rather than monolithic prompts, three things change.

First, I can reason about composition: a screening skill can hand off to a scoring skill, which can hand off to a decision-journal entry, and I can trust each step's contract. Second, I can test them independently: evaluation gates on golden cases flag regressions when a model upgrade changes behavior. Third, the token cost drops sharply because references load on demand rather than padding every invocation.

The design commitment is that each skill does one domain thing well. A communication-framework skill handles voice, register, and structure. A public-content quality-assurance skill handles disclosure, factuality, and audience calibration. A close-protocol skill handles session integrity. Put them together in the right order and you get advisory-grade output. Mash them together and you get slop.

## Layer 2: Handoffs as explicit audience-preserving contracts

The second insight came from watching skill-to-skill transitions fail. A screener would produce a verdict, a communication skill would draft the delivery, and the tone would be wrong half the time. The fix was to make audience context an explicit contract.

A handoff contract carries four things: what the upstream skill produced, who the downstream audience is, what quality layers have already been applied upstream, and what disclosure or sensitivity constraints travel with the content. When the downstream skill reads the handoff, it can skip work already done (a voice-calibration pass flagged upstream does not need to re-run), inherit audience calibration (direct versus dialogue-first versus proxy-mediated), and detect conflicts (a public-content gate catches when upstream content violates a disclosure rule the producing skill did not know about).

The handoff contract is JSON, not prose, because the downstream skill needs to parse it mechanically. But the contract is sparse: only `upstream_skill` is required; everything else defaults from the producing skill's legacy pattern. Sparse contracts survive; verbose ones get stale.

## Layer 3: Gates as quality layering, not bolt-on quality-assurance

The last layer is the one people usually add last and regret. Gates are the quality floor that fires between producing content and shipping it. Communication gate: does the voice match the calibrated profile? Does the structure serve the audience, the frame, the action? Public-content gate: does the output leak disclosures? Does the positioning match the credential inventory? Does the factual scaffolding trace to source? An integrity gate on persistent storage: does this payload encode reasoning that could mislead a future reader if wrong?

Gates are a layering, not a single check. Each gate owns a failure mode. A punctuation hook owns a specific rule that is load-bearing for voice. A cross-source consistency gate owns the risk that a draft overreaches what the inventory supports. A stress-test gate owns the risk that the reasoning underlying a persistent write is silently wrong.

A gate that can be bypassed without logging the bypass is not a gate. A gate that runs after the artifact has shipped is not a gate. A gate that accepts "skip, small change" as a default is not a gate.

## The meta-pattern

The pattern underneath all three layers is the same: you move from prompt engineering to systems engineering by making the implicit explicit. Implicit skill boundaries become library interfaces. Implicit audience context becomes a handoff contract. Implicit quality assumptions become gate checks with logged outcomes.

None of this is a secret, and none of it is clever. The work is the discipline: structuring the pipeline so that correctness and auditability survive the next model upgrade, the next collaborator, and the next month of entropy.

The repository this essay lives in contains sanitized templates for a skill and a handoff contract, plus an illustrative gate sequence. It does not contain my actual skills, hooks, or audit logs. What it contains is the shape.
