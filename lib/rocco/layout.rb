require 'mustache'

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
      {
        :docs       =>  docs,
        :docs?      =>  !docs.empty?,
        :header?    =>  /^<h.>.+<\/h.>$/.match( docs ),

        :code       =>  code,
        :code?      =>  !code.empty?,

        :empty?     =>  ( code.empty? && docs.empty? ),
        :num        =>  (num += 1)
      }
    end
  end

  def sources?
    @doc.sources.length > 1
  end

  def sources
    @doc.sources.sort.map do |source|
      {
        :path       => source,
        :basename   => File.basename(source),
        :url        => source.sub( Regexp.new( "#{File.extname(source)}$"), ".html" )
      }
    end
  end
end
