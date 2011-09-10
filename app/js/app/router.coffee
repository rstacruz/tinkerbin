App = window.App ?= {}
class App.Router extends Backbone.Router
  routes:
    ":id": "id"

  id: (slug) ->
    App.load slug

