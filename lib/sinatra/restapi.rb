require 'json'

# ## Sinatra::RestAPI [module]
# A plugin for providing rest API to models. Great for Backbone.js.
#
module Sinatra::RestAPI
  def self.registered(app)
    app.helpers Helpers
  end

  module Helpers
    def rest_params
      if File.fnmatch('*/json', request.content_type)
        JSON.parse request.body.read

      elsif params['model']
        # Account for Backbone.emulateJSON.
        JSON.parse params['model']

      else
        params
      end
    end

    # Responds with a request with the given object.
    def rest_respond(obj)
      case request.preferred_type('*/json', '*/xml')
      when '*/json'
        content_type :json
        rest_convert obj, :to_json

      when '*/xml'
        content_type :xml
        rest_convert obj, :to_xml

      else
        pass
      end
    end

    def rest_convert(obj, method)
      if obj.respond_to?(method)
        obj.send method
      elsif obj.respond_to?(:to_hash)
        obj.to_hash.send method
      else
        raise "Can't convert object #{method}"
      end
    end
  end

  # ### rest_create(path, &block) [method]
  # Creates a *create* route on the given `path`.
  #
  def rest_create(path, options={}, &blk)
    # Create
    post path do
      @object = yield
      rest_params.each { |k, v| @object.send :"#{k}=", v }
      @object.save
      rest_respond @object.to_hash
    end
  end

  # ### rest_resource(path, &block) [method]
  # Creates a *get*, *edit* and *delete* route on the given `path`.
  #
  # If you are using Backbone, ensure that you are *not* setting
  # `Backbone.emulateHTTP` to `true`.
  def rest_resource(path, options={}, &blk)
    before path do |id|
      @object = yield(id) or pass
    end

    # Get
    get path do |id|
      rest_respond @object
    end

    # Edit
    put path do |id|
      rest_params.each { |k, v| @object.send :"#{k}=", v  unless k == 'id' }
      @object.save
      rest_respond @object
    end

    # Delete
    delete path do |id|
      @object.destroy
      rest_respond :result => :success
    end
  end

  # Shortcut for everything
  # rest_model "/document" do; Document; end
  def rest_model(path, options={}, &blk)
    rest_collection("#{path}s/", options) { yield }
    rest_create("#{path}", options) { yield.new }
    rest_create("#{path}/id", options) { yield[id] }
  end
end
