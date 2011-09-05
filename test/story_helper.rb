require 'fileutils'

require_relative 'test_helper'

class StoryTest < UnitTest
  Dir[File.expand_path('../support-story/*.rb', __FILE__)].each { |f| load f }

  setup do
    Capybara.app = app
  end

  def app
    Main
  end
end
