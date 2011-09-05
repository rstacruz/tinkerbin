desc "Run all tests [Testing]"
task(:test) {
  Dir['./test/**/*_test.rb'].each { |f| load f }
}

namespace(:test) do
  desc "Run tests with JS with given driver"
  [ :chrome, :selenium, :celerity, :culerity, :webkit ].each do |driver|
    desc "Run all tests with JS tests in #{driver.to_s.capitalize} [Testing]"
    task(driver) {
      ENV['CAPYBARA_JS_DRIVER'] = driver.to_s
      Dir['./test/**/*_test.rb'].each { |f| load f }
    }
  end
end

