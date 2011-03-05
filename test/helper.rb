rootdir = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift "#{rootdir}/lib"

require 'test/unit'
begin; require 'turn'; rescue LoadError; end
begin
    require 'rdiscount'
rescue LoadError
    if !defined?(Gem)
        require 'rubygems'
        retry
    end
end
require 'rocco'

def roccoize( filename, contents, options = {} )
    Rocco.new( filename, [ filename ], options ) {
        contents
    }
end
