class Main
  get '/' do
    haml :home
  end

  helpers do
    # Gets the lines around a given string and line number.
    def get_context(string, line, spread)
      lines = string.split("\n")
      alpha = [line-spread, 0].max
      omega = [line+spread, lines.size-1].min

      lines = (alpha..omega).map { |i|
        [ i+1, lines[i] ]
      }
    end

    def handle_error(preview)
      return  unless preview.error?

      @error   = preview.error
      @area    = preview.error_area_proper
      @source  = params[preview.error_area]
      @line    = preview.error_line
      @context = get_context(@source, @line, 3)  if @line

      haml :error, layout: false
    end

    def view_source(preview)
      @html_source       = get_context(preview.built_html, 0, 5000)
      @css_source        = get_context(preview.built_css, 0, 5000)
      @javascript_source = get_context(preview.built_javascript, 0, 5000)
      haml :view_source, layout: false
    end
  end

  post '/preview' do
    preview = Previewer.new(params, self)
    handle_error(preview) || preview.html
  end

  post '/view_source' do
    preview = Previewer.new(params, self)
    handle_error(preview) || view_source(preview)
  end

  require 'sinatra/restapi'
  register Sinatra::RestAPI
  rest :Document
end

