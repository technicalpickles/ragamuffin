require 'racklet'
class HelloRacklet < Racklet
  def do_get(request, response)
    response.write "Hello World!"
  end
end
