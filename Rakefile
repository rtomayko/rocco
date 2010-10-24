$LOAD_PATH.unshift 'lib'

require 'rake/testtask'
require 'rake/clean'

task :default => [:sup, :docs, :test]

desc 'Holla'
task :sup do
  verbose do
    lines = File.read('README').split("\n")[0,12]
    lines.map! { |line| line[15..-1] }
    puts lines.join("\n")
  end
end

desc 'Run tests (default)'
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/suite.rb']
  t.ruby_opts = ['-rubygems'] if defined? Gem
end

# Bring in Rocco tasks
require 'rocco/tasks'
Rocco::make 'docs/'

desc 'Build rocco docs'
task :docs => :rocco
directory 'docs/'

desc 'Build docs and open in browser for the reading'
task :read => :docs do
  sh 'open docs/rocco.html'
end

# Make index.html a copy of rocco.html
file 'docs/index.html' => 'docs/rocco.html' do |f|
  cp 'docs/rocco.html', 'docs/index.html', :preserve => true
end
task :docs => 'docs/index.html'
CLEAN.include 'docs/index.html'

# Alias for docs task
task :doc => :docs

# GITHUB PAGES ===============================================================

desc 'Update gh-pages branch'
task :pages => ['docs/.git', :docs] do
  rev = `git rev-parse --short HEAD`.strip
  Dir.chdir 'docs' do
    sh "git add *.html"
    sh "git commit -m 'rebuild pages from #{rev}'" do |ok,res|
      if ok
        verbose { puts "gh-pages updated" }
        sh "git push -q o HEAD:gh-pages"
      end
    end
  end
end

# Update the pages/ directory clone
file 'docs/.git' => ['docs/', '.git/refs/heads/gh-pages'] do |f|
  sh "cd docs && git init -q && git remote add o ../.git" if !File.exist?(f.name)
  sh "cd docs && git fetch -q o && git reset -q --hard o/gh-pages && touch ."
end
CLOBBER.include 'docs/.git'

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
