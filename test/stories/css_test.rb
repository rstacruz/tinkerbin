require File.expand_path("../../story_helper", __FILE__)

class CssTest < StoryTest
  include Rack::Test::Methods

  test "Check CSS" do
    assert_css '/css/style.css'
  end

  def assert_css(path)
    get path
    assert last_response.headers["Content-Type"].include? "text/css"
    assert last_response.body =~ /\{\s*[a-z\-]+:\s*[^;]+;/m, "Did not find a CSS rule in #{path}"
  end
end
