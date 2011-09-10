require 'json'

module Sinatra::RestAPI
  def self.registered(app)
    app.helpers Helpers
  end

  module Helpers
    def class_from_str(str)
      Object.send :const_get, str.to_sym
    end

    def bb_params
      if params['model']
        JSON.parse params['model']
      else
        params
      end
    end
  end

  def rest(model, options={})
    name  = options[:name] || model.to_s.downcase

    collection = options[:collection] || "/#{name}s"     # /documents
    create     = options[:create]     || "/#{name}"      # /document
    item       = options[:item]       || "/#{name}/:id"  # /document/:id

    # Collection
    get collection do
    end

    # Create
    post create do
      @object = class_from_str(model).new
      bb_params.each { |k, v| @object.send :"#{k}=", v }
      @object.save
      @object.to_hash.to_json
    end

    before item do |id|
      @object = class_from_str(model)[id] or pass
    end

    # Get one
    get item do |id|
      content_type :json
      @object.to_hash.to_json
    end

    # Edit
    post item do |id|
      bb_params.each { |k, v| @object.send :"#{k}=", v }
      @object.save

      content_type :json
      @object.to_hash.to_json
    end

    # Delete
    delete item do |id|
      content_type :json
      @object.destroy
      ""
    end
  end
end
