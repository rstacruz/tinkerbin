class StoryTest
  include Capybara::DSL

  Capybara.register_driver :chrome do |app|
    Capybara::Driver::Selenium.new(app, :browser => :chrome)
  end

  def self.javascript_driver
    ENV['CAPYBARA_JS_DRIVER']
  end

  def self.javascript(name='', &blk)
    driver = javascript_driver

    describe("JavaScript tests #{name}") {
      setup { Capybara.current_driver = driver.to_sym }
      teardown { Capybara.use_default_driver }
      yield
    }  if driver
  end
end
