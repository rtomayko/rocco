require File.dirname(__FILE__) + '/helper'

class RoccoBlockCommentTest < Test::Unit::TestCase
    def test_basics
        r = Rocco.new( 'test', '', { :language => "c" } ) { "" } # Generate throwaway instance so I can test `parse`
        assert_equal(
            [
                [ [ "Comment 1" ], [ "def codeblock", "end" ] ]
            ],
            r.parse( "/**\n * Comment 1\n */\ndef codeblock\nend\n" )
        )
        assert_equal(
            [
                [ [ "Comment 1a", "Comment 1b" ], [ "def codeblock", "end" ] ]
            ],
            r.parse( "/**\n * Comment 1a\n * Comment 1b\n */\ndef codeblock\nend\n" )
        )
    end
    def test_multiple_blocks
        r = Rocco.new( 'test', '', { :language => "c" } ) { "" } # Generate throwaway instance so I can test `parse`
        assert_equal(
            [
                [ [ "Comment 1" ], [ "def codeblock", "end" ] ],
                [ [ "Comment 2" ], [] ]
            ],
            r.parse( "/**\n * Comment 1\n */\ndef codeblock\nend\n/**\n * Comment 2\n */\n" )
        )
        assert_equal(
            [
                [ [ "Comment 1" ], [ "def codeblock", "end" ] ],
                [ [ "Comment 2" ], [ "if false", "end" ] ]
            ],
            r.parse( "/**\n * Comment 1\n */\ndef codeblock\nend\n/**\n * Comment 2\n */\nif false\nend" )
        )
    end
    def test_block_without_middle_character
        r = Rocco.new( 'test', '', { :language => "python" } ) { "" } # Generate throwaway instance so I can test `parse`
        assert_equal(
            [
                [ [ "Comment 1" ], [ "def codeblock", "end" ] ],
                [ [ "Comment 2" ], [] ]
            ],
            r.parse( "\"\"\"\n  Comment 1\n\"\"\"\ndef codeblock\nend\n\"\"\"\n  Comment 2\n\"\"\"\n" )
        )
        assert_equal(
            [
                [ [ "Comment 1" ], [ "def codeblock", "end" ] ],
                [ [ "Comment 2" ], [ "if false", "end" ] ]
            ],
            r.parse( "\"\"\"\n  Comment 1\n\"\"\"\ndef codeblock\nend\n\"\"\"\n  Comment 2\n\"\"\"\nif false\nend" )
        )
    end 
    def test_language_without_single_line_comments_parse
        r = Rocco.new( 'test', '', { :language => "css" } ) { "" } # Generate throwaway instance so I can test `parse`
        assert_equal(
            [
                [ [ "Comment 1" ], [ "def codeblock", "end" ] ],
                [ [ "Comment 2" ], [ "if false", "end" ] ]
            ],
            r.parse( "/**\n * Comment 1\n */\ndef codeblock\nend\n/**\n * Comment 2\n */\nif false\nend" )
        )
    end
    def test_language_without_single_line_comments_split
        r = Rocco.new( 'test', '', { :language => "css" } ) { "" } # Generate throwaway instance so I can test `parse`
        assert_equal(
            [
              [ "Comment 1", "Comment 2" ],
              [ "def codeblock\nend", "if false\nend" ]
            ], 
            r.split( [
                [ [ "Comment 1" ], [ "def codeblock", "end" ] ],
                [ [ "Comment 2" ], [ "if false", "end" ] ]
            ] )
        )
    end
    def test_language_without_single_line_comments_highlight
        r = Rocco.new( 'test', '', { :language => "css" } ) { "" } # Generate throwaway instance so I can test `parse`
        
        highlighted = r.highlight( r.split( r.parse( "/**\n * This is a comment!\n */\n.rule { goes: here; }\n/**\n * Comment 2\n */\n.rule2 { goes: here; }" ) ) )
        assert_equal(
          "<p>This is a comment!</p>",
          highlighted[0][0]
        );
        assert_equal(
          "<p>Comment 2</p>\n",
          highlighted[1][0]
        );
        assert( 
          !highlighted[0][1].include?("DIVIDER") &&
          !highlighted[1][1].include?("DIVIDER"),
          "`DIVIDER` stripped successfully."
        )
        
        assert( true 
        );
    end

end
