class Previewer
  attr_reader :error
  attr_reader :error_area

  def initialize(params, app)
    @app = app

    @html       = params[:html]
    @css        = params[:css]
    @javascript = params[:javascript]

    @htmlFormat       = params[:html_format]
    @cssFormat        = params[:css_format]
    @javascriptFormat = params[:javascript_format]

    @error      = nil
    @error_area = nil
  end

  def javascript
    "<script type='text/javascript'>\n%s\n</script>" % [ built_javascript ]
  end

  def css
    "<style type='text/css'>\n%s\n</style>" % [ built_css ]
  end

  def error_area_proper
    case error_area
    when :javascript then "JavaScript"
    when :css then "CSS"
    when :html then "HTML"
    else nil
    end
  end

  def error_line
    return nil  unless error?

    return error.line  if @error.respond_to?(:line)
  end

  def html
    @output_html ||= begin
      # If the user submitted a valid HTML document, use it as is.
      if built_html =~ /^<!DOCTYPE/ || built_html =~ /<html>/
        [built_html, javascript, css].compact.join("\n")

      # Else, use our HTML5 layout.
      else
        @app.haml :_boilerplate, { layout: false, ugly: false },
          head: [javascript, css].compact.join("\n"),
          body: built_html
      end
    end
  end

  def error?
    return @error  unless @error.nil?

    # These will populate @error and @error_area if it finds something.
    catch_error(:javascript) { built_javascript }
    catch_error(:css)        { built_css }
    catch_error(:html)       { built_html }

    !! @error
  end
  
  def catch_error(area, &blk)
    begin
      yield
    rescue => e
      @error      = e
      @error_area = area
    end
  end

  def built_javascript
    @built_javascript ||=
      case @javascriptFormat
      when 'coffee' then @app.coffee @javascript
      else @javascript
      end
  end

  def built_css
    @built_css ||=
      case @cssFormat
      when 'scss' then @app.scss "@import 'compass/css3';\n#{@css}", sass_options
      when 'sass' then @app.sass "@import 'compass/css3'\n#{@css}", sass_options
      when 'less' then @app.less @css
      else @css
      end
  end

  def built_html
    @built_html ||=
      case @htmlFormat
      when 'haml' then @app.haml @html, { layout: false, suppress_eval: true, ugly: false }
      else @html
      end
  end

  def sass_options
    { line_numbers: false, debug_info: false, style: :nested }
  end
end

