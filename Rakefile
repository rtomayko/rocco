require 'rake/testtask'
task :default => :test

desc 'Run tests (default)'
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/*_test.rb']
  t.ruby_opts = ['-rubygems'] if defined? Gem
end

# PACKAGING =================================================================

if defined?(Gem)
  SPEC = eval(File.read('rocco.gemspec'))

  def package(ext='')
    "pkg/rocco-#{SPEC.version}" + ext
  end

  desc 'Build packages'
  task :package => %w[.gem .tar.gz].map {|e| package(e)}

  desc 'Build and install as local gem'
  task :install => package('.gem') do
    sh "gem install #{package('.gem')}"
  end

  directory 'pkg/'

  file package('.gem') => %w[pkg/ rocco.gemspec] + SPEC.files do |f|
    sh "gem build rocco.gemspec"
    mv File.basename(f.name), f.name
  end

  file package('.tar.gz') => %w[pkg/] + SPEC.files do |f|
    sh "git archive --format=tar HEAD | gzip > #{f.name}"
  end
end

# GEMSPEC ===================================================================

file 'rocco.gemspec' => FileList['{lib,test,bin}/**','Rakefile'] do |f|
  version = File.read('lib/rocco.rb')[/VERSION = '(.*)'/] && $1
  date = Time.now.strftime("%Y-%m-%d")
  spec = File.
    read(f.name).
    sub(/s\.version\s*=\s*'.*'/, "s.version = '#{version}'")
  parts = spec.split("  # = MANIFEST =\n")
  files = `git ls-files`.
    split("\n").sort.reject{ |file| file =~ /^\./ }.
    map{ |file| "    #{file}" }.join("\n")
  parts[1] = "  s.files = %w[\n#{files}\n  ]\n"
  spec = parts.join("  # = MANIFEST =\n")
  spec.sub!(/s.date = '.*'/, "s.date = '#{date}'")
  File.open(f.name, 'w') { |io| io.write(spec) }
  puts "#{f.name} #{version} (#{date})"
end
