require File.dirname(__FILE__) + '/helper'

class RoccoBasicTests < Test::Unit::TestCase
  def test_rocco_exists_and_is_instancable
    roccoize( "filename.rb", "# Comment 1\ndef codeblock\nend\n" )
  end

  def test_filename
    r = roccoize( "filename.rb", "# Comment 1\ndef codeblock\nend\n" )
    assert_equal "filename.rb", r.file
  end

  def test_sources
    r = roccoize( "filename.rb", "# Comment 1\ndef codeblock\nend\n" )
    assert_equal [ "filename.rb" ], r.sources
  end

  def test_sections
    r = roccoize( "filename.rb", "# Comment 1\ndef codeblock\nend\n" )
    assert_equal 1, r.sections.length
    assert_equal 2, r.sections[ 0 ].length
    assert_equal "<p>Comment 1</p>\n", r.sections[ 0 ][ 0 ]
    assert_equal "<span class=\"k\">def</span> <span class=\"nf\">codeblock</span>\n<span class=\"k\">end</span>", r.sections[ 0 ][ 1 ]
  end

  def test_parsing
    r = Rocco.new( 'test' ) { "" } # Generate throwaway instance so I can test `parse`
    assert_equal(
      [
        [ [ "Comment 1" ], [ "def codeblock", "end" ] ]
      ],
      r.parse( "# Comment 1\ndef codeblock\nend\n" )
    )
    assert_equal(
      [
        [ [ "Comment 1" ], [ "def codeblock" ] ],
        [ [ "Comment 2" ], [ "end" ] ]
      ],
      r.parse( "# Comment 1\ndef codeblock\n# Comment 2\nend\n" )
    )
  end

  def test_splitting
    r = Rocco.new( 'test' ) { "" } # Generate throwaway instance so I can test `split`
    assert_equal(
      [
        [ "Comment 1" ],
        [ "def codeblock\nend" ]
      ],
      r.split([ [ [ "Comment 1" ], [ "def codeblock", "end" ] ] ])
    )
    assert_equal(
      [
        [ "Comment 1", "Comment 2" ],
        [ "def codeblock", "end" ]
      ],
      r.split( [
        [ [ "Comment 1" ], [ "def codeblock" ] ],
        [ [ "Comment 2" ], [ "end" ] ]
      ] )
    )
  end
end
