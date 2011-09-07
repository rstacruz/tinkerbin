class Main
  module JsCdnHelpers
    def js_cdn(name)
      opts = settings.js_packages[name.to_sym]
      return "<!-- Unknown JS package: #{name} -->"  unless opts

      file = Main.root('app', opts[:fallback])
      if settings.development? && File.exists?(file)
        "<script type='text/javascript' src='#{opts[:fallback]}'></script>"
      else
        str =  "<script type='text/javascript' src=\"#{opts[:remote]}\"></script>"
        str += "<script>!#{opts[:test]} && document.write('<script src=\"#{opts[:fallback]}\"><\\/script>')</script>"  if opts[:test] && File.exists?(file)
        str
      end
    end

    def js_chromeframe
      "<!--[if lte IE 7 ]>" +
      "<script defer src='//ajax.googleapis.com/ajax/libs/chrome-frame/1.0.3/CFInstall.min.js'></script>" +
      "<script defer>window.attachEvent('onload',function(){CFInstall.check({mode:'overlay'})})</script>" +
      "<![endif]-->"  if browser.ie?
    end
  end

  helpers JsCdnHelpers
end
