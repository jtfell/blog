---
title: Serverless Supercookies
---

## Serverless Supercookies

Browser privacy has been getting a lot of attention lately. It’sgetting
harder and harder to navigate the web without leaking personal data to
the gremlins lurking in the dark corners or your favourite website.

In some ways Safari leads the way in protecting user privacy through their
default disabling of third-party cookies, while it has to be explicitly
activated in Chrome and Firefox. The feature I’m interested in amongst
the complex and is that choosing this setting causes the browser to
sandbox all storage within each domain so you can identify a returning
user to your site, but not who they are when they show up again elsewhere.
This presents an issue for the people who want to track your online
behaviour so they can show you ads for things that you might buy.

The ability get around this little roadblock is extremely valuable to
advertisers and analytics vendors as it offers a competitive edge in
a saturated market. Naturally, when the straightforward methods of
identifying users are blocked, they get their developers to turn to more
creative methods.

Fingerprinting is an option, but is well known to be ineffective on
homogenous iPhones on 3G connections. Imagine 30 people on the latest iOS,
with the latest iPhone on the same train to work in the morning.
Fingerprinting is essentially useless for telling them apart thanks
to the minimal customisation available.

Okay, so the conventional browser storage methods are sandboxed and the
devices themselves aren’t individual enough to be reliably differentiated.
Where to from here? As you may have guessed from the title, the answer is
to hacks involving HTTPS protocols of course!

A bit of background; the protocol we will be exploiting is the HTTP Strict
Transport Security (HSTS) protocol. The idea of this protocol is that a server
can send back a header instructing the browser to access its domain via https
next time it is visited, even requests the http version. In this scenario, the
browser reacts with a 307 (internal redirect) when it sees that it has
received this header from the domain in the past.

On the surface this sounds great. It will help people to avoid visiting sites
with sensitive information over an unencrypted connection by accident. Terrific.
The sticky part is that because this information is cached in the browser, it
can be repurposed.

There are multiple ways to take advantage of this cache for user identification
(see here for a more in-depth discussion), but the naive way to achieve it is to
have lots of domains with an endpoint that simply returns an empty response with
the HSTS header set and fails to respond at all over http. For this example, lets
assume we own the domain sneaky-hsts.com and have set up `0.sneaky-hsts.com/api`,
`1.sneaky-hsts.com/api`... `7.sneaky-hsts.com/api` with this behaviour.

![HSTS Exploit Architecture](/images/architecture.png)

On the client we generate a hexadecimal user ID (lets use `4F`). With other methods
we would just store this in a third-party cookie or local-storage cross-domain
iframe so we could pluck it out later. In this case we convert it to binary
(`01001111`) and each bit represents one of our 8 domains. If a bit is a 1, we
send a request to https://n.sneaky-hsts.com/api and if its a 0 we don’t.

Next time this device loads our script it can now attempt to load the http version
of each of our domains. The domains that were connected to earlier will be
accessed via https (because of our HSTS cache) and the others will fail to connect
as our servers won’t respond to HTTP requests. Based on the successful requests
and unsuccessful requests, we can now reconstruct our user ID. Failed requests
are zeros and successful requests are ones.

### Doing it for reals

Phew, that was a super quick rundown on the mechanics on this method for
identifying users across multiple domains. Let’s get to using AWS Lambda
for a real-life implementation using the serverless infrastructure of
the future!

The first step is to setup a wildcard SSL certificate using Certificate
Manager for `*.sneaky-hsts.com`. Next, we need a single lambda function
that returns a max-age value for my HSTS header.

```js
exports.handler = (event, context, callback) => {
  callback(null, {
    hsts: 'max-age=31536000'
  });
};
```

The key that is returned isn't special in itself, but we can easily map it
to the response headers through API Gateway. It allows us to route HTTP
requests to the lambda function. It needs to be configured to map max-age
to the correct header and to allow lenient CORS headers.

![API Gateway Headers](/images/headers.png)

Annoyingly, API Gateway doesn’t work with wildcard custom domains (but still
allows you to enter them into the console) so I had to configure a custom
domain for every. individual. domain. Go on, get clicking (note the 0, 1
and 2 subdomains in the screenshot).

![API Gateway Routing](/images/routes.png)

Finally, Route53 can route each subdomain to the corresponding Cloudfront
distribution from API Gateway. The fruits of our configuration labour
should now look something like this, with our poor little friend being tracked
out in front.

![HSTS Exploit Architecture](/images/serverless-supercookes/architecture.png)

Essentially, Cloudfront is pretending to be lots of domains so we can store
lots of bits in the browsers HSTS cache (1 bit per domain). Now that we have
the infrastructure we need to store our user IDs, all we need is the client
code to expose a cross-domain ID store to our javascript tag.

First, we need a few helper functions to generate IDs and convert between hex and
binary representation. Note that I'm using 4 bit IDs for brevity but this approach
can be easily extended to more bits.

```js
function genId() {
  return Math.floor((1 + Math.random()) * 0x10000)
    .toString(16)
    .substring(1);
}

function bin2hex(num) {
  return parseInt(num, 2).toString(4);
}

function hex2bin(num) {
  return parseInt(num, 4).toString(2);
}
```

Next we can define some functions for setting and checking bits against the server
we have setup.

```js
var $ = require('jquery');
var DOMAIN = 'example-domain.com';

/**
 * Request the http version of the subdomain, and if the request is successful it
 * means we it has HSTS cache set (encoded as a 1). If its unsuccessful, it doesn't
 * have the HSTS cache set (encdoed as a 0).
 */
function checkBit(bit, cb) {
  $.get('http://' + bit + '.' + DOMAIN)
    .done(function () { cb(1); })
    .fail(function () { cb(0); });
}

/**
 * Request the https version of the subdomain for every 1 in the id. This will set
 * the HSTS cache.
 */
function setBit(binId, bit) {
  if (binId.charAt(bit) === '1') {
    $.ajax('https://' + bit + '.' + DOMAIN);
  }
}
```

Finally we can define some (very primitive) functions for setting and getting IDs
purely through the HSTS cache. These could be defined more elegantly but they clearly
show how it all works.

```
function getId(cb) {
  checkBit(0, function (bit0) {
    checkBit(1, function (bit1) {
      checkBit(2, function (bit2) {
        checkBit(3, function (bit3) {
          var binId = [bit0, bit1, bit2, bit3].join('');
          cb(bin2hex(binId));
        });
      });
    });
  });
}

function setId() {

  // Generate a fresh ID
  var id = guid();
  var binId = guid2bin(id);

  // Set the _supercookie_ using our lambda HSTS magic
  for (var i = 0; i < binId.length; i++) {
    setBit(binId, i);
  }

  // Return the original HEX ID
  return id;
}
```

As we can only store a limited number of bits with this method, doing anything
useful with this identification would involve saving these IDs serverside
along with the information you can glean from their activity across the web.

### Not so fast..

It is important that the ethical implications of purposely circumventing user
privacy settings aren’t missed in the haze of new shiny things. This is a
particularly crafty way of getting the information that advertisers want
and uses bleeding edge tech to accomplish it easily, but it is still an
invasion of user privacy. It is actively circumventing the security settings
enforced by the user’s choice of browser. Visibility on privacy and security
issues need to be made public so that users are equipped to protect themselves
from them, so hopefully reading this will have made something think a little
harder about the part they play in this. User or developer, like it or this
applies to us all.

