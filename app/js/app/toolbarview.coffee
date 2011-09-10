App = window.App ?= {}

# App.ToolbarView [view class]
# The toolbar on the side. The main instance can be accessed
# via `App.chrome.toolbar`.
class App.ToolbarView extends Backbone.View
  events:
    'click button.run':  'run'
    'click button.view': 'viewSource'
    'click button.save': 'save'
    
  $alert: null

  render: ->
    $(@el).html JST['editor/toolbar']()
    @$alert = @$ ".alert"
    this

  run: ->
    App.chrome.run()

  viewSource: ->
    App.chrome.viewSource()

  hideShare: ->
    @$alert.slideUp()  unless @$alert.is(':hidden')

  save: ->
    App.chrome.loaderStart()
    App.save (doc, url) =>
      App.chrome.loaderEnd()
      if doc
        App.router.navigate "/#{doc.get 'slug'}"
        @$alert.slideDown()
        @$alert.find('input').val url
