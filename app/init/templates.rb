Encoding.default_external = 'utf-8'

class Main
  set :scss, load_paths: [ root('app/css') ]
  set :scss, scss.merge(line_numbers: true, always_check: true) if development?
  set :scss, scss.merge(style: :compressed) if production?
  set :sass, scss
  set :haml, escape_html: true, layout: :layout, ugly: true

  register Sinatra::CompassSupport
end

