class Document < Sequel::Model
  plugin :serialization, :yaml, :data

  # Elaborate way to deal with serialization.
  def self.attr_data(*names)
    names.each do |name|
      self.data_attrs << name
      send(:define_method, :"#{name}") { self.data && self.data[name.to_s] }
      send(:define_method, :"#{name}=") { |v| self.data = Hash.new unless data; self.data[name.to_s] = v }
    end
  end

  # Returns a list of attributes managed by attr_data.
  def self.data_attrs
    @data_attrs ||= Array.new
  end

  attr_data :html, :css, :javascript
  attr_data :html_format, :css_format, :javascript_format

  # Returns a hash of the contents.
  def to_hash
    attrs = self.class.data_attrs
    attrs << 'id'
    attrs << 'slug'

    attrs.inject(Hash.new) { |hash, name|
      hash[name] = self.send name; hash
    }
  end

  # Assign a slug.
  def before_create
    self.slug = random_slug
  end

  def self.[](id)
    find(slug: id) || super(id)
  end

private
  def random_slug
    8.times.map { pool[rand pool.size] }.join ''
  end

  def pool
    @pool ||= begin
      letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      numbers = "0123456789"
      (letters + letters.downcase + numbers).split ''
    end
  end
end
