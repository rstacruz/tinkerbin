# App [object]
# The application namespace.
App   = window.App ?= {}

# chrome [ChromeView]
# Instance of `ChromeView`.
App.chrome = new App.ChromeView
App.chrome.render()

# router [Router]
# The router.
App.router = new App.Router
Backbone.history.start pushState: true
