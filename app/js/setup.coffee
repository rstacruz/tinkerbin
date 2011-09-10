Backbone.emulateHTTP = true
Backbone.emulateJSON = true

# App [object]
# The application namespace.
App   = window.App ?= {}

# chrome [ChromeView]
# Instance of `ChromeView`.
App.chrome = new App.ChromeView
App.chrome.render()
