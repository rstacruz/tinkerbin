App = window.App ?= {}

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
    _.bindAll this, 'onChange', 'onFocus', 'onBlur'

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
      onChange: @onChange
      onFocus:  @onFocus
      onBlur:   @onBlur

    @refresh()
    this

  # Fix for the weird gutter disappearing act.
  refresh: ->
    value = @editor.getValue()
    setTimeout (=> @editor.setValue(value)), 0

  onChange: ->
    App.chrome.autoUpdate()
    App.chrome.updateIndicator()
    App.chrome.toolbar.hideShare()

  onFormatChange: (e, f) ->
    #if @val() != ''
    #  result = confirm "Do you want to change formats?\nThis will erase your current buffer."

    App.chrome.updateIndicator()

  onFocus: ->
    $(@el).addClass 'focus'

  onBlur: ->
    $(@el).removeClass 'focus'
