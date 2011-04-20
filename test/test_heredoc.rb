require File.expand_path('../helper', __FILE__)

class RoccoHeredocTest < Test::Unit::TestCase
  def test_basics
    r = Rocco.new( 'test', '', { :language => "rb" } ) { "" } # Generate throwaway instance so I can test `parse`
    assert_equal(
      [
        [ [ "Comment 1" ], [ "heredoc <<-EOH", "#comment", "code", "EOH" ] ]
      ],
      r.parse( "# Comment 1\nheredoc <<-EOH\n#comment\ncode\nEOH" )
    )
  end
end
