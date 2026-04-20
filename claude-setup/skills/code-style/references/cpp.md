# C++ Coding Guidelines — Full Reference

Source: EarthSense Coding Guidelines v1.0 (April 2024, updated Dec 2024)

---

## C++ Version
<!-- TODO: Fill in the C++ version used (e.g., C++17) once specified in your team's config -->

## Linter
<!-- TODO: Fill in the linter and version once specified -->

---

## #define Guards

All header files must have `#define` guards to prevent multiple inclusions.

Format: `<COMPONENT>_<DIRNAME>_<FILE>_H_`

```cpp
#ifndef MOTOR_V1_FILE_H_
#define MOTOR_V1_FILE_H_

// ... header content ...

#endif  // MOTOR_V1_FILE_H_
```

Guards must be unique — base them strictly on the path format above.

---

## Include What You Use

A file should only `#include` headers that directly provide declarations or
definitions it uses. Do not include transitively — if you use it, include it.

---

## Order of Includes

```cpp
// 1. Immediate headers from the same directory
#include <current_directory_header.h>

// 2. C system headers
#include <c_system_headers.h>

// 3. C++ standard library headers
#include <iostream>

// 4. Other libraries or project headers
#include <other_libs_headers.h>
```

One blank line between each group.

---

## Forward Declarations

- Avoid forward declarations wherever possible — prefer including the header.
- If you must forward declare, add a comment showing the source:

```cpp
// from b.h
class B;
struct B;

// from file.cpp
void func(FILE*);
void func(void);
```

---

## Function Declarations

Every function declaration must be preceded by a Doxygen comment block.
Return type goes on its own line (newline after `/**...*/`).

```cpp
/**
 * Description: Sum numbers in a vector.
 *
 * @param values  Container whose values are summed.
 * @return        Sum of `values`, or 0.0 if `values` is empty.
 */
double
sum(std::vector<double> const& values)
{
    ...
}
```

---

## Class Format

```cpp
class DerivedClass : public BaseClass {
 public:  // 1-space indent for access specifiers
  DerivedClass();               // 4-space indent for members
  ~DerivedClass() {}

  void someFunction();
  void someFunctionThatDoesNothing() {}

  void setSomeVar(int var) { some_var_ = var; }
  int someVar() const { return some_var_; }

 private:
  bool someInternalFunction();

  int some_var_;                // trailing underscore for all private members
  int some_other_var_;
};
```

Key rules:
- Access specifiers (`public:`, `private:`, `protected:`) are indented **1 space**.
- Member declarations are indented **4 spaces**.
- Private member variables use a **trailing underscore**: `some_var_`

---

## Horizontal Whitespace

### General

```cpp
int i = 0;  // Two spaces before end-of-line comments.

void f(bool b) {  // Space before open brace.
    int i = 0;    // No space before semicolons.

    // Spaces in braced-init-list are optional, but must be symmetric:
    int x[] = { 0 };   // OK
    int x[] = {0};     // OK
}

// Spaces around colon in inheritance and initializer lists:
class Foo : public Bar {
 public:
  Foo(int b) : Bar(), baz_(b) {}  // No spaces inside empty braces.
  void Reset() { baz_ = 0; }     // Spaces between braces and implementation.
};
```

### Loops and Conditions

```cpp
if (b) {          // Space after keyword; no space inside parens (standard).
} else {          // Spaces around else.
}

while (test) {}

switch (i) {

for (int i = 0; i < 5; ++i) {

// Rare variant with spaces inside parens — be consistent if used:
switch ( i ) {
if ( test ) {
for ( int i = 0; i < 5; ++i ) {

// For loop: space after semicolon always; space before semicolon is rare.
for ( ; i < 5 ; ++i) {

// Range-based for: space before AND after the colon.
for (auto x : counts) {
    ...
}

// Switch cases:
case 1:          // No space before colon.
    ...
case 2: break;  // Space after colon when code follows on the same line.
```

---

## Vertical Whitespace

- **Minimize** vertical whitespace.
- At most **one blank line** between function definitions.
- **No blank lines** at the start or end of a function body.
- Blank lines inside if-else chains are acceptable for readability.
