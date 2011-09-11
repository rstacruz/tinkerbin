# ## Sinatra::JstPages [module]
# A Sinatra plugin that adds support for JST (JavaScript Server Templates).
#
# #### Layout engines
# The extension of the file determines the layout engine to be used. For example,
# if you have `foo.jst.tpl`, it uses Underscore.js's `_.template` to work on it.
#
# #### Accessing in the browser
# First, you will need to link to the JST route in your page. Make a `<script>`
# tag where the `src='...'` attribute is the same path you provide to
# `serve_jst`.
#
# In the browser, you can use `JST['foo']` (which will be a function) to access it.
#
#     require 'sinatra/jstpages'
#     class App < Sinatra::Base
#       register Sinatra::JstPages
#       serve_jst '/jst.js'
#     end
#
# #### Supported templates
# Currently supports the following templates:
#
# * [Jade][jade] (`.jst.jade`) -- Jade templates. This requires
# [jade.js][jade]. For older browsers, you will also need [json2.js][json2],
# and an implementation of [String.prototype.trim][trim].
#
# * [Underscore templates][under_tpl] (`.jst.tpl`) -- Simple templates by
# underscore. This requires [underscore.js][under], which Backbone also
# requires.
#
# * [Haml.js][haml] (`.jst.haml`) -- A JavaScript implementation of Haml.
# Requires [haml.js][haml].
#
# * [Eco][eco] (`.jst.eco`) -- Embedded CoffeeScript templates. Requires
# [eco.js][eco] and [coffee-script.js][cs].
#
# [jade]: http://github.com/visionmedia/jade
# [json2]: https://github.com/douglascrockford/JSON-js
# [trim]: http://snippets.dzone.com/posts/show/701
# [under_tpl]: http://documentcloud.github.com/underscore/#template
# [under]: http://documentcloud.github.com/underscore
# [haml]: https://github.com/creationix/haml-js
# [eco]: https://github.com/sstephenson/eco
# [cs]: http://coffeescript.org
#
# ### Basic example
# Say you have a JST view written in Jade, placed in `views/editor/edit.jst.jade`:
#
#     # views/editor/edit.jst.jade
#     h1= "Edit "+name
#       form
#         button Save
#
# This serves all JST files found in `/views/**/*.jst.*` (where `/views` is
# your views directory as defined in Sinatra's `settings.views`) as
# `http://localhost:4567/jst.js`.
#
#     class App < Sinatra::Base
#       register Sinatra::JstPages
#       serve_jst '/jst.js'
#     end
#
# Now in your layout, you will need to include it like so:  
# *(TIP: If you're using the sinatra-assetpack gem, just add `/jst.js` to a package.)*
# 
#     <script type='text/javascript' src='/jst.js'></script>
#
# Now in your browser you may invoke `JST['templatename']`:
#
#     // Renders the editor/edit template
#     JST['editor/edit']();
#
#     // Renders the editor/edit template with template parameters
#     JST['editor/edit']({name: 'Item Name'});
#
module Sinatra
  module JstPages
    def self.registered(app)
      app.extend ClassMethods
      app.helpers Helpers
    end

    # Returns a hash to determine which engine is mapped onto a given extension.
    def self.mappings
      @mappings ||= Hash.new
    end

    def self.register(ext, engine)
      mappings[ext] = engine
    end

    module Helpers
      # Returns a list of JST files.
      def jst_files
        # Tuples of [ name, Engine instance ]
        tuples = Dir.chdir(Main.views) {
          Dir["**/*.jst.*"].map { |fn|
            fn       =~ %r{^(.*)\.jst\.([^\.]+)$}
            name, ext = $1, $2
            engine    = JstPages.mappings[ext]

            [ name, engine.new(File.join(Main.views, fn)) ]  if engine
          }.compact
        }

        Hash[*tuples.flatten]
      end
    end

    module ClassMethods
      # ### serve_jst(path, [options]) [class method]
      # Serves JST files in given `path`.
      #
      def serve_jst(path, options={})
        get path do
          content_type :js
          jsts = jst_files.map { |(name, engine)|
            %{
              JST[#{name.inspect}] = function() {
                if (!c[#{name.inspect}]) c[#{name.inspect}] = (#{engine.function});
                return c[#{name.inspect}].apply(this, arguments);
              };
          }.strip.gsub(/^ {12}/, '')
          }

          %{
            (function(){
              var c = {};
              if (!window.JST) window.JST = {};
              #{jsts.join("\n  ")}
            })();
          }.strip.gsub(/^ {12}/, '')
        end
      end
    end
  end
end


# ## Sinatra::JstPages::Engine [class]
# A template engine.
#
# #### Adding support for new template engines
# You will need to subclass `Engine`, override at least the `function` method,
# then use `JstPages.register`.
#
# This example will register `.jst.my` files to a new engine that uses
# `My.compile`.
#
#     module Sinatra::JstPages
#       class MyEngine < Engine
#         def function() "My.compile(%s)"; end
#       end
#
#       register 'my', MyEngine
#     end
#
module Sinatra::JstPages
  class Engine
    # ### file [attribute]
    # The string path of the template file.
    attr_reader :file
    def initialize(file)
      @file = file
    end

    # ### contents [method]
    # Returns the contents of the template file as a string.
    def contents
      File.read(@file)
    end

    # ### function [method]
    # The JavaScript function to invoke on the precompile'd object.
    #
    # What this returns should, in JavaScript, return a function that can be
    # called with an object hash of the params to be passed onto the template.
    def function
      "_.template(#{contents.inspect})"
    end
  end

  class HamlEngine < Engine
    def function() "Haml.compile(#{contents.inspect})"; end
  end

  class JadeEngine < Engine
    def function() "require('jade').compile(#{contents.inspect})"; end
  end

  class EcoEngine < Engine
    def function
      "function() { var a = arguments.slice(); a.unshift(#{contents.inspect}); return eco.compile.apply(eco, a); }"
    end
  end

  register 'tpl', Engine
  register 'jade', JadeEngine
  register 'haml', HamlEngine
  register 'eco', EcoEngine
end
