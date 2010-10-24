#### Rocco Rake Tasks
#
# To use the Rocco Rake tasks, require `rocco/tasks` in your `Rakefile`
# and define a Rake task with `rocco_task`. In its simplest form, `rocco_task`
# takes the path to a destination directory where HTML docs should be built:
#
#     require 'rocco/tasks'
#
#     desc "Build Rocco Docs"
#     Rocco::make 'docs/'
#
# This creates a `:rocco` rake task, which can then be run with:
#
#     rake rocco
#
# It's a good idea to guard against Rocco not being available, since your
# Rakefile will fail to load otherwise. Consider doing something like this,
# so that your Rakefile will still work
#
#     begin
#       require 'rocco/tasks'
#       Rocco::make 'docs/'
#     rescue LoadError
#       warn "#$! -- rocco tasks not loaded."
#       task :rocco
#     end
#
# It's also possible to pass a glob pattern:
#
#     Rocco::make 'html/', 'lib/thing/**/*.rb'
#
# Or a list of glob patterns:
#
#     Rocco::make 'html/', ['lib/thing.rb', 'lib/thing/*.rb']
#
# Finally, it is also possible to specify which Pygments language you would
# like to use to highlight the code, as well as the comment characters for the
# language in the `options` hash:
#
#    Rocco::make 'html/', 'lib/thing/**/*.rb', {
#      :language => 'io',
#      :comment_chars => '#'
#    }
#

# Might be nice to defer this until we actually need to build docs but this
# will have to do for now.
require 'rocco'

# Reopen the Rocco class and add a `make` class method. This is a simple bit
# of sugar over `Rocco::Task.new`. If you want your Rake task to be named
# something other than `:rocco`, you can use `Rocco::Task` directly.
class Rocco
  def self.make(dest='docs/', source_files='lib/**/*.rb', options={})
    Task.new(:rocco, dest, source_files, options)
  end

  # `Rocco::Task.new` takes a task name, the destination directory docs
  # should be built under, and a source file pattern or file list.
  class Task
    def initialize(task_name, dest='docs/', sources='lib/**/*.rb', options={})
      @name = task_name
      @dest = dest[-1] == ?/ ? dest : "#{dest}/"
      @sources = FileList[sources]
      @options = options

      # Make sure there's a `directory` task defined for our destination.
      define_directory_task @dest

      # Run over the source file list, constructing destination filenames
      # and defining file tasks.
      @sources.each do |source_file|
        dest_file = source_file.sub(Regexp.new("#{File.extname(source_file)}$"), ".html")
        define_file_task source_file, "#{@dest}#{dest_file}"

        # If `rake/clean` was required, add the generated files to the list.
        # That way all Rocco generated are removed when running `rake clean`.
        CLEAN.include "#{@dest}#{dest_file}" if defined? CLEAN
      end
    end

    # Define the destination directory task and make the `:rocco` task depend
    # on it. This causes the destination directory to be created if it doesn't
    # already exist.
    def define_directory_task(path)
      directory path
      task @name => path
    end

    # Setup a `file` task for a single Rocco output file (`dest_file`). It
    # depends on the source file, the destination directory, and all of Rocco's
    # internal source code, so that the destination file is rebuilt when any of
    # those changes.
    #
    # You can run these tasks directly with Rake:
    #
    #     rake docs/foo.html docs/bar.html
    #
    # ... would generate the `foo.html` and `bar.html` files but only if they
    # don't already exist or one of their dependencies was changed.
    def define_file_task(source_file, dest_file)
      prerequisites = [@dest, source_file] + rocco_source_files
      file dest_file => prerequisites do |f|
        verbose { puts "rocco: #{source_file} -> #{dest_file}" }
        rocco = Rocco.new(source_file, @sources.to_a, @options)
        FileUtils.mkdir_p(File.dirname(dest_file))
        File.open(dest_file, 'wb') { |fd| fd.write(rocco.to_html) }
      end
      task @name => dest_file
    end

    # Return a `FileList` that includes all of Roccos source files. This causes
    # output files to be regenerated properly when someone upgrades the Rocco
    # library.
    def rocco_source_files
      libdir = File.expand_path('../..', __FILE__)
      FileList["#{libdir}/rocco.rb", "#{libdir}/rocco/**"]
    end

  end
end
