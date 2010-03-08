require 'mustache'

class Rocco::Layout < Mustache
  self.template_path = File.dirname(__FILE__)

  def initialize(doc)
    @doc = doc
  end

  def title
    @doc.file
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
end
