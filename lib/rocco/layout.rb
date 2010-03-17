require 'mustache'

class Rocco::Layout < Mustache
  self.template_path = File.dirname(__FILE__)

  def initialize(doc)
    @doc = doc
  end

  def title
    File.basename(@doc.file)
  end

  def sections
    num = 0
    @doc.sections.map do |docs,code|
      {
        :docs  => docs,
        :code  => code,
        :num   => (num += 1)
      }
    end
  end

  def sources?
    @doc.sources.length > 1
  end

  def sources
    @doc.sources.sort.map do |source|
      srcparts = File.basename(source).split('.')
      {
        :path => source,
        :basename => File.basename(source),
        :url => srcparts.slice(0, srcparts.length - 1).join('.') + '.html'
      }
    end
  end
end
