module Sinatra
  # JST Support.
  #
  # == Usage
  #
  #     class App < Sinatra::Base
  #       register 'sinatra/jstsupport'
  #       serve_jst '/jst.js'
  #     end
  #
  # This serves all JST files found in `/views/**/*.jst.*` as `/jst.js`.
  #
  # The extension of the file determines the layout engine to be used. For example,
  # if you have `foo.jst.tpl`, it uses Underscore.js's `_.template` to work on it.
  #
  # In the browser, you can use `JST['foo']` (which will be a function) to access it.
  #
  # You can add more engines by subclassing {Engine} to define how files should be
  # precompiled (in the server) and compiled (in the browser). Then, use
  # `register 'extension', EngineClass`.
  #
  # == Basic example
  #
  # Say you have this view:
  #
  #     # views/jst/editor/edit.jst.jade
  #     h1= "Edit "+name
  #       form
  #         button Save
  #
  # And your app has:
  #
  #     class App < Sinatra::Base
  #       register 'sinatra/jstsupport'
  #       serve_jst '/jst.js'
  #     end
  #
  # Now in your layout:
  # 
  #     <script type='text/javascript' src='/jst.js'></script>
  #     <!-- If you're using sinatra-assetpack, just add `/jst.js` to a package. -->
  #
  # Now in your browser you may invoke `JST['templatename']`:
  #
  #     JST['editor/edit']({name: 'Item Name'});
  #
  module JstSupport
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

    class Engine
      attr_reader :file
      def initialize(file); @file = file; end
      def contents()        File.read(@file); end

      # The pre-processing that happens before sending it to the compiled
      # JST file. Override me if needed.
      def precompile()      contents.inspect; end

      # The JavaScript function to invoke on the precompile'd object.
      def function()        "_.template"; end
    end

    register 'tpl', Engine

    module Helpers
      # Returns a list of JST files.
      def jst_files
        # Tuples of [ name, Engine instance ]
        tuples = Dir.chdir(Main.views) {
          Dir["**/*.jst.*"].map { |fn|
            fn       =~ %r{^(.*)\.jst\.([^\.]+)$}
            name, ext = $1, $2
            engine    = JstSupport.mappings[ext]

            [ name, engine.new(File.join(Main.views, fn)) ]  if engine
          }.compact
        }

        Hash[*tuples.flatten]
      end
    end

    module ClassMethods
      def serve_jst(path, options={})
        get path do
          content_type :js
          jsts = jst_files.map { |(name, engine)|
            contents = engine.precompile
            fn       = engine.function

            %{
              JST[#{name.inspect}] = function() {
                if (!c[#{name.inspect}]) c[#{name.inspect}] = #{fn}(#{contents});
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


module Sinatra
  module JstSupport
    # Requires haml.js.
    # https://github.com/creationix/haml-js I think.
    class HamlEngine < Engine
      def function()  "Haml.compile"; end
    end

    # Requires jade.js.
    # https://github.com/visionmedia/jade
    class JadeEngine < Engine
      def function()  "require('jade').compile"; end
      def precompile; contents.inspect; end
    end

    register 'jade', JadeEngine
    register 'haml', HamlEngine
  end
end
