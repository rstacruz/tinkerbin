require 'sinatra/jstsupport'

class Main
  register Sinatra::JstSupport
  serve_jst '/js/jst.js'

  register Sinatra::AssetPack
  assets do
    js :application, '/app.js', %w[
      /js/vendor/codemirror.js
      /js/vendor/codemirror_modes/*/*.js
      /js/vendor/jade.js
      /js/jst.js
      /js/lib/*.js
      /js/app/**/*.js
      /js/app/*.js
      /js/setup.js
    ]

    css :main, '/main.css', %w[
      /css/style.css
    ]

    css :error, '/error.css', %w[
      /css/error.css
    ]

    css :print, '/print.css', %w[
      /css/print.css
    ]
  end
end
