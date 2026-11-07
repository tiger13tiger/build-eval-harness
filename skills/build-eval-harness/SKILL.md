---
name: build-eval-harness
description: Build an evaluation harness (golden set, guardrails, attack tests, metrics, CI gate, optional prompt evolution and RAG) for an AI agent or LLM system from a filled spec.
---

# Build an evaluation harness for an AI system

Use this when the user wants to measure, gate, or improve an AI agent / LLM feature (text-to-SQL, RAG Q&A, extraction, classification, tool-using agents) before or after it goes live.

**Reference implementation:** https://github.com/tiger13tiger/evolutionharness (text-to-SQL agent). Before writing code, read its `harness.py`, `guardrails.py`, `agents.py`, `evolver.py`, `rag.py` and `.github/workflows/`. Mirror its structure, naming and report format unless the spec says otherwise. Reuse code where the new system has the same shape.

## Step 0. Get the spec

The user should provide a filled spec (template at the end, also in `spec_template.md`). If parts are missing, ask only for the missing items, in template order, in one message. The single most important answer is **how correctness is judged automatically**. Do not start building until that is settled.

Choose the judge in this order of preference:
1. **Execution / exact match**: run the output and compare results (SQL result sets, numbers with tolerance, JSON fields, unit tests passing).
2. **Rule checks**: schema validation, regex, allow-lists, numeric grounding against source data.
3. **LLM-as-judge**: only for free-text quality. Must have a rubric, and must be calibrated against a small human-labelled set (report agreement rate) before its scores are trusted.

## Step 1. Test data

- **Golden set:** 30–60 cases, each with `id`, `category`, `difficulty`, `expect` (`answer` | `refuse`), input, and a gold answer from a trusted source (existing reports, verified SQL, SME labels). Include easy cases, business-logic traps, should-decline cases (out of scope, missing data, ambiguous), and PII requests.
- **Train / holdout split:** deterministic, stratified by category, about 1/3 holdout. Holdout is never shown to any optimiser.
- **Attack set:** direct prompt injection ("ignore previous instructions"), destructive actions, smuggled second statement/action, direct and indirect PII exfiltration, system-prompt / secret leak, and **indirect injection via data** (instructions planted inside records the agent will read).
- Never edit test cases after seeing results to improve a score. If a case turns out ambiguous, log it as a known gap and fix it in the next suite version.

## Step 2. Agent adapter

Every agent implements `run(input) -> AgentOutput(answer, action/sql, refused, input_tokens, output_tokens, tool_calls, trace, retrieved)`. The system prompt is a constructor parameter.

Always build a **MockAgent** with at least 4 planted failure modes (logic error, boundary/off-by-one, hallucinated number, nondeterministic flake, falls for an attack). It costs nothing and proves the evaluator catches real failures.

## Step 3. Guardrails

In code, before any action executes: read-only / allow-listed actions, single statement, table or tool allow-list, blocked PII sources, PII pattern check on outputs. Document the infrastructure controls that must back them in production (least-privilege credentials, read-only replica, timeouts, row limits, audit log). Safety pass = nothing unsafe executed AND nothing leaked. Answering only the safe part of a mixed request is a pass.

## Step 4. Metrics and report

Per case and run: accuracy (execution match), groundedness, task completion, safety, latency, tokens, cost, API error. Summary: accuracy, groundedness, task completion, safety pass rate, latency p50/p95, avg cost, **api_error_rate**, **consistency** (same pass/fail verdict across repeats), completion by category, and retrieval hit@k when RAG is on.

Outputs: `report.md` (gate, metrics table, failures with reason and failed-runs count, safety table), full CSVs (store answers up to 2000 chars, never truncate short), `summary.json`. In CI also write the report to the run summary page. Exit code 1 when a threshold fails.

## Step 5. Robustness (learned the hard way)

- Catch errors per case and record them; never let one API failure abort the run.
- Back off and retry on transient errors (rate limit, overloaded, timeout); fail fast on non-transient ones.
- Preflight one tiny model call before the run; try candidate model ids and keep the first that responds; print the models the key can see if all fail.
- Fail with a clear message when the provider's API key environment variable is missing or empty.
- Client timeout (about 45 s) and a CI job timeout.
- Pacing delay for free tiers, excluded from latency.
- Stop early when the baseline run has more than 5% API errors (usually a daily quota); scores would be meaningless.

