CHANGES
=======

0.8 (2011-06-19)
----------------

https://github.com/rtomayko/rocco/compare/0.7...0.8

0.7 (2011-05-22)
----------------

https://github.com/rtomayko/rocco/compare/0.6...0.7

0.6 (2011-03-05)
----------------

This release brought to you almost entirely
by [mikewest](http://github.com/mikewest).

### Features

* Added `-t`/`--template` CLI option that allows you to specify a Mustache
  template that ought be used when rendering the final documentation.
  (Issue #16)

* More variables in templates:
  * `docs?`:    True if `docs` contains text of any sort, False if it's empty.
  * `code?`:    True if `code` contains text of any sort, False if it's empty.
  * `empty?`:   True if both `code` and `docs` are empty.  False otherwise.
  * `header?`:  True if `docs` contains _only_ a HTML header.  False otherwise.

* Test suite!  (Run `rake test`)

* Autodetect file's language if Pygments is installed locally (Issue #19)

* Autopopulate comment characters for known languages (Issue #20)

* Correctly parse block comments (Issue #22)

* Stripping encoding definitions from Ruby and Python files in the same
  way we strip shebang lines (Issue #21)

* Adjusting section IDs to contain descriptive test from headers.  A header
  section's ID might be `section-Header_text_goes_here` for friendlier URLs.
  Other section IDs will remain the same (`section-2` will stay
  `section-2`). (Issue #28)

### Bugs Fixed

* Docco's CSS changed: we updated Rocco's HTML accordingly, and pinned
  the CSS file to Docco's 0.3.0 tag.  (Issues #12 and #23)

* Fixed code highlighting for shell scripts (among others) (Issue #13)

* Fixed buggy regex for comment char stripping (Issue #15)

* Specifying UTF-8 encoding for Pygments (Issue #10)

* Extensionless file support (thanks to [Vasily Polovnyov][vast] for the
  fix!) (Issue #24)

* Fixing language support for Pygments webservice (Issue #11)

* The source jumplist now generates correctly relative URLs (Issue #26)

* Fixed an issue with using mustache's `template_path=` incorrectly.

[vast]: https://github.com/vast

0.5
---

Rocco 0.5 emerged from the hazy mists, complete and unfettered by history.
