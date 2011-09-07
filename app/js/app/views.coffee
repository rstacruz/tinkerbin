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
    'command shift enter': @viewSource.bind this
    'cmd 1': @onTabAll.bind this
    'cmd 2': @onTabHtml.bind this
    'cmd 3': @onTabCss.bind this
    'cmd 4': @onTabJavascript.bind this
    'alt 1': @onTabAll.bind this
    'alt 2': @onTabHtml.bind this
    'alt 3': @onTabCss.bind this
    'alt 4': @onTabJavascript.bind this

  events:
    'click [href=#html]':       'onTabHtml'
    'click [href=#css]':        'onTabCss'
    'click [href=#javascript]': 'onTabJavascript'
    'click [href=#all]':        'onTabAll'

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

    @html.focus()

    this

  # run() [method]
  # Runs the snippet.
  # Called when you click the *Run* button.
  run: (action='/preview') ->
    @$spinner.show().css opacity: 0.7
    @$iframe.animate opacity: 0.3, 'fast'

    new App.Submitter
      action:             action
      target:             'preview'
      onSubmit:           @onUpdate.bind(this)
      html:               @html.val()
      css:                @css.val()
      javascript:         @javascript.val()
      html_format:        @html.format()
      css_format:         @css.format()
      javascript_format:  @javascript.format()

  viewSource: ->
    @run '/view_source'

  # Triggered when the preview is okay.
  onUpdate: ->
    @$spinner.fadeOut 50
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

# App.CodeView [view class]
# The code editor.
class App.CodeView extends Backbone.View
  tagName: 'article'
  className: 'code'

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
      mode: 'xml'
      theme: 'default'
      gutter: true

    @refresh()
    this

  # Fix for the weird gutter disappearing act.
  refresh: ->
    setTimeout (=> @editor.setValue('')), 0

# App.ToolbarView [view class]
# The toolbar on the side. The main instance can be accessed
# via `App.chrome.toolbar`.
class App.ToolbarView extends Backbone.View
  events:
    'click button.run':  'run'
    'click button.view': 'viewSource'
    
  render: ->
    $(@el).html JST['editor/toolbar']()
    this

  run: ->
    App.chrome.run()

  viewSource: ->
    App.chrome.viewSource()
