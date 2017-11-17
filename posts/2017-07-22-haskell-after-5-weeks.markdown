---
title: Haskell After 5 Weeks
---

Before starting to learn Haskell, I had some preconcieved notions of its strengths
and limitations. They turned out to be mostly right for the strengths but the
limitations turned out to actually be strengths in a way that was thoroughly
surprising to me. Limitations certainly exist, just not where I thought they did.

My path to Haskell enlightenment was slightly roundabout, as I tackled a heavily
functional CS topic for my thesis (reasoning about concurrent programs using the
Isabelle/HOL theorem prover), but never took the plunge to write everyday code
in a functional language. After uni, I got an exciting job as a web developer
and jumped between shiny javascript libraries that seemed like the future of
computing itself. It took one too many 

```cannot access "map" of undefined ```

errors for me to look for a way out. People talk about callback hell with
javascript but for me it was type system hell. There surely has to be a point
when you just can't write any more null checks. At an emotional level, I mean.

I think the best way to discuss the things that have surprised me most about
Haskell is to consider it in the light of a single consideration:

*As a web developer, how could I justify the use of Haskell rather than Nodejs
for my day job?*

Before learning Haskell in any depth, I would have struggled to articulate any
points aside from how much easier it would be to reason about and compose programs.
Sure this is an important property of a language, but in a small team building
webservices it isn't going to convince anyone.

At the top of my list of imagined counterpoints was that the webservices we are
writing were heavily asynchronous and didn't do a whole lot of CPU bound tasks
outside of the analytics subsystem. Despite the problems with javascript itself,
Nodejs is an excellent choice for the kind of code we are writing. Even more so
with ES6/7 and typescript available. What I didn't know was that event-loops are
a non-optimal way of dealing with concurrency especially when compared to green
threads [this article](https://www.fpcomplete.com/blog/2017/01/green-threads-are-like-garbage-collection)
explains this point far better than I can. Even when considering that the pre-fork
method can get around some of its shortcomings in relation to single-threadedness,
testability and readability still suffer.

Ultimately though, for me it comes down to the ability to write your applications as
a thin, impure shell of sequenced IO actions around a set of pure, reusable and easy
to test libraries. This is a hard one to explain to people who haven't tried it for
themselves. This leads pretty well into my next thought on the topic.

There are two big arguments for why Haskell would not be the right choice for the team
I work with that do hold up. Firstly, hiring Haskell developers is more difficult than
Nodejs developers. That is an unescapable fact. Secondly, existing team members will
have to spend some time learning Haskell and may be resistant to the idea of having
to reskill like that. They are undoubtedly more social and technical issues, but often
the social ones are the hardest to solve. 

From my sample size of one, I feel pretty strongly that these social issues are just
that. More to do with perception than the reality of the tools being compared. Consider
this. After 5 weeks of learning Haskell in my own time with the internet as my only
resource, I was able to write a reasonably functional [reverse HTTP proxy](https://github.com/jtfell/haskell-http-proxy)
using no HTTP-specific dependencies. I'm still an absolute novice at Haskell, but the
power of the language helped me to achieve something I doubt I could do with a language
I know back to front in even 4x as much code. Admittedly, it is a problem space that I'm
reasonably familiar with and I have used an ML-like language in the past, but the point
is that monadic IO and applicative parsers are not at all out of reach for solving
real problems.
