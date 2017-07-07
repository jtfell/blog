---
title: How Pretty Is Your CSS?
---

## How Pretty Is Your CSS

There are already a few apps out there that analyse stylesheets (my
favourite is cssstats.com), but they’re focused on how well structured
the code is. Sure it’s nice to know how maintainable your CSS is, but
I want more; I want to know how pretty it will make my page. I mean, 
thats the end game isn’t it?


The aesthetic quality of a page is governed by mathematical rules. These
rules can be harnessed to improve your page layouts even if you have minimal
design experience or intuition (me). I’m proposing that we try to compare
how well certain CSS frameworks adhere to some of the basic rules of design.
Of course, there are far too many subtleties in how CSS declarations make a
page look and feel to confidently say one layout is better than another
based off some arbitrary metrics, but I’m down for a challenge and the
insights it will bring.


To pick a one rule out of a sea of options, let’s tackle validating modular
scales (every font size on a page should be related by a single ratio). Let’s
decide on a scope up front to keep this achievable.

- Only analyse plain CSS (no SASS or LESS)
- Values using em units aren’t nested (so they behave the same as rem)
- All declarations are in use

From this we will calculate:

- Whether the font-size declarations use a modular scale
- What the ratio is (if it exists)

### Working Backwards
Over at type-scale.com you can pick a base and ratio, and get back a nice little
CSS snippet. This will do nicely as a test-case to see if we can work backwards
to the values used as an input. I fired it up with a base size of 1em and ratio
of 1.5 to keep things simple and got this little snippet back.

```css
html {font-size: 1em;}

body {
  background-color: white;
  font-family: 'Roboto', serif;
  font-weight: 600;
  line-height: 1.45;
  color: #333;
}

p {margin-bottom: 1.3em;}

h1, h2, h3, h4 {
  margin: 1.414em 0 0.5em;
  font-weight: inherit;
  line-height: 1.2;
}

h1 {
  margin-top: 0;
  font-size: 5.063em;
}

h2 {font-size: 3.375em;}

h3 {font-size: 2.25em;}

h4 {font-size: 1.5em;}

small, .font_small {font-size: 0.667em;}
```

### Sketching A Solution
Ok, down to business. I’m going to use PostCSS because it’s trendy and
because the AST it exposes will make getting at the declarations nice and
easy (but mainly because it’s trendy). Let’s install it.

```npm i postcss --save```

Okay, now we’re set up and need a skeleton for doing the analysis.

```js
var postcss = require('postcss');

module.exports = function(css) {
  var root = postcss.parse(css);

  // 1. Parse the AST and collect all font-size declarations
  var properties = findFontSizeDecl(root);

  // 2. Calculate the ratio used and the quality of the fit
  var results = calculateRatio(properties);
  
  console.log(results);
};
```

Note the two major steps to be filled in, findFontSizeDecl and calculateRatio.
Let’s kick it off with step 1. We’re just pulling out all the font-size
declarations out of the CSS and making a list of relative values. I’ve made
some serious simplifications here as calculating the pixel height of em is
way out of the scope of this experiment.

```js
function findFontSizeDecl(root) {
  var vals = [];

  // Iterate over font-size declarations
  root.walkDecls(/font-size/, function(decl) {
    vals.push(convertToEm(decl.value));
  });

  return vals;
};

var ROOT_FONT_SIZE = 16;
function convertToEm(value) {
  if (value == 0) return 0;
  if (value.indexOf('rem') > 0) {
    return parseFloat(value.slice(0, -3));
  }
  if (value.indexOf('em') > 0) {
    return parseFloat(value.slice(0, -2));
  }
  if (value.indexOf('px') > 0) {
    var pixels = parseFloat(value.slice(0, -2));
    return pixels/ROOT_FONT_SIZE;
  }
  // Skip declarations of inherits, initial
  console.log('Skipping: ', value);
}
```

No sweat, on to Step 2. As we are assuming that the font-sizes will have a
constant ratio, we can use exponential regression. The algorithm for this
is all over the internet so I won’t bore you with it, but the code I’m
using is here. Applying the algorithm is very straightforward.

```js
function calculateRatio(xs) {
  var uniqueSizes = xs.sort().filter(onlyUnique);
  return exponentialRegression(uniqueSizes);
}

function onlyUnique(value, index, self) {
  return self.indexOf(value) === index;
}
```

Now the core of the analysis is ready to go, all we need is to set up a test harness.

```js
var fs = require('fs');
var analyse = require('../src/index.js');

var css = fs.readFileSync('./test/basic.css', 'utf8');
analyse(css);

// Prints:
// { ratio: 1.4999140493583407, fit: 0.9999999752384222 }
```

As promised, we get back the ratio we started with and a “fit” value close
to one. So far, so good. The true test will be analysing some real CSS
frameworks though.

```
Basscss:    ratio: 1.212, fit: 0.9921
Foundation: ratio: 1.097, fit: 0.9821
Bootstrap:  ratio: 1.121, fit: 0.9653
Pure:       ratio: 1.360, fit: 0.9170
```

Does this mean that Foundation is better than Bootstrap? You be the judge.
It would be a little hasty to draw too many conclusions from these results
without looking deeper into why certain frameworks do not strictly follow
modular scales. Undoubtedly there are good reasons, edge cases or stylistic
preferences. All I know is that I want to know what these are if I’m going
to commit to them for a new project. If nothing else, finding answers to
these questions might lend some insight into how to get the most out of 
your framework of choice.

That’s all I have for now, you can take a look at my code here. I’d love to
hear from anyone going down a similar path!
