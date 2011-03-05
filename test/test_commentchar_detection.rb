require File.expand_path('../helper', __FILE__)

class RoccoAutomaticCommentChars < Test::Unit::TestCase
  def test_basic_detection
    r = Rocco.new( 'filename.js' ) { "" }
    assert_equal "//", r.options[:comment_chars][:single]
  end

  def test_fallback_language
    r = Rocco.new( 'filename.an_extension_with_no_meaning_whatsoever', '', { :language => "js" } ) { "" }
    assert_equal "//", r.options[:comment_chars][:single]
  end

  def test_fallback_default
    r = Rocco.new( 'filename.an_extension_with_no_meaning_whatsoever' ) { "" }
    assert_equal "#", r.options[:comment_chars][:single], "`:comment_chars` should be `#` when falling back to defaults."
  end

  def test_fallback_user
    r = Rocco.new( 'filename.an_extension_with_no_meaning_whatsoever', '', { :comment_chars => "user" } ) { "" }
    assert_equal "user", r.options[:comment_chars][:single], "`:comment_chars` should be the user's default when falling back to user-provided settings."
  end

  def test_fallback_user_with_unknown_language
    r = Rocco.new( 'filename.an_extension_with_no_meaning_whatsoever', '', { :language => "not-a-language", :comment_chars => "user" } ) { "" }
    assert_equal "user", r.options[:comment_chars][:single], "`:comment_chars` should be the user's default when falling back to user-provided settings."
  end
end
