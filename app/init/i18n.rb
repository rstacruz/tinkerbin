require 'sinatra/support/i18nsupport'

class Main
  register Sinatra::I18nSupport
  load_locales root('config/locales')
end

# Rename this to i18n.rb, then start making config/locales/en.yml.
# Edit the gemfile to add the I18n gem in as well.
