# ## Backbone model caching
# Backbone caching is implemented by `cache.coffee`.
#
# #### Sample implementation
# In your model (let's say, `Article`), you will probably will
# create a new record this way:
#
#     a = new Article;
#     a.set({ title: "Hello" });
#     a.save({}, {
#       success: function() {
#         this.cache();
#       }
#     });
#
#     console.log(a.id);   //=> 2     [from the server]
#     console.log(a.cid);  //=> "c4"  [from the client]
#
# Elsewhere in your code, you can use `Model.fetch()` to retrieve the
# same instance. Notice how the client id (`.cid`) is the same as what
# we had before.
#
#     a = Article.fetch(2);
#
#     console.log(a.id);   //=> 2     [from the server]
#     console.log(a.cid);  //=> "c4"  [from the client]
#

class Cache
  constructor: ->
    @clear()

  set: (id, block) ->
    @table[@_idString id] = @_use block

  unset: (id) ->
    delete @table[@_idString id]

  get: (id, block) ->
    @table[@_idString id] ||= (if block then @_use(block) else null)

  clear: ->
    @table = {}

  # Uses a given object.
  _use: (obj) ->
    if typeof obj is "function" then obj() else obj

  # Gets a string from any object to be used as a cache key.
  _idString: (obj) ->
    if typeof obj is "string"
      obj
    else if typeof obj is "function"
      if obj.name isnt "" then obj.name else obj.toString()
    else if obj.constructor is Array
      _.map(obj, (item) => @_idString item).join(":")
    else
      _.map(obj, (k, v) => "#{@_idString k}:#{@_idString v}").join(":")

cache = new Cache

# ### Model.cache [attribute]
# Returns the cache object.
Backbone.Model.cache = cache

# ### Model.fetch(id, args...) [class method]
# Fetches a model ID from either the cache or the server. The `id` parameter
# will be the ID of the record you want to fetch, and `args` will be passed
# onto Backbone's `Model#fetch` (often the `success` and `error` callbacks).
#
#     # Examples:
#     Document.fetch(2);
#     Document.fetch(2, { success: function() { ... } });
#
Backbone.Model.fetch = (id, args...) ->
  cache.get [this, id], =>
    item = new this
    item.id = id
    item.fetch.apply item, args
    item

# ### Model#cache() [method]
# Caches the model instance so `Model.fetch` will retrieve it.
# Add this to your save success callback.
Backbone.Model::cache = ->
  cache.set [this, @id], this

# ### Model#uncache() [method]
# Ensures that the item will not be accessible anymore.
# Add this to your delete success callback.
Backbone.Model::uncache = ->
  cache.unset [this, @id]

