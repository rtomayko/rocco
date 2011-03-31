require File.expand_path('../helper', __FILE__)

class RoccoBlockCommentTest < Test::Unit::TestCase
  def test_one_liner
    r = Rocco.new( 'test', '', { :language => "c" } ) { "" } # Generate throwaway instance so I can test `parse`
    assert_equal(
      [
        [ [ "Comment 1" ], [ "def codeblock", "end" ] ]
      ],
      r.parse( "/** Comment 1 */\ndef codeblock\nend\n" )
    )
  end

  def test_block_start_with_comment
    r = Rocco.new( 'test', '', { :language => "c" } ) { "" } # Generate throwaway instance so I can test `parse`
    assert_equal(
      [
        [ [ "Comment 1a", "Comment 1b" ], [ "def codeblock", "end" ] ]
      ],
      r.parse( "/** Comment 1a\n * Comment 1b\n */\ndef codeblock\nend\n" )
    )
  end

  def test_block_end_with_comment
    r = Rocco.new( 'test', '', { :language => "c" } ) { "" } # Generate throwaway instance so I can test `parse`
    assert_equal(
      [
        [ [ "Comment 1a", "Comment 1b" ], [ "def codeblock", "end" ] ]
      ],
      r.parse( "/**\n * Comment 1a\n Comment 1b */\ndef codeblock\nend\n" )
    )
  end

  def test_block_end_with_comment_and_middle
    r = Rocco.new( 'test', '', { :language => "c" } ) { "" } # Generate throwaway instance so I can test `parse`
    assert_equal(
      [
        [ [ "Comment 1a", "Comment 1b" ], [ "def codeblock", "end" ] ]
      ],
      r.parse( "/**\n * Comment 1a\n * Comment 1b */\ndef codeblock\nend\n" )
    )
  end

  def test_block_start_with_comment_and_end_with_comment
    r = Rocco.new( 'test', '', { :language => "c" } ) { "" } # Generate throwaway instance so I can test `parse`
    assert_equal(
      [
        [ [ "Comment 1a", "Comment 1b" ], [ "def codeblock", "end" ] ]
      ],
      r.parse( "/** Comment 1a\n Comment 1b */\ndef codeblock\nend\n" )
    )
  end

  def test_block_start_with_comment_and_end_with_comment_and_middle
    r = Rocco.new( 'test', '', { :language => "c" } ) { "" } # Generate throwaway instance so I can test `parse`
    assert_equal(
      [
        [ [ "Comment 1a", "Comment 1b" ], [ "def codeblock", "end" ] ]
      ],
      r.parse( "/** Comment 1a\n * Comment 1b */\ndef codeblock\nend\n" )
    )
  end

end
