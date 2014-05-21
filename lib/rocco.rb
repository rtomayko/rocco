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
require 'rocco/code_segmenter'

# We'll need a Markdown library. Try to load one if not already established.
unless defined?(Markdown)
  markdown_libraries = %w[redcarpet rdiscount bluecloth]
  begin
    require markdown_libraries.shift
  rescue LoadError => boom
    retry if markdown_libraries.any?
    raise
  end
end

# We use [{{ mustache }}](http://defunkt.github.com/mustache/) for
# HTML templating.
require 'mustache'

# We use `Net::HTTP` to highlight code via <http://pygments.appspot.com>
require 'net/http'

# Code is run through [Pygments](http://pygments.org/) for syntax
# highlighting. If it's not installed, locally, use a webservice.
unless ENV['PATH'].split(':').any? { |dir| File.executable?("#{dir}/pygmentize") }
  warn "WARNING: Pygments not found. Using webservice."
end

#### Public Interface

# `Rocco.new` takes a source `filename`, an optional list of source filenames
# for other documentation sources, an `options` hash, and an optional `block`.
# The `options` hash respects three members:
#
# * `:language`: specifies which Pygments lexer to use if one can't be
#   auto-detected from the filename.  _Defaults to `ruby`_.
#
# * `:comment_chars`, which specifies the comment characters of the
#   target language. _Defaults to `#`_.
#
# * `:template_file`, which specifies a external template file to use
#   when rendering the final, highlighted file via Mustache.  _Defaults
#   to `nil` (that is, Mustache will use `./lib/rocco/layout.mustache`)_.
#
# * `:stylesheet`, which specifies the css stylesheet to use for each
#   rendered template.  _Defaults to `http://jashkenas.github.com/docco/resources/docco.css`
#   (the original docco stylesheet)
class Rocco
  VERSION = '0.8.2'

  def initialize(filename, sources=[], options={})
    @file       = filename
    @sources    = sources

    # When `block` is given, it must read the contents of the file using
    # whatever means necessary and return it as a string. With no `block`,
    # the file is read to retrieve data.
    @data = if block_given? then yield else File.read(filename) end

    @options =  {
      :language      => 'rb',
      :comment_chars => '#',
      :template_file => nil,
      :stylesheet    => 'http://jashkenas.github.io/docco/resources/linear/docco.css'
    }.merge(options)

    # If we detect a language
    if "text" != detect_language
      # then assign the detected language to `:language`, and look for
      # comment characters based on that language
      @options[:language] = detect_language
      @options[:comment_chars] = generate_comment_chars

    # If we didn't detect a language, but the user provided one, use it
    # to look around for comment characters to override the default.
    elsif options[:language]
      @options[:comment_chars] = generate_comment_chars

    # If neither is true, then convert the default comment character string
    # into the comment_char syntax (we'll discuss that syntax in detail when
    # we get to `generate_comment_chars()` in a moment.
    else
      @options[:comment_chars] = { :single => @options[:comment_chars], :multi => nil }
    end

    # Turn `:comment_chars` into a regex matching a series of spaces, the
    # `:comment_chars` string, and the an optional space.  We'll use that
    # to detect single-line comments.
    @comment_pattern = Regexp.new("^\\s*#{@options[:comment_chars][:single]}\s?")

    # `parse()` the file contents stored in `@data`.  Run the result through
    # `split()` and that result through `highlight()` to generate the final
    # section list.
    code_segments = CodeSegmenter.new(@options).segment(@data)
    @sections = highlight(split(code_segments))
  end

  # The filename as given to `Rocco.new`.
  attr_reader :file

  # The merged options array
  attr_reader :options

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
    Rocco::Layout.new(self, @options[:stylesheet], @options[:template_file]).render
  end

  # Helper Functions
  # ----------------

  # Returns `true` if `pygmentize` is available locally, `false` otherwise.
  def pygmentize?
    @_pygmentize ||= ENV['PATH'].split(':').
      any? { |dir| File.executable?("#{dir}/pygmentize") }
  end

  # If `pygmentize` is available, we can use it to autodetect a file's
  # language based on its filename.  Filenames without extensions, or with
  # extensions that `pygmentize` doesn't understand will return `text`.
  # We'll also return `text` if `pygmentize` isn't available.
  #
  # We'll memoize the result, as we'll call this a few times.
  def detect_language
    @_language ||=
      if pygmentize?
        %x[pygmentize -N #{@file}].strip.split('+').first
      else
        "text"
      end
  end

  # Given a file's language, we should be able to autopopulate the
  # `comment_chars` variables for single-line comments.  If we don't
  # have comment characters on record for a given language, we'll
  # use the user-provided `:comment_char` option (which defaults to
  # `#`).
  #
  # Comment characters are listed as:
  #
  #     { :single       => "//",
  #       :multi_start  => "/**",
  #       :multi_middle => "*",
  #       :multi_end    => "*/" }
  #
  # `:single` denotes the leading character of a single-line comment.
  # `:multi_start` denotes the string that should appear alone on a
  # line of code to begin a block of documentation.  `:multi_middle`
  # denotes the leading character of block comment content, and
  # `:multi_end` is the string that ought appear alone on a line to
  # close a block of documentation.  That is:
  #
  #     /**                 [:multi][:start]
  #      *                  [:multi][:middle]
  #      ...
  #      *                  [:multi][:middle]
  #      */                 [:multi][:end]
  #
  # If a language only has one type of comment, the missing type
  # should be assigned `nil`.
  #
  # At the moment, we're only returning `:single`.  Consider this
  # groundwork for block comment parsing.
  require 'rocco/comment_styles'
  include CommentStyles

  def generate_comment_chars
    @_commentchar ||=
      if COMMENT_STYLES[@options[:language]]
        COMMENT_STYLES[@options[:language]]
      else
        { :single => @options[:comment_chars], :multi => nil, :heredoc => nil }
      end
  end

  # Take the list of paired *sections* two-tuples and split into two
  # separate lists: one holding the comments with leaders removed and
  # one with the code blocks.
  def split(sections)
    docs_blocks, code_blocks = [], []
    sections.each do |docs,code|
      docs_blocks << docs.join("\n")
      code_blocks << code.map do |line|
        tabs = line.match(/^(\t+)/)
        tabs ? line.sub(/^\t+/, '  ' * tabs.captures[0].length) : line
      end.join("\n")
    end
    [docs_blocks, code_blocks]
  end

  # Take a list of block comments and convert Docblock @annotations to
  # Markdown syntax.
  def docblock(docs)
    docs.map do |doc|
      doc.split("\n").map do |line|
        line.match(/^@\w+/) ? line.sub(/^@(\w+)\s+/, '> **\1** ')+"  " : line
      end.join("\n")
    end
  end

  # Take the result of `split` and apply Markdown formatting to comments and
  # syntax highlighting to source code.
  def highlight(blocks)
    docs_blocks, code_blocks = blocks

    # Pre-process Docblock @annotations.
    docs_blocks = docblock(docs_blocks) if @options[:docblocks]

    # Combine all docs blocks into a single big markdown document with section
    # dividers and run through the Markdown processor. Then split it back out
    # into separate sections.
    markdown = docs_blocks.join("\n\n##### DIVIDER\n\n")
    docs_html = process_markdown(markdown).split(/\n*<h5>DIVIDER<\/h5>\n*/m)

    # Combine all code blocks into a single big stream with section dividers and
    # run through either `pygmentize(1)` or <http://pygments.appspot.com>
    span, espan = '<span class="c.?">', '</span>'
    if @options[:comment_chars][:single]
      front = @options[:comment_chars][:single]
      divider_input  = "\n\n#{front} DIVIDER\n\n"
      divider_output = Regexp.new(
        [ "\\n*",
          span,
          Regexp.escape(CGI.escapeHTML(front)),
          ' DIVIDER',
          espan,
          "\\n*"
        ].join, Regexp::MULTILINE
      )
    else
      front = @options[:comment_chars][:multi][:start]
      back  = @options[:comment_chars][:multi][:end]
      divider_input  = "\n\n#{front}\nDIVIDER\n#{back}\n\n"
      divider_output = Regexp.new(
        [ "\\n*",
          span, Regexp.escape(CGI.escapeHTML(front)), espan,
          "\\n",
          span, "DIVIDER", espan,
          "\\n",
          span, Regexp.escape(CGI.escapeHTML(back)), espan,
          "\\n*"
        ].join, Regexp::MULTILINE
      )
    end

    code_stream = code_blocks.join(divider_input)

    code_html =
      if pygmentize?
        highlight_pygmentize(code_stream)
      else
        highlight_webservice(code_stream)
      end

    # Do some post-processing on the pygments output to split things back
    # into sections and remove partial `<pre>` blocks.
    code_html = code_html.
      split(divider_output).
      map { |code| code.sub(/\n?<div class="highlight"><pre>/m, '') }.
      map { |code| code.sub(/\n?<\/pre><\/div>\n/m, '') }

    # Lastly, combine the docs and code lists back into a list of two-tuples.
    docs_html.zip(code_html)
  end

  # Convert Markdown to classy HTML.
  def process_markdown(text)
    Markdown.new(text, :smart).to_html
  end

  # We `popen` a read/write pygmentize process in the parent and
  # then fork off a child process to write the input.
  def highlight_pygmentize(code)
    code_html = nil
    open("|pygmentize -l #{@options[:language]} -O encoding=utf-8 -f html", 'r+') do |fd|
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

  # Pygments is not one of those things that's trivial for a ruby user to install,
  # so we'll fall back on a webservice to highlight the code if it isn't available.
  def highlight_webservice(code)
    url = URI.parse 'http://pygments.appspot.com/'
    options = { 'lang' => @options[:language], 'code' => code}
    Net::HTTP.post_form(url, options).body
  end
end

# And that's it.
