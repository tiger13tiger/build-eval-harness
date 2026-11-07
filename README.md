# build-eval-harness

A reusable AI skill that teaches an assistant (Claude, or any LLM that can follow written instructions) how to build an **evaluation harness** for an AI agent or LLM feature: golden test set, prompt-injection tests, guardrails, metrics, a CI quality gate, and optional prompt evolution and RAG.

It packages the method and the lessons from [evolutionharness](https://github.com/tiger13tiger/evolutionharness), a text-to-SQL agent evaluated on DeepSeek, where prompt evolution plus RAG raised task completion from 69% to 96% with no safety regression.

## Repository layout

```
skills/build-eval-harness/
├── SKILL.md                 # the skill: steps, known evaluator pitfalls, checklist
└── spec_template.md         # fill one per new system
examples/
└── spec_text_to_sql.md      # a filled spec (the one behind evolutionharness)
dist/
└── build-eval-harness.zip   # ready to upload to claude.ai
docs/
├── usage_zh.md              # usage guide in Chinese
└── spec_template_bilingual.md
package.sh                   # rebuilds the zip after you edit the skill
```

## Why a skill and not just a spec

| Document | Tells the AI | Written |
|---|---|---|
| **Spec** | **what** to build for this system and how to judge it | once per system |
| **Skill** | **how** to build any harness, and the traps to avoid | once, reused |
| **Reference repo** | **what good looks like**, as working code | already exists |

A spec alone describes the goal. The skill carries the procedure and the hard-won lessons (eight evaluator false negatives found in real runs, leakage checks, rate-limit handling, A/B rules), so each new project starts where the last one ended.

## How to use it

### 1. Install the skill (pick one)

**claude.ai**
1. Download `dist/build-eval-harness.zip`.
2. Go to **Customize → Skills**, click **+** → **Create skill** → **Upload a skill**, and upload the zip.
3. Toggle the skill on.

Code execution must be enabled under **Settings → Capabilities**. See [Use skills in Claude](https://support.claude.com/en/articles/12512180-use-skills-in-claude).

**Claude Code**
Skills enabled in claude.ai sync to Claude Code when you sign in with the same account (run `/skills` to see them). To install locally instead, copy `skills/build-eval-harness/` into `~/.claude/skills/` (all projects) or a project's `.claude/skills/` (that project only).

**Other assistants (ChatGPT, Copilot, …)**
Paste the full `SKILL.md` and your spec into the conversation and ask: *"Follow these skill instructions and build a harness for the spec below."*

### 2. Write a spec for the new system

1. Copy `skills/build-eval-harness/spec_template.md` to e.g. `spec_my_system.md`.
2. Fill all ten sections. Use `examples/spec_text_to_sql.md` to see how much detail each needs.
3. **Section 3 (how correctness is judged automatically) matters most.** If you are unsure, write `TBD`; the assistant will settle it with you before building anything.

### 3. Ask the assistant to build it

Start a new conversation and say:

> Use the build-eval-harness skill to build a harness for the spec below.
> *(paste or attach your spec)*

The assistant will:
1. Check the spec and ask for anything missing, in one message.
2. Agree on how correctness is judged.
3. Build the golden set, attack set, mock agent and guardrails.
4. Build the scorer and reports, and **prove the scorer with the mock agent first**.
5. Run the real model three times and classify every failure as a model error or an evaluator error.
6. Optionally add prompt evolution and RAG.

### 4. Review the deliverables

Work through the **Deliverables checklist** at the end of `SKILL.md`. Two checks matter most:
- Did the evaluator catch **every** bug planted in the mock agent?
- Was **every** failing case confirmed to be a real model error and not an evaluator mistake?

### 5. Keep the skill improving

When a new project uncovers a new pitfall:
1. Add it to the *Known evaluator false negatives* section of `SKILL.md`.
2. Run `./package.sh` to rebuild the zip.
3. Commit, then re-upload the zip to claude.ai.

## Ground rules

- **Company or customer data only runs on AI services your organisation has approved** (for example its own Azure OpenAI tenant). Free tiers and offshore providers are for public or synthetic data only.
- **Never edit test cases after seeing results to raise a score.** If a case turns out to be ambiguous, log it and fix it in the next version of the suite.

## License

MIT
