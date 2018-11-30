require File.expand_path('../helper', __FILE__)

class RoccoCommentNormalization < Test::Unit::TestCase
  def test_normal_comments
    cs = Rocco::CodeSegmenter.new( :language => "python" )
    assert_equal(
      [
          [ [ "Comment 1a", "Comment 1b" ], [ "def codeblock", "end" ] ],
          [ [ "Comment 2a", "  Comment 2b" ], [] ]
      ],
      cs.segment( "\"\"\"\n  Comment 1a\n  Comment 1b\n\"\"\"\ndef codeblock\nend\n\"\"\"\n  Comment 2a\n    Comment 2b\n\"\"\"\n" )
    )
  end

  def test_single_line_comments
    cs = Rocco::CodeSegmenter.new( :language => "python" )
    assert_equal(
      [
          [ [ "Comment 1a", "Comment 1b" ], [ "def codeblock", "end" ] ],
          [ [ "Comment 2a", "  Comment 2b" ], [] ]
      ],
      cs.segment( "#   Comment 1a\n#   Comment 1b\ndef codeblock\nend\n#   Comment 2a\n#     Comment 2b\n" )
    )
  end
end
