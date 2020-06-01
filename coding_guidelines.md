Coding guidelines
=================

Rule 1
------

Write a program/library that do one thing and do it well.


Rule 2
------

Restrict all code to very simple control flow constructs – do not use goto
statements, setjmp or longjmp constructs, and direct or indirect recursion.

**Rationale**: Simpler control flow translates into stronger capabilities for verification
and often results in improved code clarity. The banishment of recursion is perhaps the
biggest surprise here. Without recursion, though, we are guaranteed to have an
acyclic function call graph, which can be exploited by code analyzers, and can
directly help to prove that all executions that should be bounded are in fact bounded.
(Note that this rule does not require that all functions have a single point of return –
although this often also simplifies control flow. There are enough cases, though,
where an early error return is the simpler solution.) 


References
----------

* [The power of 10: Rules for developing safety critical code](https://en.wikipedia.org/wiki/The_Power_of_10:_Rules_for_Developing_Safety-Critical_Code)
* [Unix philosophy](https://en.wikipedia.org/wiki/Unix_philosophy)

