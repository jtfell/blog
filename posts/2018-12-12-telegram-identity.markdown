---
title: Telegram Identity
---

When launching a new web app, the current set of options for handling authentication is highly
disappointing. It's basically a big tradeoff between privacy, streamlined signups and the
amount of work needed to implement your security. 

This is a huge issue as a signup page is one of the biggest hurdles for getting users to use your
service. Its the first thing they see!

So lets roll through the usual suspects if starting from scratch.

### Roll your own

The obvious option is to build a username/password/email/2FA system (or leverage something like auth0). This
comes with a huge amount of overhead:

 - Password resets
 - Email/Phone number verification
 - Salting/encrypting passwords
 - Implementing 2FA
 - Implementing signup/login pages

In addition to the extra work, you leave a huge surface area for bugs to cause your entire auth system to
be circumvented. Then pile on the number of users who will turn away at the first sign of needing to
generate another password and give away their email. Not a very appealling option.

### Facebook/Google OAuth

I will lump these ones together as they're both pretty ubiquitous. First the good parts:

 - Easy implementation (off the shelf in most languages)
 - Easy for users to sign up
 - Profile pic for free

That is where the positives end. It is harder and harder for me to stomach the amount of data that is
owned by these tech giants. I'm trying to use them less, not sign up to more services and tie my
identity to them further. Cross that off the list as well.

### Github/Gitlab/LinkedIn etc

There are other 3rd party auth services that are less scary to be tethered to, but they are generally
quite niche (eg. only developers have a github account). These will work well for something aimed at
users from their niche but are unworkable otherwise.

### Scratches head...

When I went through this list while building [Locationless](https://www.locationless.club), I couldn't believe
that all of the obvious options require a massive compromise where I least want one. From a user's perspective,
privacy should not be non-negotiable and frankly don't have enough confidence in myself to protect a full sign-up
system into perpetuity.

Okay I get it, you've read the title smart guy. What about [Telegram](https://telegram.org)?

There is actually a lot to like about using Telegram as an identity provider.

**Privacy** - Telegram is well-known to take security very seriously. They have offered bug bounties to
break their messanger encryption protocol and well as open-sourcing their client code.

**Business Model** - Their business model is very interesting and this impacts on how much I trust
them to not abuse their position. From their FAQs:


>  _We believe in fast and secure messaging that is also 100% free... making profits will
>  never be an end-goal for Telegram._


Basically, they have a big pile of money (and plans for a crypto venture) so the messanger part of their
business is not required to be a mine for data.

**Minimalist** - Profiles on Telegram (from a 3rd party perspective) only consist of a first name, last name,
an optional username and an optional profile picture. That's it. Less data, less trouble.

**Phone Number Vefification** - You need to verify your phone number to sign up for Telegram. That means
that everyone who signs up to your website has a verified phone number.

### It's not all sunshine and rainbows

There is a reason why most sites pick Google or Facebook as an OAuth provider; reach. Almost everyone
I know has at least one of these accounts so they can click one button and be signed up. Honestly, it's
a huge decision and I'm very likely knee-capping my website by not including these magical buttons.

But I'm taking a stand. A very small one, but hopefully one which paves the way for more people to make
the same decision. I want a future where I don't rely on Facebook or Google to sign into the services
that I use everyday so this is a small step in that direction.

I just hope most people who see value in my service can be bothered to sign up for Telegram. Let's see
what happens next.

Check out my sweet minimalist signup page at [Locationless](https://app.locationless.club).



