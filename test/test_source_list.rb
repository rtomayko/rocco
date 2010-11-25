require File.dirname(__FILE__) + '/helper'

class RoccoSourceListTests < Test::Unit::TestCase
  def test_flat_sourcelist
    r = Rocco.new( 'issue26.sh', [ 'issue26a.sh', 'issue26b.sh', 'issue26c.sh' ] ) {
        "# Comment 1\n# Comment 1\nprint 'omg!'"
    }
    html = r.to_html
    puts r.to_html
    assert(
      html.include?( '<a class="source" href="issue26a.html">issue26a.sh</a>' ) &&
      html.include?( '<a class="source" href="issue26b.html">issue26b.sh</a>' ) &&
      html.include?( '<a class="source" href="issue26c.html">issue26c.sh</a>' ),
      "URLs correctly generated for files in a flat directory structure"
    )
  end
  def test_heiarachical_sourcelist
    r = Rocco.new( 'a/issue26.sh', [ 'a/issue26a.sh', 'b/issue26b.sh', 'c/issue26c.sh' ] ) {
        "# Comment 1\n# Comment 1\nprint 'omg!'"
    }
    html = r.to_html
    puts r.to_html
    assert(
      html.include?( '<a class="source" href="issue26a.html">issue26a.sh</a>' ) &&
      html.include?( '<a class="source" href="../b/issue26b.html">issue26b.sh</a>' ) &&
      html.include?( '<a class="source" href="../c/issue26c.html">issue26c.sh</a>' ),
      "URLs correctly generated for files in a flat directory structure"
    )
  end

end
