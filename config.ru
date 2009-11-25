require 'racklet'

run Racklet::Container.parse(File.read('web.xml'))
