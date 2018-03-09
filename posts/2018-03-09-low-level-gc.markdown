---
title: Garbage Collector Low-Level API
---

See this [Previous Post](./2018-01-23-garbage-collector.markdown) for the design of my uber simple garbage collector. I'm
spliting the initial implementation into 2 phases, the low-level block-based memory allocation API and the higher-level
API for allocating runtime objects and cleaning them back up. This article will focus on building the low-level bit that
will be built upon for more useful abstractions.

### Jump in the pool

First up, we need to prepare the memory pool and set up some book keeping globals (yeah I know, bad style but I'm just doing
this for learning so get off your high horse). Please don't see these code examples and use them in your project, I haven't
written any C since I finished my university degree 2 years ago so am likely commiting plenty of sins in the process of
sketching out this GC prototype.

```c
#define BLOCK_SIZE 1024

// Direct pointers to memory locations
void * mappingStartLocation;
void * mappingCurrentLocation;
void * allocStartLocation;
void * allocCurrentLocation;
void * allocEndLocation;

void gc_pool_init() {

  // Allocate space for management struct
  mappingStartLocation = sbrk(0);
  sbrk(50 * sizeof(bdescr));

  // Get the start address
  allocStartLocation = sbrk(0);

  // Allocate a chunk of memory
  sbrk(50 * BLOCK_SIZE);

  // Get the final address
  allocEndLocation = sbrk(0);

  mappingCurrentLocation = mappingStartLocation;
  allocCurrentLocation = allocStartLocation;
}
```

The `sbrk` system call will both return the current memory address and allocate more memory if you pass in an argument that is
greater than 0. This initialisation code basically allocates a chunk of memory for keeping bookkeeping info in and a larger
chunk of memory for allocating to blocks. As it does this it keeps track of a bunch of pointers that reference key locations
in the heap.

### Allocation

Next up we need to be able to allocate groups of blocks of memory on our heap.

```c
bdescr * alloc_group(int n) {
  bdescr * blk;

  // Keep a reference to the first block we're allocating
  bdescr * firstBlk = (bdescr *) mappingCurrentLocation;
  bdescr * prevBlk = firstBlk;

  for (int i = 0; i < n; i++) {

    // Create a mapping entry
    blk = (bdescr *) mappingCurrentLocation;
    mappingCurrentLocation += sizeof(bdescr);

    blk->allocated = true;

    // Point to the next free block of unallocated space
    blk->start = allocCurrentLocation;
    allocCurrentLocation += BLOCK_SIZE;

    // If not the first block in the group, link the previous one to this block
    if (mappingCurrentLocation != prevBlk) {
      prevBlk->link = blk;
    } else {
      prevBlk->link = NULL;
    }

    prevBlk = blk;
  }

  return firstBlk;
}
```

No huge surprises there I should think. We loop from 0 up to the number of blocks that are to be in the group and flag these blocks
as allocated, move the bookkeeping pointers along and link each block to the next one. It's important to note that the final block
in a group will have a `NULL` pointer instead of a link to the next block.

### Freedom for all

We're on the home stretch now, just freeing a group left. All we need to do is follow the chain of links and flick the allocated flag
to false.

```c
void free_group(bdescr *p) {
  bdescr * blk = p;

  while(blk->link != NULL) {
    blk->allocated = false;
    blk = blk->link;
  }
  blk->allocated = false;
}
```

One simplifaction I've used throughout all of this code is that the allocation only goes upwards, never looking back at previously allocated
groups. This is because I plan on using a garbage collection algorithm which moves all memory that is still in use to a fresh heap each time,
allowing the allocation to start over at the new high-water mark and grow all over again.

You can see the rest of the implementation including some debugging functions that print out the state
[here](https://github.com/jtfell/compiler-llvm/blob/master/lib/gc/lib.c).

