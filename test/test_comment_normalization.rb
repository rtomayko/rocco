require File.expand_path('../helper', __FILE__)

class RoccoCommentNormalization < Test::Unit::TestCase
  def test_normal_comments
    r = Rocco.new( 'test', '', { :language => "python" } ) { "" } # Generate throwaway instance so I can test `parse`
    assert_equal(
      [
          [ [ "Comment 1a", "Comment 1b" ], [ "def codeblock", "end" ] ],
          [ [ "Comment 2a", "  Comment 2b" ], [] ]
      ],
      r.parse( "\"\"\"\n  Comment 1a\n  Comment 1b\n\"\"\"\ndef codeblock\nend\n\"\"\"\n  Comment 2a\n    Comment 2b\n\"\"\"\n" )
    )
  end

  def test_single_line_comments
    r = Rocco.new( 'test', '', { :language => "python" } ) { "" } # Generate throwaway instance so I can test `parse`
    assert_equal(
      [
          [ [ "Comment 1a", "Comment 1b" ], [ "def codeblock", "end" ] ],
          [ [ "Comment 2a", "  Comment 2b" ], [] ]
      ],
      r.parse( "#   Comment 1a\n#   Comment 1b\ndef codeblock\nend\n#   Comment 2a\n#     Comment 2b\n" )
    )
  end
end
