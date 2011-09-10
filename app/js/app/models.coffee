App   = window.App ?= {}

class App.Document extends Backbone.Model
  url: -> if @id? then "/document/#{@id}" else "/document"

class App.Documents extends Backbone.Collection
  model: App.Document
  url: -> "/documents"
