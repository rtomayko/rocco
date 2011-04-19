require File.expand_path('../helper', __FILE__)

class RoccoDocblockAnnotationsTest < Test::Unit::TestCase
  def test_docblock_annotation_conversion
    r = Rocco.new( 'test', '', { :language => "c", :docblocks => true } ) { "" } # Generate throwaway instance so I can test `parse`
    assert_equal(
      [
        "Comment\n\n> **param** mixed foo  \n> **return** void  "
      ],
      r.docblock( ["Comment\n\n@param mixed foo\n@return void"] )
    )
  end
end
