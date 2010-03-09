# **Rocco** is a Ruby port of [Docco][do], the quick-and-dirty,
# hundred-line-long, literate-programming-style documentation generator.
#
# Rocco reads Ruby source files and produces annotated source documentation
# in HTML format. Comments are formatted with [Markdown][md] and presented
# alongside syntax highlighted code so as to give an annotation effect.
# This page is the result of running Rocco against its own source file.
#
# Most of this was written while waiting for [node.js][no] to build (so I
# could use Docco!). Docco's gorgeous HTML and CSS are taken verbatim.
# The main difference is that Rocco is written in Ruby instead of
# [CoffeeScript][co] and may be a bit easier to obtain and install in
# existing Ruby environments or where node doesn't run yet.
#
# Rocco can be installed with rubygems:
#
#     gem install rocco
#
# Once installed, the `rocco` command can be used to generate documentation
# for a set of Ruby source files:
#
#     rocco lib/*.rb
#
# The HTML files are written to the current working directory.
#
# [no]: http://nodejs.org/
# [do]: http://jashkenas.github.com/docco/
# [co]: http://coffeescript.org/
# [md]: http://daringfireball.net/projects/markdown/

#### Prerequisites

# The [rdiscount](http://github.com/rtomayko/rdiscount) library is
# required for Markdown processing.
require 'rdiscount'

# We use [{{ mustache }}](http://defunkt.github.com/mustache/) for
# templating.
require 'mustache'

# Code is run through [Pygments](http://pygments.org/) for syntax
# highlighting. Fail fast if we can't find the `pygmentize` program.
if ! ENV['PATH'].split(':').any? { |dir| File.exist?("#{dir}/pygmentize") }
  fail "Pygments is required for syntax highlighting"
end

#### Public Interface

# `Rocco.new` takes a source `filename` and an optional `block`.
# When `block` is given, it must read the contents of the file using
# whatever means necessary and return it as a string. With no `block`, the
# file is read to retrieve data.
class Rocco
  def initialize(filename, &block)
    @file = filename
    @data =
      if block_given?
        yield
      else
        File.read(filename)
      end
    # Parsing and highlighting
    @sections = highlight(parse(@data))
  end

  # The filename as given to `Rocco.new`.
  attr_reader :file

  # A list of two-tuples representing each *section* of the source file. Each
  # item in the list has the form: `[docs_html, code_html]`, where both
  # elements are strings containing the documentation and source code HTML,
  # respectively.
  attr_reader :sections

  # Generate HTML output for the entire document.
  require 'rocco/layout'
  def to_html
    Rocco::Layout.new(self).render
  end

  #### Internal Parsing and Highlighting

  # Parse the raw file data into a list of two-tuples.
  def parse(data)
    sections = []
    docs, code = [], []
    data.split("\n").each do |line|
      case line
      when /^\s*#/
        if code.any?
          sections << [docs, code]
          docs, code = [], []
        end
        docs << line
      when /^\s*$/
        code << line
      else
        code << line
      end
    end
    sections << [docs, code] if docs.any? || code.any?
    sections
  end

  # Take the raw section data and apply markdown formatting and syntax
  # highlighting.
  def highlight(sections)
    # Start by splitting the docs and codes blocks into two separate lists.
    docs_blocks, code_blocks = [], []
    sections.each do |docs,code|
      docs_blocks << docs.map { |line| line.sub(/^\s*#\s?/, '') }.join("\n")
      code_blocks << code.join("\n")
    end

    # Combine all docs blocks into a single big markdown document and run
    # through RDiscount. Then split it back out into separate sections.
    markdown = docs_blocks.join("\n##### DIVIDER\n")
    docs_html = Markdown.new(markdown, :smart).
      to_html.
      split("\n<h5>DIVIDER</h5>\n")

    # Combine all code blocks into a single big stream and run through
    # pygments. We `popen` a pygmentize process and then fork off a
    # writer process.
    code_html = nil
    open("|pygmentize -l ruby -f html", 'r+') do |fd|
      fork {
        fd.close_read
        fd.write code_blocks.join("\n# DIVIDER\n")
        fd.close_write
        exit!
      }

      fd.close_write
      code_html = fd.read
      fd.close_read
    end

    # Do some post-processing on the pygments output to remove
    # partial `<pre>` blocks. We'll add these back when we build to main
    # document.
    code_html = code_html.
      split(/\n?<span class="c1"># DIVIDER<\/span>\n?/m).
      map { |code| code.sub(/\n?<div class="highlight"><pre>/m, '') }.
      map { |code| code.sub(/\n?<\/pre><\/div>\n/m, '') }

    # Combine the docs and code lists into the same sections style list we
    # started with.
    docs_html.zip(code_html)
  end
end
