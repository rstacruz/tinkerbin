App   = window.App ?= {}

class App.Document extends Backbone.Model
  urlRoot: "/document"

class App.Documents extends Backbone.Collection
  model: App.Document
  url: -> "/documents"
