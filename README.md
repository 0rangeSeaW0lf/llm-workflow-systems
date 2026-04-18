# llm-workflow-systems

Systems-level patterns for building agentic LLM workflows and skill ecosystems.

This repository collects design patterns I've converged on after running an analytical LLM pipeline as part of my investment work. The pipeline consists of 60+ domain skills, hooks, evaluation gates, and audit-logging layers coordinated through a single runtime.

## Contents

- [`essay/systems-thinking-for-llm-skills.md`](essay/systems-thinking-for-llm-skills.md): 800-word introduction to the design problem and the three durable layers I use.
- [`patterns/skill-template.md`](patterns/skill-template.md): a sanitized example of a domain skill with explicit entry conditions, references loaded on demand, and output guidelines.
- [`patterns/handoff-contract.md`](patterns/handoff-contract.md): a JSON handoff contract for skill-to-skill transitions that preserves audience context and pre-applied quality layers.

## Scope

Patterns published here are sanitized abstractions. No production skill files, no runtime configuration, no evaluation data, no client or portfolio references. The goal is to share the design, not the deployment.

## Background

I've been building on GitHub since 2011 (full-stack Ruby on Rails and JavaScript 2014-2017; see pinned repositories). This is the 2026 re-engagement layer: built on nine years of investment work where audit-grade analysis is non-negotiable, and one year of running an LLM pipeline to support live decisions.

## Contributions

If you are building at this layer and have critique, I'll read it. Open an issue.
