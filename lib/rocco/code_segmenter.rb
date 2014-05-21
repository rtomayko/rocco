require 'rocco/comment_styles'

class Rocco
  class CodeSegmenter
    include CommentStyles

    DEFAULT_OPTIONS = {
      :language      => 'rb',
      :comment_chars => '#'
    }

    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge options
      @options[:comment_chars] = generate_comment_chars if @options[:comment_chars].is_a? String
    end
    # Internal Parsing and Highlighting
    # ---------------------------------

    # Parse the raw file source_code into a list of two-tuples. Each tuple has the
    # form `[docs, code]` where both elements are arrays containing the
    # raw lines parsed from the input file, comment characters stripped.
    def segment(source_code)
      sections, docs, code = [], [], []
      lines = source_code.split("\n")

      # The first line is ignored if it is a shebang line.  We also ignore the
      # PEP 263 encoding information in python sourcefiles, and the similar ruby
      # 1.9 syntax.
      lines.shift if lines[0] =~ /^\#\!/
      lines.shift if lines[0] =~ /coding[:=]\s*[-\w.]+/ &&
                     [ "python", "rb" ].include?(@options[:language])

      # To detect both block comments and single-line comments, we'll set
      # up a tiny state machine, and loop through each line of the file.
      # This requires an `in_comment_block` boolean, and a few regular
      # expressions for line tests.  We'll do the same for fake heredoc parsing.
      in_comment_block = false
      in_heredoc = false
      single_line_comment, block_comment_start, block_comment_mid, block_comment_end =
        nil, nil, nil, nil
      if not @options[:comment_chars][:single].nil?
        single_line_comment = Regexp.new("^\\s*#{Regexp.escape(@options[:comment_chars][:single])}\\s?")
      end
      if not @options[:comment_chars][:multi].nil?
        block_comment_start = Regexp.new("^\\s*#{Regexp.escape(@options[:comment_chars][:multi][:start])}\\s*$")
        block_comment_end   = Regexp.new("^\\s*#{Regexp.escape(@options[:comment_chars][:multi][:end])}\\s*$")
        block_comment_one_liner = Regexp.new("^\\s*#{Regexp.escape(@options[:comment_chars][:multi][:start])}\\s*(.*?)\\s*#{Regexp.escape(@options[:comment_chars][:multi][:end])}\\s*$")
        block_comment_start_with = Regexp.new("^\\s*#{Regexp.escape(@options[:comment_chars][:multi][:start])}\\s*(.*?)$")
        block_comment_end_with = Regexp.new("\\s*(.*?)\\s*#{Regexp.escape(@options[:comment_chars][:multi][:end])}\\s*$")
        if @options[:comment_chars][:multi][:middle]
          block_comment_mid = Regexp.new("^\\s*#{Regexp.escape(@options[:comment_chars][:multi][:middle])}\\s?")
        end
      end
      if not @options[:comment_chars][:heredoc].nil?
        heredoc_start = Regexp.new("#{Regexp.escape(@options[:comment_chars][:heredoc])}(\\S+)$")
      end
      lines.each do |line|
        # If we're currently in a comment block, check whether the line matches
        # the _end_ of a comment block or the _end_ of a comment block with a
        # comment.
        if in_comment_block
          if block_comment_end && line.match(block_comment_end)
            in_comment_block = false
          elsif block_comment_end_with && line.match(block_comment_end_with)
            in_comment_block = false
            docs << line.match(block_comment_end_with).captures.first.
                          sub(block_comment_mid || '', '')
          else
            docs << line.sub(block_comment_mid || '', '')
          end
        # If we're currently in a heredoc, we're looking for the end of the
        # heredoc, and everything it contains is code.
        elsif in_heredoc
          if line.match(Regexp.new("^#{Regexp.escape(in_heredoc)}$"))
            in_heredoc = false
          end
          code << line
        # Otherwise, check whether the line starts a heredoc. If so, note the end
        # pattern, and the line is code.  Otherwise check whether the line matches
        # the beginning of a block, or a single-line comment all on it's lonesome.
        # In either case, if there's code, start a new section.
        else
          if heredoc_start && line.match(heredoc_start)
            in_heredoc = $1
            code << line
          elsif block_comment_one_liner && line.match(block_comment_one_liner)
            if code.any?
              sections << [docs, code]
              docs, code = [], []
            end
            docs << line.match(block_comment_one_liner).captures.first
          elsif block_comment_start && line.match(block_comment_start)
            in_comment_block = true
            if code.any?
              sections << [docs, code]
              docs, code = [], []
            end
          elsif block_comment_start_with && line.match(block_comment_start_with)
            in_comment_block = true
            if code.any?
              sections << [docs, code]
              docs, code = [], []
            end
            docs << line.match(block_comment_start_with).captures.first
          elsif single_line_comment && line.match(single_line_comment)
            if code.any?
              sections << [docs, code]
              docs, code = [], []
            end
            docs << line.sub(single_line_comment || '', '')
          else
            code << line
          end
        end
      end
      sections << [docs, code] if docs.any? || code.any?
      normalize_leading_spaces(sections)
    end

    # Normalizes documentation whitespace by checking for leading whitespace,
    # removing it, and then removing the same amount of whitespace from each
    # succeeding line.  That is:
    #
    #     def func():
    #       """
    #         Comment 1
    #         Comment 2
    #       """
    #       print "omg!"
    #
    # should yield a comment block of `Comment 1\nComment 2` and code of
    # `def func():\n  print "omg!"`
    def normalize_leading_spaces(sections)
      sections.map do |section|
        if section.any? && section[0].any?
          leading_space = section[0][0].match("^\s+")
          if leading_space
            section[0] =
              section[0].map{ |line| line.sub(/^#{leading_space.to_s}/, '') }
          end
        end
        section
      end
    end

    private

    def generate_comment_chars
      @_commentchar ||=
        if COMMENT_STYLES[@options[:language]]
          COMMENT_STYLES[@options[:language]]
        else
          { :single => @options[:comment_chars], :multi => nil, :heredoc => nil }
        end
    end
  end
end