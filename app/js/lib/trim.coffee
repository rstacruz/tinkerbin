# Define String::trim if it's missing. Needed by Jade for iOS.
unless String::trim?
  String::trim = -> @replace /^\s+|\s+$/g, ''
