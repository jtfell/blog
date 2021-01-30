---
title: De-Platforming
---

Has the swift de-platforming of Parler by AWS added a new dimension to vendor lock-in risk?

Avoiding lock-in is seen as good practice to keep your options open for migrating cloud vendors.
In my experience though, its rarely high on the list of priorities for most companies. 

Even if you have done a good job of isolating your code from the specifics of the cloud provider,
its going to cost you to pack up and move. Rebuilding the bulk of your devops and automation, relearning
a whole new set of service quirks and the migration itself are going to take a while even if you've done a
good job of keeping to open source tooling and services. God help you if you've got a proprietery
database or message queue in there somewhere.

Just imagine getting a call from your boss saying she's been informed that AWS will be shutting off your
account at midnight on Wednesday and that any more than 48 hours of downtime is unacceptable.

The dynamics influencing this risk are shifting a little at the moment. With the western world polarising
politically and big tech companies wading into the culture wars, the risk of being de-platformed has become
a little more real. And you don't have to be the next Parler to be worried. Adding fuel to this fire is the
standoff between Google and Facebook and the Australian government over the mandatory bargaining code.

I sure hope no Murdoch media outlets are on Google Cloud Platform.
