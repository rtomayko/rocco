require File.dirname(__FILE__) + '/helper'

class RoccoDescriptiveSectionNamesTests < Test::Unit::TestCase
  def test_section_name
    r = roccoize( "filename.rb", "# # Comment 1\ndef codeblock\nend\n" )
    html = r.to_html
    assert(
      html.include?( "<tr id='section-Comment_1'>" ),
      "The first section should be named"
    )
    assert(
      html.include?( '<a class="pilcrow" href="#section-Comment_1">' ),
      "The rendered HTML should link to a named section"
    )
  end
  def test_section_numbering
    r = roccoize( "filename.rb", "# # Header 1\ndef codeblock\nend\n# Comment 1\ndef codeblock1\nend\n# # Header 2\ndef codeblock2\nend" )
    html = r.to_html
    assert(
      html.include?( '<a class="pilcrow" href="#section-Header_1">' ) &&
      html.include?( '<a class="pilcrow" href="#section-Header_2">' ),
      "First and second headers should be named sections"
    )
    assert(
      html.include?( '<a class="pilcrow" href="#section-2">' ),
      "Sections should continue numbering as though headers were counted."
    )
  end
end
