require File.expand_path('../helper', __FILE__)
require 'test/unit'

Dir[File.expand_path('../test_*.rb', __FILE__)].
each { |file| require file }
