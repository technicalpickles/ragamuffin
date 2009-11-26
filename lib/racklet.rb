require 'rack'
require 'nokogiri'
require 'activesupport'

class Racklet

  def call(env)
    request = Rack::Request.new(env)
    response = Rack::Response.new

    send("do_#{request.request_method.downcase}", request, response)

    response.finish
  end

  def self.call(env)
    new.call(env)
  end

  class Container

    attr_accessor :url_to_class_mapping

    def initialize()
      @url_to_class_mapping = {}
    end

    def configure(xml)
      doc = Nokogiri::XML(xml)

      name_to_url_mapping = {}
      name_to_class_mapping = {}

      doc.css('racklet').each do |racklet|
        name = racklet.css('racklet-name').first.content
        class_name = racklet.css('racklet-class').first.content

        require class_name.underscore
        name_to_class_mapping[name] = Kernel.const_get(class_name)
      end

      doc.css('racklet-mapping').each do |racklet|
        name = racklet.css('racklet-name').first.content
        url = racklet.css('url-pattern').first.content

        name_to_url_mapping[name] = url
      end

      name_to_url_mapping.each do |name, url|
        racklet_class = name_to_class_mapping[name]
        url_to_class_mapping[url] = racklet_class
      end

      self
    end

    def self.configure(xml)
      returning new do |container|
        container.configure(xml)
      end
    end

    def call(env)
      Rack::URLMap.new(url_to_class_mapping).call(env)
    end

  end
end

