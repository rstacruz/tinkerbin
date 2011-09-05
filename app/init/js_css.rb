class Main
  register Sinatra::AssetPack
  assets do
    js :application, '/app.js', %w[
      /js/vendor/*.js
      /js/lib/*.js
      /js/app/*.js
    ]

    css :main, '/main.css', %w[
      /css/style.css
    ]

    css :print, '/print.css', %w[
      /css/print.css
    ]
  end
end
