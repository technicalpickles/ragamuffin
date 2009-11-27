$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'ragamuffin'
run Ragamuffin::WebApplication.new
