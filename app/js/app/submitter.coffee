App = window.App ?= {}

# App.Submitter [class]
# Creates a ghost <form> with given options.
#
#     new App.Submitter action: 'x', a: 2, b: 3
#
# Options for constructor:
#
#  * `method`: Either *POST* or *GET*.
#  * `action`: The URL.
#  * `target`: Target.
#  * `onSubmit`: Event to be called on submit.
#
# Everything else will be passed on as POST data.
#
class App.Submitter
  constructor: (options) ->
    $form = $("<form>")
    $form.attr 'method', options.method || 'POST'
    $form.attr 'action', options.action || '/'
    $form.attr 'target', options.target || '_blank'

    onSubmit = options.onSubmit

    delete options.method
    delete options.action
    delete options.target
    delete options.onSubmit

    # Add them in as hidden input fields
    for key of options
      $input = $("<input>")
      $input.attr 'type', 'hidden'
      $input.attr 'name', key
      $input.attr 'value', options[key]
      $form.append $input

    # Make sure the form is invisible.
    $form.css
      display:  'block'
      position: 'absolute'
      top:       0
      left:      '-9999px'

    #  Bind a handler.
    $form.bind 'submit', =>
      onSubmit() if onSubmit?
      $form.remove()

    # Submit the form.
    $("body").append $form
    $form.submit()

