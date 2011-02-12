require 'mustache'
require 'pathname'

class Rocco::Layout < Mustache
  self.template_path = File.dirname(__FILE__)

  def initialize(doc, file=nil)
    @doc = doc
    if not file.nil?
      Rocco::Layout.template_file = file
    end
  end

  def title
    File.basename(@doc.file)
  end

  def sections
    num = 0
    @doc.sections.map do |docs,code|
      is_header = /^<h.>(.+)<\/h.>$/.match( docs )
      header_text = is_header && is_header[1].split.join("_")
      num += 1
      {
        :docs       =>  docs,
        :docs?      =>  !docs.empty?,
        :header?    =>  is_header,

        :code       =>  code,
        :code?      =>  !code.empty?,

        :empty?     =>  ( code.empty? && docs.empty? ),
        :section_id =>  is_header ? header_text : num
      }
    end
  end

  def sources?
    @doc.sources.length > 1
  end

  def sources
    currentpath = Pathname.new( File.dirname( @doc.file ) )
    @doc.sources.sort.map do |source|
      htmlpath = Pathname.new( source.sub( Regexp.new( "#{File.extname(source)}$"), ".html" ) )

      {
        :path       => source,
        :basename   => File.basename(source),
        :url        => htmlpath.relative_path_from( currentpath )
      }
    end
  end
end
