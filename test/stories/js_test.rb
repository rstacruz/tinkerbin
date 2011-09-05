require File.expand_path("../../story_helper", __FILE__)

class JsTest < StoryTest
  include Rack::Test::Methods

  def assert_js(path)
    get path
    assert last_response.headers["Content-Type"] =~ %r{(text|application)/javascript}
    assert last_response.body.include?('function'), "Did not find a JS function in #{path}"
  end

  test "Check JS" do
    assert_js '/js/app/sample.js'
  end
end
