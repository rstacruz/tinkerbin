class Main
  GOOGLE_CDN = "//ajax.googleapis.com/ajax/libs/%s"
  CDNJS_CDN  = "//cdnjs.cloudflare.com/ajax/libs/%s"

  set :js_packages, {
    jquery: {
      remote:   GOOGLE_CDN % ["jquery/1.6.2/jquery.min.js"],
      fallback: '/js/vendor/jquery.js',
      test:     'window.jQuery'
    },
    underscore: {
      remote:     CDNJS_CDN % ['underscore.js/1.1.7/underscore-min.js'],
      fallback:   '/js/vendor/underscore.js',
      test:       'window._'
    },
    modernizr: {
      remote:     CDNJS_CDN % ['modernizr/2.0.6/modernizr.min.js'],
      fallback:   '/js/vendor/modernizr.js'
    },
    backbone: {
      remote:     CDNJS_CDN % ['backbone.js/0.5.3/backbone-min.js'],
      fallback:   '/js/vendor/backbone.js',
      test:       'window.Backbone'
    }
  }
end
