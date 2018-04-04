---
title: API Design for Pragmatists
---

Over the course of a few years building web apps, I've come across (and built) some subpar REST APIs. There are plenty of surefire
ways to design an API that will cause headaches for users and maintainers alike so it is in everyone's best interest to lend a hand. Consider
this list an investment in the welbeing of the internet at large.

### Explicit date and time handling

Dates and timezones have caused the most bugs of anything in my experience of API design. Whoever decided how modern timezones work has
a lot to answer for and you don't want to make the situation any worse. Make sure that all dates are validated and only accept a pre-defined
set of date formats (I suggest ISO formats with explicit timezones) so that there is no ambiguity about what timezone you are dealing with.
Don't forget that browsers default to using local times in many situations, so forgetting to send a timezone will result in the API interpretting
the time incorrectly.

### JSON Schema validation for all POST/PUTs

JSON schema is the perfect solution for protecting yourself from trash data. Taking the time to properly define the expected structure of inputs
will pay dividends almost immediately as your controllers no longer have to be written defensively. From useful error messages
to documentation generation, the benefits are huge and there are validation libraries for all mainstream languages. Just do this one.

### Most granular/locked down DB schema possible

I won't hesitate to admit I'm a traditionalist when it comes to databases. The consistency and data integrity you can achieve purely through
a strict SQL schema will ALWAYS be worth the initial effort of defining it. My advice is to explicitly encode every property, relationship
and restriction into your schema as this will make the database reject invalid data and also give engineers a single place to go to understand
your data model.

### Use well-understood persistence tech (postgres / redis) unless demonstrated need for specific features/performance

Closely related to the previous point, I would always recommend using a well-understood database. A single Postgres instance can scale a pretty
long way if you don't write pathological queries and will be straightforward operationally. Think about how easy it is it backup, restore from
failure, debug errors and investigate performance issues when the internet is full of experts who have already seen your exact problem before.

### Prefixed logging

Logging can be difficult to get right as you need to find a balance between filling your logs with garbage and missing out critical data for
debugging. My advice is to prefix the logs with information about the service or model that they correspond to. This will allow you to err
on the side of too much logging and still allow you to find the data you are looking for.

### Consider pagination early

Maybe this one is an obvious one but it is worth mentioning as I've been bitten by this more times than I'd like to admit. If an endpoint returns
a list of something, you WILL need pagination at some point (unless its a fixed list). To avoid a breaking change later on, always return a length
field (the number of results in the full set) and return a reasonable number of results by default along with optional pagination controls.

### Don't be too cute with deletes

It is very common advice to flip a `deleted` or `archived` flag on database entries when they are deleted, rather than actually deleting the
row. I get why this is seems like a good idea; you can restore any accidentally deleted records as easily as they are deleted because
nothing is ever actually deleted. Okay sure, that is a useful property, but let's think about the consequences of this choice. Everytime you
want to interact with that table, you now have to check that field to see if it is still meant to exist! My advice is to copy deleted data
to a second table and then actually delete it from the main one. This requires a little data juggling for delete operations but will greatly
simplify the rest of your app.

### Careful with PII

This is particularly topical at the moment with GDPR coming into effect and a number of high-profile data breaches dominating the tech headlines.
Whenever collecting personal information from users, stop and ask yourself whether you really need it! If you don't absolutely need it for your
core business then it's probably not worth the hassle. If you definitely need it, go and read [this](https://gdpr-info.eu/). Then read it again.
Then finally design your handling of that data to be compliant from the outset, with the ability for users to fully delete themselves from your
system in your very first release.

### Take devops seriously

How long has it been since you tried restoring your system from a database or deployment failure? If you are embarressed by your answer then
it's not too late! Carve out some time for making sure your deployments are replicable (infrastructure as code is helpful here) and that you have
an up-to-date strategy for restoring from your latest database backup (you have backups right?).

### Standardised error messages with codes

Consumers of your API will thank you a million times over if you send back useful error messages for incorrect usage. Just including a
unique error code (with a reference in your public docs) is a great start.

