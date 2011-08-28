require File.expand_path('../helper', __FILE__)

class RoccoStylesheetTests < Test::Unit::TestCase
  def test_default_stylesheet
    r = Rocco.new( 'file.rb', [ 'file.rb'] ) {
      "# Content"
    }
    html = r.to_html
    assert(
      html.include?('<link rel="stylesheet" href="http://jashkenas.github.com/docco/resources/docco.css">')
    )
  end

  def test_custom_stylesheet
    r = Rocco.new( 'file.rb', [ 'file.rb'], :stylesheet => 'http://example.com/custom.css' ) {
      "# Content"
    }
    html = r.to_html
    assert(
      html.include?('<link rel="stylesheet" href="http://example.com/custom.css">')
    )
  end
end
