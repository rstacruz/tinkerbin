App   = window.App ?= {}

# App.ChromeView [view class]
# The entire body thing. The main instance can be accessed
# via `App.chrome`.
class App.ChromeView extends Backbone.View
  el: 'body'

  # toolbar [attribute]
  # An instance of `ToolbarView`.
  toolbar: null

  # typenames [constant]
  # The supported code editor typenames.
  typenames: ['html', 'css', 'javascript']

  # Instances of CodeView.
  html: null
  css: null
  javascript: null

  # $iframe [attribute]
  # The preview iframe.
  $iframe: null

  # $spinner [attribute]
  # The loading spinner.
  $spinner: null

  # listener [attribute]
  # The `KeyListener` instance.
  listener: null

  # keyEvents [method]
  # Returns a hash of key events.
  keyEvents: ->
    'command enter': @run.bind this
    'alt enter':     @viewSource.bind this

    'cmd 1': @onTabAll.bind this
    'cmd 2': @onTabHtml.bind this
    'cmd 3': @onTabCss.bind this
    'cmd 4': @onTabJavascript.bind this

    'alt 1': @onTabAll.bind this
    'alt 2': @onTabHtml.bind this
    'alt 3': @onTabCss.bind this
    'alt 4': @onTabJavascript.bind this

    'alt h': @focusHtml.bind this
    'alt c': @focusCss.bind this
    'alt j': @focusJavascript.bind this

  events:
    'mousedown [href=#html]':       'onTabHtml'
    'mousedown [href=#css]':        'onTabCss'
    'mousedown [href=#javascript]': 'onTabJavascript'
    'mousedown [href=#all]':        'onTabAll'
    'click a':                      'onTabClick'

  render: ->
    $(@el).html JST['editor/chrome']()

    @$iframe = @$("iframe")
    @$spinner = @$(".spinner")

    # Listen for window resizing.
    $(window).resize => @onResize()
    @onResize()

    # Listen for keys.
    @listener = new App.KeyListener
    events = @keyEvents()
    for i of events
      @listener.on i, events[i]

    # Initialize the toolbar.
    @toolbar = (new App.ToolbarView el: @$("#toolbar")).render()

    # Initialize each of the code editors.
    _.each @typenames, (type) =>
      @[type] = (new App.CodeView type: type).render()
      $("#editorPane .area").append @[type].el

    @updateIndicator()

    @html.focus()

    this

  buildSource: ->
    """
    <!DOCTYPE html>
    <html>
    <head>
    <style type='text/css'>#{@css.val()}</style>
    </head>
    <body>
    #{@html.val()}
    <script type='text/javascript'>#{@javascript.val()}</script>
    """

  # isLocalable() [method]
  # Checks if the thing can be rendered in the browser.
  isLocalable: ->
    @html.isLocalable() and @css.isLocalable() and @javascript.isLocalable()

  updateIndicator: ->
    if @isAutoUpdateable()
      @$("#outputPane strong").html "Output <span class='auto'>&mdash; Auto-updating</span>"
    else
      @$("#outputPane strong").html "Output"

  # updatePreview [method]
  # Updates the preview `<iframe>` with the given HTML snippet.
  updatePreview: (html) ->
    doc = @$iframe[0].contentDocument
    doc.open()
    doc.write html
    doc.close()

  # run() [method]
  # Runs the snippet.
  # Called when you click the *Run* button.
  run: ->
    if @isLocalable()
      @updatePreview @buildSource()
    else
      @submit '/preview'

  # autoUpdate() [method]
  # Updates the preview if possible.
  autoUpdate: ->
    @run()  if @isAutoUpdateable()
    
  isAutoUpdateable: ->
    @isLocalable() and @javascript.val() == ''

  submit: (action='/preview') ->
    @$spinner.show().css opacity: 0.7
    @$iframe.css(opacity: 0.5).animate opacity: 0.1, 200

    p = $.post action,
      html:               @html.val()
      css:                @css.val()
      javascript:         @javascript.val()
      html_format:        @html.format()
      css_format:         @css.format()
      javascript_format:  @javascript.format()
      , (data) =>
        @updatePreview data
        @onUpdate()

    p.error =>
      @onError()
      @onUpdate()

  viewSource: ->
    @submit '/view_source'

  # Triggered when AJAX errors happen.
  onError: ->
    alert "Oops! Something went wrong."

  # Triggered when the preview is okay.
  onUpdate: ->
    @$spinner.fadeOut 200
    @$iframe.stop().css opacity: 1.0

  onResize: ->
    $iframe = @$("iframe")
    n = $iframe.parent().innerHeight()
    $iframe.css height: "#{n}px"

  tab: 'all'

  onTabHtml:       -> @onTab 'html'
  onTabCss:        -> @onTab 'css'
  onTabJavascript: -> @onTab 'javascript'
  onTabAll:        -> @onTab 'all'

  onTab: (tab) ->
    return if @tab == tab

    @$(".tabs a").removeClass 'active'
    @$(".tabs a[href=##{tab}]").addClass 'active'

    # This is what actually relayouts things.
    @$("#editorPane").attr 'class', "pane #{tab}"

    # Refresh to prevent the weird gutter look.
    @html.refresh()
    @css.refresh()
    @javascript.refresh()

    (@[tab] || @html).focus()

    @tab = tab
    false

  onTabClick: (e) ->
    e.preventDefault()

  # Switches focus
  focusHtml:       -> @focus 'html'
  focusCss:        -> @focus 'css'
  focusJavascript: -> @focus 'javascript'

  # Switches focus to given field.
  # The parameter `type` can be *html*, *css* or *javascript*.
  focus: (type) ->
    @onTab 'all'  unless @tab == 'all'
    @[type].focus()

