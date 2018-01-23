---
Title: My First Garbage Collector
---

See this [Previous Post](./2017-12-04-runtime-systems.markdown) for how to setup an environment for integrating a runtime system
written in C with a compiler for a simple language written in Haskell.

So now I can define arbitrary functions in C and use them in the compiler to power high-level constructs. A good first project
to get my feet wet is a garbage collector. This only really needs a `malloc` and `free` from the OS and shouldn't require
much of a change in the AST I've borrowed from Kaleidoscope. A good guide for some design decisions is the entry in AOSA about
[GHC](http://www.aosabook.org/en/ghc.html), which is an excellent resource for understanding how the runtime system works for
a production quality language.

### Defining the API

First, lets get the garbage collector API locked down. That will make it easy to focus on the implementation and integrating it
with the compiler later.
