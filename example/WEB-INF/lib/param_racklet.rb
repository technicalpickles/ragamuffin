class ParamRacklet < Ragamuffin::Racklet
  def do_get(request, response)
    data = request.params['data']
    if data
      response.write data
    else
      response.write 'No data'
    end
  end
end
