App = window.App ?= {}

# Loads a given document
App.load = (doc_id) ->
  doc = new App.Document
  doc.id = doc_id
  doc.fetch
    success: (doc) ->
      App.chrome.html.format doc.get 'html_format'
      App.chrome.css.format doc.get 'css_format'
      App.chrome.javascript.format doc.get 'javascript_format'

      App.chrome.html.val doc.get 'html'
      App.chrome.css.val doc.get 'css'
      App.chrome.javascript.val doc.get 'javascript'

    error: App.chrome.onError
