# Org-babel essentials

Reference for the org-mode literate-programming conventions used by this skill.
Load this when you need the exact syntax for `:tangle`, `:noweb`, and headings.

## Code blocks

A source block with a language and header args:

```org
#+begin_src python :tangle src/main.py
def main():
    print("hello")
#+end_src
```

- The `:tangle <path>` arg says which file this block emits when tangled.
  Use a relative path from the org file (usually relative to project root).
- Omit `:tangle` (or set `:tangle no`) for blocks that are illustrative only and
  should not be emitted.

## File-wide header args

Set defaults once at the top of the file:

```org
#+property: header-args:python :tangle yes
#+property: header-args:python :noweb yes
```

Per-block args override these. Use the language-specific form
(`header-args:python`, `header-args:R`, `header-args:bash`).

## Noweb (assembling a program from named chunks)

Name a block, then pull its body into another block:

```org
#+name: greet
#+begin_src python
def greet(name):
    print(f"hello, {name}")
#+end_src

#+begin_src python :noweb yes
<<greet>>
def main():
    greet("world")
#+end_src
```

At tangle time, `<<greet>>` is replaced by the body of the `greet` block. This
is how the top-level / `main` block is *literally assembled* from the
sub-heading blocks — the outline IS the program.

- `:noweb yes` enables expansion of `<<name>>` references in a block.
- `<<name>>` can also appear inside a line (e.g. for inline substitution).

## Headings as the decomposition tree

Org headings (`*`, `**`, `***`) carry the structure; code blocks live under
them. A typical file:

```org
* main
:PROPERTIES:
:...:
:END:
#+name: main
#+begin_src python :tangle src/main.py :noweb yes
<<imports>>
<<parse_args>>
if __name__ == "__main__":
    main()
#+end_src

** imports
#+name: imports
#+begin_src python
import sys
import argparse
#+end_src

** parse_args
#+name: parse_args
#+begin_src python
def parse_args():
    ...
#+end_src
```

## Naming the tangled output file

One output file per org file is the default. For a module `src/foo.org` that
tangles to `src/foo.py`, set every block's `:tangle src/foo.py` (or rely on a
file-wide default and override the illustrative blocks with `:tangle no`).

## What the agent does NOT do

- Never run `org-babel-tangle`. The user does this in Emacs.
- Never write the final source files (`src/foo.py`, etc.) directly. Author the
  org files; the source is derived by tangling.
