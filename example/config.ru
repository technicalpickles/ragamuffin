$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'racklet'
run Racklet::WebApplication.new
