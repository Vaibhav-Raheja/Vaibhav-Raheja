---
name: code-style
description: >
  Enforces coding standards for C++ and Python. Use this skill
  whenever the user shares code for review, asks you to write new C++ or Python code,
  requests docstrings or type hints, asks about formatting or naming conventions, or
  says "does this follow our standards?" or "review this file." Also trigger when the
  user pastes a function, class, or header and asks for feedback — even if they don't
  explicitly mention coding standards. Always apply this skill when working on
  Solarbot stack code, ROS2 nodes, or any project repository.
  Also known as: /code-style
---

# Coding Style Skill

Applies the official Coding Guidelines v1.0 for **C++** and **Python**.
When reviewing or generating code, always check against the rules below.
For deep-reference on a language, load the relevant file from `references/`.

---

## How to Use This Skill

**Code Review:** Go section by section through the applicable rules. For each
violation found, quote the offending snippet, name the rule, and show the corrected
version. End with a short summary of what passed and what needs fixing.

**Code Generation:** Before writing any function, class, or module, mentally run
through the checklist for the target language and produce compliant output from the
start. Never produce code that violates these rules even if the user's example does.

---

## C++ Rules (Quick Reference)

> Full detail: `references/cpp.md`

### Headers
- All header files **must** have `#define` guards in format:
  `<COMPONENT>_<DIRNAME>_<FILE>_H_`
- Only `#include` headers that provide symbols the file directly uses.
- **Include order** (blank line between groups):
  1. Current directory headers
  2. C system headers
  3. C++ standard library headers
  4. Other project / third-party headers

### Forward Declarations
- Avoid forward declarations wherever possible.
- If used, add a comment indicating the source file: `// from b.h`

### Function Declarations
Every function declaration **must** have a Doxygen-style comment block:
```cpp
/**
 * Description: What the function does.
 *
 * @param values  Description of parameter.
 * @return        Description of return value.
 */
double                          // return type on its own line
sum(std::vector<double> const& values);
```

### Class Format
```cpp
class DerivedClass : public BaseClass {
 public:  // 1-space indent for access specifiers
  DerivedClass();               // 4-space indent for members
  ~DerivedClass() {}
  void someFunction();
  int someVar() const { return some_var_; }

 private:
  int some_var_;                // trailing underscore for private members
};
```

### Horizontal Whitespace
- Two spaces before end-of-line comments: `int i = 0;  // comment`
- Space before open brace: `void f(bool b) {`
- No space before semicolons.
- Spaces around `:` in inheritance and initializer lists.
- `if`, `while`, `for`, `switch`: space after keyword, no space inside parens (usually).
- Range-based for: space before and after colon — `for (auto x : counts)`
- Switch cases: no space before colon; space after colon if code follows.

### Vertical Whitespace
- Minimize blank lines. One blank line between function definitions max.
- No blank lines at the start or end of a function body.
- Blank lines inside if-else chains are acceptable for readability.

---

## Python Rules (Quick Reference)

> Full detail: `references/python.md`
> Canonical reference: https://peps.python.org/pep-0008/

### Indentation
- 4 spaces per level. No tabs.
- Continuation lines: align with opening delimiter, OR use hanging indent with
  no arguments on the first line.

### Line Length & Multi-line Calls
- Wrap at **120 characters** (Black config).
- Multi-line when >80 chars OR when keyword arguments are used — even if short:
```python
# Always multi-line when using kwargs
x = myfunction(
    a=1,
    b=2,
    c=3,
)
# Acceptable without kwargs if short
x = myfunction(a, b, c, d)
```

### Type Hints
- **Required** on all function arguments and return types.
- Use `from typing import List, Tuple, Optional` etc.
- Required on `@dataclass` fields too.
```python
def my_function(
    a: np.ndarray,
    b: List[int],
    c: Optional[np.ndarray] = None,
) -> scipy.spatial.Rotation:
    ...
```

### Imports
- One import per line (exception: `from x import a, b` for same module).
- **Never** `from module import *`.
- Prefer `import module_x` then `module_x.y`; use `from module_x import y` only
  for few symbols, performance-critical, or loop contexts.
- Import order (blank line between groups):
  1. Standard library
  2. Third-party
  3. Local / project

### Naming Conventions
| Entity | Convention |
|---|---|
| Classes | `CamelCase` |
| Functions | `snake_case` |
| Variables | `snake_case` |
| Private class members | trailing `_` (C++ convention carried over) |

### Docstrings
- Required for all **public** modules, functions, classes, and methods.
- Non-public methods: at minimum a one-line comment after `def`.
- Multi-line: closing `"""` on its own line.
- One-liner: closing `"""` on the same line.
```python
"""Return a foobang.

Detailed description here.
"""

"""Return an ex-parrot."""
```

### Formatter: Black
- Line length: **120** characters (`--line-length 120`)
- String normalization: **disabled** (`--skip-string-normalization`)
- Format on save in VS Code (see `references/python.md` for settings.json snippet).
- Formatting PRs must be **separate** from logic/refactor PRs.

---

## Review Output Format

When reviewing code, structure your response as:

```
## Review: <filename or description>

### ✅ Passes
- <rule>: <brief note>

### ❌ Violations
1. **<Rule Name>** — Line ~N
   - Found: `<snippet>`
   - Fix:   `<corrected snippet>`
   - Reason: <one sentence>

### Summary
<1–2 sentences on overall quality and priority fixes>
```

---

## References
- `references/cpp.md` — Full C++ rules with all examples from the guidelines doc
- `references/python.md` — Full Python rules with Black config and VS Code setup
