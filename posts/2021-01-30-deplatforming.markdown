---
title: De-Platforming
---

In case you missed it, Parler got [de-platformed](https://techcrunch.com/2021/01/11/parler-is-officially-offline-after-aws-suspension/)
by AWS a little while back. I wonder if this will have an effect on the risk of vendor lock-in.
In my experience, the risk is usually identified then promptly ignored by engineers. For good reason;
it's a pain to migrate clouds and the chances of needing to is generally low.

Even if you have done a good job of isolating your code from the specifics of the cloud provider,
its going to cost you to pack up and move. Rebuilding the bulk of your devops and automation, relearning
a whole new set of service quirks and the migration itself are going to take a while even if you've done a
good job of keeping to open source tooling and services. God help you if you've got a proprietery
database or message queue in there somewhere.

That is when you have enough time to plan your move. Imagine your boss bringing you into their office and saying:

  _AWS is shutting off our account at midnight on Wednesday. I don't care where we migrate to but we need our core
  services to avoid downtime._

The dynamics influencing the risk of this actually happening are shifting a little at the moment. With the western
world polarising politically and big tech companies wading into the culture wars, the risk of being de-platformed
has become a bit more real. And you don't have to be the next Parler to be worried. Adding fuel to this fire is the
[standoff](https://www.abc.net.au/news/2021-01-28/accc-pursues-google-ad-dominance-facebook-tech-giants-news-code/13098804)
between Google and Facebook and the Australian Government over the mandatory bargaining code.

I sure hope no Murdoch media outlets are on Google Cloud Platform.
