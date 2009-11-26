$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'racklet'
run Racklet::Container.configure(File.read('web.xml'))
