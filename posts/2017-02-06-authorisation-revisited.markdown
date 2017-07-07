---
title: Authorisation Revisited
---

## Authorisation Revisited

With the emergence of any new programming paradigm, there are opportunities
to take a fresh approach to old problems. Well established best-practices
can be improved upon with new tools and more information available to the
engaged developer.

The rise of REST APIs has been well documented, and as a consequence,their
authorisation has been given plenty of thought by some pretty smart people.
The big players have undoubtedly built bullet-proof authorisation strategies
to protect their services and users, but that’s not to say there aren’t ways
to do it better.

I have recently been building out my first GraphQL API using NodeJS and while
there is plenty of discussion on authentication methods, I struggled to find
any in-depth consideration of what to do once the user is authenticated. The
way I see it, there are some amazing new opportunities to take advantage of
in this space just waiting to be mined.

As I began to understand the high level structure of a GraphQL server, I wonder
how to avoid making a separate database request for every field in the schema.
I was not alone in this. I came across the brilliant 
[dataloader](https://github.com/facebook/dataloader) library from Facebook and
the way forward became clear. The genius at the heart of dataloader is
in how it leverages the structure of the resolver functions. It unlocks
improved performance through batching and cacheing database requests with
hardly any abstraction overhead.

I know cacheing your database requests isn’t something people get excited about
in 2017, but this hints at an important point. Changes to the established paradigm
can usher in new innovations in unexpected ways. Obviously GraphQL is a huge deal
for self-documentation, client/server decoupling and type safety, but that is just
the beginning. There are huge shifts in request heuristics, opportunities for pre-
analysing the query before deciding on an optimisation strategy and many other
critical changes for the average API server.

So let’s get to leveraging some of them for solving the problem of authorisation.
For starters, GraphQL queries will generally be larger and less frequent (per client)
than their REST counterpart. This allows us to optimise some of the heavy lifting
up front and build up an easy-to-access cache of the users permissions at the
start of the request. After this initial database hit, the individual authorisation
checks can be completed extremely quickly rather than having to visit the database
for each check. This optimisation is unlocked by the client sending a single
arbitrarily nested query rather than hitting a number of different endpoints to
cobble together the data required for their UI or action. Add the ability to pre-
nalyse the query for complexity (or even which parts of the schema are touched)
and you can have multiple optimisation strategies to gain maximum performance
for queries of any size and nature.

If you will excuse the shameless plug (you knew it was coming), my new library
[authorizr](https://github.com/jtfell/authorizr) attempts to enable some of
these optimisations. It’s in use on the new GraphQL project I’m working on and
has been a revelation in abstracting away the nitty gritty of permissions tables
etc and exposing a simple API.

This in turn makes the resolver functions easy to reason about. There are some
similarities with the philosophy of dataloader and for this reason the two
libraries play well together. But as with any new development, there are always
going to be new problems to solve.

The biggest killer of dreams so far has been the need for fresh data. Much like
with dataloader needing a loader.clear method to allow stale data to be flushed
from the cache, authorizr needs to be able to react to changes in permissions
and data. The best approach for this is less clear for an authorisation mechanism
with no constraints on the structure of application data than for a cacheing
mechanism. Finding a clean way of going about this is yet to materialise for me
but maybe someone smarter than me will have a game changing idea and submit a PR
for it (hint, hint).

Unsolved problems aside, there is much to be excited about in the GraphQL server
space!
