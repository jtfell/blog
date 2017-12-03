---
title: Runtime Systems
---

After years of playing around with compilers and language design, I had a moment of clarity. The hardcore
engineering at the heart of building a modern, high-level language is the aspect of the pursuit that really
appeals to me. I'm really glad I have had this realisation as it allows me to focus in on a particularly
difficult part of building a language: the runtime system.

After reading around, I found out that the runtime system is responsible for giving the higher-level abstractions
their superpowers. For example, creating an array in a dynamic language like Javascript is so painless because
the runtime allocates and deallocates the memory required for it (this is the garbage collector at work). Or
perhaps more interestingly, any parallel or asynchronous constructs in a language need to be provided by the
runtime.

### Getting Set Up

In order to experiment with writing a runtime system I needed a language to write one for. Unfortunately my previous
experiments weren't up to the task so I took a nice and simple [example](http://www.stephendiehl.com/llvm/)
(with a full tutorial explaining its design) and tried to link in some custom C code to the output program. This
compiler outputs LLVM IR, so using clang I was able to compile my C code to the same representation, then link them
and finally run a program which calls out to the function defined there.

So the state of things after some modifications to the sample project consists of:

 - The compiler which outputs a LLVM IR representation of the AST it is given (hardcoded in the absense
   of a frontend for the compiler). I have just removed some of the JIT functionality as I'm not building
   an interpreter.
 - An external library that can be referenced in the AST (`lib/rts.c`). It only contains a basic print
   function to prove it can be called.

The makefile I wrote to glue these components together is definitely not portable but will likely be easy to
port to another system.

```
LLVM_DIR=/usr/local/Cellar/llvm-5.0/5.0.0/bin/

default:
	stack build

	### First we generate LLVM IR representation of the program and runtime lib
	# Use the custom compiler for the actual program
	stack exec main > main.ll
	# Use clang for the runtime lib
	clang -emit-llvm -S lib/rts.c -o lib/rts.ll

	# Use LLVM assembler for converting LLVM IR to bitcodes
	$(LLVM_DIR)/llvm-as-5.0 lib/rts.ll -o lib/rts.bc
	$(LLVM_DIR)/llvm-as-5.0 main.ll -o main.bc

	# Use LLVM link to generate a single bitcode file
	$(LLVM_DIR)/llvm-link-5.0 main.bc lib/rts.bc -o output.bc

	# Execute the bitcode using the LLVM interpreter
	$(LLVM_DIR)/lli-5.0 output.bc
```

The full repo for this skeleton is [here](https://github.com/jtfell/compiler-llvm/tree/94ac4332aff49874979bce4460fc506492a7e14b).

### A simple GC

So now I can define arbitrary functions in C and use them in the compiler to power high-level constructs. A good first project
to get my feet wet is a garbage collector. This only really needs a `malloc` and `free` from the OS and shouldn't require
much of a change in the AST I've borrowed from Kaleidoscope. A good guide for some design decisions is the entry in AOSA about
[GHC](http://www.aosabook.org/en/ghc.html), which is an excellent resource for understanding how the runtime system works for
a production quality language.



