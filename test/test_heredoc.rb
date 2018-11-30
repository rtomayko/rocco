require File.expand_path('../helper', __FILE__)

class RoccoHeredocTest < Test::Unit::TestCase
  def test_basics
    cs = Rocco::CodeSegmenter.new( :language => "rb" )
    assert_equal(
      [
        [ [ "Comment 1" ], [ "heredoc <<-EOH", "#comment", "code", "EOH" ] ]
      ],
      cs.segment( "# Comment 1\nheredoc <<-EOH\n#comment\ncode\nEOH" )
    )
  end
end
