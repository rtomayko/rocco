require File.expand_path('../helper', __FILE__)

class RoccoSkippableLines < Test::Unit::TestCase
  def test_shebang_first_line
    r = Rocco.new( 'filename.sh' ) { "" }
    assert_equal(
      [
        [ [ "Comment 1" ], [ "def codeblock" ] ],
        [ [ "Comment 2" ], [ "end" ] ]
      ],
      r.parse( "#!/usr/bin/env bash\n# Comment 1\ndef codeblock\n# Comment 2\nend\n" ),
      "Shebang should be stripped when it appears as the first line."
    )
  end

  def test_shebang_in_content
    r = Rocco.new( 'filename.sh' ) { "" }
    assert_equal(
      [
        # @TODO: `#!/` shouldn't be recognized as a comment.
        [ [ "Comment 1", "!/usr/bin/env bash" ], [ "def codeblock" ] ],
        [ [ "Comment 2" ], [ "end" ] ]
      ],
      r.parse( "# Comment 1\n#!/usr/bin/env bash\ndef codeblock\n# Comment 2\nend\n" ),
      "Shebang shouldn't be stripped anywhere other than as the first line."
    )
  end

  def test_encoding_in_ruby
    r = Rocco.new( 'filename.rb' ) { "" }
    assert_equal(
      [
        [ [ "Comment 1" ], [ "def codeblock" ] ],
        [ [ "Comment 2" ], [ "end" ] ]
      ],
      r.parse( "#!/usr/bin/env bash\n# encoding: utf-8\n# Comment 1\ndef codeblock\n# Comment 2\nend\n" ),
      "Strings matching the PEP 263 encoding definition regex should be stripped when they appear at the top of a python document."
    )
  end

  def test_encoding_in_python
    r = Rocco.new( 'filename.py', [], {:language => "python"} ) { "" }
    assert_equal(
      [
        [ [ "Comment 1" ], [ "def codeblock" ] ],
        [ [ "Comment 2" ], [ "end" ] ]
      ],
      r.parse( "#!/usr/bin/env bash\n# encoding: utf-8\n# Comment 1\ndef codeblock\n# Comment 2\nend\n" ),
      "Strings matching the PEP 263 encoding definition regex should be stripped when they appear at the top of a python document."
    )
  end

  def test_encoding_in_notpython
    r = Rocco.new( 'filename.sh' ) { "" }
    assert_equal(
      [
        [ [ "encoding: utf-8", "Comment 1" ], [ "def codeblock" ] ],
        [ [ "Comment 2" ], [ "end" ] ]
      ],
      r.parse( "#!/usr/bin/env bash\n# encoding: utf-8\n# Comment 1\ndef codeblock\n# Comment 2\nend\n" ),
      "Strings matching the PEP 263 encoding definition regex should be stripped when they appear at the top of a python document."
    )
  end
end
