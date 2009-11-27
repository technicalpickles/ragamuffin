require 'ragamuffin'

class HelloRacklet < Ragamuffin::Racklet
  def do_get(request, response)
    response.write "Hello World!"
  end
end
