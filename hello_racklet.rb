require 'racklet'
class HelloRacklet < HttpRacklet
  def do_get(request, response)
    response.write "Hello World!"
  end
end
