# Rocco
# =====
#
# Rocco is a quick-and-dirty literate-programming-style documentation
# generator based *heavily* on [Docco](http://jashkenas.github.com/docco/).


# The RDiscount library is required for Markdown processing.
require 'rdiscount'

class Rocco
  # `Rocco.new` takes a source `filename` and an optional `block` used to
  # read the file's contents. When `block` is given, it must read the contents
  # of the file using whatever means necessary and return it as a string.
  # With no `block`, the file is read to retrieve data.
  def initialize(filename, &block)
    @file = filename
    @data =
      if block_given?
        yield
      else
        File.read(filename)
      end

    # Jump right into the parsing and highlighting phase.
    @sections = highlight(parse(@data))
  end

  # The source filename.
  attr_reader :file

  # A list of two-tuples representing each *section* of the source file. Each
  # item in the list has the form `[docs_html, code_html]` and represents a
  # single section.
  #
  # Both `docs_html` and `code_html` are strings containing the
  # documentation and source code HTML, respectively.
  attr_reader :sections

  # Internal Parsing and Highlighting
  # ---------------------------------
  protected

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
          if code.any?
            code << line
          else
            docs << line
          end
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
        split(/\n*<span class="c1"># DIVIDER<\/span>\n*/m).
        map { |code| code.sub(/\n?<div class="highlight"><pre>/m, '') }.
        map { |code| code.sub(/\n?<\/pre><\/div>\n/m, '') }

      # Combine the docs and code lists into the same sections style list we
      # started with.
      docs_html.zip(code_html)
    end

public
  require 'rocco/layout'

  def to_html
    Rocco::Layout.new(self).render
  end
end
