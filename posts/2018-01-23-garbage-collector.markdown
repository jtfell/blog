---
title: Garbage Collectors
---

See this [Previous Post](./2017-12-04-runtime-systems.html) for how to setup an environment for integrating a runtime system
written in C with a compiler for a simple language written in Haskell.

So now I can define arbitrary functions in C and use them in the compiler to power high-level constructs. A good first project
to get my feet wet is a garbage collector. This only really needs allocation and free primitives from the OS and shouldn't require
much of a change in the AST I've borrowed from Kaleidoscope. A good guide for some design decisions is the entry in AOSA about
[GHC](http://www.aosabook.org/en/ghc.html), which is an excellent resource for understanding how the runtime system works for
a production quality language.

### Defining the API

First, lets get the garbage collector API locked down. That will make it easy to focus on the implementation and integrating it
with the compiler later. I really shouldn't have to justify that though, writing code without planning makes for rubbish design
and I want nothing to do with it.

I am going to define this at 2 levels. The lower level is a block-based memory allocator, which just keeps track of a pool of
groups of blocks which can be allocated and freed. Very simple, hopefully very achievable.

```c
/**
 * Objects are to be allocated as groups of blocks of memory.
 *
 * Define a struct to describe a block.
 */
typedef struct bdescr_ {
  
  // The memory location of the block
  void *              start;

  // The next block in the group (can be null)
  struct bdescr_ *    link;
} bdescr;

/**
 * Public methods
 */
// Initialises the GC pool
void gc_pool_init();

// Allocates a group, returning a pointer to the block at the start
bdescr * alloc_group(int n);

// Removes a group from the memory pool
void free_group(bdescr * p);

```

This is loosely based off the design of GHCs garbage collector. On top of this, we can then define more specific methods for allocating
types of objects, extending the size of existing objects and running the garbage collector algorithm. I'll start with just the implementation
for arrays. The compiler should be able to use this to manage dynamically resized arrays at runtime.

```c
typedef struct array_ {
  
  int            length;

  bdescr *       data;
} array;

void gc_init();
void gc_run();

array * alloc_array(int length);
void resize_array(array * arr, int length);
```

### Test Cases

Now that I've dreamt up an API for my garbage collector, I'll come up with some basic tests to validate the common use cases. These will
help verify the implementation is correct as well as informing how it can be integrated with the compiler. It makes sense to test that
the low-level API functions correctly, before building the higher level API on top of it.

#### Low level

Execising the low-level API is as simple as allocating and deallocating some groups of memory and checking that the expected amount of
memory is allocated and accounted for.

```c
int main () {
  gc_pool_init();

  bdescr * blockA = alloc_group(5);
  // Print memory usage = 5
  bdescr * blockB = alloc_group(11);
  // Print memory usage = 16

  free_group(blockA);
  // Print memory usage = 5
  free_group(blockB);
  // Print memory usage = 0
}
```

#### High level

The high-level array based API can be put through the motions by allocating an array, resizing it, letting it fall out of scope and then
running the GC algorithm.

```c
int main() {
  gc_init();

  do_allocs();

  gc_run();
  // Print memory usage = 0 (xs is out of scope, so is freeable)
}

void do_allocs() {  
  array * xs = alloc_array(32);
  // Print memory usage = 32

  resize_array(xs, 64);
  // Print memory usage = 64

  gc_run();
  // Print memory usage = 64 (as xs is still in scope)
}
```

### Where to from here

The implementation of the low-level API should be relatively straightforward as it is just a bunch of pointer-gymnastics and
some bookkeeping. The high-level API has me a bit more intimidated but that's the point isn't it? I'll tackle both in further
posts, wish me luck!

