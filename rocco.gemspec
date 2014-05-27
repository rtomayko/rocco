# rocco.gemspec
#
# To update this file's version, date, and file list, change the VERSION
# constant in lib/rocco.rb and run `rake rocco.gemspec`.

Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = 'rocco'
  s.version = '0.8.2'
  s.date = '2011-08-27'

  s.description = "Docco in Ruby"
  s.summary     = s.description

  s.authors = ["Ryan Tomayko", "Mike West"]
  s.email   = ["r@tomayko.com", "<mike@mikewest.org>"]

  s.licenses = ['MIT']

  # = MANIFEST =
  s.files = %w[
    CHANGES.md
    COPYING
    README
    Rakefile
    bin/rocco
    lib/rocco.rb
    lib/rocco/comment_styles.rb
    lib/rocco/layout.mustache
    lib/rocco/layout.rb
    lib/rocco/tasks.rb
    rocco.gemspec
    test/fixtures/issue10.iso-8859-1.rb
    test/fixtures/issue10.utf-8.rb
    test/helper.rb
    test/suite.rb
    test/test_basics.rb
    test/test_block_comment_styles.rb
    test/test_block_comments.rb
    test/test_comment_normalization.rb
    test/test_commentchar_detection.rb
    test/test_descriptive_section_names.rb
    test/test_docblock_annotations.rb
    test/test_heredoc.rb
    test/test_language_detection.rb
    test/test_reported_issues.rb
    test/test_skippable_lines.rb
    test/test_source_list.rb
  ]
  # = MANIFEST =

  s.executables = ["rocco"]

  s.test_files = s.files.select {|path| path =~ /^test\/.*_test.rb/}
  s.add_dependency 'redcarpet', '~> 1.17'
  s.add_dependency 'mustache'

  s.has_rdoc = false
  s.homepage = "http://rtomayko.github.com/rocco/"
  s.require_paths = %w[lib]
  s.rubygems_version = '1.1.1'
end
