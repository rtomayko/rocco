require File.expand_path('../helper', __FILE__)

class RoccoBlockCommentTest < Test::Unit::TestCase
  def test_one_liner
    cs = Rocco::CodeSegmenter.new( :language => "c" )
    assert_equal(
      [
        [ [ "Comment 1" ], [ "def codeblock", "end" ] ]
      ],
      cs.segment( "/** Comment 1 */\ndef codeblock\nend\n" )
    )
  end

  def test_block_start_with_comment
    cs = Rocco::CodeSegmenter.new( :language => "c" )
    assert_equal(
      [
        [ [ "Comment 1a", "Comment 1b" ], [ "def codeblock", "end" ] ]
      ],
      cs.segment( "/** Comment 1a\n * Comment 1b\n */\ndef codeblock\nend\n" )
    )
  end

  def test_block_end_with_comment
    cs = Rocco::CodeSegmenter.new( :language => "c" )
    assert_equal(
      [
        [ [ "Comment 1a", "Comment 1b" ], [ "def codeblock", "end" ] ]
      ],
      cs.segment( "/**\n * Comment 1a\n Comment 1b */\ndef codeblock\nend\n" )
    )
  end

  def test_block_end_with_comment_and_middle
    cs = Rocco::CodeSegmenter.new( :language => "c" )
    assert_equal(
      [
        [ [ "Comment 1a", "Comment 1b" ], [ "def codeblock", "end" ] ]
      ],
      cs.segment( "/**\n * Comment 1a\n * Comment 1b */\ndef codeblock\nend\n" )
    )
  end

  def test_block_start_with_comment_and_end_with_comment
    cs = Rocco::CodeSegmenter.new( :language => "c" )
    assert_equal(
      [
        [ [ "Comment 1a", "Comment 1b" ], [ "def codeblock", "end" ] ]
      ],
      cs.segment( "/** Comment 1a\n Comment 1b */\ndef codeblock\nend\n" )
    )
  end

  def test_block_start_with_comment_and_end_with_comment_and_middle
    cs = Rocco::CodeSegmenter.new( :language => "c" )
    assert_equal(
      [
        [ [ "Comment 1a", "Comment 1b" ], [ "def codeblock", "end" ] ]
      ],
      cs.segment( "/** Comment 1a\n * Comment 1b */\ndef codeblock\nend\n" )
    )
  end

end
