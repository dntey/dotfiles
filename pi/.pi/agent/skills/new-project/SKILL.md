---
name: new-project
description: Start and workshop a new coding project as Emacs org-mode literate programming files. Use whenever the user wants to begin a new project, draft an idea into code, or collaborate top-down from a high-level plan into tangled source files. Produces a README.org plus named org files whose code chunks tangle to .R/.py/.sh/etc.
---

# Literate Org Project

This skill defines how to collaboratively develop a new coding project with the
user using Emacs org-mode literate programming. Follow it whenever the user
wants to start a new project or workshop code.

## Core principle

Work **top-down and out loud**. We describe what a thing *is* and what it *looks
like to use* before we describe how it is built. We outline the program as a
skeleton before writing any real logic. We keep the prose rationale next to the
code it explains, in org headings and code chunks. The agent authors org files;
the user runs `org-babel-tangle` from inside Emacs to produce the final source.

**Never** write the final `.R` / `.py` / `.sh` / etc. source files directly.
Always author them as org code chunks with `:tangle` header args and let the user
tangle. **Never** attempt to run `org-babel-tangle` yourself — that happens in
the user's Emacs.

## The phases (do not skip ahead)

### Phase 0 — Choose the tools

Before writing anything, decide with the user what tools are appropriate for the
job. This is part of the process, not a footnote. Discuss and agree on:

- A language / runtime (R, Python, bash, etc.)
- Specific libraries, packages, or CLI tools that fit the problem
- Why these are appropriate

State the decision explicitly and confirm with the user before proceeding.

### Phase 1 — README.org: the high-level plan

Create `README.org` at the project root. This is where everything starts. At
this stage it is **mostly plain prose**, not code. Write:

- What the project is and why it exists
- For a tool: answer the question **"What does this tool look like to use?"** —
  describe the experience of using it (inputs, outputs, examples of running it)
- How it works at a conceptual level (no implementation details yet)
- The tool/language decision from Phase 0

Do NOT think about coding or implementation details in Phase 1. Resist filling
in functions. Get the *shape* of the project agreed first.

A starter skeleton lives at `assets/README.org.template` — copy it as a base
and adapt it. See [org-babel essentials](references/org-babel-essentials.md)
for the header-arg and noweb conventions used throughout.

### Phase 2 — The skeleton (review before coding)

Before coding anything, present the user with a **draft of what the final
high-level code will look like**:

- Start with the outline of the `main` function (or the top-level entry point)
- Decompose it into named smaller functions, each left as a stub / TODO
- This skeleton is the decomposition tree. It is not real logic yet.

Show this skeleton to the user and get agreement. Only after agreement do you
proceed to Phase 3. If the user wants changes, iterate on the skeleton here — it
is cheap to move boundaries at this stage.

### Phase 3 — Literate org files

Now express the skeleton as one or more org files:

- **Org headings mirror the decomposition tree.** Each named function /
  sub-concept gets its own heading (nested as appropriate).
- **A code chunk lives under each heading** with the appropriate `src`
  language and a `:tangle <path>` header arg naming the output file.
- The top-level / `main` block uses `:noweb yes` and `<<block-name>>` noweb
  references so it is *literally assembled* from the sub-heading blocks. The
  outline IS the program; the headings expand it.
- Place and name files logically. `README.org` stays at the root for the
  high-level idea; other org files (e.g. `src/<module>.org`) tangle to their
  corresponding source files (e.g. `src/<module>.<ext>`).

### Phase 4 — Drill into specifics

Only once Phases 1–3 are agreed do we fill in individual code chunks, **one
heading at a time**, with the user steering which one to open up next. Keep prose
alongside each chunk explaining the rationale. Update `README.org` if the
high-level understanding evolves.

## File conventions

- Every project has `README.org` at the root. Always.
- Org files use `#+property: header-args` and per-block `:tangle` / `:noweb` args.
- Source language of `src` blocks matches the Phase 0 decision.
- One tangled output file per org file is the default; split further only when
  logical.
- Do not duplicate content across files — cross-link with org links instead.

## Reminders

- The user runs tangle in Emacs. You author. Do not tangle. Do not emit final
  source files.
- Always present the skeleton for review before any real code.
- Keep prose and code together; that is the whole point of literate programming.
- When unsure which heading to fill next, ask the user rather than guessing.
