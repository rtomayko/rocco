# **Rocco** is a Ruby port of [Docco][do], the quick-and-dirty,
# hundred-line-long, literate-programming-style documentation generator.
#
# Rocco reads Ruby source files and produces annotated source documentation
# in HTML format. Comments are formatted with [Markdown][md] and presented
# alongside syntax highlighted code so as to give an annotation effect.
# This page is the result of running Rocco against [its own source file][so].
#
# Most of this was written while waiting for [node.js][no] to build (so I
# could use Docco!). Docco's gorgeous HTML and CSS are taken verbatim.
# The main difference is that Rocco is written in Ruby instead of
# [CoffeeScript][co] and may be a bit easier to obtain and install in
# existing Ruby environments or where node doesn't run yet.
#
# Install Rocco with Rubygems:
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
# [so]: http://github.com/rtomayko/rocco/blob/master/lib/rocco.rb#commit

#### Prerequisites

# We'll need a Markdown library. [RDiscount][rd], if we're lucky. Otherwise,
# issue a warning and fall back on using BlueCloth.
#
# [rd]: http://github.com/rtomayko/rdiscount
begin
  require 'rdiscount'
rescue LoadError => boom
  warn "warn: #{boom}. trying bluecloth"
  require 'bluecloth'
  Markdown = BlueCloth
end

# We use [{{ mustache }}](http://defunkt.github.com/mustache/) for
# HTML templating.
require 'mustache'

# We use `Net::HTTP` to highlight code via <http://pygments.appspot.com>
require 'net/http'

#### Public Interface

# `Rocco.new` takes a source `filename`, an optional list of source filenames
# for other documentation sources, an `options` hash, and an optional `block`.
# The `options` hash respects two members: `:language`, which specifies which
# Pygments lexer to use; and `:comment_chars`, which specifies the comment
# characters of the target language. The options default to `'ruby'` and `'#'`,
# respectively.
# When `block` is given, it must read the contents of the file using whatever
# means necessary and return it as a string. With no `block`, the file is read
# to retrieve data.
class Rocco
  VERSION = '0.4'

  def initialize(filename, sources=[], options={}, &block)
    @file = filename
    @data =
      if block_given?
        yield
      else
        File.read(filename)
      end
    defaults = {
      :language      => 'ruby',
      :comment_chars => '#',
      :webservice    => false
    }
    @options = defaults.merge(options)
    @sources = sources
    @comment_pattern = Regexp.new("^\\s*#{@options[:comment_chars]}")
    @sections = highlight(split(parse(@data)))
  end

  # The filename as given to `Rocco.new`.
  attr_reader :file

  # A list of two-tuples representing each *section* of the source file. Each
  # item in the list has the form: `[docs_html, code_html]`, where both
  # elements are strings containing the documentation and source code HTML,
  # respectively.
  attr_reader :sections

  # A list of all source filenames included in the documentation set. Useful
  # for building an index of other files.
  attr_reader :sources

  # Generate HTML output for the entire document.
  require 'rocco/layout'
  def to_html
    Rocco::Layout.new(self).render
  end

  #### Internal Parsing and Highlighting

  # Parse the raw file data into a list of two-tuples. Each tuple has the
  # form `[docs, code]` where both elements are arrays containing the
  # raw lines parsed from the input file. The first line is ignored if it
  # is a shebang line.
  def parse(data)
    sections = []
    docs, code = [], []
    lines = data.split("\n")
    lines.shift if lines[0] =~ /^\#\!/
    lines.each do |line|
      case line
      when @comment_pattern
        if code.any?
          sections << [docs, code]
          docs, code = [], []
        end
        docs << line
      else
        code << line
      end
    end
    sections << [docs, code] if docs.any? || code.any?
    sections
  end

  # Take the list of paired *sections* two-tuples and split into two
  # separate lists: one holding the comments with leaders removed and
  # one with the code blocks.
  def split(sections)
    docs_blocks, code_blocks = [], []
    sections.each do |docs,code|
      docs_blocks << docs.map { |line| line.sub(@comment_pattern, '') }.join("\n")
      code_blocks << code.map do |line|
        tabs = line.match(/^(\t+)/)
        tabs ? line.sub(/^\t+/, '  ' * tabs.captures[0].length) : line
      end.join("\n")
    end
    [docs_blocks, code_blocks]
  end

  # Take the result of `split` and apply Markdown formatting to comments and
  # syntax highlighting to source code.
  def highlight(blocks)
    docs_blocks, code_blocks = blocks

    # Combine all docs blocks into a single big markdown document with section
    # dividers and run through the Markdown processor. Then split it back out
    # into separate sections.
    markdown = docs_blocks.join("\n\n##### DIVIDER\n\n")
    docs_html = Markdown.new(markdown, :smart).
      to_html.
      split(/\n*<h5>DIVIDER<\/h5>\n*/m)

    # Combine all code blocks into a single big stream and run through either
    # `pygmentize(1)` or <http://pygments.appspot.com>
    code_stream = code_blocks.join("\n\n# DIVIDER\n\n")

    code_html =
      if @options[:webservice]
        highlight_webservice(code_stream)
      else
        highlight_pygmentize(code_stream)
      end

    # Do some post-processing on the pygments output to split things back
    # into sections and remove partial `<pre>` blocks.
    code_html = code_html.
      split(/\n*<span class="c1"># DIVIDER<\/span>\n*/m).
      map { |code| code.sub(/\n?<div class="highlight"><pre>/m, '') }.
      map { |code| code.sub(/\n?<\/pre><\/div>\n/m, '') }

    # Lastly, combine the docs and code lists back into a list of two-tuples.
    docs_html.zip(code_html)
  end

  # We `popen` a read/write pygmentize process in the parent and
  # then fork off a child process to write the input.
  def highlight_pygmentize(code)
    code_html = nil
    open("|pygmentize -l #{@options[:language]} -f html", 'r+') do |fd|
      pid =
        fork {
          fd.close_read
          fd.write code
          fd.close_write
          exit!
        }
      fd.close_write
      code_html = fd.read
      fd.close_read
      Process.wait(pid)
    end

    code_html
  end

  def highlight_webservice(code)
    Net::HTTP.post_form(
      URI.parse('http://pygments.appspot.com/'),
      {'lang' => 'ruby', 'code' => code}
    ).body
  end
end

# And that's it.
