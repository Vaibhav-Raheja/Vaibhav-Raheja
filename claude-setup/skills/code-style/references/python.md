# Python Coding Guidelines — Full Reference

Source: EarthSense Coding Guidelines v1.0 (updated Oct–Dec 2024)
Canonical: https://peps.python.org/pep-0008/

---

## Indentation

- **4 spaces** per indentation level. No tabs.
- Continuation lines: align with opening delimiter OR use hanging indent.
- Hanging indent: no arguments on first line; extra indent to distinguish from body.

```python
# Aligned with opening delimiter
def short_function_name(var_one, var_two,
                        var_three, var_four):
    print(var_one)

# Hanging indent — extra level to distinguish from function body
def short_function_name(
        var_one, var_two,
        var_three, var_four):
    print(var_one)

# Hanging indent for function call
foo = long_function_name(
    var_one,
    var_two,
    var_three,
    var_four,
)
```

---

## Line Length & Multi-line Function Calls

- Black formatter enforces **120 characters** max line length.
- Split to multi-line when the call exceeds 80 characters.
- **Always** use multi-line when passing keyword arguments, even if short.

```python
# Multi-line function definition (>80 chars or kwargs)
def my_long_function_name(
    my_long_argument: Union[List[np.ndarray], float],
    my_second_long_argument: np.ndarray,
    my_third_long_argument: str,
    my_fourth_long_argument: float,
    short_name: str,
) -> Tuple[str, int, float]:
    ...

# Multi-line return assignment
(
    my_first_long_return_variable_name,
    my_second_long_return_variable_name,
    my_third_long_return_variable_name,
) = my_long_function_name(
    my_first_argument_variable_name,
    my_second_argument_variable_name,
    my_third_argument_variable_name,
    my_fourth_argument_variable_name,
    short_name,
)

# Acceptable: short, no keyword args
x = myfunction(a, b, c, d, e, f, g)

# Required multi-line: keyword args present
x = myfunction(
    a=1,
    b=2,
    c=3,
    d=4,
)
```

---

## Type Hints

Required on **all** public function arguments and return types.

```python
import numpy as np
import scipy

from typing import List, Tuple, Optional

def my_function(
    a: np.ndarray,
    b: List[int],
    c: Tuple[str, float, bool],
    d: Optional[np.ndarray] = None,
) -> scipy.spatial.Rotation:
    ...
```

Also required on `@dataclass` fields:

```python
from dataclasses import dataclass

@dataclass
class MyClass:
    a: Optional[float] = None
    b: str = "hello world"
```

---

## Imports

### Rules
- One import per line.
- Exception: multiple names from the same module — `from subprocess import Popen, PIPE`
- **Never** `from module_x import *`
- Prefer `import module_x` then `module_x.y` explicitly.
- `from module_x import y` is acceptable for: few symbols, performance-critical code, loops.

### Order (blank line between each group)
1. Standard library imports
2. Third-party imports
3. Local / project-specific imports

```python
# Correct
import os
import sys

import numpy as np
import rclpy

from solarbot.sensors import LidarProcessor

# Wrong — wildcard
from module_x import *

# Wrong — multiple unrelated imports on one line
import os, sys
```

Imports always go at the **top of the file**, after module docstring/comments,
before any globals or constants.

---

## Naming Conventions

| Entity | Convention | Example |
|---|---|---|
| Classes | `CamelCase` | `SolarFieldScanner` |
| Functions | `snake_case` | `process_lidar_frame` |
| Variables | `snake_case` | `frame_count` |
| Constants | `UPPER_SNAKE_CASE` (PEP8) | `MAX_RETRY_COUNT` |

`mixedCase` only allowed when maintaining backwards compatibility with existing code
where it's the prevailing style (e.g., `threading.py`-style APIs).

---

## Docstrings

Required for all **public** modules, functions, classes, and methods.
Non-public methods: at minimum a single-line comment after `def`.

```python
# Multi-line — closing """ on its own line
def complex_function(x: int) -> str:
    """
    Return a foobang.

    Detailed explanation of what the function does,
    its edge cases, and any important behavior.
    """
    ...

# One-liner — closing """ on the same line
def simple_function() -> str:
    """Return an ex-parrot."""
    ...

# Non-public — comment is fine
def _internal_helper(x):
    # Computes intermediate transform for the sensor pipeline.
    ...
```

---

## Formatter: Black

### Configuration
- Line length: `120`
- Skip string normalization: `true` (preserves your quote style)

### VS Code Setup

Add to your `settings.json` (Ctrl+Shift+P → "Open User Settings (JSON)"):

```json
{
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter",
    "editor.formatOnSave": true,
    "editor.formatOnType": false,
    "editor.formatOnPaste": false,
    "editor.formatOnSaveMode": "modifications"
  },
  "black-formatter.args": [
    "--skip-string-normalization",
    "--line-length",
    "120"
  ]
}
```

Requires the **Black Formatter** extension from Microsoft.

### CLI Usage

```bash
pip install black

# Format entire folder
black .

# Format single file
black myfile.py
```

### PR Policy
- Formatting changes must be in a **separate PR** from logic or refactor changes.
- Open the formatting PR first, merge it, then open the logic PR on top.