# App.CodeView [view class]
# The code editor.
class App.CodeView extends Backbone.View
  tagName: 'article'
  className: 'code'

  events:
    'change select': 'onFormatChange'
      
  # options.type [attribute]
  # Either `html`, `js`, or `css`.

  # $editor [attribute]
  # The `<textarea>` instance.
  $editor: null

  # $format: [attribute]
  # The `<select>` format.
  $format: null

  # editor [attribute]
  # The instance of `CodeMirror`.
  editor: null

  types:
    html:
      formats:
        plain: 'Plain'
        haml:  'HAML'
    css:
      formats:
        plain: 'Plain'
        scss: 'Sass CSS'
        sass: 'Sass (old syntax)'
        less: 'Less'
    javascript:
      formats:
        plain: 'Plain'
        coffee: 'CoffeeScript'

  type: ->
    @options.type

  # val() [method]
  # Sets or gets the value.
  val: (value) ->
    if value?
      @editor.setValue value
    else
      @editor.getValue()

  # format() [method]
  # Gets the format.
  format: ->
    @$format.val()

  focus: ->
    @editor.focus()

  # isLocalable() [method]
  # Checks if the thing can be rendered in the browser.
  isLocalable: ->
    @format() == 'plain'

  getMode: ->
    return 'xml'  if @type() == 'html'
    return 'css'  if @type() == 'css'
    return 'javascript'  if @type() == 'javascript'

  render: ->
    # Initialize the container.
    $(@el).addClass @options.type

    # Drop in the code.
    $(@el).html JST['editor/code'](type: @options.type)

    # Set up the 'format' dropdown.
    @$format = @$ "select.format"

    # Populate the formats dropdown.
    formats = @types[@options.type].formats
    for name of formats
      @$format.append $("<option>").
        attr('value', name).
        text(formats[name])

    # Set up the <textarea> inside it to use the code editor.
    @$editor = @$('textarea')
    @$editor.attr 'id', "editor_#{@options.type}"

    @editor = CodeMirror.fromTextArea @$editor[0],
      lineNumbers: true
      matchBrackets: true
      mode: @getMode()
      theme: 'default'
      gutter: true
      onChange: @onChange.bind this
      onFocus: @onFocus.bind this
      onBlur: @onBlur.bind this

    @refresh()
    this

  # Fix for the weird gutter disappearing act.
  refresh: ->
    value = @editor.getValue()
    setTimeout (=> @editor.setValue(value)), 0

  onChange: ->
    App.chrome.autoUpdate()
    App.chrome.updateIndicator()

  onFormatChange: (e, f) ->
    #if @val() != ''
    #  result = confirm "Do you want to change formats?\nThis will erase your current buffer."

    App.chrome.updateIndicator()

  onFocus: ->
    $(@el).addClass 'focus'

  onBlur: ->
    $(@el).removeClass 'focus'

# App.ToolbarView [view class]
# The toolbar on the side. The main instance can be accessed
# via `App.chrome.toolbar`.
class App.ToolbarView extends Backbone.View
  events:
    'click button.run':  'run'
    'click button.view': 'viewSource'
    'click button.save': 'save'
    
  render: ->
    $(@el).html JST['editor/toolbar']()
    this

  run: ->
    App.chrome.run()

  viewSource: ->
    App.chrome.viewSource()

  save: ->
    alert "Work in progress :-)\n--rstacruz"
