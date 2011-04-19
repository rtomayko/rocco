require File.expand_path('../helper', __FILE__)

class RoccoDocblockAnnotationsTest < Test::Unit::TestCase
  def test_basics
    r = Rocco.new( 'test', '', { :language => "c", :docblocks => true } ) { "" } # Generate throwaway instance so I can test `parse`
    assert_equal(
      [
        "Comment\n\n> **param** mixed foo  \n> **return** void  "
      ],
      r.docblock( ["Comment\n\n@param mixed foo\n@return void"] )
    )
  end
  def test_highlighted_in_blocks
    r = Rocco.new( 'test', '', { :language => "c", :docblocks => true } ) { "" } # Generate throwaway instance so I can test `parse`
    highlighted = r.highlight( r.split( r.parse( "/**\n * Comment\n * @param type name\n */\ndef codeblock\nend\n" ) ) )

    assert_equal(
      "<p>Comment</p>\n\n<blockquote><p><strong>param</strong> type name</p></blockquote>\n",
      highlighted[0][0]
    )
  end
end
