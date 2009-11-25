require 'rack'

class HttpRacklet

  def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new

      send("do_#{request.request_method.downcase}", request, response)

      response.finish
  end

end

