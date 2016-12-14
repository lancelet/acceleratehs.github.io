Accelerate website
==================

[acceleratehs.github.io](https://acceleratehs.github.io)

## Instructions

  1. Install [pandoc](http://pandoc.org)

  1. For the main page content, edit the markdown files in directory `content/`

  1. Run `make` to generate the corresponding `.html` files.


## Viewing locally

Many of the intra-site links are relative to the web server root. This means
that the site needs to be accessible directly at `http://localhost`
(`127.0.0.1`) to be viewable locally.

To set this up, check out the website repo at the `DocumentRoot` listed at
`/etc/apache2/httpd.conf` (or similar), or edit that config to point to the
directory you checked the website repo out to instead.

This means that, for example, the stylesheet is always located at `/style.css`,
which is useful to know with the markdown &rarr; html template system we use.

