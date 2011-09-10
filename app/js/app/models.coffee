App   = window.App ?= {}

class App.Document extends Backbone.Model
  url: -> if @id? then "/document/#{@id}" else "/document"
  parse: (str) ->
    console.log str
    str

class App.Documents extends Backbone.Collection
  model: App.Document
  url: -> "/documents"
