require 'rack'
require 'nokogiri'
require 'activesupport'

module Ragamuffin
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
  end

  class ArchivedWebApplication

    def initialize(rawr_path)
      require 'zip/zip'
      Zip::ZipFile::open(rawr_path) do |zip_file|
        zip_file.each do |zipped_file|
          extracted_path = zipped_file.name
          FileUtils.mkdir_p File.dirname(extracted_path)
          
          zip_file.extract(zipped_file, extracted_path)
        end
      end

      @extracted_web_application = WebApplication.new(File.join('WEB-INF', 'web.xml'))
    end

    def call(env)
      @extracted_web_application.call(env)
    end
  end

  class WebApplication

    attr_accessor :url_to_class_mapping

    def initialize(web_xml_path = File.join('WEB-INF', 'web.xml'))
      @url_to_class_mapping = {}

      $LOAD_PATH.unshift File.join(File.dirname(web_xml_path), 'lib')

      web_xml = if web_xml_path =~ /<web-app>/
        web_xml_path
      else
        File.read(web_xml_path)
      end

      configure(web_xml)
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
