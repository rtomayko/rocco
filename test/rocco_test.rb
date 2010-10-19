rootdir = File.dirname(File.dirname(__FILE__))
$LOAD_PATH.unshift "#{rootdir}/lib"

require 'test/unit'
begin; require 'turn'; rescue LoadError; end
begin
    require 'rdiscount'
rescue LoadError
    if !defined?(Gem)
        require 'rubygems'
        retry
    end
end
require 'rocco'

def roccoize( filename, contents, options = {} )
    Rocco.new( filename, [ filename ], options ) {
        contents
    }
end

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
                [ [ "# Comment 1" ], [ "def codeblock", "end" ] ]
            ],
            r.parse( "# Comment 1\ndef codeblock\nend\n" )
        )
        assert_equal(
            [
                [ [ "# Comment 1" ], [ "def codeblock" ] ],
                [ [ "# Comment 2" ], [ "end" ] ]
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
            r.split([ [ [ "# Comment 1" ], [ "def codeblock", "end" ] ] ])
        )
        assert_equal(
            [
                [ "Comment 1", "Comment 2" ],
                [ "def codeblock", "end" ]
            ],
            r.split( [
                [ [ "# Comment 1" ], [ "def codeblock" ] ],
                [ [ "# Comment 2" ], [ "end" ] ]
            ] )
        )
    end

end

class RoccoIssueTests < Test::Unit::TestCase
    def test_issue07_incorrect_parsing_in_c_mode
        # Precursor to issue #13 below, Rocco incorrectly parsed C/C++
        # http://github.com/rtomayko/rocco/issues#issue/7
        r = Rocco.new( 'issue7.c', [], { :language => 'c' } ) {
            "// *stdio.h* declares *puts*\n#include <stdio.h>\n\n//### code hello world\n\n// every C program contains function *main*.\nint main (int argc, char *argv[]) {\n  puts('hello world');\n  return 0;\n}\n\n// that's it!"
        }
        r.sections.each do | section |
            if not section[1].nil?
                assert(
                    !section[1].include?("<span class=\"c\"># DIVIDER</span>"),
                    "`# DIVIDER` present in code text, which means the highligher screwed up somewhere."
                )
            end
        end
    end
    def test_issue10_utf8_processing
        # Rocco has issues with strange UTF-8 characters: need to explicitly set the encoding for Pygments
        # http://github.com/rtomayko/rocco/issues#issue/10
        r = Rocco.new( File.dirname(__FILE__) + "/fixtures/issue10.utf-8.rb" )
        assert_equal(
            "<p>hello ąćęłńóśźż</p>\n",
            r.sections[0][0],
            "UTF-8 input files ought behave correctly."
        )
        # and, just for grins, ensure that iso-8859-1 works too.
        # @TODO:    Is this really the correct behavior?  Converting text
        #           to UTF-8 on the way out is probably preferable.
        r = Rocco.new( File.dirname(__FILE__) + "/fixtures/issue10.iso-8859-1.rb" )
        assert_equal(
            "<p>hello w\366rld</p>\n",
            r.sections[0][0],
            "ISO-8859-1 input should probably also behave correctly."
        )
    end
    def test_issue12_css_octothorpe_classname_change
        # Docco changed some CSS classes.  Rocco needs to update its default template.
        # http://github.com/rtomayko/rocco/issues#issue/12
        r = Rocco.new( 'issue12.sh' ) {
            "# Comment 1\n# Comment 1\nprint 'omg!'"
        }
        html = r.to_html
        assert(
            !html.include?( "<div class=\"octowrap\">" ),
            "`octowrap` wrapper is present in rendered HTML.  This ought be replaced with `pilwrap`."
        )
        assert(
            !html.include?( "<a class=\"octothorpe\" href=\"#section-1\">" ),
            "`octothorpe` link is present in rendered HTML.  This ought be replaced with `pilcrow`."
        )
    end
    def test_issue13_incorrect_code_divider_parsing
        # In `bash` mode (among others), the comment class is `c`, not `c1`.
        # http://github.com/rtomayko/rocco/issues#issue/13
        r = Rocco.new( 'issue13.sh', [], { :language => 'bash' } ) {
            "# Comment 1\necho 'code';\n# Comment 2\necho 'code';\n# Comment 3\necho 'code';\n"
        }
        r.sections.each do | section |
            if not section[1].nil?
                assert(
                    !section[1].include?("<span class=\"c\"># DIVIDER</span>"),
                    "`# DIVIDER` present in code text, which means the highligher screwed up somewhere."
                )
            end
        end
    end
    def test_issue15_extra_space_after_comment_character_remains
        # After the comment character, a single space should be removed.
        # http://github.com/rtomayko/rocco/issues#issue/15
        r = Rocco.new( 'issue15.sh') {
            "# Comment 1\n# ---------\necho 'code';"
        }
        assert(
            !r.sections[0][0].include?( "<hr />" ),
            "`<hr />` present in rendered documentation text.  It should be a header, not text followed by a horizontal rule."
        )
        assert_equal( "<h2>Comment 1</h2>\n", r.sections[0][0] )
    end
end
