App = window.App ?= {}

# Loads a given document
App.load = (doc_id) ->
  doc = App.Document.fetch doc_id,
    success: (doc) ->
      App.chrome.html.format doc.get 'html_format'
      App.chrome.css.format doc.get 'css_format'
      App.chrome.javascript.format doc.get 'javascript_format'

      App.chrome.html.val doc.get 'html'
      App.chrome.css.val doc.get 'css'
      App.chrome.javascript.val doc.get 'javascript'

    error: App.chrome.onError

App.save = (callback) ->
  # Save via Backbone model.
  doc = new App.Document

  doc.set
    html:               App.chrome.html.val()
    css:                App.chrome.css.val()
    javascript:         App.chrome.javascript.val()
    html_format:        App.chrome.html.format()
    css_format:         App.chrome.css.format()
    javascript_format:  App.chrome.javascript.format()

  doc.save {},
    success: (doc) ->
      doc.cache()
      l = window.location
      url = "#{l.protocol}//#{l.host}/#{doc.get 'slug'}"
      callback doc, url  if callback?

    error: ->
      callback()  if callback?
      App.chrome.onError()