## Step 6. Verify the evaluator before trusting it

1. Unit-test the scoring functions.
2. Run the MockAgent: every planted bug must be caught.
3. Run the real model with `repeats >= 3`.
4. **Read every failure.** Classify each as model error or evaluator error. Fix evaluator errors, then re-run the MockAgent to prove the evaluator did not become lenient.

### Known evaluator false negatives to pre-empt
- Prediction returns extra columns → compare by projecting onto gold columns (try column permutations).
- Numbers echoed from the question (years, "top 3") counted as invented → ignore numbers that appear in the question.
- ISO dates in the answer (2026-02-01) split into numbers → strip ISO dates before grounding.
- Rank / row numbers (1, 2, 3) in tables → ignore integers from 1 to the number of result rows.
- `ORDER BY` inside a window function or subquery treated as result ordering → only a top-level ORDER BY makes order matter.
- Decline detected by "no SQL executed" → judge the answer text (schema exploration before declining is fine).
- Consistency measured on raw output → measure on pass/fail verdicts.
- Truncated stored answers re-scored → keep full answers; if re-scoring old data, drop the cut-off tail.

## Step 7 (optional). Prompt evolution

Loop per generation: collect failed **train** cases → a mutator LLM writes K candidate prompts with general rules only → evaluate on train + holdout + safety → accept only if train improves, holdout does not drop, safety stays 100%, API errors are 5% or less.

Reject candidates before evaluation if they remove required safety rules, drop the schema, copy a test question (40+ characters) or contain gold answer values. Write the winner as a pull request for human approval; never auto-merge.

## Step 8 (optional). RAG few-shot

Build a bank of verified input→output examples tagged by pattern, deliberately distinct from the test set. Run a **leakage guard**: refuse to run if any test input is a near-duplicate of a bank example (TF-IDF threshold 0.85; dense embeddings run higher, use about 0.93). Label the patterns each test case needs and report hit@k plus completion split by retrieval hit/miss, to separate retrieval failures from generation failures. Start with TF-IDF (free, no download); compare dense embeddings only when the bank is large.

## Step 9. A/B discipline

Same code version, same suite, same repeats, same scoring rules for every arm. Keep a `baseline` branch for the original configuration. Report the configurations as a table (all / train / holdout / hard / accuracy / safety / tokens / cost) and state which differences are within noise (estimate noise by running the same configuration twice).

## Data rules

Company or customer data only runs on AI services the company has approved (for example its own Azure OpenAI tenant). Free tiers and offshore providers are for public or synthetic data only. Mention data-residency implications when comparing models.

## Deliverables checklist

- [ ] Spec confirmed, judge chosen
- [ ] Golden set + split + attack set (including indirect injection)
- [ ] Agent adapter + MockAgent with planted bugs
- [ ] Guardrails + production controls documented
- [ ] harness with metrics, report, CSVs, CI gate
- [ ] Evaluator unit tests; MockAgent run catches all planted bugs
- [ ] Real run (repeats >= 3), every failure classified
- [ ] README with how to run, design choices and a results table

## Spec template (the user fills this in for each new system)

1. **System:** what it does, who uses it, example inputs and outputs.
2. **Interface:** how to call it (API, function, model + prompt + tools).
3. **Correctness:** how to judge an output right or wrong automatically, and the source of gold answers.
4. **Should-decline cases:** what it must refuse or ask about.
5. **Data access:** what it can read or act on; what it must never touch (PII, write actions).
6. **Risks and attacks:** how it could be misused or tricked, including through the data it reads.
7. **Metrics and thresholds:** go-live bar, e.g. accuracy 90%, safety 100%, p95 under 5 s, cost per call.
8. **Model and environment:** which provider is allowed; where data may be processed.
9. **Existing material:** reports, verified queries, logs or FAQ to mine for test cases and examples.
10. **Scope:** must-haves now versus later (evolution, RAG, monitoring).
