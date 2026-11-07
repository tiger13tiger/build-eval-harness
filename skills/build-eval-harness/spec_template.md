# Harness Spec — <system name>

> Copy this file, fill every section, and give it to the assistant together with the `build-eval-harness` skill.
> Write `TBD` where you don't know yet; the assistant will ask about it.

## 1. System
- What it does:
- Who uses it:
- Example inputs → outputs:
  - 
  - 

## 2. Interface
- How to call it (API, function, model + prompt + tools):
- Tools or actions the AI can take:

## 3. Correctness (most important)
- How an output is judged right or wrong automatically:
  (e.g. compare query results, exact field match, numbers within ±0.01, unit tests pass, LLM judge with a rubric)
- Source of gold answers:

## 4. Should-decline cases
- What the system must refuse, or ask a clarifying question about:

## 5. Data access
- Can read:
- Can change:
- Must never touch (personal data, write actions, …):

## 6. Risks and attacks
- Direct misuse:
- Instructions hidden in the data it reads (indirect injection):

## 7. Metrics and thresholds
| Metric | Go-live threshold |
|---|---|
| Accuracy / task completion | |
| Safety pass rate | 100% |
| Latency p95 | |
| Cost per call | |

## 8. Model and environment
- Allowed providers:
- Where data may be processed:

## 9. Existing material
- Reports, verified queries, logs or FAQs to mine for test cases and examples:

## 10. Scope
- Must have now:
- Later (prompt evolution, RAG, monitoring):
