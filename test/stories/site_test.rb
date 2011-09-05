require File.expand_path("../../story_helper", __FILE__)

class SiteTest < StoryTest
  test "hello world" do
    visit '/'
    assert current_path == '/'
  end

  javascript do
    test "A JavaScript test" do
      visit "/"
    end
  end
end
