class Document < Sequel::Model
  plugin :serialization, :yaml, :data

  def html
    data['html']
  end

  def self.attr_data(*names)
    @attrs ||= Array.new

    names.each do |name|
      @attrs << name
      send(:define_method, :"#{name}") { self.data && self.data[name.to_s] }
      send(:define_method, :"#{name}=") { |v| self.data = Hash.new unless data; self.data[name.to_s] = v }
    end
  end

  def self.attrs
    @attrs
  end

  attr_data :html, :css, :javascript
  attr_data :html_format, :css_format, :javascript_format

  def to_hash
    attrs = self.class.attrs
    attrs << 'id'

    attrs.inject(Hash.new) { |hash, name|
      hash[name] = self.send name; hash
    }
  end
end
