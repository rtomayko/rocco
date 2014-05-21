require File.expand_path('../helper', __FILE__)

class RoccoLanguageDetection < Test::Unit::TestCase
  def test_basic_detection
    r = Rocco.new( 'filename.py' ) { "" }
    if r.pygmentize?
      assert_equal "python", r.detect_language(), "`detect_language()` should return the correct language"
      assert_equal "python", r.options[:language], "`@options[:language]` should be set to the correct language"
    end
  end

  def test_fallback_default
    r = Rocco.new( 'filename.an_extension_with_no_meaning_whatsoever' ) { "" }
    if r.pygmentize?
      assert_equal "text", r.detect_language(), "`detect_language()` should return `text` when nothing else is detected"
      assert_equal "rb", r.options[:language], "`@options[:language]` should be set to `rb` when nothing else is detected"
    end
  end

  def test_fallback_user
    r = Rocco.new( 'filename.an_extension_with_no_meaning_whatsoever', '', { :language => "c" } ) { "" }
    if r.pygmentize?
      assert_equal "text", r.detect_language(), "`detect_language()` should return `text` nothing else is detected"
      assert_equal "c", r.options[:language], "`@options[:language]` should be set to the user's setting when nothing else is detected"
    end
  end
end
