Use this coding quidelines:
Specify the current <version> we use.
Linter for the C++
Specify the linter <version> to be used for the C++ code
The #define Guard
All the header files should have #define guards to prevent multiple inclusions.
The format of the symbol name shall be <COMPONENT>_<DIRNAME>_<FILE>_H_
To guarantee uniqueness, they should be based on the above format.

#ifndef MOTOR_V1_FILE_H_
#define MOTOR_V1_FILE_H_
…….

#endif // MOTOR_V1_FILE_H_


Include what you use
If a source or header file refers to a symbol defined elsewhere, the file should directly include a header file which properly intends to provide a declaration or definition of that symbol. It should not include header files for any other reason.

Order of includes
// immediate headers from the directory
#include <current_directory_header.h>


// C system headers
#include <c_system_headers.h>

// C++ standard library headers
#include<iostream>


// Other libraries or headers from the project
#include<other_libs_headers.h>

Forward declarations
Avoid forward declarations as much as possible. 
If you still need to have the forward declaration, comments shall be useful to figure out from which .h or .cpp file we are using the declarations.


//from b.h
Class B
Struct B


// from file.cpp
void func( FILE*)
void func(void)


Function Declarations
Function declaration shall have following details
/**
 *  Description: Sum numbers in a vector.
 *
 * @param values Container whose values are summed.
 * @return sum of `values`, or 0.0 if `values` is empty.
 */
double   <<<< newline should be followed by return type.
sum(std::vector<double> & const values) 
{
    ...
}

Class Format
class DerivedClass : public BaseClass {
 public:           // Note the 1 space indent!
     DerivedClass();  // Regular 4 space indent.
     ~DerivedClass() {}


     void someFunction();
     void someFunctionThatDoesNothing() {
  }


  void setSomeVar(int var) { some_var_ = var; }
  int someVar() const { return some_var_; }


 private:
     bool someInternalFunction();


     int some_var_;
     int some_other_var_;
};

Horizontal whitespace
General
int i = 0;  // Two spaces before end-of-line comments.


void f(bool b) 
{  // Open braces should always have a space before them.
  ...
int i = 0;  // Semicolons usually have no space before them.
// Spaces inside braces for braced-init-list are optional.  If you use them,
// put them on both sides!
int x[] = { 0 };
int x[] = {0};
}


