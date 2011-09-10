App = window.App ?= {}
class App.Router extends Backbone.Router
  routes:
    "": "home"
    ":id": "id"

  home: ->
    # pass

  id: (slug) ->
    App.load slug  if slug?

