class Rocco
  module CommentStyles
    C_STYLE_COMMENTS = {
      :single => "//",
      :multi  => { :start => "/**", :middle => "*", :end => "*/" },
      :heredoc => nil
    }

    COMMENT_STYLES  = {
      "bash"          =>  { :single => "#", :multi => nil },
      "c"             =>  C_STYLE_COMMENTS,
      "coffee-script" =>  {
        :single => "#",
        :multi  => { :start => "###", :middle => nil, :end => "###" },
        :heredoc => nil
      },
      "cpp" =>  C_STYLE_COMMENTS,
      "csharp" => C_STYLE_COMMENTS,
      "css"           =>  {
        :single => nil,
        :multi  => { :start => "/**", :middle => "*", :end => "*/" },
        :heredoc => nil
      },
      "html"           =>  {
        :single => nil,
        :multi => { :start => '<!--', :middle => nil, :end => '-->' },
        :heredoc => nil
      },
      "java"          =>  C_STYLE_COMMENTS,
      "js"            =>  C_STYLE_COMMENTS,
      "lua"           =>  {
        :single => "--",
        :multi => nil,
        :heredoc => nil
      },
      "objective-c"   =>  C_STYLE_COMMENTS,
      "php" => C_STYLE_COMMENTS,
      "python"        =>  {
        :single => "#",
        :multi  => { :start => '"""', :middle => nil, :end => '"""' },
        :heredoc => nil
      },
      "rb"            =>  {
        :single => "#",
        :multi  => { :start => '=begin', :middle => nil, :end => '=end' },
        :heredoc => "<<-"
      },
      "scala"         =>  C_STYLE_COMMENTS,
      "scheme"        =>  { :single => ";;",  :multi => nil, :heredoc => nil },
      "xml"           =>  {
        :single => nil,
        :multi => { :start => '<!--', :middle => nil, :end => '-->' },
        :heredoc => nil
      },
    }
  end
end