// Spaces around the colon in inheritance and initializer lists.
class Foo : public Bar 
{
 public:
  // For inline function implementations, put spaces between the braces
  // and the implementation itself.
  Foo(int b) : Bar(), baz_(b) {}  // No spaces inside empty braces.
  void Reset() { baz_ = 0; }  // Spaces separating braces from implementation.

Loops and Conditions
if (b) {          // Space after the keyword in conditions and loops.
} else {          // Spaces around else.
}


while (test) {}   // There is usually no space inside parentheses.




switch (i) {


for (int i = 0; i < 5; ++i) {
// Loops and conditions may have spaces inside parentheses, but this
// is rare.  Be consistent.
switch ( i ) {
if ( test ) {


for ( int i = 0; i < 5; ++i ) {
// For loops always have a space after the semicolon.  They may have a space


// before the semicolon, but this is rare.
for ( ; i < 5 ; ++i) {
  ...


// Range-based for loops always have a space before and after the colon.
for (auto x : counts) {
  ...
}


	 (i) {
  case 1:         // No space before colon in a switch case.
    ...
  case 2: break;  // Use a space after a colon if there's code after it.

Vertical whitespace
Minimize use of vertical white space.
Some thumb rules to help blank lines may be useful.
Don’t add unnecessary blank lines between function definitions, one blank line space between 2 function definitions is good.
Blank lines at the beginning or end of a function do not help readability.
Blank lines inside a chain of if-else blocks may well help readability.

Python

This is one of the best guidelines for python - https://peps.python.org/pep-0008/
Some important points from the above blog are mentioned below.
Indentation
Use 4 spaces per indentation level.
Continuation lines should align wrapped elements either vertically using Python’s implicit line joining inside parentheses, brackets and braces, or using a hanging indent [1]. When using a hanging indent the following should be considered; there should be no arguments on the first line and further indentation should be used to clearly distinguish itself as a continuation line:
# Add 4 spaces (an extra level of indentation) to distinguish arguments from the rest.
def short_function_name(var_one, 
	                var_two, 
                        var_three,
                        var_four):
    print(var_one)
    for i in range(10):
        if True:
            print(i)


# Hanging indents should add a level.
foo = long_function_name(
    var_one, 
    var_two,
    var_three, 
    var_four
)

Multi-line function calls
When a function call or definition is taking up more than 80 characters, we should put arguments and return elements on separate lines. Usually we’re not going to have multiple return items, but we are often going to have many arguments to functions. Anytime we pass in keywords to a function, we should use multi-line input, no matter how short the arguments are.
def my_long_function_name(my_long_argument : Union[List[np.ndarray], float],
                          my_second_long_argument : np.ndarray,
                          my_third_long_argument : str,
                          my_fourth_long_argument : float,
                          short_name : str,) -> Tuple[str, int, float]:
    
    . . . .

my_first_long_return_variable_name, \
my_second_long_return_variable_name, \
my_third_long_return_variable_name = my_long_function_name(
    my_first_argument_variable_name,
    my_second_argument_variable_name,
    my_third_argument_variable_name,
    my_fourth_argument_variable_name,
    short_name
)

# This is acceptable, because it is short and no keyword arguments are used
x = myfunction(a, b, c, d, e, f, g)

# This is how we should do it if keyword arguments are used
x = myfunction(a=1,
               b=2,
               c=3,
               d=4,
               e=5,
               f=6,
               g=7)


# Alternatively we can do it this way
x = myfunction(
    a=1,
    b=2,
    c=3,
    d=4,
    e=5,
    f=6,
    g=7
)

Type Hints
All function definitions should be written with type hints for arguments and for return types. One way to do this is to import types from the typing module.
import numpy as np
import scipy

from typing import List, Tuple, Optional

# All parameters have type hints specified
# Make sure to specify return type
def my_function(a : np.ndarray,
                b : List[int],
                c : Tuple[str, float, bool],
                d : Optional[np.ndarray] = None) -> scipy.spatial.Rotation:
    ...

Furthermore, we should include type hints when defining dataclasses.

@dataclass
class MyClass:
    a : Optional[float] = None
    b : str = “hello world”


Imports
Imports should usually be on separate lines:
# Correct:
import os
import sys


#import from same library/file can be in the same line
from subprocess import Popen, PIPE


# Usage of wildcard is INCORRECT 
from module_x import * 


# Acceptable
from module_x import y

Imports are always put at the top of the file, just after any module comments and docstrings, and before module globals and constants.
Imports should be grouped in the following order:
Standard library imports.
Related third party imports.
Local application/library specific imports.
You should put a blank line between each group of imports.
Usage of wildcard (from module_x import *) is incorrect. It is encouraged to use `import module_x` then explicitly use in the code `module_x.y`. In certain cases such as:
Using few elements (classes, functions, variables, etc) from a module;
In performance critical code (reduced attribution lookup overhead);
In loops (reduced attribution lookup overhead);
It may be advised to use `from module_x import y`. 



Naming conventions

Class Names
Class names should normally use the CamelCase  convention. The naming convention for functions may be used instead in cases where the interface is documented and used primarily as a callable.
Function and Variables names
Function names should be lowercase, with words separated by underscores as necessary to improve readability. Variable names follow the same convention as function names. mixedCase is allowed only in contexts where that’s already the prevailing style (e.g. threading.py), to retain backwards compatibility.
Docstrings
Write docstrings for all public modules, functions, classes, and methods. Docstrings are not necessary for non-public methods, but you should have a comment that describes what the method does. This comment should appear after the  def line.
 Note that most importantly, the """ that ends a multi line docstring should be on a line by itself:


"""
Return a foobang
Define what function does
”””
For one liner docstrings, please keep the closing """ on the same line:
"""Return an ex-parrot."""


Formatters
Formatters help enforce specific rules and conventions such as line spacing, indents, and spacing around operators, making the code more visually organized and comprehensible. 
Black
Suggesting to install Black formatter for python - https://github.com/psf/black. This will format the code and make it more readable and correct the spacing and indentation error if there are any.
Formatter setup for python
In order to keep things uniform and set up some rules for the whole organization, here are some guidelines to be followed:
Formatting changes should be kept separate from actual logic or organizational changes to the code - this can be done by either having a PR only for the formatting changes before opening a PR for the code changes. 
One way to use the formatter is by using a json file in the settings menu on the vs code editor, the following lines can be added to the settings.json file (found with ctrl + shift + p and then finding “Open User Settings (JSON)”) - 
{
    "[python]": {
        "editor.defaultFormatter": "ms-python.black-formatter",
        "editor.formatOnSave": true,
        "editor.formatOnType": false,
        "editor.formatOnPaste": false,
        "editor.formatOnSaveMode": "modifications", // formats whole file when saved
        // "editor.codeActionsOnSave": {
        //     "source.organizeImports": "always"
        // },
    },
    
    "black-formatter.args": [
        "--skip-string-normalization",
        "--line-length",
        "120"],
}
	Note : the extension Black from microsoft must be downloaded in the editor. 
if VSCODE is not the preferred code editor, another way to approach this would be make the necessary changes to the python files using the terminal 
locate the folder containing the scripts that need to be formatted
install the black formatter using “pip install black” 
use the command - “black .” for formatting all the files in the folder or “black <filename>.py” for a single python file to be formatted.
once the formatting is done, you can see the changes being reflected in the format of the code and these changes can be committed in a different branch ready for PR


sudo password is 260401
# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
