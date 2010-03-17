Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = 'rocco'
  s.version = '0.2'
  s.date = '2010-03-17'

  s.description = "Docco in Ruby"
  s.summary     = s.description

  s.authors = ["Ryan Tomayko"]
  s.email = "r@tomayko.com"

  # = MANIFEST =
  s.files = %w[
    COPYING
    README
    Rakefile
    bin/rocco
    lib/rocco.rb
    lib/rocco/layout.mustache
    lib/rocco/layout.rb
    lib/rocco/tasks.rb
    rocco.gemspec
  ]
  # = MANIFEST =

  s.executables = ["rocco"]

  s.test_files = s.files.select {|path| path =~ /^test\/.*_test.rb/}
  s.add_dependency 'rdiscount'
  s.add_dependency 'mustache'

  s.has_rdoc = false
  s.homepage = "http://rtomayko.github.com/rocco/"
  s.require_paths = %w[lib]
  s.rubygems_version = '1.1.1'
end
