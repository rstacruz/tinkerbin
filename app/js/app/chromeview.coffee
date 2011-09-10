App = window.App ?= {}

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

  # getKeyEvents [method]
  # Returns a hash of key events.
  getKeyEvents: ->
    'command enter': @run
    'alt enter':     @viewSource

    'cmd 1': @onTabAll
    'cmd 2': @onTabHtml
    'cmd 3': @onTabCss
    'cmd 4': @onTabJavascript

    'alt 1': @onTabAll
    'alt 2': @onTabHtml
    'alt 3': @onTabCss
    'alt 4': @onTabJavascript

    'alt h': @focusHtml
    'alt c': @focusCss
    'alt j': @focusJavascript

  events:
    'mousedown [href=#html]':       'onTabHtml'
    'mousedown [href=#css]':        'onTabCss'
    'mousedown [href=#javascript]': 'onTabJavascript'
    'mousedown [href=#all]':        'onTabAll'
    'click a':                      'onTabClick'

  render: ->
    _.bindAll this,
      'run', 'viewSource', 'onTabAll', 'onTabHtml', 'onTabCss', 'onTabJavascript',
      'focusHtml', 'focusCss', 'focusJavascript'

    $('body').removeClass 'loading'
    $(@el).html JST['editor/chrome']()

    @$iframe = @$("iframe")
    @$spinner = @$(".spinner")

    # Listen for window resizing.
    $(window).resize => @onResize()
    @onResize()

    # Listen for keys.
    @listener = new App.KeyListener
    events = @getKeyEvents()
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
    @loaderStart()

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
    @loaderEnd()

  loaderStart: ->
    @$iframe.css(opacity: 0.5).animate opacity: 0.1, 200

  loaderEnd: ->
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
